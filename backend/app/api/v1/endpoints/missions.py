from typing import List, Optional
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from uuid import UUID

from app.core.database import get_db
from app.models import MissionTemplate, PlayerMission, MissionProgressLog, Player
from app.schemas.mission import (
    MissionTemplateResponse, MissionTemplateCreate, MissionTemplateUpdate,
    PlayerMissionResponse, PlayerMissionWithTemplate, MissionListResponse,
    MissionRewardClaim, MissionRewardClaimResponse, MissionStatistics,
    MissionType, TargetType
)

router = APIRouter()


# ミッション一覧取得
@router.get("/daily", response_model=MissionListResponse)
def get_daily_missions(
    player_id: UUID = Query(..., description="プレイヤーID"),
    db: Session = Depends(get_db)
):
    """デイリーミッション一覧を取得"""
    return _get_missions_by_type(db, player_id, MissionType.DAILY)


@router.get("/weekly", response_model=MissionListResponse)
def get_weekly_missions(
    player_id: UUID = Query(..., description="プレイヤーID"),
    db: Session = Depends(get_db)
):
    """ウィークリーミッション一覧を取得"""
    return _get_missions_by_type(db, player_id, MissionType.WEEKLY)


@router.get("/achievements", response_model=MissionListResponse)
def get_achievements(
    player_id: UUID = Query(..., description="プレイヤーID"),
    db: Session = Depends(get_db)
):
    """アチーブメント一覧を取得"""
    return _get_missions_by_type(db, player_id, MissionType.ACHIEVEMENT)


@router.get("/progress", response_model=List[PlayerMissionWithTemplate])
def get_mission_progress(
    player_id: UUID = Query(..., description="プレイヤーID"),
    mission_type: Optional[MissionType] = Query(None, description="ミッションタイプフィルター"),
    db: Session = Depends(get_db)
):
    """プレイヤーのミッション進捗を取得"""
    query = db.query(PlayerMission).filter(PlayerMission.player_id == player_id)
    
    if mission_type:
        query = query.join(MissionTemplate).filter(MissionTemplate.mission_type == mission_type)
    
    missions = query.all()
    
    return [_convert_to_mission_with_template(mission) for mission in missions]


# ミッション報酬受取
@router.post("/{mission_id}/claim", response_model=MissionRewardClaimResponse)
def claim_mission_reward(
    mission_id: int,
    player_id: UUID = Query(..., description="プレイヤーID"),
    db: Session = Depends(get_db)
):
    """ミッション報酬を受け取る"""
    # プレイヤーミッションを取得
    mission = db.query(PlayerMission).filter(
        and_(
            PlayerMission.id == mission_id,
            PlayerMission.player_id == player_id
        )
    ).first()
    
    if not mission:
        raise HTTPException(status_code=404, detail="ミッションが見つかりません")
    
    if not mission.can_claim_reward():
        raise HTTPException(status_code=400, detail="報酬を受け取ることができません")
    
    # プレイヤーを取得
    player = db.query(Player).filter(Player.id == player_id).first()
    if not player:
        raise HTTPException(status_code=404, detail="プレイヤーが見つかりません")
    
    # 報酬を付与
    rewards = {}
    template = mission.mission_template
    
    if template.reward_gold > 0:
        player.add_gold(template.reward_gold)
        rewards["gold"] = template.reward_gold
    
    if template.reward_exp > 0:
        # 経験値システムが実装されたら追加
        rewards["exp"] = template.reward_exp
    
    if template.reward_items:
        # アイテム報酬システムが実装されたら追加
        rewards["items"] = template.reward_items
    
    # 報酬受取フラグを設定
    mission.is_claimed = True
    mission.claimed_at = datetime.utcnow()
    
    db.commit()
    
    return MissionRewardClaimResponse(
        success=True,
        message="報酬を受け取りました",
        rewards=rewards
    )


