from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
import uuid

from app.core.database import get_db
from app.models import (
    Player, WeaponMaster, MaterialMaster, CraftingRecipe, 
    PlayerWeapon, PlayerStatistics
)
from app.schemas.common import BaseResponse
from pydantic import BaseModel

router = APIRouter()

class DashboardStats(BaseModel):
    total_players: int
    total_weapons: int
    total_materials: int
    total_recipes: int
    active_players_today: int
    total_gold_in_circulation: int
    most_popular_weapon: str
    recent_registrations: int

@router.get("/stats", response_model=BaseResponse[DashboardStats])
async def get_dashboard_stats(db: Session = Depends(get_db)):
    """
    ダッシュボード統計を取得
    """
    # 基本統計
    total_players = db.query(Player).filter(Player.is_active == True).count()
    total_weapons = db.query(WeaponMaster).filter(WeaponMaster.is_active == True).count()
    total_materials = db.query(MaterialMaster).filter(MaterialMaster.is_active == True).count()
    total_recipes = db.query(CraftingRecipe).filter(CraftingRecipe.is_active == True).count()
    
    # 今日のアクティブプレイヤー数（今日ログインしたプレイヤー）
    today = datetime.utcnow().date()
    active_players_today = db.query(Player).filter(
        Player.is_active == True,
        func.date(Player.last_login) == today
    ).count()
    
    # 最近の登録数（過去7日）
    week_ago = datetime.utcnow() - timedelta(days=7)
    recent_registrations = db.query(Player).filter(
        Player.is_active == True,
        Player.created_at >= week_ago
    ).count()
    
    # 流通ゴールド総額
    total_gold_result = db.query(func.sum(Player.gold)).filter(
        Player.is_active == True
    ).scalar()
    total_gold_in_circulation = int(total_gold_result) if total_gold_result else 0
    
    # 最も人気の武器（所持数が多い武器）
    popular_weapon_result = db.query(
        WeaponMaster.name,
        func.count(PlayerWeapon.id).label('count')
    ).join(
        PlayerWeapon, WeaponMaster.id == PlayerWeapon.weapon_master_id
    ).group_by(
        WeaponMaster.id, WeaponMaster.name
    ).order_by(
        func.count(PlayerWeapon.id).desc()
    ).first()
    
    most_popular_weapon = popular_weapon_result[0] if popular_weapon_result else "なし"
    
    stats = DashboardStats(
        total_players=total_players,
        total_weapons=total_weapons,
        total_materials=total_materials,
        total_recipes=total_recipes,
        active_players_today=active_players_today,
        total_gold_in_circulation=total_gold_in_circulation,
        most_popular_weapon=most_popular_weapon,
        recent_registrations=recent_registrations
    )
    
    return BaseResponse(
        success=True,
        data=stats,
        message="ダッシュボード統計を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )