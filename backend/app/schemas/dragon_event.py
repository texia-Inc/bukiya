from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import List, Optional
from enum import Enum


class DragonEventStatus(str, Enum):
    SCHEDULED = "scheduled"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class DragonEventBase(BaseModel):
    name: str
    description: Optional[str] = None
    dragon_max_hp: int = 10000
    dragon_level: int = 1
    start_time: datetime
    end_time: datetime
    battle_duration_minutes: int = 30
    damage_update_interval: int = 30
    participation_reward_gold: int = 1000
    victory_bonus_gold: int = 5000
    mvp_bonus_gold: int = 10000


class DragonEventCreate(DragonEventBase):
    pass


class DragonEventUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    dragon_current_hp: Optional[int] = None
    status: Optional[DragonEventStatus] = None


class DragonParticipantBase(BaseModel):
    player_id: int
    adventurer_instance_id: int


class DragonParticipantCreate(DragonParticipantBase):
    pass


class DragonParticipant(DragonParticipantBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    event_id: int
    total_damage_dealt: int = 0
    participation_time: datetime
    rewards_claimed: bool = False
    participation_reward: int = 0
    victory_bonus: int = 0
    mvp_bonus: int = 0
    created_at: datetime


class DragonBattleLogBase(BaseModel):
    action_type: str
    damage_dealt: int = 0
    message: str
    dragon_hp_after: int
    battle_second: int


class DragonBattleLogCreate(DragonBattleLogBase):
    event_id: int
    participant_id: Optional[int] = None


class DragonBattleLog(DragonBattleLogBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    event_id: int
    participant_id: Optional[int] = None
    timestamp: datetime


class DragonEvent(DragonEventBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    dragon_current_hp: int
    status: DragonEventStatus
    created_at: datetime
    updated_at: datetime
    participants: List[DragonParticipant] = []


class DragonEventSummary(BaseModel):
    """Lightweight summary for event lists"""
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    name: str
    dragon_max_hp: int
    dragon_current_hp: int
    status: DragonEventStatus
    start_time: datetime
    end_time: datetime
    participant_count: int = 0
    is_victory: bool = False


class DragonBattleState(BaseModel):
    """Real-time battle state"""
    event_id: int
    dragon_current_hp: int
    dragon_max_hp: int
    hp_percentage: float
    time_remaining_seconds: int
    participant_count: int
    total_damage_dealt: int
    is_active: bool
    recent_logs: List[DragonBattleLog] = []


class DragonParticipationRequest(BaseModel):
    adventurer_instance_id: int


class DragonRewardsResponse(BaseModel):
    participation_reward: int
    victory_bonus: int
    mvp_bonus: int
    total_reward: int
    is_mvp: bool
    rank: int
    total_damage: int


class DragonEventStatsResponse(BaseModel):
    """Event statistics and leaderboard"""
    event: DragonEvent
    total_participants: int
    total_damage_dealt: int
    top_participants: List[dict]  # [{"player_name": str, "damage": int, "rank": int}]
    is_victory: bool
    mvp_player_name: Optional[str] = None