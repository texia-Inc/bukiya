from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
from uuid import UUID

class EnchantmentEffectType(str, Enum):
    ATTACK = "attack"
    DEFENSE = "defense"
    SPEED = "speed"
    CRITICAL = "critical"
    ACCURACY = "accuracy"
    DURABILITY = "durability"

class EnchantmentResult(str, Enum):
    SUCCESS = "success"
    FAILURE = "failure"
    DESTROY = "destroy"

class EnchantmentRarity(str, Enum):
    COMMON = "common"
    UNCOMMON = "uncommon"
    RARE = "rare"
    EPIC = "epic"
    LEGENDARY = "legendary"

# エンチャントタイプスキーマ
class EnchantmentTypeBase(BaseModel):
    name: str = Field(..., max_length=100, description="エンチャント名")
    description: Optional[str] = Field(None, description="説明")
    effect_type: EnchantmentEffectType = Field(..., description="効果タイプ")
    effect_value: float = Field(..., gt=0, description="効果値")
    max_level: int = Field(10, ge=1, le=20, description="最大レベル")
    base_success_rate: float = Field(0.8, ge=0.0, le=1.0, description="基本成功率")
    base_cost: int = Field(100, ge=0, description="基本コスト")
    required_materials: Optional[Dict[str, Any]] = Field(None, description="必要素材")
    is_active: bool = Field(True, description="有効フラグ")

class EnchantmentTypeCreate(EnchantmentTypeBase):
    pass

class EnchantmentTypeUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    description: Optional[str] = None
    effect_type: Optional[EnchantmentEffectType] = None
    effect_value: Optional[float] = Field(None, gt=0)
    max_level: Optional[int] = Field(None, ge=1, le=20)
    base_success_rate: Optional[float] = Field(None, ge=0.0, le=1.0)
    base_cost: Optional[int] = Field(None, ge=0)
    required_materials: Optional[Dict[str, Any]] = None
    is_active: Optional[bool] = None

