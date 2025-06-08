"""
固有冒険者キャラクターシステムのAPIスキーマ
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from uuid import UUID


# Base schemas
class AdventurerCharacterBase(BaseModel):
    name: str
    title: Optional[str] = None
    profession: str
    rarity: str
    base_level: int
    max_level: int
    unlock_player_level: int
    personality: str
    backstory: Optional[str] = None
    quote: Optional[str] = None
    color_theme: str
    dragon_battle_eligible: bool


class AdventurerCharacterResponse(AdventurerCharacterBase):
    id: int
    base_stats: Dict[str, Any]
    growth_rates: Dict[str, Any]
    preferred_weapon_types: List[str]
    elemental_affinity: Optional[str]
    special_abilities: List[Dict[str, Any]]
    passive_skills: List[Dict[str, Any]]
    team_synergy: Dict[str, Any]
    avatar_url: Optional[str]
    voice_type: Optional[str]
    is_story_character: bool
    unlock_order: int
    created_at: datetime
    
    class Config:
        from_attributes = True


# Bond schemas
class PlayerCharacterBondBase(BaseModel):
    trust_level: int
    friendship_level: int
    total_interactions: int
    total_weapon_gifts: int
    total_quests_together: int
    total_dragon_battles: int
    current_level: int
    current_experience: int
    is_unlocked: bool
    is_favorited: bool


class PlayerCharacterBondResponse(PlayerCharacterBondBase):
    id: UUID
    player_id: UUID
    character_id: int
    total_trust_points: int
    custom_nickname: Optional[str]
    conversation_flags: Dict[str, Any]
    story_progress: Dict[str, Any]
    unlock_date: Optional[datetime]
    last_interaction_at: Optional[datetime]
    last_level_up_at: Optional[datetime]
    created_at: datetime
    
    class Config:
        from_attributes = True


# Request schemas
class CharacterUnlockRequest(BaseModel):
    unlock_method: str = Field(..., description="解放方法 (level_up, quest_complete, event)")
    condition_description: Optional[str] = Field(None, description="解放条件の詳細")


class CharacterInteractionRequest(BaseModel):
    interaction_type: str = Field(..., description="交流タイプ (greeting, weapon_gift, conversation)")
    message: Optional[str] = Field(None, description="交流時のメッセージ")
    weapon_id: Optional[UUID] = Field(None, description="プレゼントする武器ID")


# Response schemas
class CharacterDetailResponse(BaseModel):
    character: AdventurerCharacterResponse
    bond: Optional[PlayerCharacterBondResponse]
    can_unlock: bool


class CharacterListResponse(BaseModel):
    characters: List[Dict[str, Any]]
    player_level: int
    total_available: int
    total_unlocked: int


class BondProgressResponse(BaseModel):
    bond: PlayerCharacterBondResponse
    recent_conversations: List['CharacterConversationResponse']
    can_participate_dragon_battle: bool
    next_level_progress: Dict[str, Any]


class CharacterConversationResponse(BaseModel):
    id: UUID
    conversation_type: str
    conversation_text: Optional[str]
    trust_gained: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class CharacterUnlockResponse(BaseModel):
    message: str
    character: AdventurerCharacterResponse
    bond: PlayerCharacterBondResponse


class CharacterInteractionResponse(BaseModel):
    message: str
    trust_gained: int
    new_trust_level: int
    level_up: bool
    friendship_level: int
    response_message: str


# Character management schemas
class CharacterStatsUpdate(BaseModel):
    trust_level: Optional[int] = None
    friendship_level: Optional[int] = None
    current_level: Optional[int] = None
    current_experience: Optional[int] = None


class CharacterEquipWeapon(BaseModel):
    weapon_id: UUID
    
    
class CharacterFavoriteToggle(BaseModel):
    is_favorited: bool


# Advanced schemas for future features
class DragonBattleTeam(BaseModel):
    leader_character_id: int
    member_character_ids: List[int] = Field(..., max_items=4)


class CharacterTeamSynergy(BaseModel):
    character_ids: List[int]
    total_synergy_bonus: float
    individual_bonuses: Dict[str, float]


class CharacterProgressSummary(BaseModel):
    total_characters: int
    unlocked_characters: int
    max_trust_characters: int
    dragon_ready_characters: int
    average_trust_level: float
    total_interactions: int


# Update forward references
BondProgressResponse.model_rebuild()