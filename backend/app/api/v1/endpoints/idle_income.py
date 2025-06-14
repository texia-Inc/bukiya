"""
放置収入システムAPIエンドポイント
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timezone

from app.core.dependencies import get_db, get_current_player
from app.models import Player

router = APIRouter()


@router.get("/status")
def get_idle_income_status(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """現在の放置収入状況を取得"""
    income, elapsed_minutes = current_user.calculate_idle_income()
    
    return {
        "available_income": income,
        "elapsed_minutes": elapsed_minutes,
        "max_minutes": 720,  # 12時間
        "income_rate": current_user.idle_income_rate,
        "level_bonus": 1.0 + (current_user.shop_level * 0.2),
        "multiplier": current_user.idle_income_multiplier_display,
        "last_collection_time": current_user.last_idle_collection_time.isoformat() if current_user.last_idle_collection_time else None
    }


@router.post("/collect")
def collect_idle_income(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """放置収入を回収"""
    income, elapsed_minutes = current_user.collect_idle_income()
    
    if income <= 0:
        raise HTTPException(status_code=400, detail="回収可能な収入がありません")
    
    db.commit()
    
    return {
        "message": f"{income}ゴールドを回収しました",
        "income_collected": income,
        "elapsed_minutes": elapsed_minutes,
        "new_gold_balance": current_user.gold,
        "collection_time": current_user.last_idle_collection_time.isoformat()
    }


@router.get("/info")
def get_idle_income_info(
    current_user: Player = Depends(get_current_player)
):
    """放置収入システムの詳細情報"""
    current_income_per_minute = (
        current_user.idle_income_rate * 
        (1.0 + (current_user.shop_level * 0.2)) * 
        current_user.idle_income_multiplier_display
    )
    
    return {
        "base_rate": current_user.idle_income_rate,
        "shop_level": current_user.shop_level,
        "level_bonus_percentage": current_user.shop_level * 20,  # %表示
        "facility_multiplier": current_user.idle_income_multiplier_display,
        "current_income_per_minute": round(current_income_per_minute, 2),
        "max_storage_hours": 12,
        "max_total_income": int(720 * current_income_per_minute),  # 12時間分の最大収入
        "formula": "基本収入/分 × (1 + ショップレベル × 0.2) × 施設補正"
    }


@router.post("/boost")
def boost_idle_income(
    duration_hours: int,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """放置収入をブーストする（将来の機能：ジェム消費）"""
    # TODO: ジェムシステム実装後に有効化
    # gem_cost = duration_hours * 50
    # if not current_user.spend_gems(gem_cost):
    #     raise HTTPException(status_code=400, detail="ジェムが不足しています")
    
    # 一時的に2倍の収入率に設定（実装例）
    boost_multiplier = 200  # 2.00倍
    
    # TODO: ブースト期限の管理システム実装
    
    return {
        "message": f"{duration_hours}時間のブーストを開始しました",
        "boost_duration_hours": duration_hours,
        "boost_multiplier": boost_multiplier / 100,
        "expires_at": "TODO: 実装予定"
    }