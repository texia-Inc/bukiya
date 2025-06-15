from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional, List
from uuid import UUID
import uuid
import random

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models import Player, WeaponMaster, WeaponType, RarityLevel, PlayerWeapon
from app.schemas import (
    WeaponMasterListResponse, WeaponMasterResponse,
    PlayerWeaponListResponse, PlayerWeaponResponse,
    PlayerWeaponCreate, PlayerWeaponUpdate,
    EnchantRequest, EnchantResponse, EnchantResult,
    BaseResponse, WeaponMasterCreate, WeaponMasterUpdate
)

router = APIRouter()

# 管理画面用の認証不要エンドポイント
@router.get("/", response_model=WeaponMasterListResponse)
async def get_weapons_list(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    season_id: Optional[int] = Query(None, description="シーズンIDフィルター"),
    min_level: Optional[int] = Query(None, description="最小必要レベル"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    db: Session = Depends(get_db)
):
    """
    武器マスター一覧を取得（認証不要・管理画面用）
    """
    return await get_weapons_admin(page, limit, weapon_type_id, rarity_id, season_id, min_level, max_level, db)

@router.get("/admin/list", response_model=WeaponMasterListResponse)
async def get_weapons_admin(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=1000, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    season_id: Optional[int] = Query(None, description="シーズンIDフィルター"),
    min_level: Optional[int] = Query(None, description="最小必要レベル"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    db: Session = Depends(get_db)
):
    """
    管理画面用：武器マスター一覧を取得（認証不要）
    """
    query = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity),
        joinedload(WeaponMaster.season)
    ).filter(WeaponMaster.is_active == True)
    
    # フィルター適用
    if weapon_type_id:
        query = query.filter(WeaponMaster.weapon_type_id == weapon_type_id)
    if rarity_id:
        query = query.filter(WeaponMaster.rarity_id == rarity_id)
    if season_id:
        query = query.filter(WeaponMaster.season_id == season_id)
    if min_level:
        query = query.filter(WeaponMaster.required_shop_level >= min_level)
    if max_level:
        query = query.filter(WeaponMaster.required_shop_level <= max_level)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    weapons = query.offset(offset).limit(limit).all()
    
    return WeaponMasterListResponse(
        success=True,
        data=weapons,
        message="武器一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.post("/admin/create", response_model=WeaponMasterResponse)
async def create_weapon_admin(
    weapon_data: WeaponMasterCreate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：武器マスターを作成（認証不要）
    """
    # 武器タイプとレアリティの存在確認
    weapon_type = db.query(WeaponType).filter(
        WeaponType.id == weapon_data.weapon_type_id,
        WeaponType.is_active == True
    ).first()
    
    if not weapon_type:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器タイプが見つかりません"
        )
    
    rarity = db.query(RarityLevel).filter(
        RarityLevel.id == weapon_data.rarity_id,
        RarityLevel.is_active == True
    ).first()
    
    if not rarity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="レアリティが見つかりません"
        )
    
    # 武器マスター作成
    weapon_master = WeaponMaster(
        name=weapon_data.name,
        description=weapon_data.description,
        weapon_type_id=weapon_data.weapon_type_id,
        rarity_id=weapon_data.rarity_id,
        base_attack=weapon_data.base_attack,
        base_price=weapon_data.base_price,
        required_level=weapon_data.required_level,
        image_url=weapon_data.image_url,
        is_craftable=weapon_data.is_craftable
    )
    
    db.add(weapon_master)
    db.commit()
    db.refresh(weapon_master)
    
    # リレーションシップをロード
    weapon_master = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(WeaponMaster.id == weapon_master.id).first()
    
    return WeaponMasterResponse(
        success=True,
        data=weapon_master,
        message="武器を作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/admin/{weapon_id}", response_model=WeaponMasterResponse)
async def update_weapon_admin(
    weapon_id: str,
    weapon_data: WeaponMasterUpdate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：武器マスターを更新（認証不要）
    """
    # 武器マスターの存在確認
    weapon_master = db.query(WeaponMaster).filter(
        WeaponMaster.id == weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # 武器タイプとレアリティの存在確認（変更される場合）
    if weapon_data.weapon_type_id:
        weapon_type = db.query(WeaponType).filter(
            WeaponType.id == weapon_data.weapon_type_id,
            WeaponType.is_active == True
        ).first()
        
        if not weapon_type:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="武器タイプが見つかりません"
            )
    
    if weapon_data.rarity_id:
        rarity = db.query(RarityLevel).filter(
            RarityLevel.id == weapon_data.rarity_id,
            RarityLevel.is_active == True
        ).first()
        
        if not rarity:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="レアリティが見つかりません"
            )
    
    # 武器マスター更新
    for field, value in weapon_data.dict(exclude_unset=True).items():
        setattr(weapon_master, field, value)
    
    weapon_master.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(weapon_master)
    
    # リレーションシップをロード
    weapon_master = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(WeaponMaster.id == weapon_master.id).first()
    
    return WeaponMasterResponse(
        success=True,
        data=weapon_master,
        message="武器を更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/admin/{weapon_id}", response_model=BaseResponse[dict])
async def delete_weapon_admin(
    weapon_id: str,
    db: Session = Depends(get_db)
):
    """
    管理画面用：武器マスターを削除（認証不要）
    """
    # 武器マスターの存在確認
    weapon_master = db.query(WeaponMaster).filter(
        WeaponMaster.id == weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    weapon_master.is_active = False
    weapon_master.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_weapon_id": weapon_id},
        message="武器を削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/", response_model=WeaponMasterListResponse)
async def get_weapons(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    weapon_type_id: Optional[str] = Query(None, description="武器タイプIDフィルター"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    min_level: Optional[int] = Query(None, description="最小必要レベル"),
    max_level: Optional[int] = Query(None, description="最大必要レベル"),
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器マスター一覧を取得
    """
    query = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(WeaponMaster.is_active == True)
    
    # フィルター適用
    if weapon_type_id:
        query = query.filter(WeaponMaster.weapon_type_id == weapon_type_id)
    if rarity_id:
        query = query.filter(WeaponMaster.rarity_id == rarity_id)
    if min_level:
        query = query.filter(WeaponMaster.required_level >= min_level)
    if max_level:
        query = query.filter(WeaponMaster.required_level <= max_level)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    weapons = query.offset(offset).limit(limit).all()
    
    return WeaponMasterListResponse(
        success=True,
        data=weapons,
        message="武器一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.get("/{weapon_id}", response_model=WeaponMasterResponse)
async def get_weapon_detail(
    weapon_id: int,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器詳細を取得
    """
    weapon = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(
        WeaponMaster.id == weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    return WeaponMasterResponse(
        success=True,
        data=weapon,
        message="武器詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/player/inventory", response_model=PlayerWeaponListResponse)
async def get_player_weapons(
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤーの所持武器一覧を取得
    """
    # Get player weapons without the broken relationship
    player_weapons = db.query(PlayerWeapon).filter(
        PlayerWeapon.player_id == current_player.id
    ).all()
    
    # Manually attach weapon master data for each weapon
    enriched_weapons = []
    for pw in player_weapons:
        # Get weapon master separately since relationship is disabled
        weapon_master = db.query(WeaponMaster).options(
            joinedload(WeaponMaster.weapon_type),
            joinedload(WeaponMaster.rarity),
            joinedload(WeaponMaster.season)
        ).filter(
            WeaponMaster.id == int(pw.weapon_master_id)  # Convert string to int
        ).first()
        
        if weapon_master:
            # Create a dict with the weapon data and attach the weapon master
            # Ensure all string fields are non-null for Flutter compatibility
            weapon_dict = {
                "id": str(pw.id),  # Convert UUID to string
                "player_id": str(pw.player_id),  # Convert UUID to string
                "weapon_id": int(pw.weapon_master_id),  # Flutter expects weapon_id as int
                "weapon_master_id": int(pw.weapon_master_id),  # Keep for compatibility
                "weapon_name": pw.custom_name if pw.custom_name else weapon_master.name,  # Flutter expects weapon_name
                "base_attack": pw.base_attack,
                "attack": pw.total_attack,  # Flutter expects attack field
                "enchant_level": pw.enchant_level,
                "current_durability": pw.current_durability or 100,
                "max_durability": pw.max_durability or 100,
                "abilities": pw.abilities or "",  # Ensure non-null string
                "custom_name": pw.custom_name or "",  # Ensure non-null string
                "is_favorite": pw.is_favorite or False,
                "acquired_at": pw.acquired_at,
                "last_used_at": pw.last_used_at,
                "is_equipped": pw.is_equipped,
                "is_locked": pw.is_locked or False,
                "created_at": pw.acquired_at,  # Flutter expects created_at
                "weapon_master": {
                    "id": weapon_master.id,
                    "name": weapon_master.name or "",  # Ensure non-null
                    "description": weapon_master.description or "",  # Ensure non-null
                    "image_url": weapon_master.image_url or "",  # Ensure non-null
                    "effect_color": weapon_master.effect_color or "",  # Ensure non-null
                    "attribute_id": weapon_master.attribute_id or "",  # Ensure non-null
                    "base_attack": weapon_master.base_attack,
                    "calculated_attack": weapon_master.calculated_attack,
                    "base_price": weapon_master.base_price,
                    "calculated_price": weapon_master.calculated_price,
                    "required_level": weapon_master.required_level,
                    "is_active": weapon_master.is_active,
                    "created_at": weapon_master.created_at,
                    "updated_at": weapon_master.updated_at,
                    "weapon_type_id": weapon_master.weapon_type_id,
                    "rarity_id": weapon_master.rarity_id,
                    "season_id": weapon_master.season_id,
                    "base_attack_min": weapon_master.base_attack_min,
                    "base_attack_max": weapon_master.base_attack_max,
                    "base_price_min": weapon_master.base_price_min,
                    "base_price_max": weapon_master.base_price_max,
                    "enchant_growth_rate": float(weapon_master.enchant_growth_rate) if weapon_master.enchant_growth_rate else 1.0,
                    "max_enchant_level": weapon_master.max_enchant_level,
                    "crafting_time_minutes": weapon_master.crafting_time_minutes,
                    "required_shop_level": weapon_master.required_shop_level,
                    "required_adventurer_level": weapon_master.required_adventurer_level,
                    "drop_rate": float(weapon_master.drop_rate) if weapon_master.drop_rate else 0.0,
                    "is_test_only": weapon_master.is_test_only,
                    "version": weapon_master.version,
                    "weapon_type": {
                        "id": weapon_master.weapon_type.id if weapon_master.weapon_type else "",
                        "name": weapon_master.weapon_type.name if weapon_master.weapon_type else "",
                        "description": weapon_master.weapon_type.description if weapon_master.weapon_type else "",
                        "is_active": weapon_master.weapon_type.is_active if weapon_master.weapon_type else True,
                        "created_at": weapon_master.weapon_type.created_at if weapon_master.weapon_type else datetime.utcnow(),
                        "updated_at": weapon_master.weapon_type.updated_at if weapon_master.weapon_type else None,
                    } if weapon_master.weapon_type else None,
                    "rarity": {
                        "id": weapon_master.rarity.id if weapon_master.rarity else "",
                        "name": weapon_master.rarity.name if weapon_master.rarity else "",
                        "level": weapon_master.rarity.level if weapon_master.rarity else 1,
                        "color_code": weapon_master.rarity.color_code if weapon_master.rarity else "",
                        "star_display": weapon_master.rarity.star_display if weapon_master.rarity else "",
                        "attack_multiplier": float(weapon_master.rarity.attack_multiplier) if weapon_master.rarity else 1.0,
                        "price_multiplier": float(weapon_master.rarity.price_multiplier) if weapon_master.rarity else 1.0,
                        "max_enchant_level": weapon_master.rarity.max_enchant_level if weapon_master.rarity else 10,
                        "ability_slots": weapon_master.rarity.ability_slots if weapon_master.rarity else 0,
                        "base_drop_rate": float(weapon_master.rarity.base_drop_rate) if weapon_master.rarity else 0.6,
                        "is_active": weapon_master.rarity.is_active if weapon_master.rarity else True,
                        "created_at": weapon_master.rarity.created_at if weapon_master.rarity else datetime.utcnow(),
                        "updated_at": weapon_master.rarity.updated_at if weapon_master.rarity else None,
                        "description": weapon_master.rarity.description if hasattr(weapon_master.rarity, 'description') and weapon_master.rarity.description else "",
                        "multiplier": float(weapon_master.rarity.attack_multiplier) if weapon_master.rarity else 1.0,
                        "drop_rate": float(weapon_master.rarity.base_drop_rate) if weapon_master.rarity else 0.6,
                    } if weapon_master.rarity else None,
                    "season": None  # Add season field for schema compatibility
                },
                "display_name": pw.custom_name if pw.custom_name else weapon_master.name,
                "total_attack": pw.total_attack
            }
            enriched_weapons.append(weapon_dict)
    
    return PlayerWeaponListResponse(
        success=True,
        data=enriched_weapons,
        message="所持武器一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/player/create", response_model=PlayerWeaponResponse)
async def create_player_weapon(
    weapon_data: PlayerWeaponCreate,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー武器を作成（合成・購入・ドロップ時に使用）
    """
    # 武器マスターの存在確認
    weapon_master = db.query(WeaponMaster).filter(
        WeaponMaster.id == weapon_data.weapon_master_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器マスターが見つかりません"
        )
    
    # プレイヤー武器作成
    player_weapon = PlayerWeapon(
        player_id=current_player.id,
        weapon_master_id=weapon_data.weapon_master_id,
        attack=weapon_data.attack,
        enchant_level=weapon_data.enchant_level,
        custom_name=weapon_data.custom_name
    )
    
    db.add(player_weapon)
    db.commit()
    db.refresh(player_weapon)
    
    # リレーションシップをロード
    db.refresh(player_weapon, ['weapon_master'])
    
    return PlayerWeaponResponse(
        success=True,
        data=player_weapon,
        message="武器を作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/player/{weapon_id}", response_model=PlayerWeaponResponse)
async def update_player_weapon(
    weapon_id: UUID,
    weapon_data: PlayerWeaponUpdate,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー武器を更新
    """
    player_weapon = db.query(PlayerWeapon).filter(
        PlayerWeapon.id == weapon_id,
        PlayerWeapon.player_id == current_player.id
    ).first()
    
    if not player_weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # 装備状態の変更時は他の武器の装備を解除
    if weapon_data.is_equipped is True:
        db.query(PlayerWeapon).filter(
            PlayerWeapon.player_id == current_player.id,
            PlayerWeapon.id != weapon_id
        ).update({"is_equipped": False})
    
    # 更新
    for field, value in weapon_data.dict(exclude_unset=True).items():
        setattr(player_weapon, field, value)
    
    db.commit()
    db.refresh(player_weapon)
    
    return PlayerWeaponResponse(
        success=True,
        data=player_weapon,
        message="武器を更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/player/{weapon_id}/enchant", response_model=EnchantResponse)
async def enchant_weapon(
    weapon_id: UUID,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器をエンチャント
    """
    player_weapon = db.query(PlayerWeapon).filter(
        PlayerWeapon.id == weapon_id,
        PlayerWeapon.player_id == current_player.id
    ).first()
    
    if not player_weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    if not player_weapon.can_enchant():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="これ以上エンチャントできません（最大レベル10）"
        )
    
    # エンチャントコスト計算（レベルが上がるほど高額）
    enchant_cost = (player_weapon.enchant_level + 1) * 1000
    
    if not current_player.can_afford(enchant_cost):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"ゴールドが不足しています（必要: {enchant_cost}G）"
        )
    
    # 成功率判定
    success_rate = player_weapon.enchant_success_rate()
    success = random.random() < success_rate
    
    # ゴールド消費
    current_player.spend_gold(enchant_cost)
    
    if success:
        # エンチャント成功
        player_weapon.enchant_level += 1
        message = f"エンチャント成功！レベル{player_weapon.enchant_level}になりました"
    else:
        # エンチャント失敗（レベルは変わらず）
        message = "エンチャント失敗..."
    
    db.commit()
    
    result = EnchantResult(
        success=success,
        new_level=player_weapon.enchant_level,
        new_attack=player_weapon.total_attack,
        message=message
    )
    
    return EnchantResponse(
        success=True,
        data=result,
        message="エンチャントを実行しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/player/{weapon_id}", response_model=BaseResponse[dict])
async def delete_player_weapon(
    weapon_id: UUID,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー武器を削除（売却）
    """
    player_weapon = db.query(PlayerWeapon).options(
        joinedload(PlayerWeapon.weapon_master).joinedload(WeaponMaster.rarity)
    ).filter(
        PlayerWeapon.id == weapon_id,
        PlayerWeapon.player_id == current_player.id
    ).first()
    
    if not player_weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # 売却価格計算（基本価格の50% + エンチャントボーナス）
    base_price = player_weapon.weapon_master.calculated_price
    enchant_bonus = player_weapon.enchant_level * 100
    sell_price = int(base_price * 0.5) + enchant_bonus
    
    # ゴールド追加
    current_player.add_gold(sell_price)
    
    # 武器削除
    db.delete(player_weapon)
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"gold_earned": sell_price},
        message=f"武器を売却しました（{sell_price}G獲得）",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )
