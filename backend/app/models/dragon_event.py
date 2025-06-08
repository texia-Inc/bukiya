from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text, Float, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from app.core.database import Base
from datetime import datetime
import enum


class DragonEventStatus(enum.Enum):
    SCHEDULED = "scheduled"
    ACTIVE = "active"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class DragonEvent(Base):
    """
    Weekly dragon raid events
    """
    __tablename__ = "dragon_events"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    
    # Dragon stats
    dragon_max_hp = Column(Integer, nullable=False, default=10000)
    dragon_current_hp = Column(Integer, nullable=False)
    dragon_level = Column(Integer, nullable=False, default=1)
    
    # Event timing
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=False)
    status = Column(Enum(DragonEventStatus), default=DragonEventStatus.SCHEDULED)
    
    # Battle mechanics
    battle_duration_minutes = Column(Integer, default=30)  # 30 minute battles
    damage_update_interval = Column(Integer, default=30)  # Update every 30 seconds
    
    # Rewards
    participation_reward_gold = Column(Integer, default=1000)
    victory_bonus_gold = Column(Integer, default=5000)
    mvp_bonus_gold = Column(Integer, default=10000)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    participants = relationship("DragonParticipant", back_populates="event")
    battle_logs = relationship("DragonBattleLog", back_populates="event")


class DragonParticipant(Base):
    """
    Players participating in a dragon event
    """
    __tablename__ = "dragon_participants"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("dragon_events.id"), nullable=False)
    player_id = Column(Integer, ForeignKey("players.id"), nullable=False)
    adventurer_instance_id = Column(Integer, ForeignKey("adventurer_instances.id"), nullable=False)
    
    # Participation stats
    total_damage_dealt = Column(Integer, default=0)
    participation_time = Column(DateTime, default=datetime.utcnow)
    
    # Rewards
    rewards_claimed = Column(Boolean, default=False)
    participation_reward = Column(Integer, default=0)
    victory_bonus = Column(Integer, default=0)
    mvp_bonus = Column(Integer, default=0)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    event = relationship("DragonEvent", back_populates="participants")
    player = relationship("Player")
    adventurer = relationship("AdventurerInstance")


class DragonBattleLog(Base):
    """
    Battle log entries for real-time updates
    """
    __tablename__ = "dragon_battle_logs"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("dragon_events.id"), nullable=False)
    participant_id = Column(Integer, ForeignKey("dragon_participants.id"), nullable=True)
    
    # Battle action details
    action_type = Column(String(50), nullable=False)  # "damage", "special", "heal", "status"
    damage_dealt = Column(Integer, default=0)
    message = Column(Text, nullable=False)
    
    # Dragon state after this action
    dragon_hp_after = Column(Integer, nullable=False)
    
    # Timing
    timestamp = Column(DateTime, default=datetime.utcnow)
    battle_second = Column(Integer, nullable=False)  # Second within the battle
    
    # Relationships
    event = relationship("DragonEvent", back_populates="battle_logs")
    participant = relationship("DragonParticipant")


class DragonEventSchedule(Base):
    """
    Schedule configuration for automatic dragon events
    """
    __tablename__ = "dragon_event_schedules"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    
    # Schedule configuration
    day_of_week = Column(Integer, nullable=False)  # 0=Monday, 6=Sunday
    hour = Column(Integer, nullable=False)  # 0-23
    minute = Column(Integer, nullable=False)  # 0-59
    
    # Dragon configuration template
    dragon_base_hp = Column(Integer, default=10000)
    dragon_level = Column(Integer, default=1)
    battle_duration_minutes = Column(Integer, default=30)
    
    # Reward configuration
    participation_reward = Column(Integer, default=1000)
    victory_bonus = Column(Integer, default=5000)
    mvp_bonus = Column(Integer, default=10000)
    
    # Status
    is_active = Column(Boolean, default=True)
    last_triggered = Column(DateTime)
    next_trigger = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)