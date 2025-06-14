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
    shop_exp = Column(Integer, default=0, nullable=False)  # ショップレベル経験値
    reputation = Column(Integer, default=1, nullable=False)
    
    # 放置収入システム
    idle_income_rate = Column(Integer, default=10, nullable=False)  # ゴールド/分
    idle_income_multiplier = Column(Integer, default=100, nullable=False)  # 1.00倍を100で表現
    last_idle_collection_time = Column(DateTime(timezone=True), server_default=func.now())
    
    # 訪問者スポーン制御
    last_visitor_spawn_time = Column(DateTime(timezone=True))
    
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
        CheckConstraint('shop_exp >= 0', name='players_shop_exp_check'),
        CheckConstraint('reputation >= 0', name='players_reputation_check'),
        CheckConstraint('length(username) >= 3', name='players_username_check'),
    )
    
    # リレーションシップ
    statistics = relationship("PlayerStatistics", back_populates="player", uselist=False)
    weapons = relationship("PlayerWeapon", back_populates="player")
    materials = relationship("PlayerMaterial", back_populates="player")
    missions = relationship("PlayerMission", back_populates="player")
    idle_system = relationship("PlayerIdleSystem", back_populates="player", uselist=False)
    adventurers = relationship("AdventurerInstance", back_populates="player")
    
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

    def add_shop_exp(self, amount: int) -> bool:
        """ショップ経験値を追加し、レベルアップしたらTrueを返す"""
        self.shop_exp += amount
        return self.check_shop_level_up()

    def check_shop_level_up(self) -> bool:
        """ショップレベルアップをチェックし、必要に応じてレベルアップ"""
        required_exp = self.calculate_required_shop_exp(self.shop_level)
        if self.shop_exp >= required_exp:
            self.shop_level += 1
            self.shop_exp -= required_exp  # 余った経験値は次のレベルに持ち越し
            return True
        return False

    def calculate_required_shop_exp(self, level: int) -> int:
        """指定レベルからの次レベルに必要な経験値を計算"""
        # レベル1→2: 100exp, レベル2→3: 150exp, レベル3→4: 200exp...
        # 計算式: 50 + (level * 50)
        return 50 + (level * 50)

    @property
    def next_level_exp_required(self) -> int:
        """次のレベルまでに必要な経験値"""
        required = self.calculate_required_shop_exp(self.shop_level)
        return max(0, required - self.shop_exp)

    @property
    def shop_level_progress_percentage(self) -> float:
        """現在レベルでの進捗率（0.0-1.0）"""
        required = self.calculate_required_shop_exp(self.shop_level)
        if required == 0:
            return 1.0
        return min(1.0, self.shop_exp / required)

    def calculate_idle_income(self, current_time=None) -> tuple:
        """放置収入を計算し、(獲得ゴールド, 経過分数)を返す"""
        from datetime import datetime, timezone
        
        if current_time is None:
            current_time = datetime.now(timezone.utc)
        
        last_collection = self.last_idle_collection_time
        if last_collection is None:
            last_collection = self.created_at
        
        # 経過時間（分）- 最大12時間（720分）まで
        elapsed_seconds = (current_time - last_collection).total_seconds()
        elapsed_minutes = min(720, elapsed_seconds / 60)
        
        if elapsed_minutes <= 0:
            return 0, 0
        
        # 収入計算
        base_rate = self.idle_income_rate  # 10ゴールド/分
        level_bonus = 1.0 + (self.shop_level * 0.2)  # レベル補正（+20%/レベル）
        multiplier = self.idle_income_multiplier / 100.0  # 施設補正（100 = 1.00倍）
        
        total_income = int(elapsed_minutes * base_rate * level_bonus * multiplier)
        return total_income, int(elapsed_minutes)

    def collect_idle_income(self, current_time=None) -> tuple:
        """放置収入を回収し、(獲得ゴールド, 経過分数)を返す"""
        from datetime import datetime, timezone
        
        if current_time is None:
            current_time = datetime.now(timezone.utc)
        
        income, elapsed_minutes = self.calculate_idle_income(current_time)
        
        if income > 0:
            self.add_gold(income)
            self.last_idle_collection_time = current_time
        
        return income, elapsed_minutes

    @property
    def idle_income_multiplier_display(self) -> float:
        """施設補正の表示用（1.00倍形式）"""
        return self.idle_income_multiplier / 100.0

    def can_spawn_visitors(self, current_time=None) -> tuple:
        """訪問者をスポーンできるかチェックし、(可能フラグ, 残り分数)を返す"""
        import random
        from datetime import datetime, timezone
        
        if current_time is None:
            current_time = datetime.now(timezone.utc)
        
        # 初回スポーンは常に可能
        if self.last_visitor_spawn_time is None:
            return True, 0
        
        # 経過時間を計算
        elapsed_seconds = (current_time - self.last_visitor_spawn_time).total_seconds()
        elapsed_minutes = elapsed_seconds / 60
        
        # クールダウン時間を計算（緩和版）
        base_cooldown = random.randint(10, 30)  # 10-30分のランダム（従来30-90分から短縮）
        level_reduction = min(10, self.shop_level * 1)  # レベル補正（最大10分短縮、レベル×1分）
        required_cooldown = max(5, base_cooldown - level_reduction)  # 最低5分（従来15分から短縮）
        
        if elapsed_minutes >= required_cooldown:
            return True, 0
        else:
            remaining_minutes = int(required_cooldown - elapsed_minutes)
            return False, remaining_minutes

    def update_last_visitor_spawn_time(self, current_time=None):
        """最終訪問者スポーン時間を更新"""
        from datetime import datetime, timezone
        
        if current_time is None:
            current_time = datetime.now(timezone.utc)
        
        self.last_visitor_spawn_time = current_time

    def force_spawn_with_gems(self, gem_cost: int = 100) -> bool:
        """ジェムを消費して強制的に訪問者をスポーン可能にする"""
        if not self.can_afford_gems(gem_cost):
            return False
        
        self.spend_gems(gem_cost)
        # クールダウンをリセット（過去の時刻に設定）
        from datetime import datetime, timezone, timedelta
        self.last_visitor_spawn_time = datetime.now(timezone.utc) - timedelta(hours=2)
        return True

    # リレーションシップ
    device_sessions = relationship("DeviceSession", back_populates="player", cascade="all, delete-orphan")
