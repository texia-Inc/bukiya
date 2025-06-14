from sqlalchemy import Column, Integer, String, Text, Date, Boolean, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class SeasonMaster(Base):
    __tablename__ = "season_masters"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False, index=True, comment="シーズン名")
    description = Column(Text, nullable=True, comment="シーズンの説明")
    start_date = Column(Date, nullable=False, comment="開始日")
    end_date = Column(Date, nullable=True, comment="終了日")
    display_order = Column(Integer, nullable=False, default=1, comment="表示順序")
    is_active = Column(Boolean, default=True, nullable=False, comment="有効フラグ")
    created_at = Column(DateTime(timezone=True), server_default=func.now(), comment="作成日時")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), comment="更新日時")

    # リレーションシップ
    weapons = relationship("WeaponMaster", back_populates="season")

    def __repr__(self):
        return f"<SeasonMaster(id={self.id}, name='{self.name}', start_date='{self.start_date}')>"