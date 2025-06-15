from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base

class PlayerWeapon(Base):
    __tablename__ = "player_weapons"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="CASCADE"), nullable=False)
    weapon_master_id = Column(String(50), nullable=False)  # String in database, foreign key removed for now
    base_attack = Column(Integer, nullable=False)
    enchant_level = Column(Integer, default=0, nullable=False)
    current_durability = Column(Integer, default=100)
    max_durability = Column(Integer, default=100)
    abilities = Column(String)  # JSONB in database
    custom_name = Column(String(100))  # プレイヤーが付けたカスタム名
    is_favorite = Column(Boolean, default=False)
    acquired_at = Column(DateTime(timezone=True), server_default=func.now())
    last_used_at = Column(DateTime(timezone=True))
    is_equipped = Column(Boolean, default=False, nullable=False)
    is_locked = Column(Boolean, default=False)
    
    # 制約（データベースの実際の制約に合わせる）
    __table_args__ = (
        CheckConstraint('enchant_level >= 0', name='player_weapons_enchant_level_check'),
        CheckConstraint('current_durability >= 0', name='player_weapons_current_durability_check'),
        CheckConstraint('current_durability <= max_durability', name='player_weapons_durability_check'),
        CheckConstraint('max_durability > 0', name='player_weapons_max_durability_check'),
    )
    
    # リレーションシップ
    player = relationship("Player", back_populates="weapons")
    # weapon_master = relationship("WeaponMaster", back_populates="player_weapons")  # Temporarily disabled due to type mismatch
    enchantments = relationship("WeaponEnchantment", back_populates="weapon", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<PlayerWeapon(id={self.id}, weapon_master_id='{self.weapon_master_id}', base_attack={self.base_attack})>"
    
    @property
    def display_name(self):
        """表示名（カスタム名があればそれを、なければマスター名を返す）"""
        if self.custom_name:
            return self.custom_name
        # return self.weapon_master.name if self.weapon_master else "Unknown Weapon"
        return f"Weapon {self.weapon_master_id}"  # Temporary fallback
    
    @property
    def total_attack(self):
        """エンチャントレベルを含む総攻撃力"""
        enchant_bonus = self.enchant_level * 5  # エンチャント1レベルあたり+5攻撃力
        return self.base_attack + enchant_bonus
    
    def can_enchant(self):
        """エンチャント可能かチェック（最大レベル10）"""
        return self.enchant_level < 10
    
    def enchant_success_rate(self):
        """エンチャント成功率を計算"""
        base_rate = 0.8  # 基本成功率80%
        level_penalty = self.enchant_level * 0.05  # レベルが上がるごとに5%減少
        return max(0.1, base_rate - level_penalty)  # 最低10%
