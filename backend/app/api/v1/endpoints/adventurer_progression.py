"""
Adventurer Progression API Endpoints

This module handles adventurer level-up, experience calculation, and growth mechanics.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any, List
import math

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models.player import Player
from app.models.adventurer_character import AdventurerCharacter, PlayerAdventurerRelation
from app.schemas.adventurer_progression import (
    AdventurerLevelUpResponse, ExperienceGainRequest, AdventurerStatsResponse
)

router = APIRouter()


@router.post("/level-up/{adventurer_id}", response_model=AdventurerLevelUpResponse)
def level_up_adventurer(
    adventurer_id: int,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Check and process adventurer level up based on accumulated experience
    """
    # Get adventurer character
    adventurer = db.query(AdventurerCharacter).filter(
        AdventurerCharacter.id == adventurer_id
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="Adventurer not found")
    
    # Get player relationship
    relation = db.query(PlayerAdventurerRelation).filter(
        PlayerAdventurerRelation.player_id == str(current_player.id),
        PlayerAdventurerRelation.adventurer_id == adventurer_id
    ).first()
    
    if not relation:
        raise HTTPException(status_code=404, detail="No relationship with this adventurer")
    
    # Calculate level up
    result = _calculate_level_up(adventurer, db)
    
    return AdventurerLevelUpResponse(
        adventurer_id=adventurer_id,
        old_level=result["old_level"],
        new_level=result["new_level"],
        levels_gained=result["levels_gained"],
        experience_used=result["experience_used"],
        remaining_experience=result["remaining_experience"],
        stat_improvements=result["stat_improvements"],
        new_abilities=result["new_abilities"],
        level_up_occurred=result["level_up_occurred"]
    )