# ミッション進捗更新（内部API）
@router.post("/progress", response_model=dict)
def update_mission_progress(
    player_id: UUID,
    action_type: TargetType,
    progress_delta: int = 1,
    extra_data: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """ミッション進捗を更新（内部API）"""
    # 該当するアクティブなミッションを取得
    missions = db.query(PlayerMission).join(MissionTemplate).filter(
        and_(
            PlayerMission.player_id == player_id,
            PlayerMission.is_completed == False,
            MissionTemplate.target_type == action_type,
            MissionTemplate.is_active == True
        )
    ).all()
    
    updated_missions = []
    
    for mission in missions:
        # 進捗を更新
        mission.current_progress += progress_delta
        
        # 完了チェック
        if mission.is_ready_to_complete():
            mission.is_completed = True
            mission.completed_at = datetime.utcnow()
        
        # ログを記録
        log = MissionProgressLog(
            player_id=player_id,
            mission_id=mission.id,
            action_type=action_type.value,
            progress_delta=progress_delta,
            extra_data=extra_data
        )
        db.add(log)
        
        updated_missions.append(mission.id)
    
    db.commit()
    
    return {
        "updated_missions": updated_missions,
        "total_updated": len(updated_missions)
    }


# 管理画面用API
@router.get("/admin/templates", response_model=List[MissionTemplateResponse])
def get_mission_templates(
    mission_type: Optional[MissionType] = Query(None, description="ミッションタイプフィルター"),
    is_active: Optional[bool] = Query(None, description="有効フラグフィルター"),
    skip: int = Query(0, ge=0, description="スキップ数"),
    limit: int = Query(100, ge=1, le=100, description="取得数"),
    db: Session = Depends(get_db)
):
    """ミッションテンプレート一覧を取得（管理画面用）"""
    query = db.query(MissionTemplate)
    
    if mission_type:
        query = query.filter(MissionTemplate.mission_type == mission_type)
    
    if is_active is not None:
        query = query.filter(MissionTemplate.is_active == is_active)
    
    query = query.order_by(MissionTemplate.display_order, MissionTemplate.id)
    
    return query.offset(skip).limit(limit).all()


@router.post("/admin/templates", response_model=MissionTemplateResponse)
def create_mission_template(
    template: MissionTemplateCreate,
    db: Session = Depends(get_db)
):
    """ミッションテンプレートを作成（管理画面用）"""
    db_template = MissionTemplate(**template.dict())
    db.add(db_template)
    db.commit()
    db.refresh(db_template)
    return db_template


@router.put("/admin/templates/{template_id}", response_model=MissionTemplateResponse)
def update_mission_template(
    template_id: int,
    template: MissionTemplateUpdate,
    db: Session = Depends(get_db)
):
    """ミッションテンプレートを更新（管理画面用）"""
    db_template = db.query(MissionTemplate).filter(MissionTemplate.id == template_id).first()
    if not db_template:
        raise HTTPException(status_code=404, detail="ミッションテンプレートが見つかりません")
    
    update_data = template.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_template, field, value)
    
    db.commit()
    db.refresh(db_template)
    return db_template


@router.delete("/admin/templates/{template_id}")
def delete_mission_template(
    template_id: int,
    db: Session = Depends(get_db)
):
    """ミッションテンプレートを削除（管理画面用）"""
    db_template = db.query(MissionTemplate).filter(MissionTemplate.id == template_id).first()
    if not db_template:
        raise HTTPException(status_code=404, detail="ミッションテンプレートが見つかりません")
    
    db.delete(db_template)
    db.commit()
    return {"message": "ミッションテンプレートを削除しました"}


@router.get("/admin/statistics", response_model=MissionStatistics)
def get_mission_statistics(db: Session = Depends(get_db)):
    """ミッション統計を取得（管理画面用）"""
    total_missions = db.query(MissionTemplate).count()
    active_missions = db.query(MissionTemplate).filter(MissionTemplate.is_active == True).count()
    daily_missions = db.query(MissionTemplate).filter(MissionTemplate.mission_type == MissionType.DAILY).count()
    weekly_missions = db.query(MissionTemplate).filter(MissionTemplate.mission_type == MissionType.WEEKLY).count()
    achievements = db.query(MissionTemplate).filter(MissionTemplate.mission_type == MissionType.ACHIEVEMENT).count()
    
    # 完了率を計算
    total_player_missions = db.query(PlayerMission).count()
    completed_missions = db.query(PlayerMission).filter(PlayerMission.is_completed == True).count()
    completion_rate = (completed_missions / total_player_missions * 100) if total_player_missions > 0 else 0
    
    return MissionStatistics(
        total_missions=total_missions,
        active_missions=active_missions,
        daily_missions=daily_missions,
        weekly_missions=weekly_missions,
        achievements=achievements,
        completion_rate=completion_rate
    )


