#!/usr/bin/env python3
"""
Database Schema Inspection Script
Compares current database schema with application models to identify mismatches
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text, inspect
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def inspect_database_schema():
    print('=== DATABASE SCHEMA INSPECTION ===')
    engine = create_engine(DATABASE_URL)
    
    try:
        with engine.connect() as conn:
            inspector = inspect(engine)
            
            print('\n1. EXISTING TABLES:')
            tables = inspector.get_table_names()
            for table in sorted(tables):
                print(f'  ✓ {table}')
            
            print('\n2. CRITICAL TABLES ANALYSIS:')
            
            # Check weapon_masters structure
            if 'weapon_masters' in tables:
                print('\n  WEAPON_MASTERS:')
                columns = inspector.get_columns('weapon_masters')
                for col in columns:
                    print(f'    {col["name"]}: {col["type"]} (nullable: {col["nullable"]})')
                
                # Check primary key type
                pk_columns = inspector.get_pk_constraint('weapon_masters')
                print(f'    Primary Key: {pk_columns}')
            else:
                print('  ❌ weapon_masters table does not exist')
            
            # Check material_masters structure  
            if 'material_masters' in tables:
                print('\n  MATERIAL_MASTERS:')
                columns = inspector.get_columns('material_masters')
                for col in columns:
                    print(f'    {col["name"]}: {col["type"]} (nullable: {col["nullable"]})')
            else:
                print('  ❌ material_masters table does not exist')
            
            # Check crafting_recipes structure
            if 'crafting_recipes' in tables:
                print('\n  CRAFTING_RECIPES:')
                columns = inspector.get_columns('crafting_recipes')
                for col in columns:
                    print(f'    {col["name"]}: {col["type"]} (nullable: {col["nullable"]})')
                
                # Check foreign keys
                fks = inspector.get_foreign_keys('crafting_recipes')
                print('    Foreign Keys:')
                for fk in fks:
                    print(f'      {fk["constrained_columns"]} -> {fk["referred_table"]}.{fk["referred_columns"]}')
            else:
                print('  ❌ crafting_recipes table does not exist')
            
            # Check rarity_levels structure
            if 'rarity_levels' in tables:
                print('\n  RARITY_LEVELS:')
                columns = inspector.get_columns('rarity_levels')
                for col in columns:
                    print(f'    {col["name"]}: {col["type"]} (nullable: {col["nullable"]})')
                
                # Check existing data
                result = conn.execute(text("SELECT id, name FROM rarity_levels ORDER BY id"))
                print('    Existing Data:')
                for row in result:
                    print(f'      {row[0]}: {row[1]}')
            else:
                print('  ❌ rarity_levels table does not exist')
            
            # Check weapon_types
            if 'weapon_types' in tables:
                print('\n  WEAPON_TYPES:')
                result = conn.execute(text("SELECT id, name FROM weapon_types ORDER BY id"))
                print('    Existing Data:')
                for row in result:
                    print(f'      {row[0]}: {row[1]}')
            else:
                print('  ❌ weapon_types table does not exist')
                
            print('\n3. APPLICATION MODEL REQUIREMENTS:')
            print('  WEAPON_MASTERS should have:')
            print('    - id: String(50) PRIMARY KEY')
            print('    - weapon_type_id: String(20) FK to weapon_types.id')
            print('    - rarity_id: String(20) FK to rarity_levels.id')
            
            print('\n  MATERIAL_MASTERS should have:')
            print('    - id: String(50) PRIMARY KEY')
            print('    - category: String(20)')
            print('    - emoji: String(10)')
            print('    - color_code: String(7)')
            print('    - rarity_id: String(20) FK to rarity_levels.id')
            
            print('\n  CRAFTING_RECIPES should have:')
            print('    - id: Integer PRIMARY KEY (autoincrement)')
            print('    - weapon_id: Integer FK to weapon_masters.id')
            print('    - name: String(100)')
            print('    - gold_cost: Integer')
            print('    - success_rate: Float')
            print('    - required_level: Integer')
            
            print('\n  RARITY_LEVELS should have:')
            print('    - id: String(20) PRIMARY KEY (common, rare, epic, legendary)')
            print('    - level: Integer')
            print('    - attack_multiplier: Numeric(3,2)')
            print('    - price_multiplier: Numeric(3,2)')
            
    except Exception as e:
        print(f'❌ Error connecting to database: {e}')
        print(f'Database URL: {DATABASE_URL}')
        print('\nPlease ensure:')
        print('1. PostgreSQL is running (docker-compose up -d)')
        print('2. Database connection string is correct')
        print('3. Database exists and is accessible')

if __name__ == '__main__':
    inspect_database_schema()