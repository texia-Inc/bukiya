from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta

from ....core.database import get_db
from ....core.dependencies import get_current_player
from ....models.player import Player
from ....models.idle_system import (
    PlayerIdleSystem, IdleUpgradeMaster, PlayerIdleUpgrade,
    IdleBonusMaster, PlayerIdleBonus
)
from ....schemas.idle import (
    IdleSystemResponse, IdleCollectionResult, UpgradeRequest, UpgradeResult,
    BonusActivationRequest, BonusActivationResult, IdleUpgradeResponse,
    IdleBonusResponse
)

router = APIRouter()


def get_or_create_idle_system(db: Session, player: Player) -> PlayerIdleSystem:
    """プレイヤーの放置システムを取得または作成"""
    idle_system = db.query(PlayerIdleSystem).filter(
        PlayerIdleSystem.player_id == player.id
    ).first()
    
    if not idle_system:
        idle_system = PlayerIdleSystem(
            player_id=player.id,
            base_income_per_second=1,
            current_level=1,
            upgrade_count=0,
            multiplier=1.0,
            last_collected_at=datetime.utcnow(),
            experience=0
        )
        db.add(idle_system)
        db.commit()
        db.refresh(idle_system)
        
        # 初期アップグレードを作成
        create_initial_upgrades(db, player.id, idle_system.id)
    
    return idle_system


def create_initial_upgrades(db: Session, player_id: str, idle_system_id: int):
    """初期アップグレードを作成"""
    upgrade_masters = db.query(IdleUpgradeMaster).filter(
        IdleUpgradeMaster.is_active == True,
        IdleUpgradeMaster.unlock_level <= 1
    ).all()
    
    for master in upgrade_masters:
        existing = db.query(PlayerIdleUpgrade).filter(
            PlayerIdleUpgrade.player_id == player_id,
            PlayerIdleUpgrade.upgrade_id == master.id
        ).first()
        
        if not existing:
            upgrade = PlayerIdleUpgrade(
                player_id=player_id,
                idle_system_id=idle_system_id,
                upgrade_id=master.id,
                level=0
            )
            db.add(upgrade)
    
    db.commit()


def format_time_display(seconds: int) -> str:
    """時間を表示用文字列に変換"""
    if seconds <= 0:
        return "0秒"
    
    days = seconds // 86400
    hours = (seconds % 86400) // 3600
    minutes = (seconds % 3600) // 60
    remaining_seconds = seconds % 60
    
    if days > 0:
        return f"{days}日{hours}時間"
    elif hours > 0:
        return f"{hours}時間{minutes}分"
    elif minutes > 0:
        return f"{minutes}分{remaining_seconds}秒"
    else:
        return f"{remaining_seconds}秒"


def build_upgrade_response(upgrade: PlayerIdleUpgrade) -> IdleUpgradeResponse:
    """アップグレードレスポンスを構築"""
    master = upgrade.upgrade_master
    next_cost = master.get_cost_for_level(upgrade.level + 1) if upgrade.level < master.max_level else 0
    effect_percentage = int((master.income_multiplier - 1.0) * 100)
    
    return IdleUpgradeResponse(
        id=master.id,
        name=master.name,
        description=master.description,
        cost=master.base_cost,
        income_multiplier=master.income_multiplier,
        level=upgrade.level,
        max_level=master.max_level,
        icon_name=master.icon_name,
        is_unlocked=master.unlock_level <= upgrade.idle_system.current_level,
        next_level_cost=next_cost,
        is_max_level=upgrade.level >= master.max_level,
        effect_description=f"収益 +{effect_percentage}%"
    )


def build_bonus_response(bonus: PlayerIdleBonus) -> IdleBonusResponse:
    """ボーナスレスポンスを構築"""
    master = bonus.bonus_master
    remaining = bonus.remaining_seconds
    effect_percentage = int((master.multiplier - 1.0) * 100)
    
    return IdleBonusResponse(
        id=master.id,
        name=master.name,
        description=master.description,
        multiplier=master.multiplier,
        start_time=bonus.start_time,
        duration_seconds=master.duration_seconds,
        icon_name=master.icon_name,
        type=master.bonus_type,
        is_active=bonus.is_active,
        remaining_seconds=remaining,
        remaining_time_display=format_time_display(remaining),
        effect_description=f"収益 +{effect_percentage}%" if master.bonus_type == "income" else f"{master.bonus_type} +{effect_percentage}%"
    )


