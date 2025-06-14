#!/usr/bin/env python3
"""
Quick fix script for adventurer system database issues.
Creates basic data needed for the adventurer APIs to work.
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text

def main():
    print('🔧 Fixing adventurer system data...')
    
    # Use postgres service name for Docker execution
    db_url = "postgresql://bukiya_user:bukiya_password@postgres:5432/bukiya_game"
    engine = create_engine(db_url)
    
    with engine.begin() as conn:
        try:
            # Check if quest areas exist
            result = conn.execute(text("SELECT COUNT(*) FROM quest_area_masters"))
            quest_area_count = result.scalar()
            print(f"✅ Quest areas: {quest_area_count} found")
            
            # Check if adventurer masters exist
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_masters"))
            adventurer_count = result.scalar()
            print(f"✅ Adventurer masters: {adventurer_count} found")
            
            # Create simple monster drop data for existing monsters if they don't have drops
            result = conn.execute(text("SELECT COUNT(*) FROM monster_drop_tables"))
            drop_count = result.scalar()
            
            if drop_count == 0:
                print("📦 Creating monster drop data...")
                
                # Get existing monsters and materials
                monsters = conn.execute(text("SELECT id FROM monster_masters LIMIT 5")).fetchall()
                materials = conn.execute(text("SELECT id FROM material_masters LIMIT 10")).fetchall()
                
                if monsters and materials:
                    drops_created = 0
                    for monster_id, in monsters:
                        for i, (material_id,) in enumerate(materials[:3]):  # 3 drops per monster
                            conn.execute(text("""
                                INSERT INTO monster_drop_tables (
                                    monster_master_id, item_type, item_id, drop_rate,
                                    min_quantity, max_quantity, required_weapon_enchant,
                                    required_adventurer_level, is_active, created_at
                                ) VALUES (
                                    :monster_id, 'material', :material_id, :drop_rate,
                                    1, 2, 0, 1, true, CURRENT_TIMESTAMP
                                )
                            """), {
                                'monster_id': monster_id,
                                'material_id': material_id,
                                'drop_rate': 0.3 if i == 0 else 0.15
                            })
                            drops_created += 1
                    
                    print(f"✅ Created {drops_created} monster drop entries")
                else:
                    print("⚠️  No monsters or materials found for creating drops")
            else:
                print(f"✅ Monster drops: {drop_count} found")
            
            print("✅ Adventurer system fix completed!")
            
        except Exception as e:
            print(f"❌ Error during fix: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()