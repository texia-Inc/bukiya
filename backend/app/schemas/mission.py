from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field
from enum import Enum
from uuid import UUID


class MissionType(str, Enum):
    """ミッションタイプ"""
    DAILY = "daily"
    WEEKLY = "weekly"
    ACHIEVEMENT = "achievement"


class TargetType(str, Enum):
    """目標タイプ"""
    CRAFT_WEAPON = "craft_weapon"
    SELL_WEAPON = "sell_weapon"
    COLLECT_MATERIAL = "collect_material"
    DISPATCH_ADVENTURER = "dispatch_adventurer"
    LOGIN = "login"
    EARN_GOLD = "earn_gold"
    UPGRADE_SHOP = "upgrade_shop"


class ResetSchedule(str, Enum):
    """リセットスケジュール"""
    DAILY = "daily"
    WEEKLY = "weekly"
    NONE = "none"


# ミッションテンプレート関連スキーマ
class MissionTemplateBase(BaseModel):
    """ミッションテンプレート基底スキーマ"""
    name: str = Field(..., min_length=1, max_length=100, description="ミッション名")
    description: str = Field(..., min_length=1, description="ミッション説明")
    mission_type: MissionType = Field(..., description="ミッションタイプ")
    target_type: TargetType = Field(..., description="目標タイプ")
    target_count: int = Field(..., ge=1, description="目標数")
    target_conditions: Optional[Dict[str, Any]] = Field(None, description="追加条件")
    reward_gold: int = Field(0, ge=0, description="報酬ゴールド")
    reward_exp: int = Field(0, ge=0, description="報酬経験値")
    reward_items: Optional[Dict[str, Any]] = Field(None, description="報酬アイテム")
    is_active: bool = Field(True, description="有効フラグ")
    reset_schedule: Optional[ResetSchedule] = Field(None, description="リセットスケジュール")
    required_level: int = Field(1, ge=1, description="必要プレイヤーレベル")
    display_order: int = Field(0, ge=0, description="表示順序")


class MissionTemplateCreate(MissionTemplateBase):
    """ミッションテンプレート作成スキーマ"""
    pass


class MissionTemplateUpdate(BaseModel):
    """ミッションテンプレート更新スキーマ"""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    description: Optional[str] = Field(None, min_length=1)
    mission_type: Optional[MissionType] = None
    target_type: Optional[TargetType] = None
    target_count: Optional[int] = Field(None, ge=1)
    target_conditions: Optional[Dict[str, Any]] = None
    reward_gold: Optional[int] = Field(None, ge=0)
    reward_exp: Optional[int] = Field(None, ge=0)
    reward_items: Optional[Dict[str, Any]] = None
    is_active: Optional[bool] = None
    reset_schedule: Optional[ResetSchedule] = None
    required_level: Optional[int] = Field(None, ge=1)
    display_order: Optional[int] = Field(None, ge=0)


class MissionTemplateResponse(MissionTemplateBase):
    """ミッションテンプレート応答スキーマ"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# プレイヤーミッション関連スキーマ
class PlayerMissionBase(BaseModel):
    """プレイヤーミッション基底スキーマ"""
    current_progress: int = Field(0, ge=0, description="現在の進捗")
    is_completed: bool = Field(False, description="完了フラグ")
    is_claimed: bool = Field(False, description="報酬受取フラグ")


class PlayerMissionCreate(BaseModel):
    """プレイヤーミッション作成スキーマ"""
    player_id: UUID
    mission_template_id: int


class PlayerMissionUpdate(BaseModel):
    """プレイヤーミッション更新スキーマ"""
    current_progress: Optional[int] = Field(None, ge=0)
    is_completed: Optional[bool] = None
    is_claimed: Optional[bool] = None


class PlayerMissionResponse(PlayerMissionBase):
    """プレイヤーミッション応答スキーマ"""
    id: int
    player_id: UUID
    mission_template_id: int
    progress_percentage: float = Field(..., description="進捗率")
    created_at: datetime
    completed_at: Optional[datetime] = None
    claimed_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    mission_template: MissionTemplateResponse

    class Config:
        from_attributes = True


class PlayerMissionWithTemplate(PlayerMissionResponse):
    """ミッションテンプレート情報付きプレイヤーミッション"""
    can_claim_reward: bool = Field(..., description="報酬受取可能フラグ")
    is_ready_to_complete: bool = Field(..., description="完了可能フラグ")


# ミッション進捗ログ関連スキーマ
class MissionProgressLogBase(BaseModel):
    """ミッション進捗ログ基底スキーマ"""
    action_type: str = Field(..., min_length=1, max_length=50, description="アクションタイプ")
    progress_delta: int = Field(1, ge=1, description="進捗増加量")
    extra_data: Optional[str] = Field(None, max_length=500, description="追加情報")


class MissionProgressLogCreate(MissionProgressLogBase):
    """ミッション進捗ログ作成スキーマ"""
    player_id: UUID
    mission_id: int


class MissionProgressLogResponse(MissionProgressLogBase):
    """ミッション進捗ログ応答スキーマ"""
    id: int
    player_id: UUID
    mission_id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ミッション報酬受取スキーマ
class MissionRewardClaim(BaseModel):
    """ミッション報酬受取スキーマ"""
    mission_id: int = Field(..., description="ミッションID")


class MissionRewardClaimResponse(BaseModel):
    """ミッション報酬受取応答スキーマ"""
    success: bool = Field(..., description="成功フラグ")
    message: str = Field(..., description="メッセージ")
    rewards: Dict[str, Any] = Field(..., description="受取った報酬")


# ミッション統計スキーマ
class MissionStatistics(BaseModel):
    """ミッション統計スキーマ"""
    total_missions: int = Field(..., description="総ミッション数")
    active_missions: int = Field(..., description="有効ミッション数")
    daily_missions: int = Field(..., description="デイリーミッション数")
    weekly_missions: int = Field(..., description="ウィークリーミッション数")
    achievements: int = Field(..., description="アチーブメント数")
    completion_rate: float = Field(..., description="完了率")


# ミッション一覧応答スキーマ
class MissionListResponse(BaseModel):
    """ミッション一覧応答スキーマ"""
    missions: List[PlayerMissionWithTemplate] = Field(..., description="ミッション一覧")
    statistics: MissionStatistics = Field(..., description="統計情報")
