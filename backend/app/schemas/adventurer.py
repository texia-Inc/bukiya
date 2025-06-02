from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

# 冒険者マスター関連のスキーマ
class AdventurerMasterBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="冒険者の名前")
    profession: str = Field(..., description="職業 (warrior, archer, mage, rogue, paladin)")
    level: int = Field(default=1, ge=1, le=100, description="レベル")
    personality: str = Field(..., description="性格 (generous, normal, stingy, wealthy, poor)")
    trust_level: int = Field(default=50, ge=0, le=100, description="信頼度")
    budget_min: int = Field(default=500, ge=0, description="最小予算")
    budget_max: int = Field(default=2000, ge=0, description="最大予算")
    preferred_weapon_type: str = Field(..., description="好みの武器種")
    avatar_url: Optional[str] = Field(None, description="アバター画像URL")
    description: Optional[str] = Field(None, description="説明")
    
    # 要求パターン設定
    min_attack_requirement: int = Field(default=100, ge=0, description="最小攻撃力要求")
    max_budget_multiplier: float = Field(default=1.0, ge=0.1, le=5.0, description="予算倍率")
    urgency_tendency: int = Field(default=3, ge=1, le=5, description="緊急度傾向")
    
    # 出現設定
    spawn_weight: int = Field(default=100, ge=0, description="出現確率の重み")
    min_player_level: int = Field(default=1, ge=1, description="最小プレイヤーレベル")
    max_player_level: Optional[int] = Field(None, ge=1, description="最大プレイヤーレベル")
    
    is_active: bool = Field(default=True, description="有効フラグ")

class AdventurerMasterCreate(AdventurerMasterBase):
    pass

class AdventurerMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    profession: Optional[str] = None
    level: Optional[int] = Field(None, ge=1, le=100)
    personality: Optional[str] = None
    trust_level: Optional[int] = Field(None, ge=0, le=100)
    budget_min: Optional[int] = Field(None, ge=0)
    budget_max: Optional[int] = Field(None, ge=0)
    preferred_weapon_type: Optional[str] = None
    avatar_url: Optional[str] = None
    description: Optional[str] = None
    min_attack_requirement: Optional[int] = Field(None, ge=0)
    max_budget_multiplier: Optional[float] = Field(None, ge=0.1, le=5.0)
    urgency_tendency: Optional[int] = Field(None, ge=1, le=5)
    spawn_weight: Optional[int] = Field(None, ge=0)
    min_player_level: Optional[int] = Field(None, ge=1)
    max_player_level: Optional[int] = Field(None, ge=1)
    is_active: Optional[bool] = None

class AdventurerMaster(AdventurerMasterBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# モンスターマスター関連のスキーマ
class MonsterMasterBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="モンスター名")
    monster_type: str = Field(..., description="モンスタータイプ")
    level: int = Field(default=1, ge=1, le=100, description="レベル")
    hp: int = Field(default=100, ge=1, description="HP")
    attack: int = Field(default=50, ge=1, description="攻撃力")
    defense: int = Field(default=20, ge=0, description="防御力")
    
    element: Optional[str] = Field(None, description="属性")
    weakness: Optional[str] = Field(None, description="弱点")
    resistance: Optional[str] = Field(None, description="耐性")
    
    spawn_areas: str = Field(..., description="出現エリア（カンマ区切り）")
    spawn_weight: int = Field(default=100, ge=0, description="出現確率の重み")
    min_required_weapon_level: int = Field(default=0, ge=0, description="必要武器レベル")
    
    base_gold_reward: int = Field(default=100, ge=0, description="基本ゴールド報酬")
    experience_reward: int = Field(default=50, ge=0, description="経験値報酬")
    
    image_url: Optional[str] = Field(None, description="画像URL")
    description: Optional[str] = Field(None, description="説明")
    
    is_active: bool = Field(default=True, description="有効フラグ")

class MonsterMasterCreate(MonsterMasterBase):
    pass

class MonsterMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    monster_type: Optional[str] = None
    level: Optional[int] = Field(None, ge=1, le=100)
    hp: Optional[int] = Field(None, ge=1)
    attack: Optional[int] = Field(None, ge=1)
    defense: Optional[int] = Field(None, ge=0)
    element: Optional[str] = None
    weakness: Optional[str] = None
    resistance: Optional[str] = None
    spawn_areas: Optional[str] = None
    spawn_weight: Optional[int] = Field(None, ge=0)
    min_required_weapon_level: Optional[int] = Field(None, ge=0)
    base_gold_reward: Optional[int] = Field(None, ge=0)
    experience_reward: Optional[int] = Field(None, ge=0)
    image_url: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None

class MonsterMaster(MonsterMasterBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# クエストエリアマスター関連のスキーマ
class QuestAreaMasterBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="エリア名")
    area_type: str = Field(..., description="エリアタイプ")
    difficulty: int = Field(default=1, ge=1, le=5, description="難易度")
    required_level: int = Field(default=1, ge=1, description="必要レベル")
    duration_minutes: int = Field(default=60, ge=1, description="所要時間（分）")
    
    image_url: Optional[str] = Field(None, description="画像URL")
    background_color: str = Field(default="#4CAF50", description="背景色")
    description: Optional[str] = Field(None, description="説明")
    
    unlock_condition: Optional[str] = Field(None, description="解放条件（JSON）")
    
    is_active: bool = Field(default=True, description="有効フラグ")
    display_order: int = Field(default=0, description="表示順序")

class QuestAreaMasterCreate(QuestAreaMasterBase):
    pass

class QuestAreaMasterUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    area_type: Optional[str] = None
    difficulty: Optional[int] = Field(None, ge=1, le=5)
    required_level: Optional[int] = Field(None, ge=1)
    duration_minutes: Optional[int] = Field(None, ge=1)
    image_url: Optional[str] = None
    background_color: Optional[str] = None
    description: Optional[str] = None
    unlock_condition: Optional[str] = None
    is_active: Optional[bool] = None
    display_order: Optional[int] = None

class QuestAreaMaster(QuestAreaMasterBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

# ドロップテーブル関連のスキーマ
class MonsterDropTableBase(BaseModel):
    monster_id: int = Field(..., description="モンスターID")
    item_type: str = Field(..., description="アイテムタイプ (material, weapon)")
    item_id: int = Field(..., description="アイテムID")
    drop_rate: float = Field(..., ge=0.0, le=1.0, description="ドロップ率")
    min_quantity: int = Field(default=1, ge=1, description="最小数量")
    max_quantity: int = Field(default=1, ge=1, description="最大数量")
    
    required_weapon_enchant: int = Field(default=0, ge=0, description="必要武器エンチャントレベル")
    required_adventurer_level: int = Field(default=1, ge=1, description="必要冒険者レベル")
    
    is_active: bool = Field(default=True, description="有効フラグ")

class MonsterDropTableCreate(MonsterDropTableBase):
    pass

class MonsterDropTableUpdate(BaseModel):
    monster_id: Optional[int] = None
    item_type: Optional[str] = None
    item_id: Optional[int] = None
    drop_rate: Optional[float] = Field(None, ge=0.0, le=1.0)
    min_quantity: Optional[int] = Field(None, ge=1)
    max_quantity: Optional[int] = Field(None, ge=1)
    required_weapon_enchant: Optional[int] = Field(None, ge=0)
    required_adventurer_level: Optional[int] = Field(None, ge=1)
    is_active: Optional[bool] = None

class MonsterDropTable(MonsterDropTableBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

# レスポンス用のスキーマ
class AdventurerMasterListResponse(BaseModel):
    adventurers: List[AdventurerMaster]
    total: int
    page: int
    limit: int

class MonsterMasterListResponse(BaseModel):
    monsters: List[MonsterMaster]
    total: int
    page: int
    limit: int

class QuestAreaMasterListResponse(BaseModel):
    areas: List[QuestAreaMaster]
    total: int
    page: int
    limit: int

class MonsterDropTableListResponse(BaseModel):
    drops: List[MonsterDropTable]
    total: int
    page: int
    limit: int
