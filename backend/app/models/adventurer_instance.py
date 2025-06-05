"""
冒険者インスタンスモデル
"""
from sqlalchemy import Column, String, Integer, Float, Boolean, ForeignKey, DateTime, Text, UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from ..core.database import Base

class AdventurerInstance(Base):
    """冒険者インスタンス"""
    __tablename__ = "adventurer_instances"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_master_id = Column(Integer, ForeignKey("adventurer_masters.id"), nullable=False)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="SET NULL"))
    name = Column(String(100), nullable=False)
    level = Column(Integer, nullable=False, default=1)
    trust_level = Column(Integer, nullable=False, default=0)
    status = Column(String(20), nullable=False, default="idle")  # idle, visiting, on_quest, waiting_buyback
    current_quest_id = Column(UUID(as_uuid=True))
    visit_start_time = Column(DateTime(timezone=True))
    visit_end_time = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    adventurer_master = relationship("AdventurerMaster", lazy="joined")
    player = relationship("Player", back_populates="adventurers")
    requests = relationship("AdventurerRequest", back_populates="adventurer", cascade="all, delete-orphan")
    quests = relationship("AdventurerQuest", back_populates="adventurer", cascade="all, delete-orphan")
    purchases = relationship("AdventurerPurchase", back_populates="adventurer", cascade="all, delete-orphan")


class AdventurerRequest(Base):
    """冒険者の武器リクエスト"""
    __tablename__ = "adventurer_requests"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_instance_id = Column(UUID(as_uuid=True), ForeignKey("adventurer_instances.id", ondelete="CASCADE"), nullable=False)
    weapon_type = Column(String(50), nullable=False)
    min_attack = Column(Integer, nullable=False)
    max_budget = Column(Integer, nullable=False)
    preferred_rarity = Column(String(20))
    urgency = Column(Integer, nullable=False, default=3)  # 1-5の緊急度
    description = Column(Text)
    deadline = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(20), nullable=False, default="pending")  # pending, fulfilled, expired
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    adventurer = relationship("AdventurerInstance", back_populates="requests")


class AdventurerQuest(Base):
    """冒険者のクエスト履歴"""
    __tablename__ = "adventurer_quests"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_instance_id = Column(UUID(as_uuid=True), ForeignKey("adventurer_instances.id", ondelete="CASCADE"), nullable=False)
    quest_area_id = Column(Integer, ForeignKey("quest_area_masters.id"), nullable=False)
    player_weapon_id = Column(UUID(as_uuid=True), ForeignKey("player_weapons.id"))
    status = Column(String(20), nullable=False, default="in_progress")  # in_progress, completed, failed
    start_time = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    end_time = Column(DateTime(timezone=True))
    success = Column(Boolean)
    gold_earned = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    adventurer = relationship("AdventurerInstance", back_populates="quests")
    quest_area = relationship("QuestAreaMaster", lazy="joined")
    player_weapon = relationship("PlayerWeapon")
    rewards = relationship("QuestReward", back_populates="quest", cascade="all, delete-orphan")


class QuestReward(Base):
    """クエスト報酬"""
    __tablename__ = "quest_rewards"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_quest_id = Column(UUID(as_uuid=True), ForeignKey("adventurer_quests.id", ondelete="CASCADE"), nullable=False)
    item_type = Column(String(20), nullable=False)  # material, weapon
    item_id = Column(String(50), nullable=False)
    quantity = Column(Integer, nullable=False, default=1)
    buyback_price = Column(Integer)
    buyback_deadline = Column(DateTime(timezone=True))
    is_bought = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    quest = relationship("AdventurerQuest", back_populates="rewards")


class AdventurerPurchase(Base):
    """冒険者の武器購入履歴"""
    __tablename__ = "adventurer_purchases"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_instance_id = Column(UUID(as_uuid=True), ForeignKey("adventurer_instances.id", ondelete="CASCADE"), nullable=False)
    player_weapon_id = Column(UUID(as_uuid=True), ForeignKey("player_weapons.id"), nullable=False)
    price = Column(Integer, nullable=False)
    purchased_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    adventurer = relationship("AdventurerInstance", back_populates="purchases")
    player_weapon = relationship("PlayerWeapon")