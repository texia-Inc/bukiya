"""
Dragon Battle Simulation Engine

This module handles the core battle mechanics for dragon raid events,
including damage calculation, battle progression, and text generation.
"""

import random
import math
from typing import List, Dict, Tuple, Optional
from datetime import datetime, timedelta
from dataclasses import dataclass

from app.models.dragon_event import DragonEvent, DragonParticipant, DragonBattleLog
from app.models.adventurer_instance import AdventurerInstance
from app.models.player_weapon import PlayerWeapon


@dataclass
class BattleAction:
    """Represents a single battle action"""
    participant_id: int
    adventurer_name: str
    player_name: str
    action_type: str
    damage: int
    message: str
    timestamp: datetime


class DragonBattleEngine:
    """
    Core engine for dragon battle simulation
    """
    
    def __init__(self):
        self.battle_messages = {
            'critical_hit': [
                "{adventurer} landed a devastating critical strike!",
                "{adventurer} found a weak spot and struck with precision!",
                "{adventurer} unleashed their full power!",
                "A brilliant flash erupted as {adventurer} struck!"
            ],
            'normal_attack': [
                "{adventurer} swung their {weapon} with determination!",
                "{adventurer} attacked with practiced skill!",
                "{adventurer} struck the dragon with {weapon}!",
                "{adventurer} fought valiantly against the beast!"
            ],
            'special_attack': [
                "{adventurer} activated their special technique!",
                "{adventurer} channeled their inner strength!",
                "{adventurer} used an advanced combat maneuver!",
                "Magic energy flowed through {adventurer}'s attack!"
            ],
            'low_damage': [
                "{adventurer} struggled against the dragon's tough scales.",
                "The dragon's defenses reduced {adventurer}'s impact.",
                "{adventurer} persevered despite the difficulty.",
                "{adventurer} refused to give up!"
            ],
            'dragon_retaliation': [
                "The dragon roared in fury!",
                "Dark energy swirled around the dragon!",
                "The dragon's eyes blazed with ancient anger!",
                "The ground trembled beneath the dragon's power!"
            ]
        }
    
    def calculate_adventurer_damage(
        self, 
        adventurer: AdventurerInstance, 
        weapon: Optional[PlayerWeapon] = None,
        dragon_level: int = 1
    ) -> Tuple[int, str, str]:
        """
        Calculate damage dealt by an adventurer to the dragon
        
        Returns:
            Tuple of (damage, action_type, message)
        """
        # Base damage calculation
        base_damage = self._calculate_base_damage(adventurer, weapon)
        
        # Apply randomness and special effects
        damage, action_type = self._apply_battle_effects(base_damage, adventurer.level)
        
        # Scale damage based on dragon level
        damage = self._scale_damage_for_dragon(damage, dragon_level)
        
        # Generate battle message
        message = self._generate_battle_message(
            adventurer.name, 
            weapon.weapon_master.name if weapon else "fists",
            action_type, 
            damage
        )
        
        return damage, action_type, message
    
    def _calculate_base_damage(
        self, 
        adventurer: AdventurerInstance, 
        weapon: Optional[PlayerWeapon]
    ) -> int:
        """Calculate base damage before modifiers"""
        # Adventurer level contributes to base damage
        level_damage = adventurer.level * 10
        
        # Trust level increases damage
        trust_bonus = (adventurer.trust_level / 100.0) * 50
        
        # Weapon damage
        weapon_damage = 0
        if weapon and weapon.weapon_master:
            weapon_damage = weapon.weapon_master.base_attack
            
            # Enchantment bonuses would be added here
            # For now, simple scaling based on weapon rarity
            rarity_multiplier = 1.0 + (weapon.weapon_master.rarity_id * 0.2)
            weapon_damage = int(weapon_damage * rarity_multiplier)
        
        return int(level_damage + trust_bonus + weapon_damage)
    
    def _apply_battle_effects(self, base_damage: int, adventurer_level: int) -> Tuple[int, str]:
        """Apply random effects and determine action type"""
        
        # Critical hit chance (5-20% based on level)
        crit_chance = min(0.05 + (adventurer_level * 0.005), 0.20)
        
        # Special attack chance (10-30% based on level)
        special_chance = min(0.10 + (adventurer_level * 0.01), 0.30)
        
        roll = random.random()
        
        if roll < crit_chance:
            # Critical hit: 2-3x damage
            multiplier = random.uniform(2.0, 3.0)
            return int(base_damage * multiplier), "critical_hit"
        
        elif roll < crit_chance + special_chance:
            # Special attack: 1.5-2x damage
            multiplier = random.uniform(1.5, 2.0)
            return int(base_damage * multiplier), "special_attack"
        
        else:
            # Normal attack with variance
            variance = random.uniform(0.8, 1.2)
            damage = int(base_damage * variance)
            
            # Determine if it's low damage
            action_type = "low_damage" if damage < base_damage * 0.9 else "normal_attack"
            return damage, action_type
    
    def _scale_damage_for_dragon(self, damage: int, dragon_level: int) -> int:
        """Scale damage based on dragon difficulty"""
        # Higher level dragons have more defense
        defense_reduction = max(0.1, 1.0 - (dragon_level * 0.05))
        return max(1, int(damage * defense_reduction))
    
    def _generate_battle_message(
        self, 
        adventurer_name: str, 
        weapon_name: str, 
        action_type: str, 
        damage: int
    ) -> str:
        """Generate descriptive battle message"""
        
        messages = self.battle_messages.get(action_type, self.battle_messages['normal_attack'])
        template = random.choice(messages)
        
        message = template.format(
            adventurer=adventurer_name,
            weapon=weapon_name
        )
        
        # Add damage number
        if action_type == "critical_hit":
            message += f" Critical damage: {damage}!"
        elif action_type == "special_attack":
            message += f" Special damage: {damage}!"
        elif action_type == "low_damage":
            message += f" Damage: {damage}."
        else:
            message += f" Damage: {damage}!"
        
        return message
    
    def simulate_battle_round(
        self, 
        participants: List[DragonParticipant], 
        dragon_event: DragonEvent,
        current_battle_second: int
    ) -> List[BattleAction]:
        """
        Simulate one round of battle (typically 30 seconds)
        
        Returns list of battle actions that occurred
        """
        actions = []
        
        # Each participant attacks based on their adventurer's stats
        for participant in participants:
            if not participant.adventurer:
                continue
            
            # Calculate how many attacks this adventurer makes this round
            attacks_per_round = self._calculate_attacks_per_round(
                participant.adventurer.level
            )
            
            for attack_num in range(attacks_per_round):
                # Get adventurer's best weapon
                weapon = self._get_best_weapon(participant.player_id)
                
                # Calculate damage
                damage, action_type, message = self.calculate_adventurer_damage(
                    participant.adventurer,
                    weapon,
                    dragon_event.dragon_level
                )
                
                # Create battle action
                action = BattleAction(
                    participant_id=participant.id,
                    adventurer_name=participant.adventurer.name,
                    player_name=participant.player.name if participant.player else "Unknown",
                    action_type=action_type,
                    damage=damage,
                    message=message,
                    timestamp=datetime.utcnow()
                )
                
                actions.append(action)
        
        # Add occasional dragon retaliation messages
        if random.random() < 0.3:  # 30% chance per round
            dragon_message = random.choice(self.battle_messages['dragon_retaliation'])
            action = BattleAction(
                participant_id=0,  # 0 indicates dragon action
                adventurer_name="Dragon",
                player_name="",
                action_type="dragon_action",
                damage=0,
                message=dragon_message,
                timestamp=datetime.utcnow()
            )
            actions.append(action)
        
        # Sort actions by timestamp for realistic flow
        actions.sort(key=lambda x: x.timestamp)
        
        return actions
    
    def _calculate_attacks_per_round(self, adventurer_level: int) -> int:
        """Calculate how many attacks an adventurer makes per round"""
        # Base 1 attack, +1 every 10 levels, max 3
        base_attacks = 1
        level_bonus = adventurer_level // 10
        return min(3, base_attacks + level_bonus)
    
    def _get_best_weapon(self, player_id: int) -> Optional[PlayerWeapon]:
        """Get player's best weapon for battle"""
        # This would query the database for the player's best weapon
        # For now, returning None (will be implemented when integrated with DB)
        return None
    
    def calculate_battle_progress(
        self, 
        dragon_event: DragonEvent, 
        elapsed_seconds: int
    ) -> Dict:
        """
        Calculate overall battle progress and state
        
        Returns dictionary with battle status information
        """
        total_battle_seconds = dragon_event.battle_duration_minutes * 60
        remaining_seconds = max(0, total_battle_seconds - elapsed_seconds)
        
        # Calculate progress percentage
        time_progress = (elapsed_seconds / total_battle_seconds) * 100
        hp_progress = ((dragon_event.dragon_max_hp - dragon_event.dragon_current_hp) / 
                      dragon_event.dragon_max_hp) * 100
        
        # Determine if battle is complete
        is_complete = (dragon_event.dragon_current_hp <= 0 or remaining_seconds <= 0)
        is_victory = dragon_event.dragon_current_hp <= 0
        
        return {
            'elapsed_seconds': elapsed_seconds,
            'remaining_seconds': remaining_seconds,
            'time_progress_percent': min(100, time_progress),
            'hp_progress_percent': min(100, hp_progress),
            'is_complete': is_complete,
            'is_victory': is_victory,
            'dragon_hp_percent': (dragon_event.dragon_current_hp / dragon_event.dragon_max_hp) * 100
        }
    
    def generate_victory_message(self, is_victory: bool, participants_count: int) -> str:
        """Generate end-of-battle message"""
        if is_victory:
            messages = [
                f"Victory! The mighty dragon has been defeated by {participants_count} brave adventurers!",
                f"The dragon falls! {participants_count} heroes have saved the realm!",
                f"Against all odds, {participants_count} adventurers have triumphed over the ancient beast!",
                f"The dragon's roar is silenced forever! {participants_count} champions stand victorious!"
            ]
        else:
            messages = [
                f"Time has run out! Despite the valiant efforts of {participants_count} adventurers, the dragon remains standing.",
                f"The dragon survives another assault! {participants_count} brave souls fought with honor.",
                f"Though {participants_count} adventurers gave their all, the dragon proves too mighty to defeat.",
                f"The battle ends, but the dragon lives on! {participants_count} heroes retreat to fight another day."
            ]
        
        return random.choice(messages)