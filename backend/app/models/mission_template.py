from sqlalchemy import Column, Integer, String, Boolean, DateTime, JSON, Text
from sqlalchemy.sql import func
from app.core.database import Base


class MissionTemplate(Base):
    """ミッションテンプレートモデル"""
    __tablename__ = "mission_templates"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, comment="ミッション名")
    description = Column(Text, nullable=False, comment="ミッション説明")
    mission_type = Column(String(20), nullable=False, comment="ミッションタイプ: daily, weekly, achievement")
    target_type = Column(String(50), nullable=False, comment="目標タイプ: craft_weapon, sell_weapon, collect_material, dispatch_adventurer, login")
    target_count = Column(Integer, nullable=False, default=1, comment="目標数")
    target_conditions = Column(JSON, nullable=True, comment="追加条件（武器タイプ、レアリティなど）")
    
    # 報酬設定
    reward_gold = Column(Integer, nullable=False, default=0, comment="報酬ゴールド")
    reward_exp = Column(Integer, nullable=False, default=0, comment="報酬経験値")
    reward_items = Column(JSON, nullable=True, comment="報酬アイテム")
    
    # 設定
    is_active = Column(Boolean, nullable=False, default=True, comment="有効フラグ")
    reset_schedule = Column(String(20), nullable=True, comment="リセットスケジュール: daily, weekly, none")
    required_level = Column(Integer, nullable=False, default=1, comment="必要プレイヤーレベル")
    display_order = Column(Integer, nullable=False, default=0, comment="表示順序")
    
    # タイムスタンプ
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="作成日時")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="更新日時")

    def __repr__(self):
        return f"<MissionTemplate(id={self.id}, name='{self.name}', type='{self.mission_type}')>"
