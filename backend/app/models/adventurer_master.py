from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean, Numeric
from sqlalchemy.dialects.postgresql import UUID
import uuid
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

from ..core.database import Base

class AreaMaster(Base):
    __tablename__ = "area_masters"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    required_shop_level = Column(Integer, default=1)
    required_adventurer_level = Column(Integer, default=1)
    base_expedition_time_minutes = Column(Integer, default=60)
    danger_level = Column(Integer, default=1)
    background_image = Column(String(255))
    theme_color = Column(String(7))
    is_active = Column(Boolean, default=True)
    display_order = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<AreaMaster(id={self.id}, name='{self.name}', danger_level={self.danger_level})>"

class AdventurerMaster(Base):
    __tablename__ = "adventurer_masters"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
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
    
    # 難易度ティア設定（プログレッション用）
    tier = Column(String(20), nullable=False, default="normal")  # normal, challenge, elite
    progression_multiplier = Column(Float, nullable=False, default=1.0)  # 報酬倍率
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<AdventurerMaster(id={self.id}, name='{self.name}', profession='{self.profession}')>"

class MonsterMaster(Base):
    __tablename__ = "monster_masters"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    name = Column(String(100), nullable=False, index=True)
    monster_type = Column(String(50), nullable=False, default="beast")
    level = Column(Integer, nullable=False, default=1)
    hp = Column(Integer, nullable=False)
    attack = Column(Integer, nullable=False)
    defense = Column(Integer, nullable=False)
    speed = Column(Integer, default=100)
    attribute_id = Column(String(20))
    element = Column(String(50), nullable=True)
    weakness = Column(String(50), nullable=True)
    resistance = Column(String(50), nullable=True)
    spawn_areas = Column(String(255), nullable=True)
    spawn_weight = Column(Integer, default=100)
    min_required_weapon_level = Column(Integer, default=0)
    base_gold_reward = Column(Integer, default=100)
    experience_reward = Column(Integer, default=50)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

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

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    monster_master_id = Column(Integer, nullable=False, index=True)
    drop_type = Column(String(50), nullable=False)  # material, weapon
    drop_target_id = Column(String(50), nullable=True)  # NULL for gold drops
    drop_rate = Column(Numeric(precision=10, scale=4), nullable=False, default=0.1)
    quantity_min = Column(Integer, nullable=False, default=1)
    quantity_max = Column(Integer, nullable=False, default=1)
    required_weapon_type = Column(String(50), nullable=True)
    bonus_rate = Column(Numeric(precision=10, scale=4), nullable=False, default=0.0)
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    # Property aliases for backward compatibility
    @property
    def monster_id(self):
        return self.monster_master_id
    
    @property
    def item_type(self):
        return self.drop_type
    
    @property
    def item_id(self):
        return self.drop_target_id

    def __repr__(self):
        return f"<MonsterDropTable(monster_id={self.monster_master_id}, item_type='{self.drop_type}', drop_rate={self.drop_rate})>"
