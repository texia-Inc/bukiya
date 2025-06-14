from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional, List
import uuid
import random

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.core.shop_progression import ShopProgressionService
from app.models import Player, CraftingRecipe, RecipeMaterial, WeaponMaster, MaterialMaster, PlayerWeapon, PlayerMaterial
from app.schemas import (
    CraftingRecipeListResponse, CraftingRecipeResponse,
    CraftingRecipeDetailListResponse, CraftingRecipeDetailResponse,
    CraftingRequest, CraftingResultResponse, CraftingResult,
    CraftingAvailabilityResponse, CraftingAvailabilityCheck,
    CraftingRecipeCreate, CraftingRecipeUpdate,
    BaseResponse
)

router = APIRouter()

# 管理画面用の認証不要エンドポイント
@router.get("/recipes/admin/list", response_model=CraftingRecipeListResponse)
async def get_crafting_recipes_admin(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    db: Session = Depends(get_db)
):
    """
    管理画面用：合成レシピ一覧を取得（認証不要）
    """
    query = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(CraftingRecipe.is_active == True)
    
    # フィルター適用
    if weapon_type_id:
        query = query.join(WeaponMaster).filter(WeaponMaster.weapon_type_id == weapon_type_id)
    if rarity_id:
        query = query.join(WeaponMaster).filter(WeaponMaster.rarity_id == rarity_id)
    if max_level:
        query = query.filter(CraftingRecipe.required_level <= max_level)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    recipes = query.offset(offset).limit(limit).all()
    
    return CraftingRecipeListResponse(
        success=True,
        data=recipes,
        message="合成レシピ一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.post("/recipes/admin/create", response_model=CraftingRecipeResponse)
async def create_crafting_recipe_admin(
    recipe_data: CraftingRecipeCreate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：合成レシピを作成（認証不要）
    """
    # 武器マスターの存在確認
    weapon = db.query(WeaponMaster).filter(
        WeaponMaster.id == recipe_data.weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # 素材の存在確認
    material_ids = [material.material_id for material in recipe_data.materials]
    materials = db.query(MaterialMaster).filter(
        MaterialMaster.id.in_(material_ids),
        MaterialMaster.is_active == True
    ).all()
    
    if len(materials) != len(material_ids):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="指定された素材の一部が見つかりません"
        )
    
    # レシピ作成
    recipe = CraftingRecipe(
        weapon_id=recipe_data.weapon_id,
        name=recipe_data.name,
        description=recipe_data.description,
        gold_cost=recipe_data.gold_cost,
        success_rate=recipe_data.success_rate,
        required_level=recipe_data.required_level
    )
    
    db.add(recipe)
    db.flush()  # IDを取得するため
    
    # レシピ素材作成
    for material_data in recipe_data.materials:
        recipe_material = RecipeMaterial(
            recipe_id=recipe.id,
            material_id=material_data.material_id,
            quantity=material_data.quantity
        )
        db.add(recipe_material)
    
    db.commit()
    db.refresh(recipe)
    
    # リレーションシップをロード
    recipe = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(CraftingRecipe.id == recipe.id).first()
    
    return CraftingRecipeResponse(
        success=True,
        data=recipe,
        message="合成レシピを作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/recipes/admin/{recipe_id}", response_model=CraftingRecipeResponse)
async def update_crafting_recipe_admin(
    recipe_id: int,
    recipe_data: CraftingRecipeUpdate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：合成レシピを更新（認証不要）
    """
    # レシピの存在確認
    recipe = db.query(CraftingRecipe).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="合成レシピが見つかりません"
        )
    
    # 武器マスターの存在確認（変更される場合）
    if recipe_data.weapon_id:
        weapon = db.query(WeaponMaster).filter(
            WeaponMaster.id == recipe_data.weapon_id,
            WeaponMaster.is_active == True
        ).first()
        
        if not weapon:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="武器が見つかりません"
            )
    
    # 基本情報更新
    for field, value in recipe_data.dict(exclude_unset=True, exclude={'materials'}).items():
        setattr(recipe, field, value)
    
    # 素材更新（指定された場合）
    if recipe_data.materials is not None:
        # 既存の素材を削除
        db.query(RecipeMaterial).filter(
            RecipeMaterial.recipe_id == recipe_id
        ).delete()
        
        # 新しい素材を追加
        material_ids = [material.material_id for material in recipe_data.materials]
        materials = db.query(MaterialMaster).filter(
            MaterialMaster.id.in_(material_ids),
            MaterialMaster.is_active == True
        ).all()
        
        if len(materials) != len(material_ids):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="指定された素材の一部が見つかりません"
            )
        
        for material_data in recipe_data.materials:
            recipe_material = RecipeMaterial(
                recipe_id=recipe_id,
                material_id=material_data.material_id,
                quantity=material_data.quantity
            )
            db.add(recipe_material)
    
    recipe.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(recipe)
    
    # リレーションシップをロード
    recipe = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(CraftingRecipe.id == recipe.id).first()
    
    return CraftingRecipeResponse(
        success=True,
        data=recipe,
        message="合成レシピを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/recipes/admin/{recipe_id}", response_model=BaseResponse[dict])
