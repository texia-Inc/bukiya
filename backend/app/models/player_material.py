from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class PlayerMaterial(Base):
    __tablename__ = "player_materials"
    
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="CASCADE"), primary_key=True)
    material_master_id = Column(Integer, ForeignKey("material_masters.id"), primary_key=True, nullable=False)
    quantity = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 制約
    __table_args__ = (
        CheckConstraint('quantity >= 0', name='player_materials_quantity_check'),
    )
    
    # リレーションシップ
    player = relationship("Player", back_populates="materials")
    material = relationship("MaterialMaster", back_populates="player_materials")
    
    def __repr__(self):
        return f"<PlayerMaterial(player_id={self.player_id}, material='{self.material.name if self.material else 'Unknown'}', quantity={self.quantity})>"
    
    def add_quantity(self, amount: int):
        """素材を追加（スタック上限チェック付き）"""
        if self.material:
            max_add = min(amount, self.material.stack_size - self.quantity)
            self.quantity += max_add
            return max_add
        return 0
    
    def remove_quantity(self, amount: int):
        """素材を消費"""
        if self.quantity >= amount:
            self.quantity -= amount
            return True
        return False
    
    def can_remove(self, amount: int):
        """指定数量を消費できるかチェック"""
        return self.quantity >= amount
    
    @property
    def is_full(self):
        """スタック上限に達しているかチェック"""
        if self.material:
            return self.quantity >= self.material.stack_size
        return False
    
    @property
    def remaining_capacity(self):
        """残りスタック容量"""
        if self.material:
            return self.material.stack_size - self.quantity
        return 0
