from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field
from uuid import UUID

from .common import BaseResponse, PaginatedResponse
from .weapon import RarityLevel

# 素材マスタースキーマ
class MaterialMasterBase(BaseModel):
    name: str = Field(..., max_length=100, description="素材名")
    description: Optional[str] = Field(None, description="説明")
    rarity_id: int = Field(..., description="レアリティID")
    base_price: int = Field(..., ge=0, description="基本価格")
    max_stack: int = Field(999, gt=0, description="最大スタック数")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")

class MaterialMasterCreate(MaterialMasterBase):
    pass

class MaterialMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="素材名")
    description: Optional[str] = Field(None, description="説明")
    rarity_id: Optional[int] = Field(None, description="レアリティID")
    base_price: Optional[int] = Field(None, ge=0, description="基本価格")
    max_stack: Optional[int] = Field(None, gt=0, description="最大スタック数")
    image_url: Optional[str] = Field(None, max_length=255, description="画像URL")
    is_active: Optional[bool] = Field(None, description="有効フラグ")

class MaterialMaster(MaterialMasterBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    rarity: RarityLevel
    calculated_price: int = Field(..., description="レアリティ倍率適用後価格")

    class Config:
        from_attributes = True

# プレイヤー素材スキーマ
class PlayerMaterialBase(BaseModel):
    material_id: int = Field(..., description="素材ID")
    quantity: int = Field(0, ge=0, description="所持数量")

class PlayerMaterialCreate(PlayerMaterialBase):
    pass

class PlayerMaterialUpdate(BaseModel):
    quantity: int = Field(..., ge=0, description="所持数量")

class PlayerMaterial(PlayerMaterialBase):
    player_id: UUID
    created_at: datetime
    updated_at: datetime
    material: MaterialMaster
    is_full: bool = Field(..., description="スタック上限フラグ")
    remaining_capacity: int = Field(..., description="残りスタック容量")

    class Config:
        from_attributes = True

# 素材操作関連
class MaterialAddRequest(BaseModel):
    material_id: int = Field(..., description="素材ID")
    quantity: int = Field(..., gt=0, description="追加数量")

class MaterialRemoveRequest(BaseModel):
    material_id: int = Field(..., description="素材ID")
    quantity: int = Field(..., gt=0, description="消費数量")

class MaterialOperationResult(BaseModel):
    success: bool = Field(..., description="成功フラグ")
    new_quantity: int = Field(..., description="新しい所持数量")
    message: str = Field(..., description="結果メッセージ")

# 素材売却関連
class MaterialSellRequest(BaseModel):
    material_id: int = Field(..., description="素材ID")
    quantity: int = Field(..., gt=0, description="売却数量")

class MaterialSellResult(BaseModel):
    success: bool = Field(..., description="成功フラグ")
    sold_quantity: int = Field(..., description="売却数量")
    gold_earned: int = Field(..., description="獲得ゴールド")
    new_quantity: int = Field(..., description="残り所持数量")
    message: str = Field(..., description="結果メッセージ")

# レスポンススキーマ
class MaterialMasterResponse(BaseResponse[MaterialMaster]):
    pass

class MaterialMasterListResponse(PaginatedResponse[MaterialMaster]):
    pass

class PlayerMaterialResponse(BaseResponse[PlayerMaterial]):
    pass

class PlayerMaterialListResponse(BaseResponse[List[PlayerMaterial]]):
    pass

class MaterialOperationResponse(BaseResponse[MaterialOperationResult]):
    pass

class MaterialSellResponse(BaseResponse[MaterialSellResult]):
    pass
