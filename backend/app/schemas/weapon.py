from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field
from uuid import UUID

from .common import BaseResponse, PaginatedResponse
from .season import Season

# 武器種別スキーマ
class WeaponTypeBase(BaseModel):
    name: str = Field(..., max_length=50, description="武器種別名")
    description: Optional[str] = Field(None, description="説明")

class WeaponTypeCreate(WeaponTypeBase):
    pass

class WeaponTypeUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=50, description="武器種別名")
    description: Optional[str] = Field(None, description="説明")
    is_active: Optional[bool] = Field(None, description="有効フラグ")

class WeaponType(WeaponTypeBase):
    id: str
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# レアリティレベルスキーマ
class RarityLevelBase(BaseModel):
    name: str = Field(..., max_length=50, description="レアリティ名")
    description: Optional[str] = Field(None, description="説明")
    color_code: Optional[str] = Field(None, max_length=7, description="カラーコード")
    multiplier: float = Field(1.0, ge=0.1, le=10.0, description="攻撃力倍率")
    drop_rate: float = Field(1.0, ge=0.0, le=100.0, description="ドロップ率")

class RarityLevelCreate(RarityLevelBase):
    pass

class RarityLevelUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=50, description="レアリティ名")
    description: Optional[str] = Field(None, description="説明")
    color_code: Optional[str] = Field(None, max_length=7, description="カラーコード")
    multiplier: Optional[float] = Field(None, ge=0.1, le=10.0, description="攻撃力倍率")
    drop_rate: Optional[float] = Field(None, ge=0.0, le=100.0, description="ドロップ率")
    is_active: Optional[bool] = Field(None, description="有効フラグ")

class RarityLevel(RarityLevelBase):
    id: str
    level: int
    star_display: Optional[str] = None
    attack_multiplier: float = 1.00
    max_enchant_level: int = 10
    ability_slots: int = 0
    base_drop_rate: float = 0.6000
    price_multiplier: float = 1.00
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True

# 武器マスタースキーマ
class WeaponMasterBase(BaseModel):
    name: str = Field(..., max_length=100, description="武器名")
    weapon_type_id: str = Field(..., description="武器種別ID")
    rarity_id: str = Field(..., description="レアリティID")
    season_id: Optional[int] = Field(None, description="シーズンID")
    attribute_id: Optional[str] = Field(None, description="属性ID")
    base_attack_min: int = Field(..., gt=0, description="基本攻撃力最小値")
    base_attack_max: int = Field(..., gt=0, description="基本攻撃力最大値")
    enchant_growth_rate: Optional[float] = Field(1.00, description="エンチャント成長率")
    max_enchant_level: Optional[int] = Field(None, description="最大エンチャントレベル")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")
    effect_color: Optional[str] = Field(None, max_length=7, description="エフェクト色")
    description: Optional[str] = Field(None, description="説明")
    base_price_min: int = Field(..., ge=0, description="基本価格最小値")
    base_price_max: int = Field(..., ge=0, description="基本価格最大値")
    crafting_time_minutes: Optional[int] = Field(30, description="作成時間（分）")
    required_shop_level: Optional[int] = Field(1, description="必要ショップレベル")
    required_adventurer_level: Optional[int] = Field(1, description="必要冒険者レベル")
    drop_rate: Optional[float] = Field(0.0, description="ドロップ率")
    is_test_only: Optional[bool] = Field(False, description="テスト専用フラグ")

class WeaponMasterCreate(WeaponMasterBase):
    pass

class WeaponMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="武器名")
    description: Optional[str] = Field(None, description="説明")
    weapon_type_id: Optional[str] = Field(None, description="武器種別ID")
    rarity_id: Optional[str] = Field(None, description="レアリティID")
    season_id: Optional[int] = Field(None, description="シーズンID")
    attribute_id: Optional[str] = Field(None, description="属性ID")
    base_attack_min: Optional[int] = Field(None, gt=0, description="基本攻撃力最小値")
    base_attack_max: Optional[int] = Field(None, gt=0, description="基本攻撃力最大値")
    base_price_min: Optional[int] = Field(None, ge=0, description="基本価格最小値")
    base_price_max: Optional[int] = Field(None, ge=0, description="基本価格最大値")
    enchant_growth_rate: Optional[float] = Field(None, description="エンチャント成長率")
    max_enchant_level: Optional[int] = Field(None, description="最大エンチャントレベル")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")
    effect_color: Optional[str] = Field(None, max_length=7, description="エフェクト色")
    crafting_time_minutes: Optional[int] = Field(None, description="作成時間（分）")
    required_shop_level: Optional[int] = Field(None, description="必要ショップレベル")
    required_adventurer_level: Optional[int] = Field(None, description="必要冒険者レベル")
    drop_rate: Optional[float] = Field(None, description="ドロップ率")
    is_active: Optional[bool] = Field(None, description="有効フラグ")
    is_test_only: Optional[bool] = Field(None, description="テスト専用フラグ")
    version: Optional[int] = Field(None, description="バージョン")

