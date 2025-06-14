#!/usr/bin/env python3
"""
Database Schema Migration Script
Aligns current database schema with application models
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def migrate_schema():
    print('=== DATABASE SCHEMA MIGRATION ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            print('\n1. BACKING UP EXISTING DATA...')
            
            # Backup existing rarity mappings
            result = conn.execute(text("SELECT id, name FROM rarity_levels ORDER BY id"))
            rarity_mapping = {row[0]: row[1].lower() for row in result}
            print(f'   Rarity mapping: {rarity_mapping}')
            
            # Check existing crafting recipes
            result = conn.execute(text("SELECT COUNT(*) FROM crafting_recipes"))
            recipe_count = result.scalar()
            print(f'   Existing recipes: {recipe_count}')
            
            print('\n2. UPDATING RARITY_LEVELS TO USE STRING IDS...')
            
            # Create temporary table with new structure
            conn.execute(text("""
                CREATE TABLE rarity_levels_new (
                    id VARCHAR(20) PRIMARY KEY,
                    name VARCHAR(50) NOT NULL,
                    level INTEGER NOT NULL,
                    color_code VARCHAR(7),
                    star_display VARCHAR(10),
                    attack_multiplier NUMERIC(3,2) DEFAULT 1.00,
                    max_enchant_level INTEGER DEFAULT 10,
                    ability_slots INTEGER DEFAULT 0,
                    base_drop_rate NUMERIC(6,4) DEFAULT 0.6000,
                    price_multiplier NUMERIC(3,2) DEFAULT 1.00,
                    is_active BOOLEAN DEFAULT true,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """))
            
            # Insert data with string IDs
            conn.execute(text("""
                INSERT INTO rarity_levels_new (id, name, level, color_code, star_display, attack_multiplier, price_multiplier, is_active) VALUES
                ('common', 'Common', 1, '#9E9E9E', '★', 1.00, 1.00, true),
                ('rare', 'Rare', 2, '#2196F3', '★★', 1.20, 1.50, true),
                ('epic', 'Epic', 3, '#9C27B0', '★★★', 1.50, 2.00, true),
                ('legendary', 'Legendary', 4, '#FF9800', '★★★★', 2.00, 3.00, true)
            """))
            
            print('\n3. DROPPING FOREIGN KEY CONSTRAINTS TEMPORARILY...')
            
            # Drop foreign key constraints first
            conn.execute(text("ALTER TABLE weapon_masters DROP CONSTRAINT IF EXISTS weapon_masters_rarity_id_fkey"))
            conn.execute(text("ALTER TABLE material_masters DROP CONSTRAINT IF EXISTS material_masters_rarity_id_fkey"))
            
            print('\n4. UPDATING FOREIGN KEY REFERENCES...')
            
            # Update weapon_masters rarity references
            for old_id, new_id in [(1, 'common'), (2, 'rare'), (3, 'epic'), (4, 'legendary')]:
                conn.execute(text(f"UPDATE weapon_masters SET rarity_id = '{new_id}' WHERE rarity_id = '{old_id}'"))
            
            # Update material_masters rarity references  
            for old_id, new_id in [(1, 'common'), (2, 'rare'), (3, 'epic'), (4, 'legendary')]:
                conn.execute(text(f"UPDATE material_masters SET rarity_id = '{new_id}' WHERE rarity_id = '{old_id}'"))
            
            print('\n5. REPLACING RARITY TABLE WITH NEW STRUCTURE...')
            
            # Replace old table
            conn.execute(text("DROP TABLE rarity_levels"))
            conn.execute(text("ALTER TABLE rarity_levels_new RENAME TO rarity_levels"))
            
            # Recreate foreign key constraints with new table
            conn.execute(text("ALTER TABLE weapon_masters ADD CONSTRAINT weapon_masters_rarity_id_fkey FOREIGN KEY (rarity_id) REFERENCES rarity_levels(id)"))
            conn.execute(text("ALTER TABLE material_masters ADD CONSTRAINT material_masters_rarity_id_fkey FOREIGN KEY (rarity_id) REFERENCES rarity_levels(id)"))
            
            print('\n6. FIXING CRAFTING_RECIPES TABLE...')
            
            # Backup existing recipe data
            result = conn.execute(text("SELECT result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level FROM crafting_recipes"))
            recipe_data = list(result.fetchall())
            
            # Drop and recreate crafting_recipes with correct structure
            conn.execute(text("DROP TABLE IF EXISTS recipe_materials"))
            conn.execute(text("DROP TABLE crafting_recipes"))
            
            conn.execute(text("""
                CREATE TABLE crafting_recipes (
                    id SERIAL PRIMARY KEY,
                    weapon_id VARCHAR(50) NOT NULL REFERENCES weapon_masters(id),
                    name VARCHAR(100) NOT NULL,
                    description TEXT,
                    gold_cost INTEGER DEFAULT 0 NOT NULL,
                    success_rate REAL DEFAULT 1.0 NOT NULL,
                    required_level INTEGER DEFAULT 1 NOT NULL,
                    is_active BOOLEAN DEFAULT true NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    CONSTRAINT crafting_recipes_gold_cost_check CHECK (gold_cost >= 0),
                    CONSTRAINT crafting_recipes_success_rate_check CHECK (success_rate >= 0 AND success_rate <= 1),
                    CONSTRAINT crafting_recipes_required_level_check CHECK (required_level >= 1)
                )
            """))
            
            # Recreate recipe_materials table
            conn.execute(text("""
                CREATE TABLE recipe_materials (
                    recipe_id INTEGER NOT NULL REFERENCES crafting_recipes(id) ON DELETE CASCADE,
                    material_id VARCHAR(50) NOT NULL REFERENCES material_masters(id),
                    quantity INTEGER NOT NULL,
                    PRIMARY KEY (recipe_id, material_id),
                    CONSTRAINT recipe_materials_quantity_check CHECK (quantity > 0)
                )
            """))
            
            print('\n7. ENSURING ALL REQUIRED FIELDS EXIST...')
            
            # Check and add missing fields to material_masters if needed
            try:
                conn.execute(text("ALTER TABLE material_masters ADD COLUMN IF NOT EXISTS category VARCHAR(20)"))
                conn.execute(text("ALTER TABLE material_masters ADD COLUMN IF NOT EXISTS emoji VARCHAR(10)"))
                conn.execute(text("ALTER TABLE material_masters ADD COLUMN IF NOT EXISTS color_code VARCHAR(7)"))
                conn.execute(text("ALTER TABLE material_masters ADD COLUMN IF NOT EXISTS price_volatility NUMERIC(3,2) DEFAULT 0.1"))
                conn.execute(text("ALTER TABLE material_masters ADD COLUMN IF NOT EXISTS stack_size INTEGER DEFAULT 999"))
            except Exception as e:
                print(f'   Note: Some columns may already exist: {e}')
            
            print('\n✅ SCHEMA MIGRATION COMPLETED SUCCESSFULLY!')
            print('\nNext steps:')
            print('1. Run reference data seeds (weapon_types, rarity_levels already done)')
            print('2. Run adapted seeds for weapons, materials, recipes')
            print('3. Verify data integrity')
            
        except Exception as e:
            print(f'❌ Migration failed: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    migrate_schema()