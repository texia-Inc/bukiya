from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
import uuid
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class PlayerMission(Base):
    """プレイヤーミッション進捗モデル"""
    __tablename__ = "player_missions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False, comment="プレイヤーID")
    mission_template_id = Column(Integer, ForeignKey("mission_templates.id"), nullable=False, comment="ミッションテンプレートID")
    
    # 進捗情報
    current_progress = Column(Integer, nullable=False, default=0, comment="現在の進捗")
    is_completed = Column(Boolean, nullable=False, default=False, comment="完了フラグ")
    is_claimed = Column(Boolean, nullable=False, default=False, comment="報酬受取フラグ")
    
    # タイムスタンプ
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="作成日時")
    completed_at = Column(DateTime(timezone=True), nullable=True, comment="完了日時")
    claimed_at = Column(DateTime(timezone=True), nullable=True, comment="報酬受取日時")
    expires_at = Column(DateTime(timezone=True), nullable=True, comment="有効期限")
    
    # リレーション
    player = relationship("Player", back_populates="missions")
    mission_template = relationship("MissionTemplate")

    def __repr__(self):
        return f"<PlayerMission(id={self.id}, player_id={self.player_id}, progress={self.current_progress})>"

    @property
    def progress_percentage(self) -> float:
        """進捗率を計算"""
        if not self.mission_template or self.mission_template.target_count == 0:
            return 0.0
        return min(100.0, (self.current_progress / self.mission_template.target_count) * 100)

    def is_ready_to_complete(self) -> bool:
        """完了可能かチェック"""
        if not self.mission_template:
            return False
        return self.current_progress >= self.mission_template.target_count and not self.is_completed

    def can_claim_reward(self) -> bool:
        """報酬受取可能かチェック"""
        return self.is_completed and not self.is_claimed


class MissionProgressLog(Base):
    """ミッション進捗ログモデル"""
    __tablename__ = "mission_progress_logs"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False, comment="プレイヤーID")
    mission_id = Column(UUID(as_uuid=True), ForeignKey("player_missions.id"), nullable=False, comment="プレイヤーミッションID")
    
    # ログ情報
    action_type = Column(String(50), nullable=False, comment="アクションタイプ")
    progress_delta = Column(Integer, nullable=False, default=1, comment="進捗増加量")
    extra_data = Column(String(500), nullable=True, comment="追加情報（JSON文字列）")
    
    # タイムスタンプ
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="作成日時")
    
    # リレーション
    player = relationship("Player")
    mission = relationship("PlayerMission")

    def __repr__(self):
        return f"<MissionProgressLog(id={self.id}, action='{self.action_type}', delta={self.progress_delta})>"
