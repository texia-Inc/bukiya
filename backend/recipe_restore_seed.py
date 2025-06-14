#!/usr/bin/env python3
"""
レシピデータを復旧するためのシードスクリプト
基本データ + レシピデータを投入
"""

from app.core.database import SessionLocal
from app.models import (
    WeaponType, RarityLevel, WeaponMaster, MaterialMaster, 
    CraftingRecipe, RecipeMaterial
)

def main():
    print('レシピデータを復旧中...')
    db = SessionLocal()

    try:
        # 基本データの確認
        weapon_count = db.query(WeaponMaster).count()
        material_count = db.query(MaterialMaster).count()
        rarity_count = db.query(RarityLevel).count()
        
        print(f'現在のデータ状況:')
        print(f'  武器: {weapon_count} 件')
        print(f'  素材: {material_count} 件')
        print(f'  レアリティ: {rarity_count} 件')
        
        if weapon_count == 0 or material_count == 0 or rarity_count == 0:
            print('基本データが不足しています。先にseed_data.pyを実行してください。')
            return

        # 既存レシピを削除
        db.query(RecipeMaterial).delete()
        db.query(CraftingRecipe).delete()
        db.commit()
        print('既存レシピデータを削除')

        # 武器とレアリティを取得
        weapons = db.query(WeaponMaster).all()
        materials = db.query(MaterialMaster).all()
        
        # 基本的なレシピを作成（現在の武器名に合わせて修正）
        recipes_data = [
            {
                "weapon_name": "アイアンソード",
                "recipe_name": "アイアンソードレシピ",
                "description": "基本的な鉄の剣を作成するレシピ",
                "gold_cost": 50,
                "success_rate": 0.9,
                "required_level": 1,
                "materials": [
                    {"material_name": "鉄鉱石", "quantity": 5},
                    {"material_name": "古代の木材", "quantity": 2}
                ]
            },
            {
                "weapon_name": "フレイムブレード",
                "recipe_name": "フレイムブレードレシピ",
                "description": "炎の力を宿した剣を作成するレシピ",
                "gold_cost": 300,
                "success_rate": 0.8,
                "required_level": 5,
                "materials": [
                    {"material_name": "魔法の水晶", "quantity": 5},
                    {"material_name": "鉄鉱石", "quantity": 8},
                    {"material_name": "希少な宝石", "quantity": 2}
                ]
            },
            {
                "weapon_name": "スチールブレード",
                "recipe_name": "スチールブレードレシピ",
                "description": "鋼鉄製の切れ味鋭い剣を作成するレシピ",
                "gold_cost": 120,
                "success_rate": 0.8,
                "required_level": 3,
                "materials": [
                    {"material_name": "鉄鉱石", "quantity": 6},
                    {"material_name": "古代の木材", "quantity": 3},
                    {"material_name": "魔法の水晶", "quantity": 1}
                ]
            },
            {
                "weapon_name": "シルバーソード",
                "recipe_name": "シルバーソードレシピ",
                "description": "銀の力を宿した美しい剣を作成するレシピ",
                "gold_cost": 200,
                "success_rate": 0.75,
                "required_level": 4,
                "materials": [
                    {"material_name": "鉄鉱石", "quantity": 5},
                    {"material_name": "魔法の水晶", "quantity": 3},
                    {"material_name": "聖なる水", "quantity": 2}
                ]
            },
            {
                "weapon_name": "ブロンズソード",
                "recipe_name": "ブロンズソードレシピ",
                "description": "初心者向けの青銅製の剣を作成するレシピ",
                "gold_cost": 30,
                "success_rate": 0.95,
                "required_level": 1,
                "materials": [
                    {"material_name": "鉄鉱石", "quantity": 3},
                    {"material_name": "古代の木材", "quantity": 2}
                ]
            },
            {
                "weapon_name": "エクスカリバー",
                "recipe_name": "エクスカリバーレシピ",
                "description": "伝説の聖剣を作成する究極のレシピ",
                "gold_cost": 1000,
                "success_rate": 0.3,
                "required_level": 15,
                "materials": [
                    {"material_name": "ミスリル鉱石", "quantity": 5},
                    {"material_name": "ドラゴンの鱗", "quantity": 3},
                    {"material_name": "希少な宝石", "quantity": 8},
                    {"material_name": "聖なる水", "quantity": 5}
                ]
            }
        ]

        # レシピとマテリアルのマッピングを作成
        weapon_map = {w.name: w for w in weapons}
        material_map = {m.name: m for m in materials}

        created_recipes = 0
        created_materials = 0

        for recipe_data in recipes_data:
            weapon_name = recipe_data["weapon_name"]
            
            if weapon_name not in weapon_map:
                print(f'警告: 武器 "{weapon_name}" が見つかりません')
                continue

            weapon = weapon_map[weapon_name]
            
            # レシピ作成
            recipe = CraftingRecipe(
                weapon_id=weapon.id,
                name=recipe_data["recipe_name"],
                description=recipe_data["description"],
                gold_cost=recipe_data["gold_cost"],
                success_rate=recipe_data["success_rate"],
                required_level=recipe_data["required_level"]
            )
            db.add(recipe)
            db.flush()  # IDを取得するためにflush
            
            # レシピマテリアル作成
            for mat_data in recipe_data["materials"]:
                material_name = mat_data["material_name"]
                
                if material_name not in material_map:
                    print(f'警告: 素材 "{material_name}" が見つかりません')
                    continue

                material = material_map[material_name]
                
                recipe_material = RecipeMaterial(
                    recipe_id=recipe.id,
                    material_id=material.id,
                    quantity=mat_data["quantity"]
                )
                db.add(recipe_material)
                created_materials += 1

            created_recipes += 1
            print(f'レシピ作成: {recipe_data["recipe_name"]}')

        db.commit()
        
        # 結果確認
        total_recipes = db.query(CraftingRecipe).count()
        total_recipe_materials = db.query(RecipeMaterial).count()
        
        print(f'\n=== レシピ復旧完了 ===')
        print(f'作成されたレシピ: {created_recipes} 件')
        print(f'作成されたレシピ素材: {created_materials} 件')
        print(f'総レシピ数: {total_recipes} 件')
        print(f'総レシピ素材数: {total_recipe_materials} 件')
        
    except Exception as e:
        print(f'エラーが発生しました: {e}')
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == '__main__':
    main()