class WeaponMaster(WeaponMasterBase):
    id: int
    season_id: Optional[int] = Field(None, description="シーズンID")
    attribute_id: Optional[str] = Field(None, description="属性ID")
    enchant_growth_rate: Optional[float] = Field(None, description="エンチャント成長率")
    max_enchant_level: Optional[int] = Field(None, description="最大エンチャントレベル")
    image_url: Optional[str] = Field(None, description="画像URL")
    effect_color: Optional[str] = Field(None, description="エフェクト色")
    required_adventurer_level: Optional[int] = Field(None, description="必要冒険者レベル")
    drop_rate: Optional[float] = Field(None, description="ドロップ率")
    is_active: bool
    is_test_only: Optional[bool] = Field(None, description="テスト専用フラグ")
    version: Optional[int] = Field(None, description="バージョン")
    created_at: datetime
    updated_at: datetime
    weapon_type: WeaponType
    rarity: RarityLevel
    season: Optional[Season] = Field(None, description="所属シーズン")
    base_attack: int = Field(..., description="平均攻撃力（後方互換性）")
    base_price: int = Field(..., description="平均価格（後方互換性）")
    calculated_attack: int = Field(..., description="レアリティ倍率適用後攻撃力")
    calculated_price: int = Field(..., description="レアリティ倍率適用後価格")
    required_level: int = Field(..., description="必要レベル（Flutter互換性）")

    class Config:
        from_attributes = True

# プレイヤー武器スキーマ
class PlayerWeaponBase(BaseModel):
    weapon_master_id: int = Field(..., description="武器マスターID")  # Convert to int for Flutter compatibility
    base_attack: int = Field(..., gt=0, description="基本攻撃力")
    enchant_level: int = Field(0, ge=0, description="エンチャントレベル")
    custom_name: Optional[str] = Field(None, max_length=100, description="カスタム名")

class PlayerWeaponCreate(PlayerWeaponBase):
    pass

class PlayerWeaponUpdate(BaseModel):
    custom_name: Optional[str] = Field(None, max_length=100, description="カスタム名")
    is_equipped: Optional[bool] = Field(None, description="装備フラグ")

class PlayerWeapon(PlayerWeaponBase):
    id: UUID
    player_id: UUID
    current_durability: Optional[int] = Field(None, description="現在の耐久度")
    max_durability: Optional[int] = Field(None, description="最大耐久度")
    abilities: Optional[str] = Field(None, description="特殊能力")
    is_favorite: Optional[bool] = Field(None, description="お気に入りフラグ")
    acquired_at: Optional[datetime] = Field(None, description="取得日時")
    last_used_at: Optional[datetime] = Field(None, description="最終使用日時")
    is_equipped: bool = Field(False, description="装備フラグ")
    is_locked: Optional[bool] = Field(None, description="ロックフラグ")
    weapon_master: Optional[WeaponMaster] = Field(None, description="武器マスター情報")
    display_name: Optional[str] = Field(None, description="表示名")
    total_attack: int = Field(..., description="エンチャント込み総攻撃力")

    class Config:
        from_attributes = True

# エンチャント関連
class EnchantRequest(BaseModel):
    weapon_id: UUID = Field(..., description="武器ID")

class EnchantResult(BaseModel):
    success: bool = Field(..., description="成功フラグ")
    new_level: int = Field(..., description="新しいエンチャントレベル")
    new_attack: int = Field(..., description="新しい攻撃力")
    message: str = Field(..., description="結果メッセージ")

# レスポンススキーマ
class WeaponTypeResponse(BaseResponse[WeaponType]):
    pass

class WeaponTypeListResponse(BaseResponse[List[WeaponType]]):
    pass

class RarityLevelResponse(BaseResponse[RarityLevel]):
    pass

class RarityLevelListResponse(BaseResponse[List[RarityLevel]]):
    pass

class WeaponMasterResponse(BaseResponse[WeaponMaster]):
    pass

class WeaponMasterListResponse(PaginatedResponse[WeaponMaster]):
    pass

class PlayerWeaponResponse(BaseResponse[PlayerWeapon]):
    pass

class PlayerWeaponListResponse(BaseResponse[List[PlayerWeapon]]):
    pass

class EnchantResponse(BaseResponse[EnchantResult]):
    pass
