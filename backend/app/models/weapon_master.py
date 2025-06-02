from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class WeaponMaster(Base):
    __tablename__ = "weapon_masters"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    weapon_type_id = Column(String(20), ForeignKey("weapon_types.id"), nullable=False)
    rarity_id = Column(Integer, ForeignKey("rarity_levels.id"), nullable=False)
    base_attack = Column(Integer, nullable=False)
    base_price = Column(Integer, nullable=False)
    required_level = Column(Integer, default=1, nullable=False)
    image_url = Column(String(255))
    is_craftable = Column(Boolean, default=True, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 制約
    __table_args__ = (
        CheckConstraint('base_attack > 0', name='weapon_master_base_attack_check'),
        CheckConstraint('base_price >= 0', name='weapon_master_base_price_check'),
        CheckConstraint('required_level >= 1', name='weapon_master_required_level_check'),
    )
    
    # リレーションシップ
    weapon_type = relationship("WeaponType", back_populates="weapons")
    rarity = relationship("RarityLevel", back_populates="weapons")
    player_weapons = relationship("PlayerWeapon", back_populates="weapon_master")
    crafting_recipes = relationship("CraftingRecipe", back_populates="weapon")
    
    def __repr__(self):
        return f"<WeaponMaster(id={self.id}, name='{self.name}', attack={self.base_attack})>"
    
    @property
    def calculated_attack(self):
        """レアリティ倍率を適用した攻撃力"""
        if self.rarity:
            return int(self.base_attack * self.rarity.multiplier)
        return self.base_attack
    
    @property
    def calculated_price(self):
        """レアリティ倍率を適用した価格"""
        if self.rarity:
            return int(self.base_price * self.rarity.multiplier)
        return self.base_price
