from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional
import uuid

from app.core.database import get_db
from app.models import CraftingRecipe, RecipeMaterial, WeaponMaster, MaterialMaster
from app.schemas import (
    CraftingRecipeListResponse, CraftingRecipeResponse,
    CraftingRecipeCreate, CraftingRecipeUpdate,
    BaseResponse
)

router = APIRouter()

@router.get("/", response_model=CraftingRecipeListResponse)
async def get_recipes(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    db: Session = Depends(get_db)
):
    """
    レシピ一覧を取得（管理画面用）
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
        message="レシピ一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.get("/{recipe_id}", response_model=CraftingRecipeResponse)
async def get_recipe_detail(
    recipe_id: int,
    db: Session = Depends(get_db)
):
    """
    レシピ詳細を取得
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
            detail="レシピが見つかりません"
        )
    
    return CraftingRecipeResponse(
        success=True,
        data=recipe,
        message="レシピ詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/", response_model=CraftingRecipeResponse)
async def create_recipe(
    recipe_data: CraftingRecipeCreate,
    db: Session = Depends(get_db)
):
    """
    レシピを作成
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
        message="レシピを作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/{recipe_id}", response_model=CraftingRecipeResponse)
async def update_recipe(
    recipe_id: int,
    recipe_data: CraftingRecipeUpdate,
    db: Session = Depends(get_db)
):
    """
    レシピを更新
    """
    # レシピの存在確認
    recipe = db.query(CraftingRecipe).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="レシピが見つかりません"
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
        message="レシピを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/{recipe_id}", response_model=BaseResponse[dict])
async def delete_recipe(
    recipe_id: int,
    db: Session = Depends(get_db)
):
    """
    レシピを削除
    """
    # レシピの存在確認
    recipe = db.query(CraftingRecipe).filter(
        CraftingRecipe.id == recipe_id,
        CraftingRecipe.is_active == True
    ).first()
    
    if not recipe:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="レシピが見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    recipe.is_active = False
    recipe.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_recipe_id": recipe_id},
        message="レシピを削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )