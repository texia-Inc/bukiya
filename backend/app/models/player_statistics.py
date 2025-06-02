from sqlalchemy import Column, BigInteger, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class PlayerStatistics(Base):
    __tablename__ = "player_statistics"
    
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id", ondelete="CASCADE"), primary_key=True)
    
    # プレイ統計
    total_play_time_seconds = Column(BigInteger, default=0, nullable=False)
    session_count = Column(Integer, default=0, nullable=False)
    last_session_duration = Column(Integer, default=0, nullable=False)
    
    # 経済統計
    total_gold_earned = Column(BigInteger, default=0, nullable=False)
    total_gold_spent = Column(BigInteger, default=0, nullable=False)
    total_gems_purchased = Column(Integer, default=0, nullable=False)
    total_gems_spent = Column(Integer, default=0, nullable=False)
    
    # ゲーム統計
    weapons_crafted = Column(Integer, default=0, nullable=False)
    enchants_attempted = Column(Integer, default=0, nullable=False)
    enchants_succeeded = Column(Integer, default=0, nullable=False)
    trades_completed = Column(Integer, default=0, nullable=False)
    expeditions_sent = Column(Integer, default=0, nullable=False)
    
    # 最高記録
    highest_weapon_attack = Column(Integer, default=0, nullable=False)
    highest_enchant_level = Column(Integer, default=0, nullable=False)
    max_daily_gold = Column(Integer, default=0, nullable=False)
    
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # リレーションシップ
    player = relationship("Player", back_populates="statistics")
    
    def __repr__(self):
        return f"<PlayerStatistics(player_id={self.player_id}, weapons_crafted={self.weapons_crafted})>"
    
    @property
    def enchant_success_rate(self) -> float:
        """エンチャント成功率"""
        if self.enchants_attempted == 0:
            return 0.0
        return self.enchants_succeeded / self.enchants_attempted
    
    @property
    def average_session_duration(self) -> float:
        """平均セッション時間（秒）"""
        if self.session_count == 0:
            return 0.0
        return self.total_play_time_seconds / self.session_count
    
    def add_crafting_stats(self):
        """武器作成統計を更新"""
        self.weapons_crafted += 1
    
    def add_enchant_stats(self, success: bool):
        """エンチャント統計を更新"""
        self.enchants_attempted += 1
        if success:
            self.enchants_succeeded += 1
    
    def add_trade_stats(self):
        """取引統計を更新"""
        self.trades_completed += 1
    
    def add_expedition_stats(self):
        """派遣統計を更新"""
        self.expeditions_sent += 1
    
    def update_highest_weapon_attack(self, attack: int):
        """最高武器攻撃力を更新"""
        if attack > self.highest_weapon_attack:
            self.highest_weapon_attack = attack
    
    def update_highest_enchant_level(self, level: int):
        """最高エンチャントレベルを更新"""
        if level > self.highest_enchant_level:
            self.highest_enchant_level = level
    
    def update_max_daily_gold(self, gold: int):
        """最高日次ゴールドを更新"""
        if gold > self.max_daily_gold:
            self.max_daily_gold = gold
