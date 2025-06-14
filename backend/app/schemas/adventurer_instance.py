"""
冒険者インスタンススキーマ
"""
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List
from uuid import UUID

from .adventurer import AdventurerMaster, QuestAreaMaster


# 冒険者リクエストスキーマ
class AdventurerRequestBase(BaseModel):
    weapon_type: str
    min_attack: int = Field(ge=1)
    max_budget: int = Field(ge=1)
    preferred_rarity: Optional[str] = None
    urgency: int = Field(ge=1, le=5, default=3)
    description: Optional[str] = None
    deadline: datetime


class AdventurerRequestCreate(AdventurerRequestBase):
    pass


class AdventurerRequest(AdventurerRequestBase):
    id: UUID
    adventurer_instance_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True


# クエスト報酬スキーマ
class QuestRewardBase(BaseModel):
    item_type: str  # material, weapon, gold
    item_id: Optional[str] = None  # NULL for gold rewards
    quantity: int = Field(ge=1, default=1)
    buyback_price: Optional[int] = None


class QuestReward(QuestRewardBase):
    id: UUID
    adventurer_quest_id: UUID
    buyback_deadline: Optional[datetime] = None
    is_bought: bool = False
    created_at: datetime
    
    class Config:
        orm_mode = True


# 冒険者クエストスキーマ
class AdventurerQuestBase(BaseModel):
    quest_area_id: int
    player_weapon_id: Optional[UUID] = None


class AdventurerQuestCreate(AdventurerQuestBase):
    pass


class AdventurerQuest(AdventurerQuestBase):
    id: UUID
    adventurer_instance_id: UUID
    status: str
    start_time: datetime
    end_time: Optional[datetime] = None
    success: Optional[bool] = None
    gold_earned: int = 0
    created_at: datetime
    updated_at: datetime
    quest_area: Optional[QuestAreaMaster] = None
    rewards: List[QuestReward] = []
    
    class Config:
        orm_mode = True


# 冒険者購入履歴スキーマ
class AdventurerPurchaseBase(BaseModel):
    player_weapon_id: UUID
    price: int = Field(ge=1)


class AdventurerPurchaseCreate(AdventurerPurchaseBase):
    pass


class AdventurerPurchase(AdventurerPurchaseBase):
    id: UUID
    adventurer_instance_id: UUID
    purchased_at: datetime
    
    class Config:
        orm_mode = True


# 冒険者インスタンススキーマ
class AdventurerInstanceBase(BaseModel):
    name: str
    level: int = Field(ge=1, default=1)
    trust_level: int = Field(ge=0, le=100, default=0)


class AdventurerInstanceCreate(BaseModel):
    adventurer_master_id: str


class AdventurerInstance(AdventurerInstanceBase):
    id: UUID
    adventurer_master_id: Optional[str] = None  # Nullable for named characters
    player_id: Optional[UUID] = None
    status: str  # idle, visiting, on_quest, waiting_buyback
    current_quest_id: Optional[UUID] = None
    visit_start_time: Optional[datetime] = None
    visit_end_time: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    adventurer_master: Optional[AdventurerMaster] = None
    requests: List[AdventurerRequest] = []
    
    # 固有キャラクターシステム用
    is_named_character: bool = False
    character_id: Optional[int] = None
    generic_name: Optional[str] = None
    
    class Config:
        orm_mode = True


class AdventurerInstanceDetail(AdventurerInstance):
    """冒険者の詳細情報（クエスト履歴、購入履歴含む）"""
    quests: List[AdventurerQuest] = []
    purchases: List[AdventurerPurchase] = []
    
    class Config:
        orm_mode = True


# レスポンススキーマ
class AdventurerListResponse(BaseModel):
    """冒険者一覧レスポンス"""
    adventurers: List[AdventurerInstance]
    total: int
    page: int
    limit: int


class QuestResultResponse(BaseModel):
    """クエスト結果（買取待ち）レスポンス"""
    results: List[AdventurerQuest]
    total: int


# 武器販売リクエスト
class WeaponSaleRequest(BaseModel):
    weapon_id: UUID
    price: int = Field(ge=1)


# クエスト派遣リクエスト
class QuestDispatchRequest(BaseModel):
    quest_area_id: int


# 買取リクエスト
class BuybackRequest(BaseModel):
    quest_result_id: UUID
    item_ids: List[UUID]


class BulkBuybackRequest(BaseModel):
    """一括買取リクエスト"""
    max_gold: Optional[int] = None  # 指定した場合は上限金額、Noneの場合は全所持金


class BuybackItem(BaseModel):
    """買取アイテム情報"""
    reward_id: UUID
    quest_id: UUID
    item_type: str
    item_id: str
    item_name: str
    quantity: int
    price: int
    quest_area_name: str
    adventurer_name: str


class BulkBuybackResponse(BaseModel):
    """一括買取レスポンス"""
    success: bool
    message: str
    total_cost: int
    total_items: int
    items_purchased: List[BuybackItem]
    gold_remaining: int
    exp_gained: int = 0
    shop_level: int
    shop_level_up: Optional[dict] = None