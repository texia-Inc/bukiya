from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class PlayerMaterial(Base):
    __tablename__ = "player_materials"
    
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="CASCADE"), primary_key=True)
    material_master_id = Column(String(50), primary_key=True, nullable=False)  # String in database
    quantity = Column(Integer, default=0, nullable=False)
    total_acquired = Column(Integer, default=0)
    total_used = Column(Integer, default=0)
    last_acquired_at = Column(DateTime(timezone=True))
    
    # 制約
    __table_args__ = (
        CheckConstraint('quantity >= 0', name='player_materials_quantity_check'),
    )
    
    # リレーションシップ
    player = relationship("Player", back_populates="materials")
    # material = relationship("MaterialMaster", back_populates="player_materials")  # Temporarily disabled due to type mismatch
    
    def __repr__(self):
        return f"<PlayerMaterial(player_id={self.player_id}, material_id='{self.material_master_id}', quantity={self.quantity})>"
    
    def add_quantity(self, amount: int):
        """素材を追加"""
        self.quantity += amount
        return amount
    
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
        """スタック上限に達しているかチェック（仮実装）"""
        return self.quantity >= 999  # 仮の上限値
    
    @property
    def remaining_capacity(self):
        """残りスタック容量（仮実装）"""
        return max(0, 999 - self.quantity)  # 仮の上限値