@router.get("/status", response_model=IdleSystemResponse)
async def get_idle_status(
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """放置システムの状態を取得"""
    idle_system = get_or_create_idle_system(db, current_player)
    
    # アップグレード情報を取得
    upgrades = db.query(PlayerIdleUpgrade).filter(
        PlayerIdleUpgrade.player_id == current_player.id
    ).all()
    
    # アクティブボーナスを取得
    active_bonuses = db.query(PlayerIdleBonus).filter(
        PlayerIdleBonus.player_id == current_player.id
    ).all()
    
    # レスポンスを構築
    upgrade_responses = [build_upgrade_response(upgrade) for upgrade in upgrades]
    bonus_responses = [build_bonus_response(bonus) for bonus in active_bonuses if bonus.is_active]
    
    return IdleSystemResponse(
        base_income_per_second=idle_system.base_income_per_second,
        current_level=idle_system.current_level,
        upgrade_count=idle_system.upgrade_count,
        multiplier=idle_system.multiplier,
        last_collected_at=idle_system.last_collected_at,
        experience=idle_system.experience,
        current_income_per_second=idle_system.current_income_per_second,
        pending_income=idle_system.pending_income,
        experience_to_next_level=idle_system.experience_to_next_level,
        efficiency_display=f"{idle_system.current_income_per_second}G/秒",
        available_upgrades=upgrade_responses,
        active_bonuses=bonus_responses
    )


@router.post("/collect", response_model=IdleCollectionResult)
async def collect_income(
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """放置収益を回収"""
    idle_system = get_or_create_idle_system(db, current_player)
    
    # 収益を計算
    now = datetime.utcnow()
    offline_time = now - idle_system.last_collected_at
    offline_seconds = int(offline_time.total_seconds())
    
    # 最大8時間分の収益に制限
    max_offline_seconds = 8 * 3600
    effective_offline_seconds = min(offline_seconds, max_offline_seconds)
    
    gold_earned = idle_system.current_income_per_second * effective_offline_seconds
    experience_gained = int(gold_earned * 0.1)  # ゴールドの10%を経験値として
    
    # 期限切れボーナスをチェック
    expired_bonuses = []
    bonuses_to_remove = []
    
    for bonus in idle_system.bonuses:
        if not bonus.is_active:
            expired_bonuses.append(bonus.bonus_master.name)
            bonuses_to_remove.append(bonus)
    
    # 期限切れボーナスを削除
    for bonus in bonuses_to_remove:
        db.delete(bonus)
    
    # レベルアップチェック
    leveled_up = False
    new_level = idle_system.current_level
    idle_system.experience += experience_gained
    
    while idle_system.can_level_up():
        if idle_system.level_up():
            leveled_up = True
            new_level = idle_system.current_level
        else:
            break
    
    # プレイヤーのゴールドを更新
    current_player.add_gold(gold_earned)
    
    # 放置システムの最終回収時刻を更新
    idle_system.last_collected_at = now
    
    db.commit()
    
    return IdleCollectionResult(
        gold_earned=gold_earned,
        experience_gained=experience_gained,
        offline_time_seconds=effective_offline_seconds,
        bonuses_expired=expired_bonuses,
        leveled_up=leveled_up,
        new_level=new_level,
        offline_time_display=format_time_display(effective_offline_seconds)
    )


@router.post("/upgrade", response_model=UpgradeResult)
async def purchase_upgrade(
    request: UpgradeRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """アップグレードを購入"""
    idle_system = get_or_create_idle_system(db, current_player)
    
    # アップグレードを取得
    upgrade = db.query(PlayerIdleUpgrade).filter(
        PlayerIdleUpgrade.player_id == current_player.id,
        PlayerIdleUpgrade.upgrade_id == request.upgrade_id
    ).first()
    
    if not upgrade:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="アップグレードが見つかりません"
        )
    
    # アップグレード可能かチェック
    if not upgrade.can_upgrade(current_player.gold):
        if upgrade.is_max_level:
            return UpgradeResult(
                success=False,
                message="このアップグレードは最大レベルです",
                new_gold_amount=current_player.gold,
                new_multiplier=idle_system.multiplier
            )
        else:
            return UpgradeResult(
                success=False,
                message="ゴールドが不足しています",
                new_gold_amount=current_player.gold,
                new_multiplier=idle_system.multiplier
            )
    
    # ゴールドを消費
    cost = upgrade.next_level_cost
    if not current_player.spend_gold(cost):
        return UpgradeResult(
            success=False,
            message="ゴールドが不足しています",
            new_gold_amount=current_player.gold,
            new_multiplier=idle_system.multiplier
        )
    
    # アップグレードを実行
    upgrade.level += 1
    idle_system.upgrade_count += 1
    idle_system.multiplier *= upgrade.upgrade_master.income_multiplier
    
    db.commit()
    
    return UpgradeResult(
        success=True,
        message=f"{upgrade.upgrade_master.name} をレベル {upgrade.level} にアップグレードしました！",
        upgraded_item=build_upgrade_response(upgrade),
        new_gold_amount=current_player.gold,
        new_multiplier=idle_system.multiplier
    )


@router.post("/activate-bonus", response_model=BonusActivationResult)
async def activate_bonus(
    request: BonusActivationRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """ボーナスを有効化"""
    idle_system = get_or_create_idle_system(db, current_player)
    
    # ボーナスマスターを取得
    bonus_master = db.query(IdleBonusMaster).filter(
        IdleBonusMaster.id == request.bonus_id,
        IdleBonusMaster.is_active == True
    ).first()
    
    if not bonus_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ボーナスが見つかりません"
        )
    
    # 既存のアクティブボーナスをチェック
    existing_bonus = db.query(PlayerIdleBonus).filter(
        PlayerIdleBonus.player_id == current_player.id,
        PlayerIdleBonus.bonus_id == request.bonus_id
    ).first()
    
    if existing_bonus and existing_bonus.is_active:
        return BonusActivationResult(
            success=False,
            message="このボーナスは既にアクティブです"
        )
    
    # 新しいボーナスを作成
    new_bonus = PlayerIdleBonus(
        player_id=current_player.id,
        idle_system_id=idle_system.id,
        bonus_id=request.bonus_id,
        start_time=datetime.utcnow()
    )
    
    db.add(new_bonus)
    db.commit()
    db.refresh(new_bonus)
    
    return BonusActivationResult(
        success=True,
        message=f"{bonus_master.name} を有効化しました！",
        activated_bonus=build_bonus_response(new_bonus)
    )
