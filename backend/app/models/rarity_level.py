from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class RarityLevel(Base):
    __tablename__ = "rarity_levels"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(50), unique=True, nullable=False)
    description = Column(Text)
    color_code = Column(String(7))  # HEXカラーコード (#FFFFFF)
    multiplier = Column(Float, default=1.0, nullable=False)  # 攻撃力倍率
    drop_rate = Column(Float, default=1.0, nullable=False)  # ドロップ率
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーションシップ
    weapons = relationship("WeaponMaster", back_populates="rarity")
    materials = relationship("MaterialMaster", back_populates="rarity")
    
    def __repr__(self):
        return f"<RarityLevel(id={self.id}, name='{self.name}', multiplier={self.multiplier})>"
