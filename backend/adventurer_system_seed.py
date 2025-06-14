#!/usr/bin/env python3
"""
Seed data script for the adventurer system.
Creates initial adventurer masters, quest areas, and monsters for testing.
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text

def main():
    print('🌱 Seeding adventurer system data...')
    
    # Use postgres service name for Docker execution
    db_url = "postgresql://bukiya_user:bukiya_password@postgres:5432/bukiya_game"
    engine = create_engine(db_url)
    
    with engine.begin() as conn:
        try:
            # Seed adventurer masters with beginner-friendly stats
            print("👥 Seeding adventurer masters...")
            seed_adventurer_masters(conn)
            
            # Seed quest areas
            print("🗺️  Seeding quest areas...")
            seed_quest_areas(conn)
            
            # Seed monsters
            print("👹 Seeding monsters...")
            seed_monsters(conn)
            
            # Seed monster drop tables
            print("💎 Seeding monster drop tables...")
            seed_monster_drops(conn)
            
            print("✅ Adventurer system seed data completed!")
            
            # Show summary
            print("\n📊 Summary:")
            show_summary(conn)
            
        except Exception as e:
            print(f"❌ Error during seeding: {e}")
            import traceback
            traceback.print_exc()
            raise

def seed_adventurer_masters(conn):
    """Seed adventurer master data"""
    
    # Check if data already exists
    result = conn.execute(text("SELECT COUNT(*) FROM adventurer_masters"))
    if result.scalar() > 0:
        print("   ⚠️  Adventurer masters already exist, skipping...")
        return
    
    adventurers = [
        # Super beginner-friendly adventurers
        ("村の少年タム", "warrior", 1, "friendly", 10, 50, 200, "sword", 
         "村で冒険を始めたばかりの少年。どんな武器でも喜んで使う。", 
         10, 1.0, 1, 100, 1, 3, "normal", 1.0),
        
        ("見習い狩人サラ", "archer", 2, "normal", 15, 80, 300, "bow",
         "弓の練習をしている見習い。安い弓を探している。", 
         20, 1.2, 2, 80, 1, 5, "normal", 1.0),
        
        ("魔法学校の生徒リオ", "mage", 2, "stingy", 20, 60, 250, "staff",
         "魔法学校の1年生。お小遣いで買える杖を探している。", 
         15, 0.8, 1, 60, 1, 4, "normal", 1.0),
        
        # Intermediate adventurers
        ("新米剣士アレン", "warrior", 5, "normal", 50, 200, 800, "sword",
         "剣術を学び始めた新米騎士。良い剣を求めている。",
         50, 1.0, 3, 100, 3, 8, "normal", 1.0),
        
        ("見習い弓使いリリー", "archer", 8, "generous", 60, 300, 1000, "bow",
         "森の中で狩りを学んでいる弓使い見習い。",
         80, 1.3, 2, 120, 5, 10, "normal", 1.0),
        
        ("駆け出し魔法使いミナ", "mage", 6, "normal", 45, 250, 900, "staff",
         "魔法学院を卒業したばかりの若い魔法使い。",
         60, 1.1, 3, 90, 4, 8, "normal", 1.0),
        
        # Advanced adventurers
        ("熟練戦士ガルド", "warrior", 25, "wealthy", 200, 1000, 3000, "sword",
         "多くの戦場を経験した熟練の戦士。高品質な武器を好む。",
         200, 1.5, 4, 150, 15, 30, "challenge", 1.2),
        
        ("狩人マスターエリオット", "archer", 30, "normal", 250, 1500, 4000, "bow",
         "森の主と呼ばれる伝説的な狩人。最高の弓を求めている。",
         300, 1.4, 5, 200, 20, 35, "challenge", 1.3),
        
        ("大魔道士セレナ", "mage", 35, "stingy", 300, 800, 2500, "staff",
         "古代魔法を研究する大魔道士。コスパの良い杖を好む。",
         250, 0.9, 4, 180, 25, 40, "challenge", 1.1),
        
        # Elite adventurers
        ("伝説の騎士王アルトリウス", "paladin", 50, "wealthy", 500, 3000, 8000, "sword",
         "王国を救った伝説の騎士王。最高級の武器のみを使用する。",
         500, 2.0, 5, 300, 40, None, "elite", 2.0),
    ]
    
    for adv in adventurers:
        conn.execute(text("""
            INSERT INTO adventurer_masters (
                name, profession, level, personality, trust_level, 
                budget_min, budget_max, preferred_weapon_type, 
                description, min_attack_requirement, max_budget_multiplier, 
                urgency_tendency, spawn_weight, min_player_level, max_player_level,
                tier, progression_multiplier, is_active, created_at, updated_at
            ) VALUES (
                :name, :profession, :level, :personality, :trust_level,
                :budget_min, :budget_max, :preferred_weapon_type,
                :description, :min_attack_requirement, :max_budget_multiplier,
                :urgency_tendency, :spawn_weight, :min_player_level, :max_player_level,
                :tier, :progression_multiplier, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            )
        """), {
            'name': adv[0], 'profession': adv[1], 'level': adv[2], 'personality': adv[3],
            'trust_level': adv[4], 'budget_min': adv[5], 'budget_max': adv[6],
            'preferred_weapon_type': adv[7], 'description': adv[8],
            'min_attack_requirement': adv[9], 'max_budget_multiplier': adv[10],
            'urgency_tendency': adv[11], 'spawn_weight': adv[12],
            'min_player_level': adv[13], 'max_player_level': adv[14],
            'tier': adv[15], 'progression_multiplier': adv[16]
        })
    
    print(f"   ✅ Created {len(adventurers)} adventurer masters")

def seed_quest_areas(conn):
    """Seed quest area data"""
    
    # Check if data already exists
    result = conn.execute(text("SELECT COUNT(*) FROM quest_area_masters"))
    if result.scalar() > 0:
        print("   ⚠️  Quest areas already exist, skipping...")
        return
    
    quest_areas = [
        ("近くの森", "forest", 1, 1, 30, "初心者向けの平和な森", "#4CAF50", 0),
        ("洞窟の入口", "cave", 2, 5, 45, "薄暗い洞窟の入口付近", "#795548", 1),
        ("古い遺跡", "ruins", 3, 10, 60, "古代文明の遺跡", "#9E9E9E", 2),
        ("深い森", "forest", 3, 8, 75, "森の奥深く、危険な獣が住む", "#2E7D32", 3),
        ("地下洞窟", "cave", 4, 15, 90, "地下深くの危険な洞窟", "#424242", 4),
        ("魔法の森", "magical_forest", 4, 20, 120, "魔法に満ちた不思議な森", "#673AB7", 5),
        ("竜の巣窟", "dragon_lair", 5, 30, 150, "伝説の竜が住むと言われる洞窟", "#D32F2F", 6),
        ("天空の遺跡", "sky_ruins", 5, 35, 180, "雲の上に浮かぶ古代遺跡", "#03A9F4", 7),
    ]
    
    for area in quest_areas:
        conn.execute(text("""
            INSERT INTO quest_area_masters (
                name, area_type, difficulty, required_level, duration_minutes,
                description, background_color, display_order, is_active,
                created_at, updated_at
            ) VALUES (
                :name, :area_type, :difficulty, :required_level, :duration_minutes,
                :description, :background_color, :display_order, true,
                CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            )
        """), {
            'name': area[0], 'area_type': area[1], 'difficulty': area[2],
            'required_level': area[3], 'duration_minutes': area[4],
            'description': area[5], 'background_color': area[6],
            'display_order': area[7]
        })
    
    print(f"   ✅ Created {len(quest_areas)} quest areas")

def seed_monsters(conn):
    """Seed monster data"""
    
    # Check if data already exists
    result = conn.execute(text("SELECT COUNT(*) FROM monster_masters"))
    if result.scalar() > 0:
        print("   ⚠️  Monsters already exist, skipping...")
        return
    
    monsters = [
        # Beginner monsters (Forest)
        ("森のスライム", "slime", 1, 30, 15, 5, None, "fire", None, "1", 100, 0, 20, 10, "弱い森のスライム"),
        ("野ウサギ", "beast", 2, 25, 20, 8, None, "thunder", None, "1", 80, 0, 30, 15, "素早い野ウサギ"),
        ("森のゴブリン", "goblin", 3, 50, 35, 15, None, None, None, "1,2", 90, 0, 50, 25, "いたずら好きなゴブリン"),
        
        # Intermediate monsters (Cave, Ruins)
        ("洞窟バット", "beast", 4, 40, 45, 20, "wind", "ice", None, "2,3", 85, 5, 80, 40, "洞窟に住む大きなコウモリ"),
        ("石の番人", "golem", 8, 120, 60, 40, "earth", "wind", "fire", "3,4", 70, 10, 150, 75, "古代遺跡を守る石像"),
        ("スケルトン戦士", "undead", 6, 80, 55, 25, None, "fire", None, "3,4", 80, 8, 120, 60, "骨だけの戦士"),
        
        # Advanced monsters (Deep areas)
        ("森の王オーク", "orc", 12, 200, 80, 50, None, None, None, "4", 60, 15, 250, 125, "森を支配するオークの王"),
        ("氷の魔導師", "mage", 15, 150, 100, 60, "ice", "fire", "ice", "5", 50, 20, 300, 150, "氷の魔法を操る魔導師"),
        ("ドラゴンの子", "dragon", 20, 300, 120, 80, "fire", "ice", "fire", "6", 40, 25, 500, 250, "若いドラゴンの子供"),
        
        # Elite monsters (High-level areas)
        ("古代の守護竜", "dragon", 35, 800, 200, 150, "fire", None, "fire", "7", 20, 40, 1000, 500, "天空遺跡を守る古代竜"),
        ("闇の大魔王", "demon", 40, 1000, 250, 180, "dark", "light", "dark", "8", 15, 45, 1500, 750, "闇の力を持つ大魔王"),
    ]
    
    for monster in monsters:
        conn.execute(text("""
            INSERT INTO monster_masters (
                name, monster_type, level, hp, attack, defense,
                element, weakness, resistance, spawn_areas, spawn_weight,
                min_required_weapon_level, base_gold_reward, experience_reward,
                description, is_active, created_at, updated_at
            ) VALUES (
                :name, :monster_type, :level, :hp, :attack, :defense,
                :element, :weakness, :resistance, :spawn_areas, :spawn_weight,
                :min_required_weapon_level, :base_gold_reward, :experience_reward,
                :description, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            )
        """), {
            'name': monster[0], 'monster_type': monster[1], 'level': monster[2],
            'hp': monster[3], 'attack': monster[4], 'defense': monster[5],
            'element': monster[6], 'weakness': monster[7], 'resistance': monster[8],
            'spawn_areas': monster[9], 'spawn_weight': monster[10],
            'min_required_weapon_level': monster[11], 'base_gold_reward': monster[12],
            'experience_reward': monster[13], 'description': monster[14]
        })
    
    print(f"   ✅ Created {len(monsters)} monsters")

def seed_monster_drops(conn):
    """Seed monster drop table data"""
    
    # Check if data already exists
    result = conn.execute(text("SELECT COUNT(*) FROM monster_drop_tables"))
    if result.scalar() > 0:
        print("   ⚠️  Monster drops already exist, skipping...")
        return
    
    # Get monster and material IDs for drops
    monsters = conn.execute(text("SELECT id, name FROM monster_masters ORDER BY level")).fetchall()
    materials = conn.execute(text("SELECT id, name FROM material_masters ORDER BY rarity_id")).fetchall()
    
    if not materials:
        print("   ⚠️  No materials found, skipping monster drops...")
        return
    
    # Create drops for each monster
    drops_created = 0
    for monster_id, monster_name in monsters:
        # Each monster drops 2-3 different materials
        num_drops = min(3, len(materials))
        for i in range(num_drops):
            material_id, material_name = materials[i % len(materials)]
            
            # Adjust drop rates based on monster level
            base_drop_rate = 0.3 if i == 0 else 0.15  # First drop is more common
            
            conn.execute(text("""
                INSERT INTO monster_drop_tables (
                    monster_id, item_type, item_id, drop_rate,
                    min_quantity, max_quantity, required_weapon_enchant,
                    required_adventurer_level, is_active, created_at
                ) VALUES (
                    :monster_id, 'material', :item_id, :drop_rate,
                    1, :max_quantity, 0, 1, true, CURRENT_TIMESTAMP
                )
            """), {
                'monster_id': monster_id,
                'item_id': material_id,
                'drop_rate': base_drop_rate,
                'max_quantity': 2 if i == 0 else 1
            })
            drops_created += 1
    
    print(f"   ✅ Created {drops_created} monster drop entries")

def show_summary(conn):
    """Show summary of seeded data"""
    
    # Count adventurers by tier
    result = conn.execute(text("""
        SELECT tier, COUNT(*) as count 
        FROM adventurer_masters 
        GROUP BY tier 
        ORDER BY 
            CASE tier 
                WHEN 'normal' THEN 1 
                WHEN 'challenge' THEN 2 
                WHEN 'elite' THEN 3 
                ELSE 4 
            END
    """))
    print("   Adventurer Masters by Tier:")
    for tier, count in result:
        print(f"     {tier}: {count}")
    
    # Count quest areas by difficulty
    result = conn.execute(text("""
        SELECT difficulty, COUNT(*) as count 
        FROM quest_area_masters 
        GROUP BY difficulty 
        ORDER BY difficulty
    """))
    print("   Quest Areas by Difficulty:")
    for difficulty, count in result:
        print(f"     Level {difficulty}: {count}")
    
    # Count monsters by level range
    result = conn.execute(text("""
        SELECT 
            CASE 
                WHEN level <= 5 THEN 'Beginner (1-5)'
                WHEN level <= 15 THEN 'Intermediate (6-15)'
                WHEN level <= 30 THEN 'Advanced (16-30)'
                ELSE 'Elite (31+)'
            END as level_range,
            COUNT(*) as count
        FROM monster_masters
        GROUP BY 
            CASE 
                WHEN level <= 5 THEN 'Beginner (1-5)'
                WHEN level <= 15 THEN 'Intermediate (6-15)'
                WHEN level <= 30 THEN 'Advanced (16-30)'
                ELSE 'Elite (31+)'
            END
        ORDER BY 
            CASE 
                WHEN level <= 5 THEN 1
                WHEN level <= 15 THEN 2
                WHEN level <= 30 THEN 3
                ELSE 4
            END
    """))
    print("   Monsters by Level Range:")
    for level_range, count in result:
        print(f"     {level_range}: {count}")

if __name__ == '__main__':
    main()