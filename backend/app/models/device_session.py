from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base

class DeviceSession(Base):
    """
    デバイスセッション管理テーブル
    ゲームアプリの永続ログインとデバイス管理を行う
    """
    __tablename__ = "device_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    device_id = Column(String(255), nullable=False, unique=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=True)
    
    # デバイス情報
    device_name = Column(String(255), nullable=True)
    device_model = Column(String(255), nullable=True)
    platform = Column(String(50), nullable=True)  # iOS, Android, etc
    platform_version = Column(String(50), nullable=True)
    app_version = Column(String(50), nullable=True)
    
    # セッション管理
    is_active = Column(Boolean, default=True, nullable=False)
    is_trusted = Column(Boolean, default=False, nullable=False)
    last_used_at = Column(DateTime(timezone=True), server_default=func.now())
    expires_at = Column(DateTime(timezone=True), nullable=True)
    
    # セキュリティ
    ip_address = Column(String(45), nullable=True)  # IPv6対応
    user_agent = Column(Text, nullable=True)
    refresh_token_hash = Column(String(255), nullable=True)  # リフレッシュトークンのハッシュ
    
    # タイムスタンプ
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # リレーションシップ
    player = relationship("Player", back_populates="device_sessions")

    def __repr__(self):
        return f"<DeviceSession(device_id='{self.device_id}', player_id='{self.player_id}', is_active={self.is_active})>"

    def is_expired(self) -> bool:
        """デバイスセッションが期限切れかどうかを確認"""
        if self.expires_at is None:
            return False
        from datetime import datetime
        return datetime.utcnow() > self.expires_at

    def update_last_used(self):
        """最終使用時刻を更新"""
        from datetime import datetime
        self.last_used_at = datetime.utcnow()

    def revoke(self):
        """デバイスセッションを無効化"""
        self.is_active = False
        self.refresh_token_hash = None