"""
冒険者インスタンスモデル
"""
from sqlalchemy import Column, String, Integer, Float, Boolean, ForeignKey, DateTime, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from ..core.database import Base

class AdventurerInstance(Base):
    """冒険者インスタンス"""
    __tablename__ = "adventurer_instances"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_master_id = Column(Integer, ForeignKey("adventurer_masters.id"), nullable=True)  # Allow NULL for named characters
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="SET NULL"))
    name = Column(String(100), nullable=False)
    level = Column(Integer, nullable=False, default=1)
    trust_level = Column(Integer, nullable=False, default=0)
    status = Column(String(20), nullable=False, default="idle")  # idle, visiting, on_quest, waiting_buyback
    current_quest_id = Column(UUID(as_uuid=True))
    visit_start_time = Column(DateTime(timezone=True))
    visit_end_time = Column(DateTime(timezone=True))
    
    # 新しいキャラクターシステムとの連携
    is_named_character = Column(Boolean, default=False)  # 固有キャラクターかどうか
    character_id = Column(Integer, ForeignKey("adventurer_characters.id"))  # 固有キャラクターID
    generic_name = Column(String(100))  # 名前なしキャラクター用の汎用名前
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーション
    adventurer_master = relationship("AdventurerMaster", lazy="joined")
    character = relationship("AdventurerCharacter", back_populates="adventurer_instances")  # 新しいキャラクターシステム
    player = relationship("Player", back_populates="adventurers")
    requests = relationship("AdventurerRequest", back_populates="adventurer", cascade="all, delete-orphan")
    quests = relationship("AdventurerQuest", back_populates="adventurer", cascade="all, delete-orphan")
    purchases = relationship("AdventurerPurchase", back_populates="adventurer", cascade="all, delete-orphan")
    
    @property
    def display_name(self):
        """表示用の名前を取得（キャラクターシステム対応）"""
        if self.is_named_character and self.character:
            return self.character.display_name
        elif self.generic_name:
            return self.generic_name
        else:
            # フォールバック：職業名ベースの汎用名前を生成
            if self.adventurer_master:
                profession_names = {
                    'warrior': '戦士',
                    'archer': '弓使い', 
                    'mage': '魔法使い',
                    'rogue': '盗賊',
                    'paladin': '聖騎士'
                }
                profession = profession_names.get(self.adventurer_master.profession, '冒険者')
                return f"訪問中の{profession}"
            return self.name


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
    monster_id = Column(Integer, ForeignKey("monster_masters.id"))  # 戦闘するモンスター
    target_material_id = Column(Integer, ForeignKey("material_masters.id"))  # 狙い素材
    target_material_boost = Column(Float, default=1.0)  # ドロップ率倍率
    target_cost = Column(Integer, default=0)  # ターゲティングコスト
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
    monster = relationship("MonsterMaster", lazy="joined")  # 戦闘するモンスター
    target_material = relationship("MaterialMaster", lazy="joined")  # 狙い素材
    rewards = relationship("QuestReward", back_populates="quest", cascade="all, delete-orphan")


class QuestReward(Base):
    """クエスト報酬"""
    __tablename__ = "quest_rewards"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    adventurer_quest_id = Column(UUID(as_uuid=True), ForeignKey("adventurer_quests.id", ondelete="CASCADE"), nullable=False)
    item_type = Column(String(20), nullable=False)  # material, weapon
    item_id = Column(String(50), nullable=True)  # NULL for gold rewards, string for material/weapon IDs
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
    weapon_id = Column(UUID(as_uuid=True), ForeignKey("player_weapons.id"), nullable=False)
    purchase_price = Column(Integer, nullable=False)
    purchased_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # リレーション
    adventurer = relationship("AdventurerInstance", back_populates="purchases")
    player_weapon = relationship("PlayerWeapon")