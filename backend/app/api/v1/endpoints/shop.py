from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, validator
from uuid import UUID
import uuid

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.core.shop_progression import ShopProgressionService
from app.models import Player, WeaponMaster, PlayerWeapon
from app.schemas import (
    BaseResponse, PlayerWeaponResponse, PlayerResponse
)

class ProcurementRequest(BaseModel):
    weapon_id: int

class SellRequest(BaseModel):
    player_weapon_id: UUID
    
    @validator('player_weapon_id', pre=True)
    def validate_player_weapon_id(cls, v):
        if isinstance(v, str):
            try:
                return UUID(v)
            except ValueError:
                raise ValueError('Invalid UUID format for player_weapon_id')
        return v

router = APIRouter()

@router.post("/procure", response_model=BaseResponse[dict])
async def procure_weapon(
    request: ProcurementRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器を仕入れ
    """
    # 武器マスターの存在確認
    weapon_master = db.query(WeaponMaster).options(
        joinedload(WeaponMaster.weapon_type),
        joinedload(WeaponMaster.rarity)
    ).filter(
        WeaponMaster.id == request.weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    # プレイヤーのショップレベル確認
    if current_player.shop_level < weapon_master.required_shop_level:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"ショップレベルが不足しています（必要レベル: {weapon_master.required_shop_level}）"
        )
    
    # 仕入れ価格計算（販売価格の70%で仕入れ）
    procurement_price = int(weapon_master.calculated_price * 0.7)
    
    # ゴールド確認
    if not current_player.can_afford(procurement_price):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"ゴールドが不足しています（仕入れ費用: {procurement_price}G）"
        )
    
    # ゴールド消費
    current_player.spend_gold(procurement_price)
    
    # プレイヤー武器作成
    player_weapon = PlayerWeapon(
        player_id=current_player.id,
        weapon_master_id=request.weapon_id,
        base_attack=weapon_master.base_attack,
        attack=weapon_master.base_attack,
        enchant_level=0,
        custom_name=None
    )
    
    db.add(player_weapon)
    db.commit()
    db.refresh(player_weapon)
    
    # ショップ経験値を追加
    progression_result = ShopProgressionService.add_experience(
        current_player, "weapon_procurement", db
    )
    
    response_data = {
        "weapon_id": str(player_weapon.id),
        "weapon_name": weapon_master.name,
        "procurement_cost": procurement_price,
        "remaining_gold": current_player.gold
    }
    
    # レベルアップした場合の情報を追加
    if progression_result.get("leveled_up"):
        response_data["shop_level_up"] = {
            "new_level": progression_result["new_level"],
            "message": progression_result["level_up_message"]
        }
    
    response_data["shop_progression"] = {
        "exp_gained": progression_result["exp_gained"],
        "current_level": progression_result["new_level"],
        "progress_percentage": progression_result["progress_percentage"]
    }
    
    message = f"{weapon_master.name}を仕入れました"
    if progression_result.get("leveled_up"):
        message += f" | {progression_result['level_up_message']}"
    
    return BaseResponse(
        success=True,
        data=response_data,
        message=message,
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

# 後方互換性のために古いエンドポイントも維持
@router.post("/purchase", response_model=BaseResponse[dict])
async def purchase_weapon_legacy(
    request: ProcurementRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    武器購入（旧API - 仕入れエンドポイントにリダイレクト）
    """
    return await procure_weapon(request, current_player, db)

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
    
    # ショップ経験値を追加
    progression_result = ShopProgressionService.add_experience(
        current_player, "weapon_sell", db
    )
    
    response_data = {
        "gold_earned": sell_price,
        "remaining_gold": current_player.gold
    }
    
    # レベルアップした場合の情報を追加
    if progression_result.get("leveled_up"):
        response_data["shop_level_up"] = {
            "new_level": progression_result["new_level"],
            "message": progression_result["level_up_message"]
        }
    
    response_data["shop_progression"] = {
        "exp_gained": progression_result["exp_gained"],
        "current_level": progression_result["new_level"],
        "progress_percentage": progression_result["progress_percentage"]
    }
    
    message = f"{weapon_name}を売却しました（{sell_price}G獲得）"
    if progression_result.get("leveled_up"):
        message += f" | {progression_result['level_up_message']}"
    
    return BaseResponse(
        success=True,
        data=response_data,
        message=message,
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )