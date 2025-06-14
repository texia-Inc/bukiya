#!/usr/bin/env python3
"""
Corrected Weapon Masters Seed Data
Uses String IDs and proper rarity references compatible with application models
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== CORRECTED WEAPON MASTERS SEED ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # Clear existing weapon data to start fresh
            print('1. Clearing existing weapon data...')
            conn.execute(text("DELETE FROM weapon_masters"))
            
            print('2. Inserting corrected weapon masters data...')
            
            # Weapon masters with proper String IDs and rarity references
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description, is_active, created_at, updated_at) VALUES
            
            -- === COMMON TIER WEAPONS ===
            -- Common Swords
            ('iron_sword_common', '鉄の剣', 'sword', 'common', 50, 80, 200, 300, 5, 1, '基本的な鉄製の剣。初心者におすすめ', true, NOW(), NOW()),
            ('steel_sword_common', '鋼の剣', 'sword', 'common', 80, 120, 400, 600, 10, 2, '鋼で作られた丈夫な剣', true, NOW(), NOW()),
            ('knight_sword_common', '騎士の剣', 'sword', 'common', 100, 150, 600, 900, 15, 3, '騎士が愛用する実用的な剣', true, NOW(), NOW()),
            
            -- Common Bows
            ('wooden_bow_common', '木の弓', 'bow', 'common', 45, 75, 180, 270, 5, 1, '木製の基本的な弓。軽量で扱いやすい', true, NOW(), NOW()),
            ('hunter_bow_common', 'ハンターボウ', 'bow', 'common', 75, 110, 360, 540, 10, 2, '狩人が使う実用的な弓', true, NOW(), NOW()),
            ('longbow_common', 'ロングボウ', 'bow', 'common', 90, 135, 540, 810, 15, 3, '長距離射撃に適した弓', true, NOW(), NOW()),
            
            -- Common Staves
            ('wooden_staff_common', '木の杖', 'staff', 'common', 40, 70, 160, 240, 5, 1, '木製の基本的な杖。魔法の入門用', true, NOW(), NOW()),
            ('mage_staff_common', '魔法使いの杖', 'staff', 'common', 70, 100, 320, 480, 10, 2, '魔法使いが愛用する杖', true, NOW(), NOW()),
            ('crystal_staff_common', 'クリスタルスタッフ', 'staff', 'common', 85, 125, 480, 720, 15, 3, '水晶を埋め込んだ美しい杖', true, NOW(), NOW()),
            
            -- === RARE TIER WEAPONS ===
            -- Rare Swords
            ('silver_sword_rare', '銀の剣', 'sword', 'rare', 120, 200, 1000, 1500, 30, 5, '銀で作られた美しい剣。高い魔法抵抗を持つ', true, NOW(), NOW()),
            ('magic_sword_rare', 'マジックソード', 'sword', 'rare', 180, 280, 1800, 2700, 45, 7, '魔法の力を宿した神秘的な剣', true, NOW(), NOW()),
            ('blessed_sword_rare', '祝福の剣', 'sword', 'rare', 220, 320, 2500, 3750, 60, 8, '聖なる力で祝福された聖剣', true, NOW(), NOW()),
            
            -- Rare Bows
            ('silver_bow_rare', '銀の弓', 'bow', 'rare', 110, 180, 900, 1350, 30, 5, '銀で装飾された美しい弓', true, NOW(), NOW()),
            ('magic_bow_rare', 'マジックボウ', 'bow', 'rare', 160, 250, 1600, 2400, 45, 7, '魔法の矢を放つ特殊な弓', true, NOW(), NOW()),
            ('elven_bow_rare', 'エルフの弓', 'bow', 'rare', 200, 290, 2250, 3375, 60, 8, 'エルフの技術で作られた精密な弓', true, NOW(), NOW()),
            
            -- Rare Staves
            ('silver_staff_rare', '銀の杖', 'staff', 'rare', 100, 160, 800, 1200, 30, 5, '銀で装飾された高級な杖', true, NOW(), NOW()),
            ('arcane_staff_rare', 'アルケインスタッフ', 'staff', 'rare', 150, 230, 1500, 2250, 45, 7, '秘術の力を宿した神秘的な杖', true, NOW(), NOW()),
            ('wisdom_staff_rare', '賢者の杖', 'staff', 'rare', 180, 270, 2000, 3000, 60, 8, '賢者が愛用した知恵の杖', true, NOW(), NOW()),
            
            -- === EPIC TIER WEAPONS ===
            -- Epic Swords
            ('flame_sword_epic', '炎の剣', 'sword', 'epic', 350, 450, 8000, 12000, 120, 10, '炎の力を宿した伝説の剣。火属性攻撃付与', true, NOW(), NOW()),
            ('dragon_slayer_epic', 'ドラゴンスレイヤー', 'sword', 'epic', 400, 550, 12000, 18000, 180, 12, 'ドラゴンを倒すために作られた伝説の大剣', true, NOW(), NOW()),
            ('void_blade_epic', 'ヴォイドブレード', 'sword', 'epic', 380, 500, 10000, 15000, 150, 11, '虚無の力を宿した漆黒の剣', true, NOW(), NOW()),
            
            -- Epic Bows
            ('storm_bow_epic', '嵐の弓', 'bow', 'epic', 320, 420, 7200, 10800, 120, 10, '嵐の力を宿した雷属性の弓', true, NOW(), NOW()),
            ('phoenix_bow_epic', 'フェニックスボウ', 'bow', 'epic', 380, 500, 11400, 17100, 180, 12, '不死鳥の力を宿した炎の弓', true, NOW(), NOW()),
            ('shadow_bow_epic', 'シャドウボウ', 'bow', 'epic', 360, 480, 9600, 14400, 150, 11, '影の力で敵を貫く暗黒の弓', true, NOW(), NOW()),
            
            -- Epic Staves
            ('archmage_staff_epic', '大魔法使いの杖', 'staff', 'epic', 300, 400, 6400, 9600, 120, 10, '大魔法使いが使った伝説の杖', true, NOW(), NOW()),
            ('cosmos_staff_epic', 'コスモススタッフ', 'staff', 'epic', 360, 480, 10800, 16200, 180, 12, '宇宙の力を宿した最高級の杖', true, NOW(), NOW()),
            ('time_staff_epic', 'タイムスタッフ', 'staff', 'epic', 340, 460, 8800, 13200, 150, 11, '時間を操る神秘的な杖', true, NOW(), NOW()),
            
            -- === LEGENDARY TIER WEAPONS ===
            -- Legendary Swords
            ('excalibur_legendary', 'エクスカリバー', 'sword', 'legendary', 500, 700, 20000, 30000, 240, 15, '選ばれし者のみが扱える聖なる剣', true, NOW(), NOW()),
            ('demon_bane_legendary', 'デーモンベイン', 'sword', 'legendary', 550, 750, 25000, 37500, 300, 18, '悪魔を滅ぼすために作られた究極の剣', true, NOW(), NOW()),
            
            -- Legendary Bows
            ('artemis_bow_legendary', 'アルテミスの弓', 'bow', 'legendary', 480, 650, 18000, 27000, 240, 15, '狩猟の女神が愛用した神弓', true, NOW(), NOW()),
            ('infinity_bow_legendary', 'インフィニティボウ', 'bow', 'legendary', 520, 700, 22000, 33000, 300, 18, '無限の力を秘めた究極の弓', true, NOW(), NOW()),
            
            -- Legendary Staves
            ('merlin_staff_legendary', 'マーリンの杖', 'staff', 'legendary', 450, 600, 16000, 24000, 240, 15, '伝説の魔法使いマーリンの杖', true, NOW(), NOW()),
            ('creation_staff_legendary', '創世の杖', 'staff', 'legendary', 500, 680, 20000, 30000, 300, 18, '世界を創造した神の杖', true, NOW(), NOW())
            """
            
            conn.execute(text(weapons_sql))
            
            print('3. Verifying weapon masters data...')
            
            # Count by rarity
            result = conn.execute(text("""
                SELECT r.name, COUNT(*) as count 
                FROM weapon_masters w 
                JOIN rarity_levels r ON w.rarity_id = r.id 
                GROUP BY r.name, r.level 
                ORDER BY r.level
            """))
            
            print('\nWeapon count by rarity:')
            total_weapons = 0
            for row in result:
                print(f'  {row[0]}: {row[1]} weapons')
                total_weapons += row[1]
            
            print(f'\nTotal weapons created: {total_weapons}')
            
            # Count by type
            result = conn.execute(text("""
                SELECT wt.name, COUNT(*) as count 
                FROM weapon_masters w 
                JOIN weapon_types wt ON w.weapon_type_id = wt.id 
                GROUP BY wt.name 
                ORDER BY wt.name
            """))
            
            print('\nWeapon count by type:')
            for row in result:
                print(f'  {row[0]}: {row[1]} weapons')
            
            print('\n✅ WEAPON MASTERS SEED COMPLETED SUCCESSFULLY!')
            
        except Exception as e:
            print(f'❌ Error: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()