from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class EnchantmentType(Base):
    """エンチャントタイプマスター"""
    __tablename__ = "enchantment_types"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, comment="エンチャント名")
    description = Column(Text, comment="説明")
    effect_type = Column(String(50), nullable=False, comment="効果タイプ (attack, defense, speed, etc.)")
    effect_value = Column(Float, nullable=False, comment="効果値")
    max_level = Column(Integer, default=10, comment="最大レベル")
    base_success_rate = Column(Float, default=0.8, comment="基本成功率")
    base_cost = Column(Integer, default=100, comment="基本コスト")
    required_materials = Column(JSON, comment="必要素材")
    is_active = Column(Boolean, default=True, comment="有効フラグ")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # リレーション
    weapon_enchantments = relationship("WeaponEnchantment", back_populates="enchantment_type")

class WeaponEnchantment(Base):
    """武器エンチャント"""
    __tablename__ = "weapon_enchantments"

    id = Column(Integer, primary_key=True, index=True)
    weapon_id = Column(UUID(as_uuid=True), ForeignKey("player_weapons.id"), nullable=False)
    enchantment_type_id = Column(Integer, ForeignKey("enchantment_types.id"), nullable=False)
    level = Column(Integer, default=1, comment="エンチャントレベル")
    success_count = Column(Integer, default=0, comment="成功回数")
    failure_count = Column(Integer, default=0, comment="失敗回数")
    total_cost = Column(Integer, default=0, comment="総コスト")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # リレーション
    weapon = relationship("PlayerWeapon", back_populates="enchantments")
    enchantment_type = relationship("EnchantmentType", back_populates="weapon_enchantments")

class EnchantmentLog(Base):
    """エンチャント履歴"""
    __tablename__ = "enchantment_logs"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False)
    weapon_id = Column(UUID(as_uuid=True), ForeignKey("player_weapons.id"), nullable=False)
    enchantment_type_id = Column(Integer, ForeignKey("enchantment_types.id"), nullable=False)
    before_level = Column(Integer, nullable=False, comment="強化前レベル")
    after_level = Column(Integer, nullable=False, comment="強化後レベル")
    result = Column(String(20), nullable=False, comment="結果 (success, failure, destroy)")
    cost = Column(Integer, nullable=False, comment="コスト")
    materials_used = Column(JSON, comment="使用素材")
    success_rate = Column(Float, nullable=False, comment="成功率")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # リレーション
    player = relationship("Player")
    weapon = relationship("PlayerWeapon")
    enchantment_type = relationship("EnchantmentType")

class EnchantmentMaterial(Base):
    """エンチャント素材マスター"""
    __tablename__ = "enchantment_materials"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, comment="素材名")
    description = Column(Text, comment="説明")
    rarity = Column(String(20), default="common", comment="レアリティ")
    effect_type = Column(String(50), comment="効果タイプ")
    success_rate_bonus = Column(Float, default=0.0, comment="成功率ボーナス")
    cost_multiplier = Column(Float, default=1.0, comment="コスト倍率")
    max_stack = Column(Integer, default=999, comment="最大所持数")
    is_active = Column(Boolean, default=True, comment="有効フラグ")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class PlayerEnchantmentMaterial(Base):
    """プレイヤーエンチャント素材"""
    __tablename__ = "player_enchantment_materials"

    id = Column(Integer, primary_key=True, index=True)
    player_id = Column(UUID(as_uuid=True), ForeignKey("players.id"), nullable=False)
    material_id = Column(Integer, ForeignKey("enchantment_materials.id"), nullable=False)
    quantity = Column(Integer, default=0, comment="所持数")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # リレーション
    player = relationship("Player")
    material = relationship("EnchantmentMaterial")

    # ユニーク制約
    __table_args__ = (
        {"mysql_engine": "InnoDB", "mysql_charset": "utf8mb4"},
    )
