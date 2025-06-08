"""
Pydantic schemas for adventurer progression system
"""

from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime


class ExperienceGainRequest(BaseModel):
    """Request to add experience to an adventurer"""
    activity_type: str  # trade_completed, dragon_raid, quest_completed, etc.
    activity_data: Dict[str, Any]  # Additional data about the activity


class AdventurerLevelUpResponse(BaseModel):
    """Response when checking/processing adventurer level up"""
    adventurer_id: int
    old_level: int
    new_level: int
    levels_gained: int
    experience_used: int
    remaining_experience: int
    stat_improvements: List[Dict[str, Any]]
    new_abilities: List[Dict[str, Any]]
    level_up_occurred: bool


class AdventurerStatsResponse(BaseModel):
    """Detailed adventurer stats and progression info"""
    adventurer_id: int
    name: str
    profession: str
    level: int
    experience_points: int
    experience_to_next_level: int
    base_attack: int
    base_defense: int
    base_hp: int
    trust_level: int
    total_trades: int
    total_gold_spent: int
    dragon_raids: int
    special_abilities: List[Dict[str, Any]]


class ProgressionSummary(BaseModel):
    """Summary of all adventurer progression"""
    total_adventurers: int
    highest_level: int
    total_experience_earned: int
    total_abilities_unlocked: int
    average_trust_level: float


class AbilityInfo(BaseModel):
    """Information about a special ability"""
    name: str
    description: str
    type: str  # active, passive
    unlock_level: int
    profession: str


class LevelUpBenefits(BaseModel):
    """Benefits gained from leveling up"""
    level: int
    attack_gain: int
    defense_gain: int
    hp_gain: int
    new_ability: Optional[AbilityInfo] = None