# ヘルパー関数
def _get_missions_by_type(db: Session, player_id: UUID, mission_type: MissionType) -> MissionListResponse:
    """指定されたタイプのミッションを取得"""
    # プレイヤーの既存ミッションを取得
    existing_missions = db.query(PlayerMission).join(MissionTemplate).filter(
        and_(
            PlayerMission.player_id == player_id,
            MissionTemplate.mission_type == mission_type
        )
    ).all()
    
    # 新しいミッションを自動生成（デイリー・ウィークリーの場合）
    if mission_type in [MissionType.DAILY, MissionType.WEEKLY]:
        _auto_generate_missions(db, player_id, mission_type)
        # 再取得
        existing_missions = db.query(PlayerMission).join(MissionTemplate).filter(
            and_(
                PlayerMission.player_id == player_id,
                MissionTemplate.mission_type == mission_type
            )
        ).all()
    
    missions = [_convert_to_mission_with_template(mission) for mission in existing_missions]
    
    # 統計情報を計算
    total_missions = len(missions)
    completed_missions = len([m for m in missions if m.is_completed])
    completion_rate = (completed_missions / total_missions * 100) if total_missions > 0 else 0
    
    statistics = MissionStatistics(
        total_missions=total_missions,
        active_missions=len([m for m in missions if not m.is_completed]),
        daily_missions=len(missions) if mission_type == MissionType.DAILY else 0,
        weekly_missions=len(missions) if mission_type == MissionType.WEEKLY else 0,
        achievements=len(missions) if mission_type == MissionType.ACHIEVEMENT else 0,
        completion_rate=completion_rate
    )
    
    return MissionListResponse(missions=missions, statistics=statistics)


def _convert_to_mission_with_template(mission: PlayerMission) -> PlayerMissionWithTemplate:
    """PlayerMissionをPlayerMissionWithTemplateに変換"""
    return PlayerMissionWithTemplate(
        id=mission.id,
        player_id=mission.player_id,
        mission_template_id=mission.mission_template_id,
        current_progress=mission.current_progress,
        is_completed=mission.is_completed,
        is_claimed=mission.is_claimed,
        progress_percentage=mission.progress_percentage,
        created_at=mission.created_at,
        completed_at=mission.completed_at,
        claimed_at=mission.claimed_at,
        expires_at=mission.expires_at,
        mission_template=mission.mission_template,
        can_claim_reward=mission.can_claim_reward(),
        is_ready_to_complete=mission.is_ready_to_complete()
    )


def _auto_generate_missions(db: Session, player_id: UUID, mission_type: MissionType):
    """ミッションを自動生成"""
    # 今日/今週の期間を計算
    now = datetime.utcnow()
    if mission_type == MissionType.DAILY:
        start_time = now.replace(hour=0, minute=0, second=0, microsecond=0)
        end_time = start_time + timedelta(days=1)
    else:  # WEEKLY
        days_since_monday = now.weekday()
        start_time = (now - timedelta(days=days_since_monday)).replace(hour=0, minute=0, second=0, microsecond=0)
        end_time = start_time + timedelta(days=7)
    
    # 既存のミッションをチェック
    existing_missions = db.query(PlayerMission).join(MissionTemplate).filter(
        and_(
            PlayerMission.player_id == player_id,
            MissionTemplate.mission_type == mission_type,
            PlayerMission.created_at >= start_time
        )
    ).count()
    
    if existing_missions > 0:
        return  # 既に生成済み
    
    # アクティブなテンプレートを取得
    templates = db.query(MissionTemplate).filter(
        and_(
            MissionTemplate.mission_type == mission_type,
            MissionTemplate.is_active == True
        )
    ).all()
    
    # プレイヤーミッションを生成
    for template in templates:
        player_mission = PlayerMission(
            player_id=player_id,
            mission_template_id=template.id,
            expires_at=end_time if mission_type != MissionType.ACHIEVEMENT else None
        )
        db.add(player_mission)
    
    db.commit()
