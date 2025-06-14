#!/usr/bin/env python3
"""
Database migration script to fix adventurer system schema issues.
This script fixes data type mismatches and creates missing tables safely.
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text, inspect
from app.core.config import settings

def main():
    print('🔧 Starting database migration to fix adventurer system...')
    
    # Use localhost for local script execution
    db_url = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"
    engine = create_engine(db_url)
    inspector = inspect(engine)
    
    with engine.begin() as conn:
        try:
            # 1. Check and fix adventurer_masters table
            print("📋 Checking adventurer_masters table...")
            if 'adventurer_masters' not in inspector.get_table_names():
                print("⚠️  adventurer_masters table doesn't exist. Creating...")
                conn.execute(text("""
                    CREATE TABLE adventurer_masters (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        profession VARCHAR(50) NOT NULL,
                        level INTEGER NOT NULL DEFAULT 1,
                        personality VARCHAR(50) NOT NULL,
                        trust_level INTEGER NOT NULL DEFAULT 50,
                        budget_min INTEGER NOT NULL DEFAULT 500,
                        budget_max INTEGER NOT NULL DEFAULT 2000,
                        preferred_weapon_type VARCHAR(50) NOT NULL,
                        avatar_url VARCHAR(255),
                        description TEXT,
                        min_attack_requirement INTEGER NOT NULL DEFAULT 100,
                        max_budget_multiplier FLOAT NOT NULL DEFAULT 1.0,
                        urgency_tendency INTEGER NOT NULL DEFAULT 3,
                        spawn_weight INTEGER NOT NULL DEFAULT 100,
                        min_player_level INTEGER NOT NULL DEFAULT 1,
                        max_player_level INTEGER,
                        tier VARCHAR(20) NOT NULL DEFAULT 'normal',
                        progression_multiplier FLOAT NOT NULL DEFAULT 1.0,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE INDEX idx_adventurer_masters_name ON adventurer_masters(name);
                    CREATE INDEX idx_adventurer_masters_active ON adventurer_masters(is_active);
                """))
                print("✅ adventurer_masters table created")
            else:
                print("✅ adventurer_masters table exists")

            # 2. Check for missing columns in adventurer_masters
            print("🔍 Checking adventurer_masters columns...")
            columns = [col['name'] for col in inspector.get_columns('adventurer_masters')]
            missing_columns = []
            
            expected_columns = {
                'tier': "VARCHAR(20) NOT NULL DEFAULT 'normal'",
                'progression_multiplier': "FLOAT NOT NULL DEFAULT 1.0",
                'spawn_weight': "INTEGER NOT NULL DEFAULT 100",
                'min_player_level': "INTEGER NOT NULL DEFAULT 1",
                'max_player_level': "INTEGER",
                'min_attack_requirement': "INTEGER NOT NULL DEFAULT 100",
                'max_budget_multiplier': "FLOAT NOT NULL DEFAULT 1.0",
                'urgency_tendency': "INTEGER NOT NULL DEFAULT 3"
            }
            
            for col_name, col_def in expected_columns.items():
                if col_name not in columns:
                    missing_columns.append((col_name, col_def))
            
            if missing_columns:
                print(f"📝 Adding {len(missing_columns)} missing columns to adventurer_masters...")
                for col_name, col_def in missing_columns:
                    conn.execute(text(f"ALTER TABLE adventurer_masters ADD COLUMN {col_name} {col_def}"))
                    print(f"   ✅ Added {col_name}")
            else:
                print("✅ All required columns exist in adventurer_masters")

            # 3. Create missing master tables
            print("🏗️  Creating additional master tables...")
            
            # Monster Masters
            if 'monster_masters' not in inspector.get_table_names():
                conn.execute(text("""
                    CREATE TABLE monster_masters (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        monster_type VARCHAR(50) NOT NULL,
                        level INTEGER NOT NULL DEFAULT 1,
                        hp INTEGER NOT NULL DEFAULT 100,
                        attack INTEGER NOT NULL DEFAULT 50,
                        defense INTEGER NOT NULL DEFAULT 20,
                        element VARCHAR(50),
                        weakness VARCHAR(50),
                        resistance VARCHAR(50),
                        spawn_areas VARCHAR(255) NOT NULL,
                        spawn_weight INTEGER NOT NULL DEFAULT 100,
                        min_required_weapon_level INTEGER NOT NULL DEFAULT 0,
                        base_gold_reward INTEGER NOT NULL DEFAULT 100,
                        experience_reward INTEGER NOT NULL DEFAULT 50,
                        image_url VARCHAR(255),
                        description TEXT,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE INDEX idx_monster_masters_name ON monster_masters(name);
                """))
                print("✅ monster_masters table created")

            # Quest Area Masters
            if 'quest_area_masters' not in inspector.get_table_names():
                conn.execute(text("""
                    CREATE TABLE quest_area_masters (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR(100) NOT NULL,
                        area_type VARCHAR(50) NOT NULL,
                        difficulty INTEGER NOT NULL DEFAULT 1,
                        required_level INTEGER NOT NULL DEFAULT 1,
                        duration_minutes INTEGER NOT NULL DEFAULT 60,
                        image_url VARCHAR(255),
                        background_color VARCHAR(7) NOT NULL DEFAULT '#4CAF50',
                        description TEXT,
                        unlock_condition VARCHAR(255),
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        display_order INTEGER NOT NULL DEFAULT 0,
                        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE INDEX idx_quest_area_masters_name ON quest_area_masters(name);
                """))
                print("✅ quest_area_masters table created")

            # Monster Drop Tables
            if 'monster_drop_tables' not in inspector.get_table_names():
                conn.execute(text("""
                    CREATE TABLE monster_drop_tables (
                        id SERIAL PRIMARY KEY,
                        monster_id INTEGER NOT NULL,
                        item_type VARCHAR(50) NOT NULL,
                        item_id INTEGER NOT NULL,
                        drop_rate FLOAT NOT NULL DEFAULT 0.1,
                        min_quantity INTEGER NOT NULL DEFAULT 1,
                        max_quantity INTEGER NOT NULL DEFAULT 1,
                        required_weapon_enchant INTEGER NOT NULL DEFAULT 0,
                        required_adventurer_level INTEGER NOT NULL DEFAULT 1,
                        is_active BOOLEAN NOT NULL DEFAULT TRUE,
                        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE INDEX idx_monster_drop_tables_monster_id ON monster_drop_tables(monster_id);
                """))
                print("✅ monster_drop_tables table created")

            # 4. Fix or create adventurer_instances table with correct data types
            print("🔧 Fixing adventurer_instances table...")
            if 'adventurer_instances' in inspector.get_table_names():
                # Check the current structure
                columns = inspector.get_columns('adventurer_instances')
                col_dict = {col['name']: col for col in columns}
                
                # Check if adventurer_master_id has wrong type
                if 'adventurer_master_id' in col_dict:
                    col_type = str(col_dict['adventurer_master_id']['type'])
                    if 'VARCHAR' in col_type or 'TEXT' in col_type:
                        print("⚠️  adventurer_master_id has wrong type. Recreating table...")
                        # Drop and recreate with correct types
                        conn.execute(text("DROP TABLE IF EXISTS adventurer_instances CASCADE"))
                        create_adventurer_instances_table(conn)
                    else:
                        print("✅ adventurer_instances has correct data types")
                else:
                    print("⚠️  adventurer_master_id column missing. Recreating table...")
                    conn.execute(text("DROP TABLE IF EXISTS adventurer_instances CASCADE"))
                    create_adventurer_instances_table(conn)
            else:
                print("📝 Creating adventurer_instances table...")
                create_adventurer_instances_table(conn)

            # 5. Create remaining adventurer system tables
            create_adventurer_system_tables(conn, inspector)

            # 6. Create or update indexes and triggers
            print("🔗 Creating indexes and triggers...")
            create_indexes_and_triggers(conn)

            print("✅ Database migration completed successfully!")
            
            # 7. Verify the schema
            print("\n📊 Verifying schema...")
            verify_schema(conn)
            
        except Exception as e:
            print(f"❌ Error during migration: {e}")
            import traceback
            traceback.print_exc()
            raise

def create_adventurer_instances_table(conn):
    """Create adventurer_instances table with correct data types"""
    conn.execute(text("""
        CREATE TABLE adventurer_instances (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            adventurer_master_id INTEGER REFERENCES adventurer_masters(id),
            player_id UUID REFERENCES players(id) ON DELETE SET NULL,
            name VARCHAR(100) NOT NULL,
            level INTEGER NOT NULL DEFAULT 1,
            trust_level INTEGER NOT NULL DEFAULT 0,
            status VARCHAR(20) NOT NULL DEFAULT 'idle',
            current_quest_id UUID,
            visit_start_time TIMESTAMP WITH TIME ZONE,
            visit_end_time TIMESTAMP WITH TIME ZONE,
            is_named_character BOOLEAN DEFAULT FALSE,
            character_id INTEGER,
            generic_name VARCHAR(100),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
    """))
    print("✅ adventurer_instances table created with correct types")

def create_adventurer_system_tables(conn, inspector):
    """Create all adventurer system related tables"""
    
    # Adventurer Requests
    if 'adventurer_requests' not in inspector.get_table_names():
        conn.execute(text("""
            CREATE TABLE adventurer_requests (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                weapon_type VARCHAR(50) NOT NULL,
                min_attack INTEGER NOT NULL,
                max_budget INTEGER NOT NULL,
                preferred_rarity VARCHAR(20),
                urgency INTEGER NOT NULL DEFAULT 3,
                description TEXT,
                deadline TIMESTAMP WITH TIME ZONE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pending',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """))
        print("✅ adventurer_requests table created")

    # Adventurer Quests
    if 'adventurer_quests' not in inspector.get_table_names():
        conn.execute(text("""
            CREATE TABLE adventurer_quests (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                quest_area_id INTEGER NOT NULL REFERENCES quest_area_masters(id),
                player_weapon_id UUID REFERENCES player_weapons(id),
                monster_id INTEGER REFERENCES monster_masters(id),
                target_material_id INTEGER REFERENCES material_masters(id),
                target_material_boost FLOAT DEFAULT 1.0,
                target_cost INTEGER DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
                start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                end_time TIMESTAMP WITH TIME ZONE,
                success BOOLEAN,
                gold_earned INTEGER DEFAULT 0,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """))
        print("✅ adventurer_quests table created")

    # Quest Rewards
    if 'quest_rewards' not in inspector.get_table_names():
        conn.execute(text("""
            CREATE TABLE quest_rewards (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_quest_id UUID NOT NULL REFERENCES adventurer_quests(id) ON DELETE CASCADE,
                item_type VARCHAR(20) NOT NULL,
                item_id VARCHAR(50) NOT NULL,
                quantity INTEGER NOT NULL DEFAULT 1,
                buyback_price INTEGER,
                buyback_deadline TIMESTAMP WITH TIME ZONE,
                is_bought BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """))
        print("✅ quest_rewards table created")

    # Adventurer Purchases
    if 'adventurer_purchases' not in inspector.get_table_names():
        conn.execute(text("""
            CREATE TABLE adventurer_purchases (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                player_weapon_id UUID NOT NULL REFERENCES player_weapons(id),
                price INTEGER NOT NULL,
                purchased_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """))
        print("✅ adventurer_purchases table created")

def create_indexes_and_triggers(conn):
    """Create indexes and update triggers"""
    
    # Create indexes
    indexes = [
        "CREATE INDEX IF NOT EXISTS idx_adventurer_instances_player_id ON adventurer_instances(player_id)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_instances_status ON adventurer_instances(status)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_instances_master_id ON adventurer_instances(adventurer_master_id)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_requests_adventurer_id ON adventurer_requests(adventurer_instance_id)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_requests_status ON adventurer_requests(status)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_quests_adventurer_id ON adventurer_quests(adventurer_instance_id)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_quests_status ON adventurer_quests(status)",
        "CREATE INDEX IF NOT EXISTS idx_quest_rewards_quest_id ON quest_rewards(adventurer_quest_id)",
        "CREATE INDEX IF NOT EXISTS idx_quest_rewards_buyback ON quest_rewards(is_bought, buyback_deadline)",
        "CREATE INDEX IF NOT EXISTS idx_adventurer_purchases_adventurer_id ON adventurer_purchases(adventurer_instance_id)"
    ]
    
    for index_sql in indexes:
        conn.execute(text(index_sql))
    
    # Create update trigger function
    conn.execute(text("""
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        $$ language 'plpgsql';
    """))
    
    # Create triggers for tables with updated_at columns
    tables_with_updated_at = [
        'adventurer_masters', 'adventurer_instances', 'adventurer_requests', 
        'adventurer_quests', 'monster_masters', 'quest_area_masters'
    ]
    
    for table in tables_with_updated_at:
        trigger_name = f"update_{table}_updated_at"
        conn.execute(text(f"""
            DROP TRIGGER IF EXISTS {trigger_name} ON {table};
            CREATE TRIGGER {trigger_name}
                BEFORE UPDATE ON {table}
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column();
        """))

def verify_schema(conn):
    """Verify that all tables and relationships are properly created"""
    tables_to_check = [
        'adventurer_masters',
        'monster_masters', 
        'quest_area_masters',
        'monster_drop_tables',
        'adventurer_instances',
        'adventurer_requests',
        'adventurer_quests',
        'quest_rewards',
        'adventurer_purchases'
    ]
    
    for table in tables_to_check:
        result = conn.execute(text(f"SELECT COUNT(*) FROM information_schema.tables WHERE table_name = '{table}'"))
        count = result.scalar()
        if count == 1:
            print(f"   ✅ {table} exists")
        else:
            print(f"   ❌ {table} missing!")
    
    # Check foreign key relationships
    print("\n🔗 Checking foreign key relationships...")
    fk_checks = [
        ("adventurer_instances", "adventurer_master_id", "adventurer_masters", "id"),
        ("adventurer_quests", "quest_area_id", "quest_area_masters", "id"),
        ("adventurer_quests", "monster_id", "monster_masters", "id"),
    ]
    
    for child_table, child_col, parent_table, parent_col in fk_checks:
        result = conn.execute(text(f"""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu 
                ON tc.constraint_name = kcu.constraint_name
                WHERE tc.table_name = '{child_table}'
                AND kcu.column_name = '{child_col}'
                AND tc.constraint_type = 'FOREIGN KEY'
            )
        """))
        exists = result.scalar()
        if exists:
            print(f"   ✅ {child_table}.{child_col} -> {parent_table}.{parent_col}")
        else:
            print(f"   ⚠️  {child_table}.{child_col} -> {parent_table}.{parent_col} (may not exist)")

if __name__ == '__main__':
    main()