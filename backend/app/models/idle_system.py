from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime

from ..core.database import Base


class PlayerIdleSystem(Base):
    """プレイヤーの放置システム情報"""
    __tablename__ = "player_idle_systems"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False, unique=True)
    base_income_per_second = Column(Integer, default=1)
    current_level = Column(Integer, default=1)
    upgrade_count = Column(Integer, default=0)
    multiplier = Column(Float, default=1.0)
    last_collected_at = Column(DateTime, default=datetime.utcnow)
    experience = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # リレーション
    player = relationship("Player", back_populates="idle_system")
    upgrades = relationship("PlayerIdleUpgrade", back_populates="idle_system")
    bonuses = relationship("PlayerIdleBonus", back_populates="idle_system")

    @property
    def current_income_per_second(self):
        """現在の1秒あたりの収益を計算"""
        income = self.base_income_per_second * self.multiplier
        
        # アクティブボーナスを適用
        for bonus in self.bonuses:
            if bonus.is_active:
                income *= bonus.multiplier
        
        return int(income)

    @property
    def pending_income(self):
        """最後の回収から現在までの収益を計算"""
        now = datetime.utcnow()
        duration_seconds = (now - self.last_collected_at).total_seconds()
        return int(self.current_income_per_second * duration_seconds)

    @property
    def experience_to_next_level(self):
        """次のレベルまでの必要経験値"""
        return self.current_level * 100

    def can_level_up(self):
        """レベルアップ可能かチェック"""
        return self.experience >= self.experience_to_next_level

    def level_up(self):
        """レベルアップを実行"""
        if self.can_level_up():
            self.experience -= self.experience_to_next_level
            self.current_level += 1
            # レベルアップ時に基本収益を増加
            self.base_income_per_second += 1
            return True
        return False


class IdleUpgradeMaster(Base):
    """放置システムアップグレードマスター"""
    __tablename__ = "idle_upgrade_masters"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    base_cost = Column(Integer, nullable=False)
    income_multiplier = Column(Float, default=1.1)
    max_level = Column(Integer, default=10)
    icon_name = Column(String, default="upgrade")
    unlock_level = Column(Integer, default=1)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # リレーション
    player_upgrades = relationship("PlayerIdleUpgrade", back_populates="upgrade_master")

    def get_cost_for_level(self, level):
        """指定レベルでのコスト計算"""
        return int(self.base_cost * (1.5 ** level))


class PlayerIdleUpgrade(Base):
    """プレイヤーの放置システムアップグレード"""
    __tablename__ = "player_idle_upgrades"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False)
    idle_system_id = Column(Integer, ForeignKey("player_idle_systems.id"), nullable=False)
    upgrade_id = Column(String, ForeignKey("idle_upgrade_masters.id"), nullable=False)
    level = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # リレーション
    player = relationship("Player")
    idle_system = relationship("PlayerIdleSystem", back_populates="upgrades")
    upgrade_master = relationship("IdleUpgradeMaster", back_populates="player_upgrades")

    @property
    def is_max_level(self):
        """最大レベルかチェック"""
        return self.level >= self.upgrade_master.max_level

    @property
    def next_level_cost(self):
        """次のレベルのコスト"""
        if self.is_max_level:
            return 0
        return self.upgrade_master.get_cost_for_level(self.level + 1)

    def can_upgrade(self, player_gold):
        """アップグレード可能かチェック"""
        return not self.is_max_level and player_gold >= self.next_level_cost


class IdleBonusMaster(Base):
    """放置システムボーナスマスター"""
    __tablename__ = "idle_bonus_masters"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    multiplier = Column(Float, default=2.0)
    duration_seconds = Column(Integer, default=3600)  # 1時間
    icon_name = Column(String, default="bonus")
    bonus_type = Column(String, default="income")  # income, experience, crafting
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # リレーション
    player_bonuses = relationship("PlayerIdleBonus", back_populates="bonus_master")


class PlayerIdleBonus(Base):
    """プレイヤーの放置システムボーナス"""
    __tablename__ = "player_idle_bonuses"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False)
    idle_system_id = Column(Integer, ForeignKey("player_idle_systems.id"), nullable=False)
    bonus_id = Column(String, ForeignKey("idle_bonus_masters.id"), nullable=False)
    start_time = Column(DateTime, default=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)

    # リレーション
    player = relationship("Player")
    idle_system = relationship("PlayerIdleSystem", back_populates="bonuses")
    bonus_master = relationship("IdleBonusMaster", back_populates="player_bonuses")

    @property
    def end_time(self):
        """ボーナス終了時刻"""
        from datetime import timedelta
        return self.start_time + timedelta(seconds=self.bonus_master.duration_seconds)

    @property
    def is_active(self):
        """ボーナスがアクティブかチェック"""
        now = datetime.utcnow()
        return now < self.end_time

    @property
    def remaining_seconds(self):
        """残り時間（秒）"""
        if not self.is_active:
            return 0
        now = datetime.utcnow()
        return int((self.end_time - now).total_seconds())

    @property
    def multiplier(self):
        """ボーナス倍率"""
        return self.bonus_master.multiplier if self.is_active else 1.0
