#!/usr/bin/env python3
"""
Test script for adventurer progression system
"""

import asyncio
import sys
import os

# Add the app directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'app'))

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.adventurer_character import AdventurerCharacter, PlayerAdventurerRelation
from app.api.v1.endpoints.adventurer_progression import _calculate_level_up, _experience_for_level, _calculate_experience_gain


def create_test_adventurer():
    """Create a test adventurer character and relation"""
    db = SessionLocal()
    
    try:
        # Create test adventurer
        adventurer = AdventurerCharacter(
            name="Test Warrior",
            profession="warrior",
            level=1,
            personality="normal",
            preferred_weapon_types=["sword", "shield"],
            budget_base=1000,
            experience_points=0,
            base_attack=100,
            base_defense=50,
            base_hp=200
        )
        
        db.add(adventurer)
        db.commit()
        db.refresh(adventurer)
        
        # Create player relation
        relation = PlayerAdventurerRelation(
            player_id="test-player-123",
            adventurer_id=adventurer.id,
            trust_level=25,
            relationship_status="acquaintance"
        )
        
        db.add(relation)
        db.commit()
        
        print(f"Created test adventurer: {adventurer.name} (ID: {adventurer.id})")
        print(f"Initial stats: Level {adventurer.level}, EXP {adventurer.experience_points}")
        print(f"Initial combat stats: ATK {adventurer.base_attack}, DEF {adventurer.base_defense}, HP {adventurer.base_hp}")
        
        return adventurer.id
        
    except Exception as e:
        print(f"Error creating test adventurer: {e}")
        db.rollback()
        return None
    finally:
        db.close()


def test_experience_calculation():
    """Test experience calculation for different levels"""
    print("\n=== Experience Level Requirements ===")
    for level in range(1, 11):
        exp_needed = _experience_for_level(level)
        print(f"Level {level}: {exp_needed} EXP total")


def test_experience_gain():
    """Test experience gain calculations"""
    print("\n=== Experience Gain Tests ===")
    
    # Test trade completion
    trade_exp = _calculate_experience_gain("trade_completed", {
        "gold_amount": 500,
        "item_rarity": "rare"
    })
    print(f"Trade (500 gold, rare item): {trade_exp} EXP")
    
    # Test dragon raid
    raid_exp = _calculate_experience_gain("dragon_raid", {
        "difficulty": 3,
        "performance_score": 80
    })
    print(f"Dragon raid (difficulty 3, 80% performance): {raid_exp} EXP")
    
    # Test quest completion
    quest_exp = _calculate_experience_gain("quest_completed", {})
    print(f"Quest completion: {quest_exp} EXP")


def test_level_up(adventurer_id):
    """Test level up system"""
    db = SessionLocal()
    
    try:
        adventurer = db.query(AdventurerCharacter).filter(
            AdventurerCharacter.id == adventurer_id
        ).first()
        
        if not adventurer:
            print(f"Adventurer {adventurer_id} not found")
            return
        
        print(f"\n=== Level Up Test for {adventurer.name} ===")
        print(f"Current: Level {adventurer.level}, EXP {adventurer.experience_points}")
        
        # Add enough experience to level up multiple times
        test_exp_amounts = [150, 300, 500, 800]  # Should reach levels 2, 3, 4, 5
        
        for i, exp_amount in enumerate(test_exp_amounts):
            print(f"\n--- Adding {exp_amount} experience ---")
            
            # Save old stats
            old_level = adventurer.level
            old_attack = adventurer.base_attack
            old_defense = adventurer.base_defense
            old_hp = adventurer.base_hp
            
            # Add experience
            adventurer.experience_points += exp_amount
            
            # Test level up
            result = _calculate_level_up(adventurer, db)
            
            print(f"Experience added: {exp_amount}")
            print(f"Total experience: {adventurer.experience_points}")
            print(f"Level up occurred: {result['level_up_occurred']}")
            
            if result['level_up_occurred']:
                print(f"Level: {old_level} → {result['new_level']} (+{result['levels_gained']})")
                print(f"Attack: {old_attack} → {adventurer.base_attack}")
                print(f"Defense: {old_defense} → {adventurer.base_defense}")
                print(f"HP: {old_hp} → {adventurer.base_hp}")
                
                if result['new_abilities']:
                    print("New abilities unlocked:")
                    for ability in result['new_abilities']:
                        print(f"  - {ability['name']}: {ability['description']}")
            
            db.commit()
            
    except Exception as e:
        print(f"Error testing level up: {e}")
        db.rollback()
    finally:
        db.close()


def main():
    print("=== Adventurer Progression System Test ===")
    
    # Test experience calculations
    test_experience_calculation()
    test_experience_gain()
    
    # Create test adventurer
    adventurer_id = create_test_adventurer()
    
    if adventurer_id:
        # Test level up
        test_level_up(adventurer_id)
    
    print("\n=== Test Complete ===")


if __name__ == "__main__":
    main()