#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('元のシードデータを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 元のシードデータを投入
            
            # 1. 素材マスタ
            print('素材マスタデータを投入中...')
            materials_sql = """
            INSERT INTO material_masters (id, name, category, rarity_id, description, base_price, price_volatility, stack_size, emoji, color_code) VALUES
            -- 基本素材
            ('iron_ore', '鉄鉱石', 'basic', 'common', '武器作成の基本素材', 50, 0.1, 999, '⛏️', '#C0C0C0'),
            ('copper_ore', '銅鉱石', 'basic', 'common', '初級武器の材料', 30, 0.1, 999, '🟫', '#B87333'),
            ('wood', '木材', 'basic', 'common', '弓や杖の材料', 20, 0.1, 999, '🪵', '#8B4513'),
            ('stone', '石材', 'basic', 'common', '基礎的な建材', 15, 0.1, 999, '🪨', '#808080'),
            ('enhancement_stone', '強化石', 'magic', 'common', 'エンチャントに使用する石', 100, 0.2, 999, '💎', '#4169E1'),
            
            -- 中級素材
            ('silver_ore', '銀鉱石', 'basic', 'rare', '中級武器の材料', 200, 0.15, 999, '⚪', '#C0C0C0'),
            ('magic_crystal', '魔法石', 'magic', 'rare', '魔法武器の核となる石', 500, 0.2, 999, '🔮', '#9370DB'),
            ('rare_ore', 'レア鉱石', 'rare', 'rare', '希少な鉱石', 800, 0.25, 999, '💠', '#FF6347'),
            
            -- 上級素材
            ('gold_ore', '金鉱石', 'basic', 'epic', '最高級武器の材料', 1500, 0.3, 999, '🟨', '#FFD700'),
            ('ancient_stone', '古代石', 'special', 'epic', '古代の力を宿した石', 3000, 0.4, 999, '🗿', '#8A2BE2')
            """
            
            conn.execute(text(materials_sql))
            print('素材マスタ 10 件投入完了')
            
            # 2. 武器マスタ
            print('武器マスタデータを投入中...')
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
            -- Common 剣
            ('iron_sword_common', '鉄の剣', 'sword', 'common', 50, 80, 200, 300, 5, 1, '基本的な鉄製の剣'),
            ('steel_sword_common', '鋼の剣', 'sword', 'common', 80, 120, 400, 600, 10, 2, '鋼で作られた丈夫な剣'),
            ('knight_sword_common', '騎士の剣', 'sword', 'common', 100, 150, 600, 900, 15, 3, '騎士が愛用する剣'),
            
            -- Common 弓
            ('wooden_bow_common', '木の弓', 'bow', 'common', 45, 75, 180, 270, 5, 1, '木製の基本的な弓'),
            ('hunter_bow_common', 'ハンターボウ', 'bow', 'common', 75, 110, 360, 540, 10, 2, '狩人が使う実用的な弓'),
            ('longbow_common', 'ロングボウ', 'bow', 'common', 90, 135, 540, 810, 15, 3, '長距離射撃に適した弓'),
            
            -- Common 杖
            ('wooden_staff_common', '木の杖', 'staff', 'common', 40, 70, 160, 240, 5, 1, '木製の基本的な杖'),
            ('mage_staff_common', '魔法使いの杖', 'staff', 'common', 70, 100, 320, 480, 10, 2, '魔法使いが愛用する杖'),
            ('crystal_staff_common', 'クリスタルスタッフ', 'staff', 'common', 85, 125, 480, 720, 15, 3, '水晶を埋め込んだ杖'),
            
            -- Rare 剣
            ('silver_sword_rare', '銀の剣', 'sword', 'rare', 120, 200, 1000, 1500, 30, 5, '銀で作られた美しい剣'),
            ('magic_sword_rare', 'マジックソード', 'sword', 'rare', 180, 280, 1800, 2700, 45, 7, '魔法の力を宿した剣'),
            ('blessed_sword_rare', '祝福の剣', 'sword', 'rare', 220, 320, 2500, 3750, 60, 8, '聖なる力で祝福された剣'),
            
            -- Rare 弓
            ('silver_bow_rare', '銀の弓', 'bow', 'rare', 110, 180, 900, 1350, 30, 5, '銀で装飾された美しい弓'),
            ('magic_bow_rare', 'マジックボウ', 'bow', 'rare', 160, 250, 1600, 2400, 45, 7, '魔法の矢を放つ弓'),
            ('elven_bow_rare', 'エルフの弓', 'bow', 'rare', 200, 290, 2250, 3375, 60, 8, 'エルフの技術で作られた弓'),
            
            -- Rare 杖
            ('silver_staff_rare', '銀の杖', 'staff', 'rare', 100, 160, 800, 1200, 30, 5, '銀で装飾された杖'),
            ('arcane_staff_rare', 'アルケインスタッフ', 'staff', 'rare', 150, 230, 1500, 2250, 45, 7, '秘術の力を宿した杖'),
            ('wisdom_staff_rare', '賢者の杖', 'staff', 'rare', 180, 270, 2000, 3000, 60, 8, '賢者が愛用した杖'),
            
            -- Epic 剣
            ('flame_sword_epic', '炎の剣', 'sword', 'epic', 350, 450, 8000, 12000, 120, 10, '炎の力を宿した伝説の剣'),
            ('dragon_slayer_epic', 'ドラゴンスレイヤー', 'sword', 'epic', 400, 550, 12000, 18000, 180, 12, 'ドラゴンを倒すために作られた剣'),
            
            -- Epic 弓
            ('storm_bow_epic', '嵐の弓', 'bow', 'epic', 320, 420, 7200, 10800, 120, 10, '嵐の力を宿した弓'),
            ('phoenix_bow_epic', 'フェニックスボウ', 'bow', 'epic', 380, 500, 11400, 17100, 180, 12, '不死鳥の力を宿した弓'),
            
            -- Epic 杖
            ('archmage_staff_epic', '大魔法使いの杖', 'staff', 'epic', 300, 400, 6400, 9600, 120, 10, '大魔法使いが使った伝説の杖'),
            ('cosmos_staff_epic', 'コスモススタッフ', 'staff', 'epic', 360, 480, 10800, 16200, 180, 12, '宇宙の力を宿した杖')
            """
            
            conn.execute(text(weapons_sql))
            print('武器マスタ 21 件投入完了')
            
            # 3. レシピデータ
            print('レシピデータを投入中...')
            recipes_sql = """
            INSERT INTO crafting_recipes (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level) VALUES
            -- Common 武器レシピ
            ('recipe_iron_sword', 'iron_sword_common', 1.0000, 5, 100, 1),
            ('recipe_steel_sword', 'steel_sword_common', 1.0000, 10, 200, 2),
            ('recipe_knight_sword', 'knight_sword_common', 1.0000, 15, 300, 3),
            ('recipe_wooden_bow', 'wooden_bow_common', 1.0000, 5, 90, 1),
            ('recipe_hunter_bow', 'hunter_bow_common', 1.0000, 10, 180, 2),
            ('recipe_longbow', 'longbow_common', 1.0000, 15, 270, 3),
            ('recipe_wooden_staff', 'wooden_staff_common', 1.0000, 5, 80, 1),
            ('recipe_mage_staff', 'mage_staff_common', 1.0000, 10, 160, 2),
            ('recipe_crystal_staff', 'crystal_staff_common', 1.0000, 15, 240, 3),
            
            -- Rare 武器レシピ
            ('recipe_silver_sword', 'silver_sword_rare', 0.9000, 30, 500, 5),
            ('recipe_magic_sword', 'magic_sword_rare', 0.8500, 45, 900, 7),
            ('recipe_blessed_sword', 'blessed_sword_rare', 0.8000, 60, 1250, 8),
            ('recipe_silver_bow', 'silver_bow_rare', 0.9000, 30, 450, 5),
            ('recipe_magic_bow', 'magic_bow_rare', 0.8500, 45, 800, 7),
            ('recipe_elven_bow', 'elven_bow_rare', 0.8000, 60, 1125, 8),
            ('recipe_silver_staff', 'silver_staff_rare', 0.9000, 30, 400, 5),
            ('recipe_arcane_staff', 'arcane_staff_rare', 0.8500, 45, 750, 7),
            ('recipe_wisdom_staff', 'wisdom_staff_rare', 0.8000, 60, 1000, 8),
            
            -- Epic 武器レシピ
            ('recipe_flame_sword', 'flame_sword_epic', 0.7000, 120, 4000, 10),
            ('recipe_dragon_slayer', 'dragon_slayer_epic', 0.6000, 180, 6000, 12),
            ('recipe_storm_bow', 'storm_bow_epic', 0.7000, 120, 3600, 10),
            ('recipe_phoenix_bow', 'phoenix_bow_epic', 0.6000, 180, 5700, 12),
            ('recipe_archmage_staff', 'archmage_staff_epic', 0.7000, 120, 3200, 10),
            ('recipe_cosmos_staff', 'cosmos_staff_epic', 0.6000, 180, 5400, 12)
            """
            
            conn.execute(text(recipes_sql))
            print('レシピ 21 件投入完了')
            
            conn.commit()
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            material_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM crafting_recipes"))
            recipe_count = result.scalar()
            
            print(f'\n🎉 元のシードデータ投入完了！')
            print(f'✅ 武器マスター: {weapon_count} 件')
            print(f'✅ 素材マスター: {material_count} 件')
            print(f'✅ レシピ: {recipe_count} 件')
            print('\n元の豊富なデータが復活しました！')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()