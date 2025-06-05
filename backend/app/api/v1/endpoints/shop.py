from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional
from pydantic import BaseModel
import uuid

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models import Player, WeaponMaster, PlayerWeapon
from app.schemas import (
    BaseResponse, PlayerWeaponResponse, PlayerResponse
)

class PurchaseRequest(BaseModel):
    weapon_id: str

class SellRequest(BaseModel):
    player_weapon_id: str

router = APIRouter()

@router.post("/purchase", response_model=BaseResponse[dict])
async def purchase_weapon(
    request: PurchaseRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器を購入
    """
    # 武器マスターの存在確認
    weapon_master = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(
        WeaponMaster.id == int(request.weapon_id),
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # プレイヤーのショップレベル確認
    if current_player.shop_level < weapon_master.required_level:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"ショップレベルが不足しています（必要レベル: {weapon_master.required_level}）"
        )
    
    # 価格計算
    purchase_price = weapon_master.calculated_price
    
    # ゴールド確認
    if not current_player.can_afford(purchase_price):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"ゴールドが不足しています（必要: {purchase_price}G）"
        )
    
    # ゴールド消費
    current_player.spend_gold(purchase_price)
    
    # プレイヤー武器作成
    player_weapon = PlayerWeapon(
        player_id=current_player.id,
        weapon_master_id=int(request.weapon_id),
        attack=weapon_master.base_attack,
        enchant_level=0,
        custom_name=None
    )
    
    db.add(player_weapon)
    db.commit()
    db.refresh(player_weapon)
    
    return BaseResponse(
        success=True,
        data={
            "weapon_id": str(player_weapon.id),
            "weapon_name": weapon_master.name,
            "gold_spent": purchase_price,
            "remaining_gold": current_player.gold
        },
        message=f"{weapon_master.name}を購入しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/sell", response_model=BaseResponse[dict])
async def sell_weapon(
    request: SellRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器を売却
    """
    # プレイヤー武器の存在確認
    player_weapon = db.query(PlayerWeapon).options(
        joinedload(PlayerWeapon.weapon_master).joinedload(WeaponMaster.rarity)
    ).filter(
        PlayerWeapon.id == request.player_weapon_id,
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
    weapon_name = player_weapon.weapon_master.name
    db.delete(player_weapon)
    db.commit()
    
    return BaseResponse(
        success=True,
        data={
            "gold_earned": sell_price,
            "remaining_gold": current_player.gold
        },
        message=f"{weapon_name}を売却しました（{sell_price}G獲得）",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )