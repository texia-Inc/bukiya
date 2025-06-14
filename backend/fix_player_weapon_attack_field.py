#!/usr/bin/env python3
"""
Fix player_weapon attack field migration script.
Populates the 'attack' field from 'base_attack' for all existing player weapons.
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add parent directory to path for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)

from app.models.player_weapon import PlayerWeapon
from app.core.database import engine, SessionLocal

def fix_attack_field():
    """Update all player_weapons records to set attack = base_attack where attack is NULL"""
    db = SessionLocal()
    try:
        # Update all records where attack is NULL
        result = db.execute(
            text("UPDATE player_weapons SET attack = base_attack WHERE attack IS NULL")
        )
        
        print(f"Updated {result.rowcount} player weapon records to fix attack field")
        
        # Verify the fix
        null_count = db.execute(
            text("SELECT COUNT(*) FROM player_weapons WHERE attack IS NULL")
        ).scalar()
        
        total_count = db.execute(
            text("SELECT COUNT(*) FROM player_weapons")
        ).scalar()
        
        print(f"After fix: {null_count} records still have NULL attack field out of {total_count} total records")
        
        db.commit()
        
    except Exception as e:
        print(f"Error fixing attack field: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("Starting player weapon attack field fix...")
    fix_attack_field()
    print("Attack field fix completed!")