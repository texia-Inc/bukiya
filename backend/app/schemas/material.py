from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field
from uuid import UUID

from .common import BaseResponse, PaginatedResponse
from .weapon import RarityLevel

# 素材マスタースキーマ
class MaterialMasterBase(BaseModel):
    name: str = Field(..., max_length=100, description="素材名")
    category: Optional[str] = Field(None, description="カテゴリ")
    rarity_id: str = Field(..., description="レアリティID")
    description: Optional[str] = Field(None, description="説明")
    base_price: int = Field(..., ge=0, description="基本価格")
    price_volatility: Optional[float] = Field(0.1, description="価格変動率")
    stack_size: int = Field(999, gt=0, description="スタック数")
    emoji: Optional[str] = Field(None, description="絵文字")
    color_code: Optional[str] = Field(None, description="カラーコード")

class MaterialMasterCreate(MaterialMasterBase):
    pass

class MaterialMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100, description="素材名")
    category: Optional[str] = Field(None, description="カテゴリ")
    rarity_id: Optional[str] = Field(None, description="レアリティID")
    description: Optional[str] = Field(None, description="説明")
    base_price: Optional[int] = Field(None, ge=0, description="基本価格")
    price_volatility: Optional[float] = Field(None, description="価格変動率")
    stack_size: Optional[int] = Field(None, gt=0, description="スタック数")
    emoji: Optional[str] = Field(None, description="絵文字")
    color_code: Optional[str] = Field(None, description="カラーコード")
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

# Flutter互換のマテリアル情報
class FlutterMaterial(BaseModel):
    id: int
    name: str
    description: str
    rarity: str
    sell_price: int
    is_active: bool

    @classmethod
    def from_material_master(cls, material_master: "MaterialMaster") -> "FlutterMaterial":
        return cls(
            id=material_master.id,
            name=material_master.name,
            description=material_master.description or "",
            rarity=material_master.rarity.name if material_master.rarity else "common",
            sell_price=material_master.calculated_price,
            is_active=material_master.is_active
        )

class PlayerMaterial(PlayerMaterialBase):
    player_id: UUID
    created_at: datetime
    updated_at: datetime
    material: FlutterMaterial
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