async def delete_crafting_recipe_admin(
    recipe_id: int,
    db: Session = Depends(get_db)
):
    """
    管理画面用：合成レシピを削除（認証不要）
    """
    # レシピの存在確認
    recipe = db.query(CraftingRecipe).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="合成レシピが見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    recipe.is_active = False
    recipe.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_recipe_id": recipe_id},
        message="合成レシピを削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/recipes", response_model=CraftingRecipeListResponse)
async def get_crafting_recipes(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    合成レシピ一覧を取得
    """
    query = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(CraftingRecipe.is_active == True)
    
    # フィルター適用
    if weapon_type_id:
        query = query.join(WeaponMaster).filter(WeaponMaster.weapon_type_id == weapon_type_id)
    if rarity_id:
        query = query.join(WeaponMaster).filter(WeaponMaster.rarity_id == rarity_id)
    if max_level:
        query = query.filter(CraftingRecipe.required_level <= max_level)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    recipes = query.offset(offset).limit(limit).all()
    
    return CraftingRecipeListResponse(
        success=True,
        data=recipes,
        message="合成レシピ一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.get("/recipes/{recipe_id}", response_model=CraftingRecipeResponse)
async def get_crafting_recipe_detail(
    recipe_id: int,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    合成レシピ詳細を取得
    """
    recipe = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="合成レシピが見つかりません"
        )
    
    return CraftingRecipeResponse(
        success=True,
        data=recipe,
        message="合成レシピ詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/recipes/available", response_model=CraftingRecipeDetailListResponse)
async def get_available_crafting_recipes(
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤーが合成可能なレシピ一覧を取得
    """
    # 全レシピを取得
    recipes = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.weapon_type),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(CraftingRecipe.is_active == True).all()
    
    # プレイヤーの所持素材を取得
    player_materials = {
        pm.material_master_id: pm.quantity 
        for pm in db.query(PlayerMaterial).filter(
            PlayerMaterial.player_id == current_player.id
        ).all()
    }
    
    recipe_details = []
    for recipe in recipes:
        can_craft, missing_requirements = _check_recipe_availability(recipe, current_player, player_materials)
        
        # CraftingRecipeDetailオブジェクトを作成
        recipe_detail = type('CraftingRecipeDetail', (), {})()
        
        # 基本属性をコピー
        for attr in ['id', 'weapon_id', 'name', 'description', 'gold_cost', 'success_rate', 'required_level', 'is_active', 'created_at', 'updated_at']:
            setattr(recipe_detail, attr, getattr(recipe, attr))
        
        # リレーションシップをコピー
        recipe_detail.weapon = recipe.weapon
        recipe_detail.materials = recipe.materials
        
        # 追加属性
        recipe_detail.can_craft = can_craft
        recipe_detail.missing_requirements = missing_requirements
        
        recipe_details.append(recipe_detail)
    
    return CraftingRecipeDetailListResponse(
        success=True,
        data=recipe_details,
        message="合成可能レシピ一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/recipes/{recipe_id}/availability", response_model=CraftingAvailabilityResponse)
async def check_crafting_availability(
    recipe_id: int,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    特定レシピの合成可能性をチェック
    """
    recipe = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="合成レシピが見つかりません"
        )
    
    # プレイヤーの所持素材を取得
    player_materials = {
        pm.material_master_id: pm.quantity 
        for pm in db.query(PlayerMaterial).filter(
            PlayerMaterial.player_id == current_player.id
        ).all()
    }
    
    can_craft, missing_requirements = _check_recipe_availability(recipe, current_player, player_materials)
    
    # 必要素材リスト
    required_materials = [
        {
            "material_id": rm.material_id,
            "material_name": rm.material.name,
            "required_quantity": rm.quantity
        }
        for rm in recipe.materials
    ]
    
    # プレイヤー所持素材リスト
    player_material_list = [
        {
            "material_id": material_id,
            "quantity": quantity
        }
        for material_id, quantity in player_materials.items()
    ]
    
    availability = CraftingAvailabilityCheck(
        recipe_id=recipe_id,
        can_craft=can_craft,
        missing_requirements=missing_requirements,
        required_materials=required_materials,
        player_materials=player_material_list
    )
    
    return CraftingAvailabilityResponse(
        success=True,
        data=availability,
        message="合成可能性をチェックしました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/craft", response_model=CraftingResultResponse)
