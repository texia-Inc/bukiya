from sqlalchemy import Column, String, BigInteger, Integer, Boolean, Text, DateTime, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base

class Player(Base):
    __tablename__ = "players"
    
    # 基本情報
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    
    # ゲーム進捗
    gold = Column(BigInteger, default=1000, nullable=False)
    gems = Column(Integer, default=50, nullable=False)
    shop_level = Column(Integer, default=1, nullable=False)
    reputation = Column(Integer, default=1, nullable=False)
    
    # メタデータ
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), server_default=func.now())
    
    # 管理フラグ
    is_active = Column(Boolean, default=True, nullable=False)
    is_banned = Column(Boolean, default=False, nullable=False)
    ban_reason = Column(Text)
    banned_at = Column(DateTime(timezone=True))
    ban_expires_at = Column(DateTime(timezone=True))
    
    # 制約
    __table_args__ = (
        CheckConstraint('gold >= 0', name='players_gold_check'),
        CheckConstraint('gems >= 0', name='players_gems_check'),
        CheckConstraint('shop_level >= 1', name='players_shop_level_check'),
        CheckConstraint('reputation >= 0', name='players_reputation_check'),
        CheckConstraint('length(username) >= 3', name='players_username_check'),
    )
    
    # リレーションシップ
    statistics = relationship("PlayerStatistics", back_populates="player", uselist=False)
    weapons = relationship("PlayerWeapon", back_populates="player")
    materials = relationship("PlayerMaterial", back_populates="player")
    missions = relationship("PlayerMission", back_populates="player")
    idle_system = relationship("PlayerIdleSystem", back_populates="player", uselist=False)
    
    def __repr__(self):
        return f"<Player(id={self.id}, username='{self.username}', shop_level={self.shop_level})>"
    
    @property
    def total_weapons(self):
        """所持武器数"""
        return len(self.weapons)
    
    @property
    def total_materials(self):
        """所持素材種類数"""
        return len([m for m in self.materials if m.quantity > 0])
    
    def can_afford(self, cost: int) -> bool:
        """指定されたゴールドを支払えるかチェック"""
        return self.gold >= cost
    
    def spend_gold(self, amount: int) -> bool:
        """ゴールドを消費（残高不足の場合はFalse）"""
        if not self.can_afford(amount):
            return False
        self.gold -= amount
        return True
    
    def add_gold(self, amount: int):
        """ゴールドを追加"""
        self.gold += amount
    
    def can_afford_gems(self, cost: int) -> bool:
        """指定されたジェムを支払えるかチェック"""
        return self.gems >= cost
    
    def spend_gems(self, amount: int) -> bool:
        """ジェムを消費（残高不足の場合はFalse）"""
        if not self.can_afford_gems(amount):
            return False
        self.gems -= amount
        return True
    
    def add_gems(self, amount: int):
        """ジェムを追加"""
        self.gems += amount
