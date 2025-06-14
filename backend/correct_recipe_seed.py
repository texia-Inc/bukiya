#!/usr/bin/env python3
"""
実際のテーブル構造に合わせたレシピデータ復旧スクリプト
"""

import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# データベース接続
DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('レシピデータを正しい構造で復旧中...')
    
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()

    try:
        # 既存レシピを削除
        db.execute(text("DELETE FROM recipe_materials"))
        db.execute(text("DELETE FROM crafting_recipes"))
        db.commit()
        print('既存レシピデータを削除')

        # 現在の武器を確認
        result = db.execute(text("SELECT id, name FROM weapon_masters LIMIT 10"))
        weapons = result.fetchall()
        print('\n現在の武器（最初の10個）:')
        for weapon in weapons:
            print(f'  {weapon[1]} (ID: {weapon[0]})')

        # 現在の素材を確認
        result = db.execute(text("SELECT id, name FROM material_masters"))
        materials = result.fetchall()
        print('\n現在の素材:')
        for material in materials:
            print(f'  {material[1]} (ID: {material[0]})')

        # レシピデータを投入（実際のテーブル構造に合わせて）
        recipes_data = [
            {
                "id": "recipe_bronze_sword",
                "result_weapon_master_id": "bronze_sword_new",
                "success_rate": 0.95,
                "crafting_time_minutes": 15,
                "required_gold": 30,
                "required_shop_level": 1,
                "required_facility_level": 1,
                "materials": [
                    {"material_id": "iron_ore", "quantity": 3},
                    {"material_id": "ancient_wood", "quantity": 2}
                ]
            },
            {
                "id": "recipe_iron_sword",
                "result_weapon_master_id": "iron_sword_new",
                "success_rate": 0.90,
                "crafting_time_minutes": 30,
                "required_gold": 50,
                "required_shop_level": 1,
                "required_facility_level": 1,
                "materials": [
                    {"material_id": "iron_ore", "quantity": 5},
                    {"material_id": "ancient_wood", "quantity": 2}
                ]
            },
            {
                "id": "recipe_steel_blade",
                "result_weapon_master_id": "steel_blade",
                "success_rate": 0.80,
                "crafting_time_minutes": 45,
                "required_gold": 120,
                "required_shop_level": 2,
                "required_facility_level": 2,
                "materials": [
                    {"material_id": "iron_ore", "quantity": 6},
                    {"material_id": "ancient_wood", "quantity": 3},
                    {"material_id": "magic_crystal", "quantity": 1}
                ]
            },
            {
                "id": "recipe_silver_sword",
                "result_weapon_master_id": "silver_sword_new",
                "success_rate": 0.75,
                "crafting_time_minutes": 60,
                "required_gold": 200,
                "required_shop_level": 3,
                "required_facility_level": 2,
                "materials": [
                    {"material_id": "iron_ore", "quantity": 5},
                    {"material_id": "magic_crystal", "quantity": 3},
                    {"material_id": "holy_water", "quantity": 2}
                ]
            },
            {
                "id": "recipe_flame_blade",
                "result_weapon_master_id": "flame_blade",
                "success_rate": 0.70,
                "crafting_time_minutes": 90,
                "required_gold": 300,
                "required_shop_level": 4,
                "required_facility_level": 3,
                "materials": [
                    {"material_id": "magic_crystal", "quantity": 5},
                    {"material_id": "iron_ore", "quantity": 8},
                    {"material_id": "rare_gem", "quantity": 2}
                ]
            },
            {
                "id": "recipe_excalibur",
                "result_weapon_master_id": "excalibur",
                "success_rate": 0.30,
                "crafting_time_minutes": 180,
                "required_gold": 1000,
                "required_shop_level": 10,
                "required_facility_level": 5,
                "materials": [
                    {"material_id": "mithril_ore", "quantity": 5},
                    {"material_id": "dragon_scale", "quantity": 3},
                    {"material_id": "rare_gem", "quantity": 8},
                    {"material_id": "holy_water", "quantity": 5}
                ]
            }
        ]

        created_recipes = 0
        created_materials = 0

        for recipe_data in recipes_data:
            # レシピを作成
            recipe_sql = """
            INSERT INTO crafting_recipes 
            (id, result_weapon_master_id, success_rate, crafting_time_minutes, 
             required_gold, required_shop_level, required_facility_level, is_active) 
            VALUES (:id, :result_weapon_master_id, :success_rate, :crafting_time_minutes, 
                    :required_gold, :required_shop_level, :required_facility_level, true)
            """
            
            db.execute(text(recipe_sql), {
                "id": recipe_data["id"],
                "result_weapon_master_id": recipe_data["result_weapon_master_id"],
                "success_rate": recipe_data["success_rate"],
                "crafting_time_minutes": recipe_data["crafting_time_minutes"],
                "required_gold": recipe_data["required_gold"],
                "required_shop_level": recipe_data["required_shop_level"],
                "required_facility_level": recipe_data["required_facility_level"]
            })
            
            # レシピマテリアルを作成
            for mat_data in recipe_data["materials"]:
                material_sql = """
                INSERT INTO recipe_materials (recipe_id, material_master_id, quantity)
                VALUES (:recipe_id, :material_master_id, :quantity)
                """
                
                db.execute(text(material_sql), {
                    "recipe_id": recipe_data["id"],
                    "material_master_id": mat_data["material_id"],
                    "quantity": mat_data["quantity"]
                })
                created_materials += 1

            created_recipes += 1
            print(f'レシピ作成: {recipe_data["id"]}')

        db.commit()
        
        # 結果確認
        result = db.execute(text("SELECT COUNT(*) FROM crafting_recipes"))
        total_recipes = result.scalar()
        
        result = db.execute(text("SELECT COUNT(*) FROM recipe_materials"))
        total_recipe_materials = result.scalar()
        
        print(f'\n=== レシピ復旧完了 ===')
        print(f'作成されたレシピ: {created_recipes} 件')
        print(f'作成されたレシピ素材: {created_materials} 件')
        print(f'総レシピ数: {total_recipes} 件')
        print(f'総レシピ素材数: {total_recipe_materials} 件')
        
        # サンプルレシピの確認
        result = db.execute(text("""
        SELECT cr.id, cr.result_weapon_master_id, wm.name as weapon_name, cr.required_gold
        FROM crafting_recipes cr
        JOIN weapon_masters wm ON cr.result_weapon_master_id = wm.id
        LIMIT 5
        """))
        
        print(f'\n作成されたレシピ（サンプル）:')
        for row in result:
            print(f'  {row[0]} -> {row[2]} (ゴールド: {row[3]})')
        
    except Exception as e:
        print(f'エラーが発生しました: {e}')
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == '__main__':
    main()