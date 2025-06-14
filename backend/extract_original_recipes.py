#!/usr/bin/env python3
"""
元のシードファイルからレシピ部分だけを抽出して現在の武器IDに合わせて投入
"""

from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('元のレシピデータを現在の武器に合わせて投入中...')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # 既存レシピを削除
            conn.execute(text("DELETE FROM recipe_materials"))
            conn.execute(text("DELETE FROM crafting_recipes"))
            print('既存レシピデータを削除')

            # 現在の武器一覧を取得
            result = conn.execute(text("SELECT id, name FROM weapon_masters ORDER BY name"))
            current_weapons = {row[1]: row[0] for row in result}
            
            print(f'\n現在の武器数: {len(current_weapons)} 件')
            
            # 元のレシピデータを現在の武器IDに適合させる
            # 武器名マッピング（元の名前 -> 現在の名前）
            weapon_mapping = {
                'iron_sword_common': ('アイアンソード', 'iron_sword_new'),
                'steel_sword_common': ('スチールブレード', 'steel_blade'), 
                'knight_sword_common': ('ロングソード', 'long_sword'),
                'wooden_bow_common': ('ウッドボウ', 'wood_bow'),
                'hunter_bow_common': ('ハンターボウ', 'hunter_bow'),
                'longbow_common': ('ロングボウ', 'long_bow'),
                'wooden_staff_common': ('ウッドスタッフ', 'wood_staff'),
                'mage_staff_common': ('マジックワンド', 'magic_wand'),
                'crystal_staff_common': ('クリスタルロッド', 'crystal_rod'),
                'silver_sword_rare': ('シルバーソード', 'silver_sword_new'),
                'magic_sword_rare': ('クリスタルソード', 'crystal_sword'),
                'blessed_sword_rare': ('ロングソード', 'long_sword'),
                'silver_bow_rare': ('エルヴンボウ', 'elven_bow'),
                'magic_bow_rare': ('リカーブボウ', 'recurve_bow'), 
                'elven_bow_rare': ('エルヴンボウ', 'elven_bow'),
                'silver_staff_rare': ('ファイアスタッフ', 'fire_staff'),
                'arcane_staff_rare': ('アークメイジスタッフ', 'archmage_staff'),
                'wisdom_staff_rare': ('ファイアスタッフ', 'fire_staff'),
                'flame_sword_epic': ('フレイムブレード', 'flame_blade'),
                'dragon_slayer_epic': ('ドラゴンスレイヤー', 'dragon_slayer'),
                'storm_bow_epic': ('サンダーボウ', 'thunder_bow'),
                'phoenix_bow_epic': ('フェニックスボウ', 'phoenix_bow'),
                'archmage_staff_epic': ('アークメイジスタッフ', 'archmage_staff'),
                'cosmos_staff_epic': ('ミスリルスタッフ', 'mithril_staff')
            }

            # レシピデータを作成
            recipes_data = [
                # Common 武器レシピ
                ('recipe_iron_sword', 'iron_sword_common', 1.0000, 5, 100, 1),
                ('recipe_steel_sword', 'steel_sword_common', 1.0000, 10, 200, 2),
                ('recipe_knight_sword', 'knight_sword_common', 1.0000, 15, 300, 3),
                ('recipe_wooden_bow', 'wooden_bow_common', 1.0000, 5, 90, 1),
                ('recipe_hunter_bow', 'hunter_bow_common', 1.0000, 10, 180, 2),
                ('recipe_longbow', 'longbow_common', 1.0000, 15, 270, 3),
                ('recipe_wooden_staff', 'wooden_staff_common', 1.0000, 5, 80, 1),
                ('recipe_mage_staff', 'mage_staff_common', 1.0000, 10, 160, 2),
                ('recipe_crystal_staff', 'crystal_staff_common', 1.0000, 15, 240, 3),
                
                # Rare 武器レシピ
                ('recipe_silver_sword', 'silver_sword_rare', 0.9000, 30, 500, 5),
                ('recipe_magic_sword', 'magic_sword_rare', 0.8500, 45, 900, 7),
                ('recipe_blessed_sword', 'blessed_sword_rare', 0.8000, 60, 1250, 8),
                ('recipe_silver_bow', 'silver_bow_rare', 0.9000, 30, 450, 5),
                ('recipe_magic_bow', 'magic_bow_rare', 0.8500, 45, 800, 7),
                ('recipe_elven_bow', 'elven_bow_rare', 0.8000, 60, 1125, 8),
                ('recipe_silver_staff', 'silver_staff_rare', 0.9000, 30, 400, 5),
                ('recipe_arcane_staff', 'arcane_staff_rare', 0.8500, 45, 750, 7),
                ('recipe_wisdom_staff', 'wisdom_staff_rare', 0.8000, 60, 1000, 8),
                
                # Epic 武器レシピ
                ('recipe_flame_sword', 'flame_sword_epic', 0.7000, 120, 4000, 10),
                ('recipe_dragon_slayer', 'dragon_slayer_epic', 0.6000, 180, 6000, 12),
                ('recipe_storm_bow', 'storm_bow_epic', 0.7000, 120, 3600, 10),
                ('recipe_phoenix_bow', 'phoenix_bow_epic', 0.6000, 180, 5700, 12),
                ('recipe_archmage_staff', 'archmage_staff_epic', 0.7000, 120, 3200, 10),
                ('recipe_cosmos_staff', 'cosmos_staff_epic', 0.6000, 180, 5400, 12)
            ]

            created_recipes = 0
            skipped_recipes = 0

            for recipe_id, old_weapon_id, success_rate, time_min, gold, shop_level in recipes_data:
                # 武器IDをマッピング
                if old_weapon_id in weapon_mapping:
                    weapon_name, current_weapon_id = weapon_mapping[old_weapon_id]
                    
                    # 武器が存在するかチェック
                    if current_weapon_id in [wid for wid in current_weapons.values()]:
                        # レシピを投入
                        recipe_sql = """
                        INSERT INTO crafting_recipes 
                        (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level, is_active) 
                        VALUES (:id, :weapon_id, :success_rate, :time_min, :gold, :shop_level, true)
                        """
                        
                        conn.execute(text(recipe_sql), {
                            "id": recipe_id,
                            "weapon_id": current_weapon_id,
                            "success_rate": success_rate,
                            "time_min": time_min,
                            "gold": gold,
                            "shop_level": shop_level
                        })
                        
                        created_recipes += 1
                        print(f'レシピ作成: {recipe_id} -> {weapon_name}')
                    else:
                        print(f'警告: 武器 {current_weapon_id} が見つかりません')
                        skipped_recipes += 1
                else:
                    print(f'警告: マッピングが見つかりません: {old_weapon_id}')
                    skipped_recipes += 1

            # 基本的な素材も追加
            basic_materials = [
                ('recipe_bronze_sword', 'bronze_sword_new', [('iron_ore', 3), ('ancient_wood', 2)]),
                ('recipe_iron_sword', 'iron_sword_new', [('iron_ore', 5), ('ancient_wood', 2)]),
                ('recipe_steel_blade', 'steel_blade', [('iron_ore', 6), ('magic_crystal', 1), ('ancient_wood', 3)]),
                ('recipe_flame_blade', 'flame_blade', [('magic_crystal', 5), ('rare_gem', 2), ('iron_ore', 8)]),
                ('recipe_silver_sword', 'silver_sword_new', [('iron_ore', 5), ('magic_crystal', 3), ('holy_water', 2)])
            ]

            for recipe_id, weapon_id, materials in basic_materials:
                # 武器が存在するかチェック
                weapon_exists = conn.execute(text("SELECT COUNT(*) FROM weapon_masters WHERE id = :id"), {"id": weapon_id}).scalar()
                
                if weapon_exists:
                    # レシピがまだなければ作成
                    recipe_exists = conn.execute(text("SELECT COUNT(*) FROM crafting_recipes WHERE id = :id"), {"id": recipe_id}).scalar()
                    
                    if not recipe_exists:
                        conn.execute(text("""
                        INSERT INTO crafting_recipes 
                        (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level, is_active) 
                        VALUES (:id, :weapon_id, 0.9, 30, 100, 1, true)
                        """), {"id": recipe_id, "weapon_id": weapon_id})
                        created_recipes += 1
                    
                    # 素材を追加
                    for material_id, quantity in materials:
                        material_exists = conn.execute(text("SELECT COUNT(*) FROM material_masters WHERE id = :id"), {"id": material_id}).scalar()
                        
                        if material_exists:
                            conn.execute(text("""
                            INSERT INTO recipe_materials (recipe_id, material_master_id, quantity)
                            VALUES (:recipe_id, :material_id, :quantity)
                            ON CONFLICT DO NOTHING
                            """), {"recipe_id": recipe_id, "material_id": material_id, "quantity": quantity})

            
            # 結果確認
            result = conn.execute(text("SELECT COUNT(*) FROM crafting_recipes"))
            total_recipes = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM recipe_materials"))
            total_materials = result.scalar()
            
            print(f'\n=== レシピ復旧完了 ===')
            print(f'作成されたレシピ: {created_recipes} 件')
            print(f'スキップされたレシピ: {skipped_recipes} 件')
            print(f'総レシピ数: {total_recipes} 件')
            print(f'総レシピ素材数: {total_materials} 件')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    main()