async def craft_weapon(
    craft_request: CraftingRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器を合成
    """
    recipe = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity),
        joinedload(CraftingRecipe.materials).joinedload(RecipeMaterial.material)
    ).filter(
        CraftingRecipe.id == craft_request.recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="合成レシピが見つかりません"
        )
    
    # プレイヤーの所持素材を取得
    player_materials = {
        pm.material_master_id: pm 
        for pm in db.query(PlayerMaterial).filter(
            PlayerMaterial.player_id == current_player.id
        ).all()
    }
    
    # 合成可能性チェック
    player_material_quantities = {mid: pm.quantity for mid, pm in player_materials.items()}
    can_craft, missing_requirements = _check_recipe_availability(recipe, current_player, player_material_quantities)
    
    if not can_craft:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"合成できません: {', '.join(missing_requirements)}"
        )
    
    # ゴールド消費
    current_player.spend_gold(recipe.gold_cost)
    
    # 素材消費
    consumed_materials = []
    for recipe_material in recipe.materials:
        player_material = player_materials[recipe_material.material_id]
        player_material.remove_quantity(recipe_material.quantity)
        consumed_materials.append({
            "material_id": recipe_material.material_id,
            "material_name": recipe_material.material.name,
            "quantity": recipe_material.quantity
        })
    
    # 成功率判定
    success = random.random() < recipe.success_rate
    weapon_created = False
    weapon_id = None
    
    if success:
        # 武器作成
        weapon_attack = recipe.weapon.calculated_attack
        player_weapon = PlayerWeapon(
            player_id=current_player.id,
            weapon_master_id=recipe.weapon_id,
            attack=weapon_attack,
            enchant_level=0
        )
        db.add(player_weapon)
        db.flush()  # IDを取得するため
        
        weapon_created = True
        weapon_id = player_weapon.id
        message = f"{recipe.weapon.name}の合成に成功しました！"
    else:
        message = "合成に失敗しました..."
    
    db.commit()
    
    # ショップ経験値を追加（成功時はより多く）
    progression_action = "weapon_craft" if success else "weapon_craft"
    multiplier = 1.0 if success else 0.3  # 失敗時は経験値減少
    progression_result = ShopProgressionService.add_experience(
        current_player, progression_action, db, multiplier
    )
    
    result = CraftingResult(
        success=success,
        weapon_created=weapon_created,
        weapon_id=weapon_id,
        gold_spent=recipe.gold_cost,
        materials_consumed=consumed_materials,
        message=message
    )
    
    # レベルアップ情報をレスポンスに追加
    response_message = "合成を実行しました"
    if progression_result.get("leveled_up"):
        response_message += f" | {progression_result['level_up_message']}"
    
    return CraftingResultResponse(
        success=True,
        data=result,
        message=response_message,
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        shop_progression={
            "exp_gained": progression_result["exp_gained"],
            "current_level": progression_result["new_level"],
            "leveled_up": progression_result["leveled_up"],
            "progress_percentage": progression_result["progress_percentage"]
        }
    )

def _check_recipe_availability(recipe: CraftingRecipe, player: Player, player_materials: dict):
    """
    レシピの合成可能性をチェック
    """
    missing_requirements = []
    
    # レベルチェック
    if player.shop_level < recipe.required_level:
        missing_requirements.append(f"ショップレベル{recipe.required_level}が必要")
    
    # ゴールドチェック
    if not player.can_afford(recipe.gold_cost):
        missing_requirements.append(f"ゴールド{recipe.gold_cost}Gが必要")
    
    # 素材チェック
    for recipe_material in recipe.materials:
        player_quantity = player_materials.get(recipe_material.material_id, 0)
        if player_quantity < recipe_material.quantity:
            missing_requirements.append(
                f"{recipe_material.material.name}が{recipe_material.quantity - player_quantity}個不足"
            )
    
    return len(missing_requirements) == 0, missing_requirements
