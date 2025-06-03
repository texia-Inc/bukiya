from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class BonusType(str, Enum):
    income = "income"
    experience = "experience"
    crafting = "crafting"


class IdleUpgradeBase(BaseModel):
    id: str
    name: str
    description: str
    cost: int
    income_multiplier: float
    level: int
    max_level: int
    icon_name: str
    is_unlocked: bool


class IdleUpgradeResponse(IdleUpgradeBase):
    next_level_cost: int
    is_max_level: bool
    effect_description: str

    class Config:
        from_attributes = True


class IdleBonusBase(BaseModel):
    id: str
    name: str
    description: str
    multiplier: float
    start_time: datetime
    duration_seconds: int
    icon_name: str
    type: BonusType


class IdleBonusResponse(IdleBonusBase):
    is_active: bool
    remaining_seconds: int
    remaining_time_display: str
    effect_description: str

    class Config:
        from_attributes = True


class IdleSystemBase(BaseModel):
    base_income_per_second: int
    current_level: int
    upgrade_count: int
    multiplier: float
    last_collected_at: datetime
    experience: int


class IdleSystemResponse(IdleSystemBase):
    current_income_per_second: int
    pending_income: int
    experience_to_next_level: int
    efficiency_display: str
    available_upgrades: List[IdleUpgradeResponse]
    active_bonuses: List[IdleBonusResponse]

    class Config:
        from_attributes = True


class IdleCollectionResult(BaseModel):
    gold_earned: int
    experience_gained: int
    offline_time_seconds: int
    bonuses_expired: List[str]
    leveled_up: bool
    new_level: int
    offline_time_display: str

    class Config:
        from_attributes = True


class UpgradeRequest(BaseModel):
    upgrade_id: str = Field(..., description="アップグレードID")


class UpgradeResult(BaseModel):
    success: bool
    message: str
    upgraded_item: Optional[IdleUpgradeResponse] = None
    new_gold_amount: int
    new_multiplier: float

    class Config:
        from_attributes = True


class BonusActivationRequest(BaseModel):
    bonus_id: str = Field(..., description="ボーナスID")


class BonusActivationResult(BaseModel):
    success: bool
    message: str
    activated_bonus: Optional[IdleBonusResponse] = None

    class Config:
        from_attributes = True


# 管理画面用のスキーマ
class IdleUpgradeMasterCreate(BaseModel):
    id: str
    name: str
    description: str
    base_cost: int
    income_multiplier: float = 1.1
    max_level: int = 10
    icon_name: str = "upgrade"
    unlock_level: int = 1
    is_active: bool = True


class IdleUpgradeMasterUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    base_cost: Optional[int] = None
    income_multiplier: Optional[float] = None
    max_level: Optional[int] = None
    icon_name: Optional[str] = None
    unlock_level: Optional[int] = None
    is_active: Optional[bool] = None


class IdleUpgradeMasterResponse(BaseModel):
    id: str
    name: str
    description: str
    base_cost: int
    income_multiplier: float
    max_level: int
    icon_name: str
    unlock_level: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class IdleBonusMasterCreate(BaseModel):
    id: str
    name: str
    description: str
    multiplier: float = 2.0
    duration_seconds: int = 3600
    icon_name: str = "bonus"
    bonus_type: BonusType = BonusType.income
    is_active: bool = True


class IdleBonusMasterUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    multiplier: Optional[float] = None
    duration_seconds: Optional[int] = None
    icon_name: Optional[str] = None
    bonus_type: Optional[BonusType] = None
    is_active: Optional[bool] = None


class IdleBonusMasterResponse(BaseModel):
    id: str
    name: str
    description: str
    multiplier: float
    duration_seconds: int
    icon_name: str
    bonus_type: BonusType
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class PlayerIdleSystemResponse(BaseModel):
    id: int
    player_id: str
    base_income_per_second: int
    current_level: int
    upgrade_count: int
    multiplier: float
    last_collected_at: datetime
    experience: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
