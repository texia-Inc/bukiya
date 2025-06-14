#!/usr/bin/env python3
"""
レシピの素材不足問題を解決するシードデータスクリプト
- レジェンダリー素材の追加
- エピック素材の追加
- 空のレシピに適切な素材を設定
"""

import asyncio
from sqlalchemy.orm import sessionmaker, joinedload
from sqlalchemy import create_engine
from app.models import (
    CraftingRecipe, RecipeMaterial, WeaponMaster, MaterialMaster, RarityLevel
)

# Database configuration
DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def create_legendary_materials(db):
    """レジェンダリー素材を作成"""
    legendary_rarity = db.query(RarityLevel).filter(RarityLevel.name == "レジェンダリー").first()
    
    legendary_materials = [
        {
            "name": "星の欠片",
            "description": "宇宙の星から落ちた神秘的な欠片。強力な武器の製作に必要。",
            "base_price": 50000,
            "max_stack": 10
        },
        {
            "name": "永遠の炎",
            "description": "決して消えることのない神聖な炎のエッセンス。",
            "base_price": 75000,
            "max_stack": 5
        },
        {
            "name": "時空の結晶",
            "description": "時間と空間を操る力を秘めた稀少な結晶。",
            "base_price": 100000,
            "max_stack": 3
        },
        {
            "name": "神の涙",
            "description": "神々の涙から生まれた究極の聖水。",
            "base_price": 80000,
            "max_stack": 5
        },
        {
            "name": "世界樹の根",
            "description": "世界を支える巨木の根の一部。生命力に満ちている。",
            "base_price": 60000,
            "max_stack": 8
        },
        {
            "name": "ヴォイドエッセンス",
            "description": "虚無の力を凝縮した漆黒のエッセンス。",
            "base_price": 90000,
            "max_stack": 4
        },
        {
            "name": "ドラゴンハート",
            "description": "古代ドラゴンの心臓から採取した究極の素材。",
            "base_price": 120000,
            "max_stack": 2
        },
        {
            "name": "光の聖石",
            "description": "純粋な光の力を宿した聖なる石。",
            "base_price": 70000,
            "max_stack": 6
        },
        {
            "name": "混沌の核",
            "description": "創造と破壊の力を内包する危険な素材。",
            "base_price": 110000,
            "max_stack": 3
        },
        {
            "name": "始祖の骨",
            "description": "世界の始まりに存在した原初の生命体の骨。",
            "base_price": 85000,
            "max_stack": 5
        }
    ]
    
    created_materials = []
    for mat_data in legendary_materials:
        # 既存チェック
        existing = db.query(MaterialMaster).filter(MaterialMaster.name == mat_data["name"]).first()
        if existing:
            print(f"既存の素材をスキップ: {mat_data['name']}")
            created_materials.append(existing)
            continue
            
        material = MaterialMaster(
            name=mat_data["name"],
            description=mat_data["description"],
            rarity_id=legendary_rarity.id,
            base_price=mat_data["base_price"],
            max_stack=mat_data["max_stack"],
            image_url=None,
            is_active=True
        )
        db.add(material)
        created_materials.append(material)
        print(f"レジェンダリー素材作成: {mat_data['name']}")
    
    db.commit()
    return created_materials

def create_additional_epic_materials(db):
    """エピック素材を追加"""
    epic_rarity = db.query(RarityLevel).filter(RarityLevel.name == "エピック").first()
    
    additional_epic_materials = [
        {
            "name": "魔王の角",
            "description": "強大な魔王から採取した漆黒の角。邪悪な力を宿す。",
            "base_price": 25000,
            "max_stack": 15
        },
        {
            "name": "天使の羽根",
            "description": "純白の天使の羽根。神聖な力で満ちている。",
            "base_price": 30000,
            "max_stack": 12
        },
        {
            "name": "古代遺跡の石板",
            "description": "失われた文明の知識が刻まれた神秘的な石板。",
            "base_price": 20000,
            "max_stack": 20
        },
        {
            "name": "フェニックスの灰",
            "description": "不死鳥の死と再生から生まれた神聖な灰。",
            "base_price": 35000,
            "max_stack": 10
        },
        {
            "name": "深海の真珠",
            "description": "深海の底で何千年もかけて形成された巨大な真珠。",
            "base_price": 28000,
            "max_stack": 15
        },
        {
            "name": "雷神の欠片",
            "description": "雷神の力の一部が結晶化した稀少な素材。",
            "base_price": 32000,
            "max_stack": 12
        },
        {
            "name": "闇の精髄",
            "description": "純粋な闇の力を凝縮した液体状の素材。",
            "base_price": 27000,
            "max_stack": 18
        }
    ]
    
    created_materials = []
    for mat_data in additional_epic_materials:
        # 既存チェック
        existing = db.query(MaterialMaster).filter(MaterialMaster.name == mat_data["name"]).first()
        if existing:
            print(f"既存の素材をスキップ: {mat_data['name']}")
            created_materials.append(existing)
            continue
            
        material = MaterialMaster(
            name=mat_data["name"],
            description=mat_data["description"],
            rarity_id=epic_rarity.id,
            base_price=mat_data["base_price"],
            max_stack=mat_data["max_stack"],
            image_url=None,
            is_active=True
        )
        db.add(material)
        created_materials.append(material)
        print(f"エピック素材作成: {mat_data['name']}")
    
    db.commit()
    return created_materials

