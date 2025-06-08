"""
Adventurer System Migration Tool

This module handles the migration from the current temporary instance-based 
adventurer system to the new permanent character-based system with trust levels.
"""

import json
import logging
from typing import Dict, List, Tuple, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.core.database import get_db, SessionLocal
from app.models.adventurer_instance import (
    AdventurerInstance, AdventurerRequest, AdventurerQuest, AdventurerPurchase
)
from app.models.adventurer_character import (
    AdventurerCharacter, PlayerAdventurerRelation, AdventurerVisit, 
    AdventurerTransaction, TrustLevel
)
from app.models.adventurer_master import AdventurerMaster
from app.core.trust_system import TrustCalculator, TrustEventProcessor, TrustEvent

logger = logging.getLogger(__name__)


class AdventurerMigrationTool:
    """
    Tool for migrating from the old adventurer instance system 
    to the new permanent character system
    """
    
    def __init__(self):
        self.migration_log = []
        self.errors = []
        self.warnings = []
    
    def analyze_current_data(self, db: Session) -> Dict:
        """
        Analyze current adventurer data to prepare for migration
        
        Returns:
            Dictionary with analysis results
        """
        analysis = {
            "current_instances": 0,
            "unique_adventurer_names": set(),
            "player_interactions": {},
            "total_transactions": 0,
            "date_range": {"earliest": None, "latest": None},
            "profession_distribution": {},
            "estimated_relationships": 0
        }
        
        # Count total instances
        analysis["current_instances"] = db.query(func.count(AdventurerInstance.id)).scalar() or 0
        
        # Analyze unique adventurers
        instances = db.query(AdventurerInstance).all()
        for instance in instances:
            analysis["unique_adventurer_names"].add(instance.name)
            
            # Track profession distribution
            profession = instance.profession
            analysis["profession_distribution"][profession] = \
                analysis["profession_distribution"].get(profession, 0) + 1
            
            # Track player interactions
            player_id = instance.player_id
            if player_id not in analysis["player_interactions"]:
                analysis["player_interactions"][player_id] = {
                    "adventurer_names": set(),
                    "total_interactions": 0,
                    "successful_transactions": 0
                }
            
            analysis["player_interactions"][player_id]["adventurer_names"].add(instance.name)
            analysis["player_interactions"][player_id]["total_interactions"] += 1
            
            # Update date range
            created_at = instance.created_at
            if analysis["date_range"]["earliest"] is None or created_at < analysis["date_range"]["earliest"]:
                analysis["date_range"]["earliest"] = created_at
            if analysis["date_range"]["latest"] is None or created_at > analysis["date_range"]["latest"]:
                analysis["date_range"]["latest"] = created_at
        
        # Count transactions
        analysis["total_transactions"] = db.query(func.count(AdventurerPurchase.id)).scalar() or 0
        
        # Estimate relationships (unique player-adventurer combinations)
        for player_data in analysis["player_interactions"].values():
            analysis["estimated_relationships"] += len(player_data["adventurer_names"])
        
        # Convert sets to counts for JSON serialization
        analysis["unique_adventurer_count"] = len(analysis["unique_adventurer_names"])
        analysis["unique_adventurer_names"] = list(analysis["unique_adventurer_names"])
        
        for player_id, data in analysis["player_interactions"].items():
            data["unique_adventurers"] = len(data["adventurer_names"])
            data["adventurer_names"] = list(data["adventurer_names"])
        
        return analysis
    
    def create_adventurer_characters_from_instances(self, db: Session, dry_run: bool = True) -> List[Dict]:
        """
        Create AdventurerCharacter records from unique adventurer instances
        
        Args:
            db: Database session
            dry_run: If True, don't actually create records
            
        Returns:
            List of character creation results
        """
        results = []
        
        # Group instances by name to find unique adventurers
        adventurer_groups = {}
        instances = db.query(AdventurerInstance).all()
        
        for instance in instances:
            name = instance.name
            if name not in adventurer_groups:
                adventurer_groups[name] = []
            adventurer_groups[name].append(instance)
        
        # Create characters from unique names
        for name, instances_list in adventurer_groups.items():
            # Use the most recent instance as the base
            base_instance = max(instances_list, key=lambda x: x.created_at)
            
            # Calculate aggregated stats
            total_level_sum = sum(inst.level for inst in instances_list)
            avg_level = total_level_sum // len(instances_list)
            
            # Determine profession (most common)
            profession_counts = {}
            for inst in instances_list:
                prof = inst.profession
                profession_counts[prof] = profession_counts.get(prof, 0) + 1
            most_common_profession = max(profession_counts.items(), key=lambda x: x[1])[0]
            
            # Create character data
            character_data = {
                "name": name,
                "profession": most_common_profession,
                "level": max(1, avg_level),
                "personality": base_instance.personality or "normal",
                "base_attack": base_instance.attack or 100,
                "base_defense": 50,  # Default
                "base_hp": 200,     # Default
                "preferred_weapon_types": [base_instance.preferred_weapon_type] if base_instance.preferred_weapon_type else ["sword"],
                "budget_base": base_instance.budget or 1000,
                "budget_variance": 0.2,
                "negotiation_skill": 1.0,
                "visit_frequency_hours": 24,
                "stay_duration_minutes": 30,
                "urgency_tendency": 3,
                "min_player_level": 1,
                "experience_points": len(instances_list) * 10,  # Based on appearances
                "total_trades_completed": 0,  # Will be calculated from purchases
                "total_gold_spent": 0,
                "is_active": True
            }
            
            if not dry_run:
                # Create the character
                character = AdventurerCharacter(**character_data)
                db.add(character)
                db.flush()  # Get the ID
                character_data["id"] = character.id
                
                # Store mapping for later use
                for instance in instances_list:
                    instance.migrated_character_id = character.id
            
            results.append({
                "action": "create_character",
                "name": name,
                "data": character_data,
                "source_instances": len(instances_list),
                "dry_run": dry_run
            })
        
        if not dry_run:
            db.commit()
        
        return results
    
    def create_player_relationships(self, db: Session, dry_run: bool = True) -> List[Dict]:
        """
        Create PlayerAdventurerRelation records from instance history
        
        Args:
            db: Database session
            dry_run: If True, don't actually create records
            
        Returns:
            List of relationship creation results
        """
        results = []
        
        # Group instances by player_id and character
        player_adventurer_groups = {}
        instances = db.query(AdventurerInstance).all()
        
        for instance in instances:
            player_id = instance.player_id
            adventurer_name = instance.name
            
            if player_id not in player_adventurer_groups:
                player_adventurer_groups[player_id] = {}
            
            if adventurer_name not in player_adventurer_groups[player_id]:
                player_adventurer_groups[player_id][adventurer_name] = []
            
            player_adventurer_groups[player_id][adventurer_name].append(instance)
        
        # Create relationships
        for player_id, adventurer_groups in player_adventurer_groups.items():
            for adventurer_name, instances_list in adventurer_groups.items():
                # Find the corresponding character
                character = db.query(AdventurerCharacter).filter(
                    AdventurerCharacter.name == adventurer_name
                ).first()
                
                if not character:
                    self.warnings.append(f"No character found for adventurer '{adventurer_name}'")
                    continue
                
                # Calculate relationship stats from instances
                total_interactions = len(instances_list)
                
                # Calculate trust level based on interaction history
                estimated_trust = self._estimate_trust_level(instances_list, db)
                
                # Get purchase history for this relationship
                purchase_stats = self._calculate_purchase_stats(instances_list, db)
                
                # Calculate dates
                first_interaction = min(inst.created_at for inst in instances_list)
                last_interaction = max(inst.created_at for inst in instances_list)
                
                relationship_data = {
                    "player_id": player_id,
                    "adventurer_id": character.id,
                    "trust_level": estimated_trust,
                    "relationship_status": self._get_trust_tier_name(estimated_trust),
                    "total_interactions": total_interactions,
                    "successful_trades": purchase_stats["successful_purchases"],
                    "failed_negotiations": 0,  # Not tracked in old system
                    "total_gold_traded": purchase_stats["total_gold"],
                    "total_items_sold": purchase_stats["total_items"],
                    "total_items_bought": 0,
                    "first_met_at": first_interaction,
                    "last_interaction_at": last_interaction,
                    "last_visit_at": last_interaction
                }
                
                if not dry_run:
                    # Create the relationship
                    relation = PlayerAdventurerRelation(**relationship_data)
                    db.add(relation)
                    db.flush()
                    relationship_data["id"] = relation.id
                
                results.append({
                    "action": "create_relationship",
                    "player_id": player_id,
                    "adventurer_name": adventurer_name,
                    "data": relationship_data,
                    "source_instances": total_interactions,
                    "dry_run": dry_run
                })
        
        if not dry_run:
            db.commit()
        
        return results
    
    def migrate_active_visits(self, db: Session, dry_run: bool = True) -> List[Dict]:
        """
        Convert active adventurer instances to visits
        
        Args:
            db: Database session
            dry_run: If True, don't actually create records
            
        Returns:
            List of visit migration results
        """
        results = []
        
        # Find active instances (those with recent activity)
        cutoff_time = datetime.utcnow() - timedelta(hours=2)
        active_instances = db.query(AdventurerInstance).filter(
            AdventurerInstance.created_at >= cutoff_time
        ).all()
        
        for instance in active_instances:
            # Find the corresponding character and relationship
            character = db.query(AdventurerCharacter).filter(
                AdventurerCharacter.name == instance.name
            ).first()
            
            if not character:
                continue
            
            relation = db.query(PlayerAdventurerRelation).filter(
                and_(
                    PlayerAdventurerRelation.player_id == instance.player_id,
                    PlayerAdventurerRelation.adventurer_id == character.id
                )
            ).first()
            
            if not relation:
                continue
            
            # Create visit data
            visit_data = {
                "player_id": instance.player_id,
                "adventurer_id": character.id,
                "relation_id": relation.id,
                "visit_start_time": instance.created_at,
                "planned_duration_minutes": character.stay_duration_minutes,
                "visit_purpose": "trade",
                "current_status": "browsing",
                "budget_for_visit": instance.budget or character.budget_base,
                "urgency_level": 3
            }
            
            # Add weapon request if available
            if hasattr(instance, 'current_request') and instance.current_request:
                visit_data["weapon_request"] = {
                    "weapon_type": instance.preferred_weapon_type,
                    "min_attack": instance.min_attack_requirement or 0,
                    "max_budget": instance.budget or 0
                }
            
            if not dry_run:
                visit = AdventurerVisit(**visit_data)
                db.add(visit)
                db.flush()
                visit_data["id"] = visit.id
            
            results.append({
                "action": "create_visit",
                "instance_id": instance.id,
                "data": visit_data,
                "dry_run": dry_run
            })
        
        if not dry_run:
            db.commit()
        
        return results
    
    def _estimate_trust_level(self, instances: List[AdventurerInstance], db: Session) -> int:
        """
        Estimate trust level based on interaction history
        
        Args:
            instances: List of adventurer instances for this relationship
            db: Database session
            
        Returns:
            Estimated trust level (0-100)
        """
        base_trust = 10  # Starting trust
        
        # Trust increases with number of interactions
        interaction_bonus = min(30, len(instances) * 2)
        
        # Trust increases with successful purchases
        successful_purchases = 0
        for instance in instances:
            purchases = db.query(AdventurerPurchase).filter(
                AdventurerPurchase.adventurer_instance_id == instance.id
            ).count()
            successful_purchases += purchases
        
        purchase_bonus = min(40, successful_purchases * 5)
        
        # Trust increases with time (repeat customer)
        if len(instances) > 1:
            date_span = (max(inst.created_at for inst in instances) - 
                        min(inst.created_at for inst in instances)).days
            if date_span > 7:  # Repeat customer over time
                time_bonus = min(20, date_span // 7 * 3)
            else:
                time_bonus = 0
        else:
            time_bonus = 0
        
        total_trust = base_trust + interaction_bonus + purchase_bonus + time_bonus
        return min(100, max(0, total_trust))
    
    def _get_trust_tier_name(self, trust_level: int) -> str:
        """Get trust tier name for a trust level"""
        if trust_level >= 80:
            return "partner"
        elif trust_level >= 60:
            return "trusted"
        elif trust_level >= 40:
            return "friend"
        elif trust_level >= 20:
            return "acquaintance"
        else:
            return "stranger"
    
    def _calculate_purchase_stats(self, instances: List[AdventurerInstance], db: Session) -> Dict:
        """
        Calculate purchase statistics for instances
        
        Args:
            instances: List of adventurer instances
            db: Database session
            
        Returns:
            Dictionary with purchase statistics
        """
        stats = {
            "successful_purchases": 0,
            "total_gold": 0,
            "total_items": 0
        }
        
        for instance in instances:
            purchases = db.query(AdventurerPurchase).filter(
                AdventurerPurchase.adventurer_instance_id == instance.id
            ).all()
            
            stats["successful_purchases"] += len(purchases)
            for purchase in purchases:
                stats["total_gold"] += purchase.purchase_price or 0
                stats["total_items"] += 1
        
        return stats
    
    def execute_full_migration(self, dry_run: bool = True) -> Dict:
        """
        Execute the complete migration process
        
        Args:
            dry_run: If True, don't actually modify data
            
        Returns:
            Migration results summary
        """
        db = SessionLocal()
        try:
            migration_results = {
                "dry_run": dry_run,
                "started_at": datetime.utcnow(),
                "analysis": {},
                "characters_created": [],
                "relationships_created": [],
                "visits_migrated": [],
                "errors": [],
                "warnings": []
            }
            
            # Step 1: Analyze current data
            logger.info("Starting migration analysis...")
            migration_results["analysis"] = self.analyze_current_data(db)
            
            # Step 2: Create characters from instances
            logger.info("Creating adventurer characters...")
            migration_results["characters_created"] = self.create_adventurer_characters_from_instances(db, dry_run)
            
            # Step 3: Create relationships
            logger.info("Creating player relationships...")
            migration_results["relationships_created"] = self.create_player_relationships(db, dry_run)
            
            # Step 4: Migrate active visits
            logger.info("Migrating active visits...")
            migration_results["visits_migrated"] = self.migrate_active_visits(db, dry_run)
            
            migration_results["completed_at"] = datetime.utcnow()
            migration_results["errors"] = self.errors
            migration_results["warnings"] = self.warnings
            
            logger.info(f"Migration completed. Dry run: {dry_run}")
            return migration_results
            
        except Exception as e:
            logger.error(f"Migration failed: {str(e)}")
            migration_results["errors"].append(str(e))
            if not dry_run:
                db.rollback()
            raise
        finally:
            db.close()
    
    def create_default_adventurer_masters(self, db: Session) -> List[Dict]:
        """
        Create default AdventurerMaster records for the new system
        
        Args:
            db: Database session
            
        Returns:
            List of created masters
        """
        default_masters = [
            {
                "name": "ガレス",
                "profession": "warrior",
                "level": 15,
                "personality": "generous",
                "trust_level": 50,
                "budget_min": 800,
                "budget_max": 2000,
                "preferred_weapon_type": "sword",
                "min_attack_requirement": 150,
                "min_player_level": 5,
                "tier": "normal"
            },
            {
                "name": "エルフィン",
                "profession": "archer",
                "level": 12,
                "personality": "normal",
                "trust_level": 50,
                "budget_min": 600,
                "budget_max": 1500,
                "preferred_weapon_type": "bow",
                "min_attack_requirement": 120,
                "min_player_level": 3,
                "tier": "normal"
            },
            {
                "name": "ウィザード・ザクロ",
                "profession": "mage",
                "level": 20,
                "personality": "wealthy",
                "trust_level": 50,
                "budget_min": 1200,
                "budget_max": 3000,
                "preferred_weapon_type": "staff",
                "min_attack_requirement": 180,
                "min_player_level": 8,
                "tier": "challenge"
            },
            {
                "name": "シャドウ",
                "profession": "rogue",
                "level": 18,
                "personality": "stingy",
                "trust_level": 50,
                "budget_min": 400,
                "budget_max": 1200,
                "preferred_weapon_type": "dagger",
                "min_attack_requirement": 160,
                "min_player_level": 6,
                "tier": "normal"
            },
            {
                "name": "聖騎士アルトリア",
                "profession": "paladin",
                "level": 25,
                "personality": "generous",
                "trust_level": 50,
                "budget_min": 1500,
                "budget_max": 4000,
                "preferred_weapon_type": "sword",
                "min_attack_requirement": 200,
                "min_player_level": 10,
                "tier": "elite"
            }
        ]
        
        created_masters = []
        for master_data in default_masters:
            master = AdventurerMaster(**master_data)
            db.add(master)
            db.flush()
            created_masters.append({
                "id": master.id,
                "name": master.name,
                "data": master_data
            })
        
        db.commit()
        return created_masters


# Global migration tool instance
migration_tool = AdventurerMigrationTool()