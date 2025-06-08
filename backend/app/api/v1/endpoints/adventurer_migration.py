"""
Adventurer Migration API Endpoints

This module provides endpoints for migrating from the old adventurer instance
system to the new permanent character-based system.
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import Dict, Any

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models.player import Player
from app.core.adventurer_migration import migration_tool
from app.schemas.adventurer_character import MigrationPreviewResponse, MigrationExecuteRequest

router = APIRouter()


@router.get("/preview", response_model=Dict[str, Any])
def preview_migration(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Preview what would happen during migration without making changes
    """
    # Only allow admin users to preview migration
    # if not current_player.email.endswith("@admin"):  # Simple admin check
    #     raise HTTPException(status_code=403, detail="Admin access required")
    
    try:
        analysis = migration_tool.analyze_current_data(db)
        
        # Estimate trust levels for preview
        estimated_trust_levels = {}
        for player_id, data in analysis.get("player_interactions", {}).items():
            for adventurer_name in data["adventurer_names"]:
                # Simple estimation based on interactions
                interactions = data["total_interactions"]
                estimated_trust = min(100, 10 + interactions * 3)
                estimated_trust_levels[f"{player_id}_{adventurer_name}"] = estimated_trust
        
        preview = {
            "current_instances": analysis["current_instances"],
            "unique_adventurers": analysis["unique_adventurer_count"],
            "total_relationships": analysis["estimated_relationships"],
            "data_preserved": [
                "Adventurer names and professions",
                "Player interaction history",
                "Purchase transaction records",
                "Quest completion data"
            ],
            "estimated_trust_levels": estimated_trust_levels,
            "migration_warnings": [
                "Current adventurer instances will be converted to permanent characters",
                "Some data may be lost during conversion (temporary states)",
                "Trust levels are estimated based on interaction history",
                "Active visits will be preserved"
            ],
            "profession_distribution": analysis["profession_distribution"],
            "date_range": analysis["date_range"]
        }
        
        return preview
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to preview migration: {str(e)}")


@router.post("/execute")
def execute_migration(
    migration_request: MigrationExecuteRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Execute the migration from old to new adventurer system
    """
    # Only allow admin users to execute migration
    if not current_player.email.endswith("@admin"):
        raise HTTPException(status_code=403, detail="Admin access required")
    
    if not migration_request.confirm_data_loss and not migration_request.dry_run:
        raise HTTPException(
            status_code=400, 
            detail="Must confirm data loss understanding or use dry_run mode"
        )
    
    try:
        # Execute migration
        if migration_request.dry_run:
            # Execute as dry run
            results = migration_tool.execute_full_migration(dry_run=True)
        else:
            # Execute actual migration in background
            background_tasks.add_task(
                _execute_migration_background,
                migration_request.preserve_current_visits,
                migration_request.recalculate_trust
            )
            
            return {
                "message": "Migration started in background",
                "dry_run": False,
                "preserve_current_visits": migration_request.preserve_current_visits,
                "recalculate_trust": migration_request.recalculate_trust
            }
        
        return {
            "message": "Migration completed" if not migration_request.dry_run else "Dry run completed",
            "results": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Migration failed: {str(e)}")


@router.post("/create-default-masters")
def create_default_adventurer_masters(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Create default adventurer master records for the new system
    """
    # Only allow admin users
    if not current_player.email.endswith("@admin"):
        raise HTTPException(status_code=403, detail="Admin access required")
    
    try:
        created_masters = migration_tool.create_default_adventurer_masters(db)
        
        return {
            "message": f"Created {len(created_masters)} default adventurer masters",
            "masters": created_masters
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create masters: {str(e)}")


@router.get("/status")
def get_migration_status(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """
    Get current migration status and system state
    """
    # Check if migration has been run
    from app.models.adventurer_character import AdventurerCharacter, PlayerAdventurerRelation
    from app.models.adventurer_instance import AdventurerInstance
    
    old_instances_count = db.query(AdventurerInstance).count()
    new_characters_count = db.query(AdventurerCharacter).count()
    relationships_count = db.query(PlayerAdventurerRelation).count()
    
    # Determine system state
    if new_characters_count == 0 and old_instances_count > 0:
        system_state = "old_system"
        migration_needed = True
    elif new_characters_count > 0 and old_instances_count > 0:
        system_state = "transitional"
        migration_needed = False  # Migration partially complete
    elif new_characters_count > 0 and old_instances_count == 0:
        system_state = "new_system"
        migration_needed = False
    else:
        system_state = "empty"
        migration_needed = False
    
    return {
        "system_state": system_state,
        "migration_needed": migration_needed,
        "old_instances_count": old_instances_count,
        "new_characters_count": new_characters_count,
        "relationships_count": relationships_count,
        "can_use_new_features": new_characters_count > 0
    }


def _execute_migration_background(preserve_visits: bool, recalculate_trust: bool):
    """
    Execute migration in background task
    """
    try:
        # Execute full migration
        results = migration_tool.execute_full_migration(dry_run=False)
        
        # Log results
        import logging
        logger = logging.getLogger(__name__)
        logger.info(f"Background migration completed: {results}")
        
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Background migration failed: {str(e)}")