class EnchantmentType(EnchantmentTypeBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# 武器エンチャントスキーマ
class WeaponEnchantmentBase(BaseModel):
    weapon_id: UUID = Field(..., description="武器ID")
    enchantment_type_id: int = Field(..., description="エンチャントタイプID")
    level: int = Field(1, ge=1, description="エンチャントレベル")

class WeaponEnchantmentCreate(WeaponEnchantmentBase):
    pass

class WeaponEnchantmentUpdate(BaseModel):
    level: Optional[int] = Field(None, ge=1)

class WeaponEnchantment(WeaponEnchantmentBase):
    id: int
    success_count: int = Field(0, description="成功回数")
    failure_count: int = Field(0, description="失敗回数")
    total_cost: int = Field(0, description="総コスト")
    created_at: datetime
    updated_at: Optional[datetime] = None
    enchantment_type: Optional[EnchantmentType] = None

    class Config:
        from_attributes = True

# エンチャント実行リクエスト
class EnchantmentRequest(BaseModel):
    weapon_id: UUID = Field(..., description="武器ID")
    enchantment_type_id: int = Field(..., description="エンチャントタイプID")
    use_materials: Optional[List[Dict[str, int]]] = Field(None, description="使用素材")
    use_protection: bool = Field(False, description="保護アイテム使用")

class EnchantmentResponse(BaseModel):
    result: EnchantmentResult = Field(..., description="結果")
    before_level: int = Field(..., description="強化前レベル")
    after_level: int = Field(..., description="強化後レベル")
    cost: int = Field(..., description="コスト")
    success_rate: float = Field(..., description="成功率")
    materials_used: Optional[Dict[str, int]] = Field(None, description="使用素材")
    message: str = Field(..., description="結果メッセージ")

# エンチャント履歴スキーマ
class EnchantmentLogBase(BaseModel):
    player_id: UUID
    weapon_id: UUID
    enchantment_type_id: int
    before_level: int
    after_level: int
    result: EnchantmentResult
    cost: int
    materials_used: Optional[Dict[str, Any]] = None
    success_rate: float

class EnchantmentLogCreate(EnchantmentLogBase):
    pass

class EnchantmentLog(EnchantmentLogBase):
    id: int
    created_at: datetime
    enchantment_type: Optional[EnchantmentType] = None

    class Config:
        from_attributes = True

# エンチャント素材スキーマ
class EnchantmentMaterialBase(BaseModel):
    name: str = Field(..., max_length=100, description="素材名")
    description: Optional[str] = Field(None, description="説明")
    rarity: EnchantmentRarity = Field(EnchantmentRarity.COMMON, description="レアリティ")
    effect_type: Optional[str] = Field(None, max_length=50, description="効果タイプ")
    success_rate_bonus: float = Field(0.0, ge=0.0, le=1.0, description="成功率ボーナス")
    cost_multiplier: float = Field(1.0, gt=0.0, description="コスト倍率")
    max_stack: int = Field(999, ge=1, description="最大所持数")
    is_active: bool = Field(True, description="有効フラグ")

class EnchantmentMaterialCreate(EnchantmentMaterialBase):
    pass

class EnchantmentMaterialUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    description: Optional[str] = None
    rarity: Optional[EnchantmentRarity] = None
    effect_type: Optional[str] = Field(None, max_length=50)
    success_rate_bonus: Optional[float] = Field(None, ge=0.0, le=1.0)
    cost_multiplier: Optional[float] = Field(None, gt=0.0)
    max_stack: Optional[int] = Field(None, ge=1)
    is_active: Optional[bool] = None

class EnchantmentMaterial(EnchantmentMaterialBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# プレイヤーエンチャント素材スキーマ
class PlayerEnchantmentMaterialBase(BaseModel):
    player_id: UUID
    material_id: int
    quantity: int = Field(0, ge=0, description="所持数")

class PlayerEnchantmentMaterialCreate(PlayerEnchantmentMaterialBase):
    pass

class PlayerEnchantmentMaterialUpdate(BaseModel):
    quantity: int = Field(..., ge=0)

class PlayerEnchantmentMaterial(PlayerEnchantmentMaterialBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    material: Optional[EnchantmentMaterial] = None

    class Config:
        from_attributes = True

# エンチャント統計スキーマ
class EnchantmentStats(BaseModel):
    total_enchantments: int = Field(..., description="総エンチャント数")
    success_count: int = Field(..., description="成功回数")
    failure_count: int = Field(..., description="失敗回数")
    destroy_count: int = Field(..., description="破壊回数")
    success_rate: float = Field(..., description="成功率")
    total_cost: int = Field(..., description="総コスト")
    average_level: float = Field(..., description="平均レベル")

# エンチャント一覧レスポンス
class EnchantmentListResponse(BaseModel):
    enchantment_types: List[EnchantmentType]
    materials: List[EnchantmentMaterial]
    player_materials: List[PlayerEnchantmentMaterial]
    stats: Optional[EnchantmentStats] = None

# 管理画面用スキーマ
class AdminEnchantmentTypeListParams(BaseModel):
    page: int = Field(1, ge=1, description="ページ番号")
    limit: int = Field(10, ge=1, le=100, description="取得件数")
    search: Optional[str] = Field(None, description="検索キーワード")
    effect_type: Optional[EnchantmentEffectType] = Field(None, description="効果タイプフィルター")
    is_active: Optional[bool] = Field(None, description="有効フラグフィルター")

class AdminEnchantmentMaterialListParams(BaseModel):
    page: int = Field(1, ge=1, description="ページ番号")
    limit: int = Field(10, ge=1, le=100, description="取得件数")
    search: Optional[str] = Field(None, description="検索キーワード")
    rarity: Optional[EnchantmentRarity] = Field(None, description="レアリティフィルター")
    is_active: Optional[bool] = Field(None, description="有効フラグフィルター")
