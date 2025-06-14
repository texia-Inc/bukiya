from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, Float, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class RarityLevel(Base):
    __tablename__ = "rarity_levels"
    
    id = Column(String(20), primary_key=True)
    name = Column(String(50), nullable=False)
    level = Column(Integer, nullable=False)
    color_code = Column(String(7))
    star_display = Column(String(10))
    attack_multiplier = Column(Numeric(3,2), default=1.00)
    max_enchant_level = Column(Integer, default=10)
    ability_slots = Column(Integer, default=0)
    base_drop_rate = Column(Numeric(6,4), default=0.6000)
    price_multiplier = Column(Numeric(3,2), default=1.00)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーションシップ
    weapons = relationship("WeaponMaster", back_populates="rarity")
    materials = relationship("MaterialMaster", back_populates="rarity")
    
    def __repr__(self):
        return f"<RarityLevel(id={self.id}, name='{self.name}', attack_multiplier={self.attack_multiplier})>"
