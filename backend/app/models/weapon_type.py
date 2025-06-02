from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class WeaponType(Base):
    __tablename__ = "weapon_types"
    
    id = Column(String(20), primary_key=True)
    name = Column(String(50), unique=True, nullable=False)
    description = Column(Text)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーションシップ
    weapons = relationship("WeaponMaster", back_populates="weapon_type")
    
    def __repr__(self):
        return f"<WeaponType(id={self.id}, name='{self.name}')>"
