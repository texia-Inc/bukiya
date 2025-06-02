from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

from ..core.database import Base

class AdventurerMaster(Base):
    __tablename__ = "adventurer_masters"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    profession = Column(String(50), nullable=False)  # warrior, archer, mage, rogue, paladin
    level = Column(Integer, nullable=False, default=1)
    personality = Column(String(50), nullable=False)  # generous, normal, stingy, wealthy, poor
    trust_level = Column(Integer, nullable=False, default=50)  # 0-100
    budget_min = Column(Integer, nullable=False, default=500)
    budget_max = Column(Integer, nullable=False, default=2000)
    preferred_weapon_type = Column(String(50), nullable=False)
    avatar_url = Column(String(255), nullable=True)
    description = Column(Text, nullable=True)
    
    # 要求パターン設定
    min_attack_requirement = Column(Integer, nullable=False, default=100)
    max_budget_multiplier = Column(Float, nullable=False, default=1.0)
    urgency_tendency = Column(Integer, nullable=False, default=3)  # 1-5
    
    # 出現設定
    spawn_weight = Column(Integer, nullable=False, default=100)  # 出現確率の重み
    min_player_level = Column(Integer, nullable=False, default=1)
    max_player_level = Column(Integer, nullable=True)
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<AdventurerMaster(id={self.id}, name='{self.name}', profession='{self.profession}')>"

class MonsterMaster(Base):
    __tablename__ = "monster_masters"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    monster_type = Column(String(50), nullable=False)  # beast, undead, dragon, elemental, etc.
    level = Column(Integer, nullable=False, default=1)
    hp = Column(Integer, nullable=False, default=100)
    attack = Column(Integer, nullable=False, default=50)
    defense = Column(Integer, nullable=False, default=20)
    
    # 属性
    element = Column(String(50), nullable=True)  # fire, ice, thunder, earth, wind
    weakness = Column(String(50), nullable=True)
    resistance = Column(String(50), nullable=True)
    
    # 出現設定
    spawn_areas = Column(String(255), nullable=False)  # カンマ区切りのエリアID
    spawn_weight = Column(Integer, nullable=False, default=100)
    min_required_weapon_level = Column(Integer, nullable=False, default=0)
    
    # 報酬設定
    base_gold_reward = Column(Integer, nullable=False, default=100)
    experience_reward = Column(Integer, nullable=False, default=50)
    
    # 見た目
    image_url = Column(String(255), nullable=True)
    description = Column(Text, nullable=True)
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<MonsterMaster(id={self.id}, name='{self.name}', level={self.level})>"

class QuestAreaMaster(Base):
    __tablename__ = "quest_area_masters"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    area_type = Column(String(50), nullable=False)  # forest, cave, mountain, ruins, etc.
    difficulty = Column(Integer, nullable=False, default=1)  # 1-5
    required_level = Column(Integer, nullable=False, default=1)
    duration_minutes = Column(Integer, nullable=False, default=60)
    
    # 見た目
    image_url = Column(String(255), nullable=True)
    background_color = Column(String(7), nullable=False, default="#4CAF50")
    description = Column(Text, nullable=True)
    
    # 解放条件
    unlock_condition = Column(String(255), nullable=True)  # JSON形式の条件
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    display_order = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<QuestAreaMaster(id={self.id}, name='{self.name}', difficulty={self.difficulty})>"

class MonsterDropTable(Base):
    __tablename__ = "monster_drop_tables"

    id = Column(Integer, primary_key=True, index=True)
    monster_id = Column(Integer, nullable=False, index=True)
    item_type = Column(String(50), nullable=False)  # material, weapon
    item_id = Column(Integer, nullable=False)
    drop_rate = Column(Float, nullable=False, default=0.1)  # 0.0-1.0
    min_quantity = Column(Integer, nullable=False, default=1)
    max_quantity = Column(Integer, nullable=False, default=1)
    
    # 条件
    required_weapon_enchant = Column(Integer, nullable=False, default=0)
    required_adventurer_level = Column(Integer, nullable=False, default=1)
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    def __repr__(self):
        return f"<MonsterDropTable(monster_id={self.monster_id}, item_type='{self.item_type}', drop_rate={self.drop_rate})>"
