from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, CheckConstraint, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class WeaponMaster(Base):
    __tablename__ = "weapon_masters"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    weapon_type_id = Column(String(20), ForeignKey("weapon_types.id"), nullable=False)
    rarity_id = Column(String(20), ForeignKey("rarity_levels.id"), nullable=False)
    season_id = Column(Integer, ForeignKey("season_masters.id"), nullable=True, comment="所属シーズンID")
    attribute_id = Column(String(20), nullable=True)
    base_attack_min = Column(Integer, nullable=False)
    base_attack_max = Column(Integer, nullable=False)
    enchant_growth_rate = Column(Numeric(4, 2), default=1.00)
    max_enchant_level = Column(Integer, nullable=True)
    image_url = Column(String(255), nullable=True)
    effect_color = Column(String(7), nullable=True)
    description = Column(Text)
    base_price_min = Column(Integer, nullable=False)
    base_price_max = Column(Integer, nullable=False)
    crafting_time_minutes = Column(Integer, default=30)
    required_shop_level = Column(Integer, default=1)
    required_adventurer_level = Column(Integer, default=1)
    drop_rate = Column(Numeric(6, 4), default=0.0)
    is_active = Column(Boolean, default=True)
    is_test_only = Column(Boolean, default=False)
    version = Column(Integer, default=1)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 制約
    __table_args__ = (
        CheckConstraint('base_attack_min > 0', name='weapon_masters_base_attack_min_check'),
        CheckConstraint('base_attack_max >= base_attack_min', name='weapon_masters_attack_check'),
        CheckConstraint('base_price_max >= base_price_min', name='weapon_masters_price_check'),
    )
    
    # リレーションシップ
    weapon_type = relationship("WeaponType", back_populates="weapons")
    rarity = relationship("RarityLevel", back_populates="weapons")
    season = relationship("SeasonMaster", back_populates="weapons")
    crafting_recipes = relationship("CraftingRecipe", back_populates="weapon")
    
    def __repr__(self):
        return f"<WeaponMaster(id={self.id}, name='{self.name}', attack={self.base_attack_min}-{self.base_attack_max})>"
    
    @property
    def base_attack(self):
        """後方互換性のための平均攻撃力"""
        return (self.base_attack_min + self.base_attack_max) // 2
    
    @property
    def base_price(self):
        """後方互換性のための平均価格"""
        return (self.base_price_min + self.base_price_max) // 2
    
    @property
    def calculated_attack(self):
        """レアリティ倍率を適用した攻撃力（最小値）"""
        if self.rarity:
            return int(self.base_attack_min * float(self.rarity.attack_multiplier))
        return self.base_attack_min
    
    @property
    def calculated_price(self):
        """レアリティ倍率を適用した価格（最小値）"""
        if self.rarity:
            return int(self.base_price_min * float(self.rarity.price_multiplier))
        return self.base_price_min
    
    @property
    def required_level(self):
        """Flutter互換性のための必要レベル"""
        return self.required_shop_level
