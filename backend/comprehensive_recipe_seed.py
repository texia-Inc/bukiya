#!/usr/bin/env python3
"""
レア以上の全武器に対応する包括的なレシピシードデータ
"""

from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('包括的なレシピデータを投入中...')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # レア以上でレシピがない武器を取得
            result = conn.execute(text('''
            SELECT wm.id, wm.name, rl.name as rarity, rl.level
            FROM weapon_masters wm 
            JOIN rarity_levels rl ON wm.rarity_id = rl.id 
            LEFT JOIN crafting_recipes cr ON wm.id = cr.result_weapon_master_id 
            WHERE rl.level >= 3 AND cr.id IS NULL
            ORDER BY rl.level, wm.name
            '''))
            
            missing_weapons = list(result)
            print(f'レシピが必要な武器: {len(missing_weapons)} 件')
            
            # 素材リストを取得
            material_result = conn.execute(text("SELECT id, name FROM material_masters ORDER BY base_price"))
            materials = list(material_result)
            print(f'利用可能な素材: {len(materials)} 件')
            
            created_recipes = 0
            created_materials = 0
            
            # レアリティ別の基本設定
            rarity_configs = {
                'Epic': {
                    'success_rate': 0.7,
                    'time_minutes': 60,
                    'base_gold': 1000,
                    'shop_level': 8,
                    'facility_level': 3,
                    'material_count': 4
                },
                'Legendary': {
                    'success_rate': 0.5,
                    'time_minutes': 120,
                    'base_gold': 2500,
                    'shop_level': 15,
                    'facility_level': 5,
                    'material_count': 5
                }
            }
            
            # 素材を価格順にグループ分け
            basic_materials = [m for m in materials if 'iron_ore' in m[0] or 'ancient_wood' in m[0]]
            rare_materials = [m for m in materials if 'magic_crystal' in m[0] or 'holy_water' in m[0]]
            epic_materials = [m for m in materials if 'rare_gem' in m[0] or 'dragon_scale' in m[0]]
            legendary_materials = [m for m in materials if 'mithril_ore' in m[0]]
            
            print(f'基本素材: {len(basic_materials)}, レア素材: {len(rare_materials)}, エピック素材: {len(epic_materials)}, レジェンダリー素材: {len(legendary_materials)}')
            
            for weapon_id, weapon_name, rarity, rarity_level in missing_weapons:
                if rarity not in rarity_configs:
                    continue
                    
                config = rarity_configs[rarity]
                recipe_id = f"recipe_{weapon_id}"
                
                # レシピ作成
                recipe_sql = """
                INSERT INTO crafting_recipes 
                (id, result_weapon_master_id, success_rate, crafting_time_minutes, 
                 required_gold, required_shop_level, required_facility_level, is_active) 
                VALUES (:id, :weapon_id, :success_rate, :time_min, :gold, :shop_level, :facility_level, true)
                """
                
                # 価格調整（武器名に基づく）
                gold_multiplier = 1.0
                if any(keyword in weapon_name.lower() for keyword in ['ヴォイド', 'ドラゴン', 'エクスカリバー', 'ミスリル']):
                    gold_multiplier = 1.5
                elif any(keyword in weapon_name.lower() for keyword in ['フェニックス', 'ホーリー', 'デモン']):
                    gold_multiplier = 1.3
                
                final_gold = int(config['base_gold'] * gold_multiplier)
                
                conn.execute(text(recipe_sql), {
                    "id": recipe_id,
                    "weapon_id": weapon_id,
                    "success_rate": config['success_rate'],
                    "time_min": config['time_minutes'],
                    "gold": final_gold,
                    "shop_level": config['shop_level'],
                    "facility_level": config['facility_level']
                })
                
                # 素材を設定
                material_requirements = []
                
                if rarity == 'Epic':
                    # エピック武器の素材構成
                    if basic_materials:
                        material_requirements.append((basic_materials[0][0], 8))  # 鉄鉱石 x8
                    if rare_materials:
                        material_requirements.append((rare_materials[0][0], 5))   # 魔法の水晶 x5
                    if epic_materials:
                        material_requirements.append((epic_materials[0][0], 3))  # 希少な宝石 x3
                    if len(materials) > 3:
                        material_requirements.append((materials[3][0], 2))       # その他素材 x2
                        
                elif rarity == 'Legendary':
                    # レジェンダリー武器の素材構成
                    if rare_materials:
                        material_requirements.append((rare_materials[0][0], 10)) # 魔法の水晶 x10
                    if epic_materials:
                        material_requirements.append((epic_materials[0][0], 8))  # 希少な宝石 x8
                    if legendary_materials:
                        material_requirements.append((legendary_materials[0][0], 5))  # ミスリル鉱石 x5
                    if len(epic_materials) > 1:
                        material_requirements.append((epic_materials[1][0], 3))  # ドラゴンの鱗 x3
                    if len(materials) > 7:
                        material_requirements.append((materials[7][0], 2))       # 聖なる水 x2
                
                # 素材をデータベースに投入
                for material_id, quantity in material_requirements:
                    material_sql = """
                    INSERT INTO recipe_materials (recipe_id, material_master_id, quantity)
                    VALUES (:recipe_id, :material_id, :quantity)
                    ON CONFLICT DO NOTHING
                    """
                    
                    conn.execute(text(material_sql), {
                        "recipe_id": recipe_id,
                        "material_id": material_id,
                        "quantity": quantity
                    })
                    created_materials += 1
                
                created_recipes += 1
                if created_recipes % 10 == 0:
                    print(f'進行状況: {created_recipes}/{len(missing_weapons)} レシピ作成完了')
            
            # 結果確認
            result = conn.execute(text("SELECT COUNT(*) FROM crafting_recipes"))
            total_recipes = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM recipe_materials"))
            total_materials = result.scalar()
            
            print(f'\n=== 包括的レシピ投入完了 ===')
            print(f'新規作成レシピ: {created_recipes} 件')
            print(f'新規作成素材関連: {created_materials} 件')
            print(f'総レシピ数: {total_recipes} 件')
            print(f'総レシピ素材数: {total_materials} 件')
            
            # 最終確認: レア以上でレシピがない武器
            result = conn.execute(text('''
            SELECT COUNT(*) FROM weapon_masters wm 
            JOIN rarity_levels rl ON wm.rarity_id = rl.id 
            LEFT JOIN crafting_recipes cr ON wm.id = cr.result_weapon_master_id 
            WHERE rl.level >= 3 AND cr.id IS NULL
            '''))
            remaining_without_recipes = result.scalar()
            
            print(f'レシピなし残り武器: {remaining_without_recipes} 件')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    main()