def assign_materials_to_recipes(db):
    """空のレシピに適切な素材を設定"""
    
    # レア度別の素材を取得
    rarities = db.query(RarityLevel).filter(RarityLevel.is_active == True).all()
    materials_by_rarity = {}
    
    for rarity in rarities:
        materials = db.query(MaterialMaster).filter(
            MaterialMaster.rarity_id == rarity.id,
            MaterialMaster.is_active == True
        ).all()
        materials_by_rarity[rarity.name] = materials
        print(f"{rarity.name}素材: {len(materials)}個")
    
    # 空のレシピを取得
    empty_recipes = db.query(CraftingRecipe).options(
        joinedload(CraftingRecipe.materials),
        joinedload(CraftingRecipe.weapon).joinedload(WeaponMaster.rarity)
    ).filter(~CraftingRecipe.materials.any()).all()
    
    print(f"\n空のレシピ数: {len(empty_recipes)}")
    
    # レシピ素材の設定パターン
    recipe_patterns = {
        "レア": [
            {"rarity": "コモン", "count": 3, "quantity_range": (8, 15)},
            {"rarity": "アンコモン", "count": 2, "quantity_range": (5, 10)},
            {"rarity": "レア", "count": 1, "quantity_range": (2, 4)}
        ],
        "エピック": [
            {"rarity": "アンコモン", "count": 2, "quantity_range": (10, 15)},
            {"rarity": "レア", "count": 3, "quantity_range": (5, 8)},
            {"rarity": "エピック", "count": 1, "quantity_range": (2, 3)}
        ],
        "レジェンダリー": [
            {"rarity": "レア", "count": 2, "quantity_range": (8, 12)},
            {"rarity": "エピック", "count": 2, "quantity_range": (3, 5)},
            {"rarity": "レジェンダリー", "count": 1, "quantity_range": (1, 2)}
        ]
    }
    
    import random
    
    for recipe in empty_recipes:
        weapon_rarity = recipe.weapon.rarity.name
        print(f"\n処理中: {recipe.name} ({weapon_rarity})")
        
        if weapon_rarity not in recipe_patterns:
            print(f"  警告: {weapon_rarity}のパターンが定義されていません")
            continue
        
        pattern = recipe_patterns[weapon_rarity]
        
        for material_req in pattern:
            rarity_name = material_req["rarity"]
            count = material_req["count"]
            quantity_range = material_req["quantity_range"]
            
            available_materials = materials_by_rarity.get(rarity_name, [])
            if not available_materials:
                print(f"  警告: {rarity_name}素材が利用できません")
                continue
            
            # ランダムに素材を選択
            selected_materials = random.sample(
                available_materials, 
                min(count, len(available_materials))
            )
            
            for material in selected_materials:
                quantity = random.randint(*quantity_range)
                
                recipe_material = RecipeMaterial(
                    recipe_id=recipe.id,
                    material_id=material.id,
                    quantity=quantity
                )
                db.add(recipe_material)
                print(f"  追加: {material.name} x{quantity}")
    
    db.commit()
    print(f"\n{len(empty_recipes)}個のレシピに素材を設定しました")

def main():
    # データベース接続
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(bind=engine)
    db = SessionLocal()
    
    try:
        print("=== レシピ素材不足問題の修正開始 ===\n")
        
        # 1. レジェンダリー素材作成
        print("1. レジェンダリー素材の作成...")
        legendary_materials = create_legendary_materials(db)
        
        # 2. エピック素材追加
        print("\n2. エピック素材の追加...")
        additional_epic_materials = create_additional_epic_materials(db)
        
        # 3. 空のレシピに素材設定
        print("\n3. 空のレシピに素材設定...")
        assign_materials_to_recipes(db)
        
        print("\n=== 修正完了 ===")
        
        # 結果確認
        total_recipes = db.query(CraftingRecipe).count()
        empty_recipes = db.query(CraftingRecipe).filter(~CraftingRecipe.materials.any()).count()
        
        print(f"\n最終結果:")
        print(f"総レシピ数: {total_recipes}")
        print(f"空のレシピ数: {empty_recipes}")
        print(f"素材設定済み: {total_recipes - empty_recipes}")
        
        # 素材数確認
        for rarity_name in ["レア", "エピック", "レジェンダリー"]:
            rarity = db.query(RarityLevel).filter(RarityLevel.name == rarity_name).first()
            if rarity:
                count = db.query(MaterialMaster).filter(
                    MaterialMaster.rarity_id == rarity.id,
                    MaterialMaster.is_active == True
                ).count()
                print(f"{rarity_name}素材数: {count}")
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    main()