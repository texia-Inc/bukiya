from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field
from uuid import UUID

from .common import BaseResponse, PaginatedResponse

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
    updated_at: datetime

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
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# 武器マスタースキーマ
class WeaponMasterBase(BaseModel):
    name: str = Field(..., max_length=100, description="武器名")
    description: Optional[str] = Field(None, description="説明")
    weapon_type_id: str = Field(..., description="武器種別ID")
    rarity_id: int = Field(..., description="レアリティID")
    base_attack: int = Field(..., gt=0, description="基本攻撃力")
    base_price: int = Field(..., ge=0, description="基本価格")
    required_level: int = Field(1, ge=1, description="必要レベル")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")
    is_craftable: bool = Field(True, description="合成可能フラグ")

class WeaponMasterCreate(WeaponMasterBase):
    pass

class WeaponMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="武器名")
    description: Optional[str] = Field(None, description="説明")
    weapon_type_id: Optional[str] = Field(None, description="武器種別ID")
    rarity_id: Optional[int] = Field(None, description="レアリティID")
    base_attack: Optional[int] = Field(None, gt=0, description="基本攻撃力")
    base_price: Optional[int] = Field(None, ge=0, description="基本価格")
    required_level: Optional[int] = Field(None, ge=1, description="必要レベル")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")
    is_craftable: Optional[bool] = Field(None, description="合成可能フラグ")
    is_active: Optional[bool] = Field(None, description="有効フラグ")

class WeaponMaster(WeaponMasterBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    weapon_type: WeaponType
    rarity: RarityLevel
    calculated_attack: int = Field(..., description="レアリティ倍率適用後攻撃力")
    calculated_price: int = Field(..., description="レアリティ倍率適用後価格")

    class Config:
        from_attributes = True

# プレイヤー武器スキーマ
class PlayerWeaponBase(BaseModel):
    weapon_master_id: int = Field(..., description="武器マスターID")
    attack: int = Field(..., gt=0, description="攻撃力")
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
    is_equipped: bool
    created_at: datetime
    updated_at: datetime
    weapon_master: WeaponMaster
    display_name: str = Field(..., description="表示名")
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
