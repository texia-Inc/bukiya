from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

from .common import BaseResponse, PaginatedResponse
from .weapon import WeaponMaster
from .material import MaterialMaster

# レシピ素材スキーマ（先に定義）
class RecipeMaterialBase(BaseModel):
    material_id: int = Field(..., description="素材ID")
    quantity: int = Field(..., gt=0, description="必要数量")

class RecipeMaterialCreate(RecipeMaterialBase):
    pass

# 合成レシピスキーマ
class CraftingRecipeBase(BaseModel):
    weapon_id: int = Field(..., description="武器ID")
    name: str = Field(..., max_length=100, description="レシピ名")
    description: Optional[str] = Field(None, description="説明")
    gold_cost: int = Field(0, ge=0, description="ゴールドコスト")
    success_rate: float = Field(1.0, ge=0.0, le=1.0, description="成功率")
    required_level: int = Field(1, ge=1, description="必要レベル")

class CraftingRecipeCreate(CraftingRecipeBase):
    materials: List[RecipeMaterialCreate] = Field(..., description="必要素材リスト")

class CraftingRecipeUpdate(BaseModel):
    weapon_id: Optional[int] = Field(None, description="武器ID")
    name: Optional[str] = Field(None, max_length=100, description="レシピ名")
    description: Optional[str] = Field(None, description="説明")
    gold_cost: Optional[int] = Field(None, ge=0, description="ゴールドコスト")
    success_rate: Optional[float] = Field(None, ge=0.0, le=1.0, description="成功率")
    required_level: Optional[int] = Field(None, ge=1, description="必要レベル")
    is_active: Optional[bool] = Field(None, description="有効フラグ")
    materials: Optional[List[RecipeMaterialCreate]] = Field(None, description="必要素材リスト（指定時は全置換）")

class RecipeMaterial(RecipeMaterialBase):
    recipe_id: int
    material: MaterialMaster

    class Config:
        from_attributes = True

class CraftingRecipe(CraftingRecipeBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    weapon: WeaponMaster
    materials: List[RecipeMaterial]

    class Config:
        from_attributes = True

# 合成実行関連
class CraftingRequest(BaseModel):
    recipe_id: int = Field(..., description="レシピID")

class CraftingResult(BaseModel):
    success: bool = Field(..., description="成功フラグ")
    weapon_created: bool = Field(..., description="武器作成フラグ")
    weapon_id: Optional[str] = Field(None, description="作成された武器ID")
    gold_spent: int = Field(..., description="消費ゴールド")
    materials_consumed: List[dict] = Field(..., description="消費素材リスト")
    message: str = Field(..., description="結果メッセージ")

# 合成可能チェック
class CraftingAvailabilityCheck(BaseModel):
    recipe_id: int
    can_craft: bool = Field(..., description="合成可能フラグ")
    missing_requirements: List[str] = Field(..., description="不足要件リスト")
    required_materials: List[dict] = Field(..., description="必要素材リスト")
    player_materials: List[dict] = Field(..., description="プレイヤー所持素材リスト")

# レシピ詳細（合成可能性込み）
class CraftingRecipeDetail(CraftingRecipe):
    can_craft: bool = Field(..., description="プレイヤーが合成可能か")
    missing_requirements: List[str] = Field(..., description="不足要件")

# レスポンススキーマ
class CraftingRecipeResponse(BaseResponse[CraftingRecipe]):
    pass

class CraftingRecipeListResponse(PaginatedResponse[CraftingRecipe]):
    pass

class CraftingRecipeDetailResponse(BaseResponse[CraftingRecipeDetail]):
    pass

class CraftingRecipeDetailListResponse(BaseResponse[List[CraftingRecipeDetail]]):
    pass

class CraftingResultResponse(BaseResponse[CraftingResult]):
    pass

class CraftingAvailabilityResponse(BaseResponse[CraftingAvailabilityCheck]):
    pass

# レシピ作成・更新用（管理画面向け）
class CraftingRecipeCreateWithMaterials(BaseModel):
    recipe: CraftingRecipeCreate
    materials: List[RecipeMaterialCreate]

class CraftingRecipeUpdateWithMaterials(BaseModel):
    recipe: CraftingRecipeUpdate
    materials: Optional[List[RecipeMaterialCreate]] = Field(None, description="素材リスト（指定時は全置換）")