@router.post("/gain-experience/{adventurer_id}")
def add_experience(
    adventurer_id: int,
    request: ExperienceGainRequest,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Add experience to an adventurer based on activities
    """
    # Get adventurer character
    adventurer = db.query(AdventurerCharacter).filter(
        AdventurerCharacter.id == adventurer_id
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="Adventurer not found")
    
    # Get player relationship
    relation = db.query(PlayerAdventurerRelation).filter(
        PlayerAdventurerRelation.player_id == str(current_player.id),
        PlayerAdventurerRelation.adventurer_id == adventurer_id
    ).first()
    
    if not relation:
        raise HTTPException(status_code=404, detail="No relationship with this adventurer")
    
    # Calculate experience based on activity
    experience_gained = _calculate_experience_gain(request.activity_type, request.activity_data)
    
    # Add experience
    adventurer.experience_points += experience_gained
    
    # Update activity counters
    if request.activity_type == "trade_completed":
        adventurer.total_trades_completed += 1
        adventurer.total_gold_spent += request.activity_data.get("gold_amount", 0)
        relation.successful_trades += 1
        relation.total_gold_traded += request.activity_data.get("gold_amount", 0)
    elif request.activity_type == "dragon_raid":
        adventurer.dragon_raids_participated += 1
        relation.dragon_raids_together += 1
    elif request.activity_type == "quest_completed":
        relation.quests_completed_together += 1
    
    db.commit()
    
    # Check for level up
    level_up_result = _calculate_level_up(adventurer, db)
    
    return {
        "experience_gained": experience_gained,
        "total_experience": adventurer.experience_points,
        "level_up_occurred": level_up_result["level_up_occurred"],
        "new_level": level_up_result["new_level"] if level_up_result["level_up_occurred"] else adventurer.level
    }


@router.get("/stats/{adventurer_id}", response_model=AdventurerStatsResponse)
def get_adventurer_stats(
    adventurer_id: int,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Get detailed adventurer stats and progression info
    """
    # Get adventurer character
    adventurer = db.query(AdventurerCharacter).filter(
        AdventurerCharacter.id == adventurer_id
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="Adventurer not found")
    
    # Get player relationship
    relation = db.query(PlayerAdventurerRelation).filter(
        PlayerAdventurerRelation.player_id == str(current_player.id),
        PlayerAdventurerRelation.adventurer_id == adventurer_id
    ).first()
    
    if not relation:
        raise HTTPException(status_code=404, detail="No relationship with this adventurer")
    
    # Calculate experience needed for next level
    current_exp_needed = _experience_for_level(adventurer.level)
    next_exp_needed = _experience_for_level(adventurer.level + 1)
    experience_to_next_level = next_exp_needed - adventurer.experience_points
    
    return AdventurerStatsResponse(
        adventurer_id=adventurer_id,
        name=adventurer.name,
        profession=adventurer.profession,
        level=adventurer.level,
        experience_points=adventurer.experience_points,
        experience_to_next_level=max(0, experience_to_next_level),
        base_attack=adventurer.base_attack,
        base_defense=adventurer.base_defense,
        base_hp=adventurer.base_hp,
        trust_level=relation.trust_level,
        total_trades=adventurer.total_trades_completed,
        total_gold_spent=adventurer.total_gold_spent,
        dragon_raids=adventurer.dragon_raids_participated,
        special_abilities=adventurer.special_abilities or []
    )


@router.get("/all-stats", response_model=List[AdventurerStatsResponse])
def get_all_adventurer_stats(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Get stats for all adventurers the player has relationships with
    """
    # Get all player relationships
    relations = db.query(PlayerAdventurerRelation).filter(
        PlayerAdventurerRelation.player_id == str(current_player.id)
    ).all()
    
    stats_list = []
    for relation in relations:
        adventurer = relation.adventurer
        
        # Calculate experience needed for next level
        next_exp_needed = _experience_for_level(adventurer.level + 1)
        experience_to_next_level = next_exp_needed - adventurer.experience_points
        
        stats_list.append(AdventurerStatsResponse(
            adventurer_id=adventurer.id,
            name=adventurer.name,
            profession=adventurer.profession,
            level=adventurer.level,
            experience_points=adventurer.experience_points,
            experience_to_next_level=max(0, experience_to_next_level),
            base_attack=adventurer.base_attack,
            base_defense=adventurer.base_defense,
            base_hp=adventurer.base_hp,
            trust_level=relation.trust_level,
            total_trades=adventurer.total_trades_completed,
            total_gold_spent=adventurer.total_gold_spent,
            dragon_raids=adventurer.dragon_raids_participated,
            special_abilities=adventurer.special_abilities or []
        ))
    
    return stats_list


def _experience_for_level(level: int) -> int:
    """
    Calculate total experience needed to reach a specific level
    Formula: base_exp * level^1.5 (exponential growth)
    """
    if level <= 1:
        return 0
    
    base_exp = 100  # Base experience for level 2
    return int(base_exp * (level ** 1.5))


def _calculate_level_up(adventurer: AdventurerCharacter, db: Session) -> Dict[str, Any]:
    """
    Calculate if adventurer can level up and apply level up benefits
    """
    old_level = adventurer.level
    current_exp = adventurer.experience_points
    
    # Find highest level achievable with current experience
    new_level = old_level
    total_exp_used = 0
    
    while True:
        exp_needed_for_next = _experience_for_level(new_level + 1)
        if current_exp >= exp_needed_for_next:
            new_level += 1
        else:
            break
    
    levels_gained = new_level - old_level
    level_up_occurred = levels_gained > 0
    
    stat_improvements = []
    new_abilities = []
    
    if level_up_occurred:
        # Apply level up benefits
        adventurer.level = new_level
        
        # Calculate stat improvements based on profession
        for level in range(old_level + 1, new_level + 1):
            improvements = _get_level_up_benefits(adventurer.profession, level)
            
            # Apply stat increases
            adventurer.base_attack += improvements["attack"]
            adventurer.base_defense += improvements["defense"] 
            adventurer.base_hp += improvements["hp"]
            
            stat_improvements.append({
                "level": level,
                "attack": improvements["attack"],
                "defense": improvements["defense"],
                "hp": improvements["hp"]
            })
            
            # Check for new abilities
            if improvements.get("new_ability"):
                new_abilities.append(improvements["new_ability"])
                
                # Add to adventurer's special abilities
                if not adventurer.special_abilities:
                    adventurer.special_abilities = []
                adventurer.special_abilities.append(improvements["new_ability"])
        
        db.commit()
    
    return {
        "old_level": old_level,
        "new_level": new_level,
        "levels_gained": levels_gained,
        "experience_used": total_exp_used,
        "remaining_experience": current_exp,
        "stat_improvements": stat_improvements,
        "new_abilities": new_abilities,
        "level_up_occurred": level_up_occurred
    }


def _get_level_up_benefits(profession: str, level: int) -> Dict[str, Any]:
    """
    Get stat improvements and abilities for a specific profession and level
    """
    # Base stat gains per level
    base_gains = {
        "warrior": {"attack": 8, "defense": 6, "hp": 25},
        "archer": {"attack": 6, "defense": 4, "hp": 15},
        "mage": {"attack": 10, "defense": 3, "hp": 12},
        "rogue": {"attack": 7, "defense": 5, "hp": 18},
        "paladin": {"attack": 6, "defense": 8, "hp": 22}
    }
    
    gains = base_gains.get(profession, {"attack": 5, "defense": 5, "hp": 20})
    
    # Special abilities at certain levels
    special_abilities = {
        "warrior": {
            5: {"name": "Power Strike", "description": "Deals 150% damage", "type": "active"},
            10: {"name": "Berserker Rage", "description": "Attack +50% for 3 turns", "type": "active"},
            15: {"name": "Weapon Master", "description": "Can wield any weapon type", "type": "passive"},
            20: {"name": "Legendary Warrior", "description": "All stats +25%", "type": "passive"}
        },
        "archer": {
            5: {"name": "Precision Shot", "description": "Never misses critical spots", "type": "active"},
            10: {"name": "Multi Shot", "description": "Hits multiple enemies", "type": "active"}, 
            15: {"name": "Eagle Eye", "description": "Critical hit rate +30%", "type": "passive"},
            20: {"name": "Master Archer", "description": "All ranged attacks +50%", "type": "passive"}
        },
        "mage": {
            5: {"name": "Fireball", "description": "Magical fire attack", "type": "active"},
            10: {"name": "Shield Spell", "description": "Defense +100% for 2 turns", "type": "active"},
            15: {"name": "Elemental Master", "description": "Can use all elements", "type": "passive"},
            20: {"name": "Archmage", "description": "All magical damage +75%", "type": "passive"}
        },
        "rogue": {
            5: {"name": "Stealth Attack", "description": "First attack deals 200% damage", "type": "active"},
            10: {"name": "Poison Blade", "description": "Attacks inflict poison", "type": "active"},
            15: {"name": "Shadow Step", "description": "Dodge chance +40%", "type": "passive"},
            20: {"name": "Master Assassin", "description": "Critical hits instant kill weaker enemies", "type": "passive"}
        },
        "paladin": {
            5: {"name": "Holy Strike", "description": "Light-based attack vs evil", "type": "active"},
            10: {"name": "Divine Protection", "description": "Damage reduction +50%", "type": "active"},
            15: {"name": "Aura of Courage", "description": "Party gets +20% all stats", "type": "passive"},
            20: {"name": "Divine Champion", "description": "Immune to negative effects", "type": "passive"}
        }
    }
    
    result = gains.copy()
    
    # Check for special ability unlock
    if profession in special_abilities and level in special_abilities[profession]:
        result["new_ability"] = special_abilities[profession][level]
    
    return result


def _calculate_experience_gain(activity_type: str, activity_data: Dict[str, Any]) -> int:
    """
    Calculate experience gained from different activities
    """
    base_experience = {
        "trade_completed": 10,
        "successful_negotiation": 5,
        "failed_negotiation": 1,
        "dragon_raid": 100,
        "quest_completed": 50,
        "trust_level_up": 25,
        "special_event": 75
    }
    
    base_exp = base_experience.get(activity_type, 1)
    
    # Activity-specific multipliers
    if activity_type == "trade_completed":
        # Bonus experience based on gold amount
        gold_amount = activity_data.get("gold_amount", 0)
        gold_bonus = min(20, gold_amount // 100)  # +1 exp per 100 gold, max +20
        base_exp += gold_bonus
        
        # Bonus for high-value items
        item_rarity = activity_data.get("item_rarity", "common")
        rarity_bonus = {
            "common": 0,
            "uncommon": 5,
            "rare": 10,
            "epic": 20,
            "legendary": 50
        }.get(item_rarity, 0)
        base_exp += rarity_bonus
    
    elif activity_type == "dragon_raid":
        # Bonus based on raid difficulty and performance
        difficulty = activity_data.get("difficulty", 1)
        performance = activity_data.get("performance_score", 50)  # 0-100
        
        difficulty_bonus = difficulty * 25
        performance_bonus = int(performance * 0.5)  # 0-50 bonus
        base_exp += difficulty_bonus + performance_bonus
    
    return base_exp