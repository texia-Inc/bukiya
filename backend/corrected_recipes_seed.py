#!/usr/bin/env python3
"""
Corrected Recipes and Recipe Materials Seed Data
Uses proper weapon_id and material_id references with new schema structure
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== CORRECTED RECIPES AND RECIPE MATERIALS SEED ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # Clear existing recipe data
            print('1. Clearing existing recipe data...')
            conn.execute(text("DELETE FROM recipe_materials"))
            conn.execute(text("DELETE FROM crafting_recipes"))
            
            print('2. Inserting crafting recipes...')
            
            # Crafting recipes with proper structure
            recipes_sql = """
            INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
            
            -- === COMMON WEAPON RECIPES ===
            -- Common Swords
            ('iron_sword_common', '鉄の剣のレシピ', '基本的な鉄の剣を作成するレシピ', 100, 1.0, 1, true),
            ('steel_sword_common', '鋼の剣のレシピ', '鋼の剣を作成する中級レシピ', 200, 1.0, 2, true),
            ('knight_sword_common', '騎士の剣のレシピ', '騎士の剣を作成する上級レシピ', 300, 1.0, 3, true),
            
            -- Common Bows
            ('wooden_bow_common', '木の弓のレシピ', '基本的な木の弓を作成するレシピ', 80, 1.0, 1, true),
            ('hunter_bow_common', 'ハンターボウのレシピ', 'ハンターボウを作成する中級レシピ', 160, 1.0, 2, true),
            ('longbow_common', 'ロングボウのレシピ', 'ロングボウを作成する上級レシピ', 240, 1.0, 3, true),
            
            -- Common Staves
            ('wooden_staff_common', '木の杖のレシピ', '基本的な木の杖を作成するレシピ', 70, 1.0, 1, true),
            ('mage_staff_common', '魔法使いの杖のレシピ', '魔法使いの杖を作成する中級レシピ', 140, 1.0, 2, true),
            ('crystal_staff_common', 'クリスタルスタッフのレシピ', 'クリスタルスタッフを作成する上級レシピ', 210, 1.0, 3, true),
            
            -- === RARE WEAPON RECIPES ===
            -- Rare Swords
            ('silver_sword_rare', '銀の剣のレシピ', '美しい銀の剣を作成する高級レシピ', 500, 0.9, 5, true),
            ('magic_sword_rare', 'マジックソードのレシピ', '魔法の力を宿した剣を作成する特殊レシピ', 900, 0.85, 7, true),
            ('blessed_sword_rare', '祝福の剣のレシピ', '聖なる力で祝福された剣を作成する神聖レシピ', 1250, 0.8, 8, true),
            
            -- Rare Bows
            ('silver_bow_rare', '銀の弓のレシピ', '美しい銀の弓を作成する高級レシピ', 450, 0.9, 5, true),
            ('magic_bow_rare', 'マジックボウのレシピ', '魔法の矢を放つ弓を作成する特殊レシピ', 800, 0.85, 7, true),
            ('elven_bow_rare', 'エルフの弓のレシピ', 'エルフの技術で作る精密な弓のレシピ', 1125, 0.8, 8, true),
            
            -- Rare Staves
            ('silver_staff_rare', '銀の杖のレシピ', '銀で装飾された高級杖を作成するレシピ', 400, 0.9, 5, true),
            ('arcane_staff_rare', 'アルケインスタッフのレシピ', '秘術の力を宿した杖を作成する神秘レシピ', 750, 0.85, 7, true),
            ('wisdom_staff_rare', '賢者の杖のレシピ', '賢者の知恵を宿した杖を作成する知識レシピ', 1000, 0.8, 8, true),
            
            -- === EPIC WEAPON RECIPES ===
            -- Epic Swords
            ('flame_sword_epic', '炎の剣のレシピ', '炎の力を宿した伝説の剣を作成する危険なレシピ', 4000, 0.7, 10, true),
            ('dragon_slayer_epic', 'ドラゴンスレイヤーのレシピ', 'ドラゴンを倒すための究極の剣を作成する伝説レシピ', 6000, 0.6, 12, true),
            ('void_blade_epic', 'ヴォイドブレードのレシピ', '虚無の力を宿した漆黒の剣を作成する禁断レシピ', 5000, 0.65, 11, true),
            
            -- Epic Bows
            ('storm_bow_epic', '嵐の弓のレシピ', '嵐の力を宿した雷の弓を作成する伝説レシピ', 3600, 0.7, 10, true),
            ('phoenix_bow_epic', 'フェニックスボウのレシピ', '不死鳥の力を宿した炎の弓を作成する神話レシピ', 5700, 0.6, 12, true),
            ('shadow_bow_epic', 'シャドウボウのレシピ', '影の力で敵を貫く暗黒の弓を作成する闇のレシピ', 4800, 0.65, 11, true),
            
            -- Epic Staves
            ('archmage_staff_epic', '大魔法使いの杖のレシピ', '大魔法使いが使った伝説の杖を作成する究極レシピ', 3200, 0.7, 10, true),
            ('cosmos_staff_epic', 'コスモススタッフのレシピ', '宇宙の力を宿した最高級杖を作成する宇宙レシピ', 5400, 0.6, 12, true),
            ('time_staff_epic', 'タイムスタッフのレシピ', '時間を操る神秘的な杖を作成する時空レシピ', 4400, 0.65, 11, true),
            
            -- === LEGENDARY WEAPON RECIPES ===
            -- Legendary Swords  
            ('excalibur_legendary', 'エクスカリバーのレシピ', '選ばれし者のみが扱える聖剣を作成する運命のレシピ', 15000, 0.5, 15, true),
            ('demon_bane_legendary', 'デーモンベインのレシピ', '悪魔を滅ぼす究極の剣を作成する審判のレシピ', 20000, 0.4, 18, true),
            
            -- Legendary Bows
            ('artemis_bow_legendary', 'アルテミスの弓のレシピ', '狩猟の女神の神弓を作成する神域のレシピ', 12000, 0.5, 15, true),
            ('infinity_bow_legendary', 'インフィニティボウのレシピ', '無限の力を秘めた究極の弓を作成する無限レシピ', 18000, 0.4, 18, true),
            
            -- Legendary Staves
            ('merlin_staff_legendary', 'マーリンの杖のレシピ', '伝説の魔法使いマーリンの杖を作成する叡智のレシピ', 10000, 0.5, 15, true),
            ('creation_staff_legendary', '創世の杖のレシピ', '世界を創造した神の杖を作成する創造のレシピ', 22000, 0.4, 18, true)
            """
            
            conn.execute(text(recipes_sql))
            
            print('3. Inserting recipe materials...')
            
            # Recipe materials - linking recipes to required materials
            recipe_materials_sql = """
            INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
            
            -- === COMMON WEAPON MATERIAL REQUIREMENTS ===
            -- Iron Sword (Recipe ID will be 1)
            (1, 'iron_ore', 5),
            (1, 'coal', 2),
            (1, 'wood', 1),
            
            -- Steel Sword (Recipe ID will be 2)
            (2, 'iron_ore', 8),
            (2, 'coal', 4),
            (2, 'bronze_alloy', 2),
            
            -- Knight Sword (Recipe ID will be 3)
            (3, 'steel_ingot', 3),
            (3, 'leather', 2),
            (3, 'enhancement_stone', 1),
            
            -- Wooden Bow (Recipe ID will be 4)
            (4, 'wood', 5),
            (4, 'hemp', 3),
            (4, 'feather', 10),
            
            -- Hunter Bow (Recipe ID will be 5)
            (5, 'ancient_wood', 2),
            (5, 'hemp', 5),
            (5, 'feather', 15),
            (5, 'bone', 2),
            
            -- Longbow (Recipe ID will be 6)
            (6, 'ancient_wood', 4),
            (6, 'hemp', 8),
            (6, 'enhancement_stone', 1),
            
            -- Wooden Staff (Recipe ID will be 7)
            (7, 'wood', 4),
            (7, 'stone', 2),
            (7, 'resin', 1),
            
            -- Mage Staff (Recipe ID will be 8)
            (8, 'ancient_wood', 2),
            (8, 'magic_crystal', 1),
            (8, 'enhancement_stone', 2),
            
            -- Crystal Staff (Recipe ID will be 9)
            (9, 'ancient_wood', 3),
            (9, 'magic_crystal', 2),
            (9, 'mana_essence', 1),
            
            -- === RARE WEAPON MATERIAL REQUIREMENTS ===
            -- Silver Sword (Recipe ID will be 10)
            (10, 'silver_ore', 5),
            (10, 'steel_ingot', 2),
            (10, 'magic_crystal', 1),
            (10, 'enhancement_stone', 3),
            
            -- Magic Sword (Recipe ID will be 11)
            (11, 'silver_ore', 3),
            (11, 'mana_essence', 3),
            (11, 'spirit_gem', 2),
            (11, 'enhancement_stone', 5),
            
            -- Blessed Sword (Recipe ID will be 12)
            (12, 'silver_ore', 4),
            (12, 'angel_feather', 2),
            (12, 'spirit_gem', 3),
            (12, 'enhancement_stone', 8),
            
            -- Silver Bow (Recipe ID will be 13)
            (13, 'silver_ore', 4),
            (13, 'ancient_wood', 3),
            (13, 'phoenix_feather', 5),
            (13, 'enhancement_stone', 3),
            
            -- Magic Bow (Recipe ID will be 14)
            (14, 'ancient_wood', 2),
            (14, 'mana_essence', 4),
            (14, 'lightning_shard', 2),
            (14, 'enhancement_stone', 5),
            
            -- Elven Bow (Recipe ID will be 15)
            (15, 'ancient_wood', 5),
            (15, 'phoenix_feather', 3),
            (15, 'spirit_gem', 2),
            (15, 'enhancement_stone', 8),
            
            -- Silver Staff (Recipe ID will be 16)
            (16, 'silver_ore', 3),
            (16, 'magic_crystal', 3),
            (16, 'ancient_wood', 2),
            (16, 'enhancement_stone', 3),
            
            -- Arcane Staff (Recipe ID will be 17)
            (17, 'ancient_wood', 2),
            (17, 'mana_essence', 5),
            (17, 'spirit_gem', 3),
            (17, 'enhancement_stone', 5),
            
            -- Wisdom Staff (Recipe ID will be 18)
            (18, 'ancient_wood', 4),
            (18, 'spirit_gem', 4),
            (18, 'angel_feather', 2),
            (18, 'enhancement_stone', 8),
            
            -- === EPIC WEAPON MATERIAL REQUIREMENTS ===
            -- Flame Sword (Recipe ID will be 19)
            (19, 'adamantite_ore', 3),
            (19, 'fire_stone', 8),
            (19, 'elemental_core_fire', 2),
            (19, 'dragon_scale', 5),
            
            -- Dragon Slayer (Recipe ID will be 20)
            (20, 'adamantite_ore', 5),
            (20, 'dragon_scale', 10),
            (20, 'ancient_stone', 3),
            (20, 'beast_fang', 8),
            
            -- Void Blade (Recipe ID will be 21)
            (21, 'adamantite_ore', 4),
            (21, 'void_fragment', 5),
            (21, 'soul_crystal', 3),
            (21, 'demon_horn', 6),
            
            -- Storm Bow (Recipe ID will be 22)
            (22, 'ancient_wood', 8),
            (22, 'lightning_shard', 10),
            (22, 'elemental_core_air', 2),
            (22, 'phoenix_feather', 8),
            
            -- Phoenix Bow (Recipe ID will be 23)
            (23, 'ancient_wood', 6),
            (23, 'phoenix_feather', 15),
            (23, 'elemental_core_fire', 3),
            (23, 'fire_stone', 12),
            
            -- Shadow Bow (Recipe ID will be 24)
            (24, 'ancient_wood', 7),
            (24, 'void_fragment', 4),
            (24, 'soul_crystal', 2),
            (24, 'demon_horn', 8),
            
            -- Archmage Staff (Recipe ID will be 25)
            (25, 'mithril_ingot', 2),
            (25, 'mana_essence', 15),
            (25, 'star_fragment', 3),
            (25, 'spirit_gem', 10),
            
            -- Cosmos Staff (Recipe ID will be 26)
            (26, 'mithril_ingot', 3),
            (26, 'star_fragment', 5),
            (26, 'elemental_core_air', 2),
            (26, 'elemental_core_fire', 2),
            
            -- Time Staff (Recipe ID will be 27)
            (27, 'mithril_ingot', 2),
            (27, 'time_shard', 8),
            (27, 'void_fragment', 3),
            (27, 'ancient_stone', 5),
            
            -- === LEGENDARY WEAPON MATERIAL REQUIREMENTS ===
            -- Excalibur (Recipe ID will be 28)
            (28, 'genesis_fragment', 1),
            (28, 'divine_blood', 2),
            (28, 'truth_crystal', 1),
            (28, 'eternal_flame', 3),
            
            -- Demon Bane (Recipe ID will be 29)
            (29, 'chaos_crystal', 3),
            (29, 'divine_blood', 3),
            (29, 'void_heart', 2),
            (29, 'infinity_metal', 1),
            
            -- Artemis Bow (Recipe ID will be 30)
            (30, 'world_tree_heart', 1),
            (30, 'life_essence', 5),
            (30, 'destiny_thread', 3),
            (30, 'star_fragment', 8),
            
            -- Infinity Bow (Recipe ID will be 31)
            (31, 'infinity_metal', 2),
            (31, 'chaos_crystal', 2),
            (31, 'time_shard', 15),
            (31, 'void_heart', 1),
            
            -- Merlin Staff (Recipe ID will be 32)
            (32, 'truth_crystal', 1),
            (32, 'genesis_fragment', 2),
            (32, 'star_fragment', 10),
            (32, 'destiny_thread', 5),
            
            -- Creation Staff (Recipe ID will be 33)
            (33, 'world_tree_heart', 1),
            (33, 'genesis_fragment', 3),
            (33, 'divine_blood', 5),
            (33, 'eternal_flame', 4)
            """
            
            conn.execute(text(recipe_materials_sql))
            
            print('4. Verifying recipe data...')
            
            # Count recipes by weapon rarity
            result = conn.execute(text("""
                SELECT r.name, COUNT(*) as recipe_count 
                FROM crafting_recipes cr
                JOIN weapon_masters w ON cr.weapon_id = w.id
                JOIN rarity_levels r ON w.rarity_id = r.id
                GROUP BY r.name, r.level 
                ORDER BY r.level
            """))
            
            print('\nRecipe count by weapon rarity:')
            total_recipes = 0
            for row in result:
                print(f'  {row[0]}: {row[1]} recipes')
                total_recipes += row[1]
            
            print(f'\nTotal recipes created: {total_recipes}')
            
            # Count recipe materials
            result = conn.execute(text("SELECT COUNT(*) FROM recipe_materials"))
            material_entries = result.scalar()
            print(f'Total recipe material entries: {material_entries}')
            
            # Sample recipe with materials
            result = conn.execute(text("""
                SELECT cr.name, m.name, rm.quantity 
                FROM crafting_recipes cr
                JOIN recipe_materials rm ON cr.id = rm.recipe_id
                JOIN material_masters m ON rm.material_id = m.id
                WHERE cr.id = 1
                ORDER BY rm.quantity DESC
            """))
            
            print('\nSample recipe (Iron Sword) materials:')
            for row in result:
                print(f'  {row[0]}: {row[1]} x{row[2]}')
            
            print('\n✅ RECIPES AND RECIPE MATERIALS SEED COMPLETED SUCCESSFULLY!')
            
        except Exception as e:
            print(f'❌ Error: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()