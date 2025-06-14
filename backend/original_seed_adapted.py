#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('元のシードデータを現在のスキーマに合わせて投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 既存武器・素材データクリア
            conn.execute(text("DELETE FROM crafting_recipes"))
            conn.execute(text("DELETE FROM recipe_materials"))
            conn.execute(text("DELETE FROM weapon_masters"))
            conn.execute(text("DELETE FROM material_masters"))
            conn.commit()
            print('既存データクリア完了')
            
            # 元のデータを現在のスキーマに合わせて投入
            
            # 素材マスタ投入
            materials_sql = """
            INSERT INTO material_masters (name, description, rarity_id, base_price, max_stack, is_active, created_at, updated_at) VALUES
            -- 基本素材
            ('鉄鉱石', '武器作成の基本素材', 1, 50, 999, true, NOW(), NOW()),
            ('銅鉱石', '初級武器の材料', 1, 30, 999, true, NOW(), NOW()),
            ('木材', '弓や杖の材料', 1, 20, 999, true, NOW(), NOW()),
            ('石材', '基礎的な建材', 1, 15, 999, true, NOW(), NOW()),
            ('強化石', 'エンチャントに使用する石', 1, 100, 999, true, NOW(), NOW()),
            
            -- 中級素材
            ('銀鉱石', '中級武器の材料', 2, 200, 999, true, NOW(), NOW()),
            ('魔法石', '魔法武器の核となる石', 2, 500, 999, true, NOW(), NOW()),
            ('レア鉱石', '希少な鉱石', 2, 800, 999, true, NOW(), NOW()),
            
            -- 上級素材
            ('金鉱石', '最高級武器の材料', 3, 1500, 999, true, NOW(), NOW()),
            ('古代石', '古代の力を宿した石', 3, 3000, 999, true, NOW(), NOW())
            """
            
            conn.execute(text(materials_sql))
            print('素材マスタ 10 件投入完了')
            
            # 武器マスタ投入（元のデータに基づく）
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description, is_active, created_at, updated_at) VALUES
            -- Common 剣
            ('iron_sword_common', '鉄の剣', 'sword', 1, 50, 80, 200, 300, 5, 1, '基本的な鉄製の剣', true, NOW(), NOW()),
            ('steel_sword_common', '鋼の剣', 'sword', 1, 80, 120, 400, 600, 10, 2, '鋼で作られた丈夫な剣', true, NOW(), NOW()),
            ('knight_sword_common', '騎士の剣', 'sword', 1, 100, 150, 600, 900, 15, 3, '騎士が愛用する剣', true, NOW(), NOW()),
            
            -- Common 弓
            ('wooden_bow_common', '木の弓', 'bow', 1, 45, 75, 180, 270, 5, 1, '木製の基本的な弓', true, NOW(), NOW()),
            ('hunter_bow_common', 'ハンターボウ', 'bow', 1, 75, 110, 360, 540, 10, 2, '狩人が使う実用的な弓', true, NOW(), NOW()),
            ('longbow_common', 'ロングボウ', 'bow', 1, 90, 135, 540, 810, 15, 3, '長距離射撃に適した弓', true, NOW(), NOW()),
            
            -- Common 杖
            ('wooden_staff_common', '木の杖', 'staff', 1, 40, 70, 160, 240, 5, 1, '木製の基本的な杖', true, NOW(), NOW()),
            ('mage_staff_common', '魔法使いの杖', 'staff', 1, 70, 100, 320, 480, 10, 2, '魔法使いが愛用する杖', true, NOW(), NOW()),
            ('crystal_staff_common', 'クリスタルスタッフ', 'staff', 1, 85, 125, 480, 720, 15, 3, '水晶を埋め込んだ杖', true, NOW(), NOW()),
            
            -- Uncommon 剣
            ('silver_sword_rare', '銀の剣', 'sword', 2, 120, 200, 1000, 1500, 30, 5, '銀で作られた美しい剣', true, NOW(), NOW()),
            ('magic_sword_rare', 'マジックソード', 'sword', 2, 180, 280, 1800, 2700, 45, 7, '魔法の力を宿した剣', true, NOW(), NOW()),
            ('blessed_sword_rare', '祝福の剣', 'sword', 2, 220, 320, 2500, 3750, 60, 8, '聖なる力で祝福された剣', true, NOW(), NOW()),
            
            -- Uncommon 弓
            ('silver_bow_rare', '銀の弓', 'bow', 2, 110, 180, 900, 1350, 30, 5, '銀で装飾された美しい弓', true, NOW(), NOW()),
            ('magic_bow_rare', 'マジックボウ', 'bow', 2, 160, 250, 1600, 2400, 45, 7, '魔法の矢を放つ弓', true, NOW(), NOW()),
            ('elven_bow_rare', 'エルフの弓', 'bow', 2, 200, 290, 2250, 3375, 60, 8, 'エルフの技術で作られた弓', true, NOW(), NOW()),
            
            -- Uncommon 杖
            ('silver_staff_rare', '銀の杖', 'staff', 2, 100, 160, 800, 1200, 30, 5, '銀で装飾された杖', true, NOW(), NOW()),
            ('arcane_staff_rare', 'アルケインスタッフ', 'staff', 2, 150, 230, 1500, 2250, 45, 7, '秘術の力を宿した杖', true, NOW(), NOW()),
            ('wisdom_staff_rare', '賢者の杖', 'staff', 2, 180, 270, 2000, 3000, 60, 8, '賢者が愛用した杖', true, NOW(), NOW()),
            
            -- Rare Epic 剣
            ('flame_sword_epic', '炎の剣', 'sword', 3, 350, 450, 8000, 12000, 120, 10, '炎の力を宿した伝説の剣', true, NOW(), NOW()),
            ('dragon_slayer_epic', 'ドラゴンスレイヤー', 'sword', 3, 400, 550, 12000, 18000, 180, 12, 'ドラゴンを倒すために作られた剣', true, NOW(), NOW()),
            
            -- Rare Epic 弓
            ('storm_bow_epic', '嵐の弓', 'bow', 3, 320, 420, 7200, 10800, 120, 10, '嵐の力を宿した弓', true, NOW(), NOW()),
            ('phoenix_bow_epic', 'フェニックスボウ', 'bow', 3, 380, 500, 11400, 17100, 180, 12, '不死鳥の力を宿した弓', true, NOW(), NOW()),
            
            -- Rare Epic 杖
            ('archmage_staff_epic', '大魔法使いの杖', 'staff', 3, 300, 400, 6400, 9600, 120, 10, '大魔法使いが使った伝説の杖', true, NOW(), NOW()),
            ('cosmos_staff_epic', 'コスモススタッフ', 'staff', 3, 360, 480, 10800, 16200, 180, 12, '宇宙の力を宿した杖', true, NOW(), NOW())
            """
            
            conn.execute(text(weapons_sql))
            print('武器マスタ 21 件投入完了')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            material_count = result.scalar()
            
            print(f'\n=== 元データ復元結果 ===')
            print(f'武器マスター: {weapon_count} 件')
            print(f'素材マスター: {material_count} 件')
            print('\n元のシードデータ復元完了！')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()