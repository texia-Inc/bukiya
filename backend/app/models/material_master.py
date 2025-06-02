from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class MaterialMaster(Base):
    __tablename__ = "material_masters"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    rarity_id = Column(Integer, ForeignKey("rarity_levels.id"), nullable=False)
    base_price = Column(Integer, nullable=False)
    max_stack = Column(Integer, default=999, nullable=False)
    image_url = Column(String(255))
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 制約
    __table_args__ = (
        CheckConstraint('base_price >= 0', name='material_master_base_price_check'),
        CheckConstraint('max_stack > 0', name='material_master_max_stack_check'),
    )
    
    # リレーションシップ
    rarity = relationship("RarityLevel", back_populates="materials")
    player_materials = relationship("PlayerMaterial", back_populates="material")
    recipe_materials = relationship("RecipeMaterial", back_populates="material")
    
    def __repr__(self):
        return f"<MaterialMaster(id={self.id}, name='{self.name}', price={self.base_price})>"
    
    @property
    def calculated_price(self):
        """レアリティ倍率を適用した価格"""
        if self.rarity:
            return int(self.base_price * self.rarity.multiplier)
        return self.base_price
