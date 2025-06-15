#!/usr/bin/env python3
"""
新しいマスターデータを作成するスクリプト
武器30種、素材20種、レシピ（レア以上）、モンスター20種
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from app.models.weapon_master import WeaponMaster
from app.models.material_master import MaterialMaster
from app.models.crafting_recipe import CraftingRecipe
from app.models.recipe_material import RecipeMaterial

def create_weapons():
    """武器30種を作成"""
    weapons = [
        # コモン (1-10)
        {"name": "木の剣", "rarity_id": 1, "attack": 10, "price": 100, "shop_level": 1, "description": "初心者向けの木製の剣"},
        {"name": "鉄の剣", "rarity_id": 1, "attack": 15, "price": 150, "shop_level": 1, "description": "基本的な鉄製の剣"},
        {"name": "銅の斧", "rarity_id": 1, "attack": 12, "price": 120, "shop_level": 1, "description": "銅でできた重い斧"},
        {"name": "石の槌", "rarity_id": 1, "attack": 18, "price": 180, "shop_level": 2, "description": "石でできた鈍器"},
        {"name": "短剣", "rarity_id": 1, "attack": 8, "price": 80, "shop_level": 1, "description": "素早い攻撃ができる短剣"},
        {"name": "木の弓", "rarity_id": 1, "attack": 14, "price": 140, "shop_level": 2, "description": "遠距離攻撃用の弓"},
        {"name": "鉄の槍", "rarity_id": 1, "attack": 16, "price": 160, "shop_level": 2, "description": "長いリーチの槍"},
        {"name": "銅の盾", "rarity_id": 1, "attack": 5, "price": 200, "shop_level": 1, "description": "防御に特化した盾"},
        {"name": "皮の鞭", "rarity_id": 1, "attack": 9, "price": 90, "shop_level": 1, "description": "しなやかな皮の鞭"},
        {"name": "石の投石器", "rarity_id": 1, "attack": 11, "price": 110, "shop_level": 1, "description": "石を投げる道具"},
        
        # アンコモン (11-20)
        {"name": "鋼鉄の剣", "rarity_id": 2, "attack": 25, "price": 500, "shop_level": 3, "description": "鋼で鍛えられた剣"},
        {"name": "魔法の杖", "rarity_id": 2, "attack": 22, "price": 600, "shop_level": 3, "description": "魔力を込めた杖"},
        {"name": "銀の剣", "rarity_id": 2, "attack": 28, "price": 700, "shop_level": 4, "description": "銀でできた美しい剣"},
        {"name": "戦斧", "rarity_id": 2, "attack": 30, "price": 800, "shop_level": 4, "description": "戦場で使われる大きな斧"},
        {"name": "長弓", "rarity_id": 2, "attack": 24, "price": 550, "shop_level": 3, "description": "遠距離専用の長い弓"},
        {"name": "鉄の盾", "rarity_id": 2, "attack": 15, "price": 450, "shop_level": 3, "description": "頑丈な鉄の盾"},
        {"name": "双剣", "rarity_id": 2, "attack": 26, "price": 650, "shop_level": 4, "description": "二刀流用の双剣"},
        {"name": "クロスボウ", "rarity_id": 2, "attack": 27, "price": 750, "shop_level": 4, "description": "機械式の弩"},
        {"name": "メイス", "rarity_id": 2, "attack": 29, "price": 800, "shop_level": 4, "description": "重い鉄球のついた棍棒"},
        {"name": "投げナイフ", "rarity_id": 2, "attack": 20, "price": 400, "shop_level": 3, "description": "投擲用のナイフ"},
        
        # レア (21-25)
        {"name": "エンチャント剣", "rarity_id": 3, "attack": 45, "price": 2000, "shop_level": 6, "description": "魔法で強化された剣"},
        {"name": "ドラゴンスレイヤー", "rarity_id": 3, "attack": 50, "price": 2500, "shop_level": 7, "description": "ドラゴンを倒すための剣"},
        {"name": "炎の杖", "rarity_id": 3, "attack": 42, "price": 1800, "shop_level": 6, "description": "炎の魔法を操る杖"},
        {"name": "氷の槍", "rarity_id": 3, "attack": 48, "price": 2200, "shop_level": 7, "description": "氷の力を宿した槍"},
        {"name": "雷の弓", "rarity_id": 3, "attack": 46, "price": 2100, "shop_level": 6, "description": "雷の力を持つ弓"},
        
        # エピック (26-28)
        {"name": "聖剣エクスカリバー", "rarity_id": 4, "attack": 80, "price": 8000, "shop_level": 10, "description": "伝説の聖剣"},
        {"name": "破壊の斧", "rarity_id": 4, "attack": 85, "price": 9000, "shop_level": 10, "description": "全てを破壊する斧"},
        {"name": "賢者の杖", "rarity_id": 4, "attack": 75, "price": 7500, "shop_level": 9, "description": "賢者の知恵が込められた杖"},
        
        # レジェンダリー (29-30)
        {"name": "神剣グラム", "rarity_id": 5, "attack": 150, "price": 50000, "shop_level": 15, "description": "神々が作った最強の剣"},
        {"name": "世界樹の弓", "rarity_id": 5, "attack": 140, "price": 45000, "shop_level": 15, "description": "世界樹から作られた神弓"},
    ]
    
    db = SessionLocal()
    try:
        for weapon_data in weapons:
            weapon = WeaponMaster(**weapon_data)
            db.add(weapon)
        db.commit()
        print(f"✓ 武器 {len(weapons)} 種を作成しました")
    finally:
        db.close()

def create_materials():
    """素材20種を作成"""
    materials = [
        {"name": "鉄鉱石", "rarity_id": 1, "description": "基本的な鉄の原料"},
        {"name": "銅鉱石", "rarity_id": 1, "description": "銅を精製する原料"},
        {"name": "木材", "rarity_id": 1, "description": "武器の柄に使用する木"},
        {"name": "皮革", "rarity_id": 1, "description": "防具や装飾に使用"},
        {"name": "石材", "rarity_id": 1, "description": "重い武器の材料"},
        {"name": "魔石", "rarity_id": 2, "description": "魔法の力を持つ石"},
        {"name": "銀鉱石", "rarity_id": 2, "description": "高級な銀の原料"},
        {"name": "クリスタル", "rarity_id": 2, "description": "透明で美しい水晶"},
        {"name": "妖精の粉", "rarity_id": 2, "description": "妖精が落とした魔法の粉"},
        {"name": "獣の骨", "rarity_id": 2, "description": "強い魔獣の骨"},
        {"name": "ミスリル鉱石", "rarity_id": 3, "description": "伝説の金属の原料"},
        {"name": "ドラゴンの鱗", "rarity_id": 3, "description": "ドラゴンの硬い鱗"},
        {"name": "炎の結晶", "rarity_id": 3, "description": "炎の魔力が込められた結晶"},
        {"name": "氷の結晶", "rarity_id": 3, "description": "氷の魔力が込められた結晶"},
        {"name": "雷の結晶", "rarity_id": 3, "description": "雷の魔力が込められた結晶"},
        {"name": "オリハルコン", "rarity_id": 4, "description": "神話の金属"},
        {"name": "フェニックスの羽", "rarity_id": 4, "description": "不死鳥の羽根"},
        {"name": "虹色の宝石", "rarity_id": 4, "description": "七色に輝く宝石"},
        {"name": "天使の涙", "rarity_id": 5, "description": "天使が流した涙の結晶"},
        {"name": "神の欠片", "rarity_id": 5, "description": "神の力の欠片"},
    ]
    
    db = SessionLocal()
    try:
        for material_data in materials:
            material = MaterialMaster(**material_data)
            db.add(material)
        db.commit()
        print(f"✓ 素材 {len(materials)} 種を作成しました")
    finally:
        db.close()

def create_recipes():
    """レア以上の武器のレシピを作成"""
    recipes = [
        # レア武器のレシピ (21-25)
        {"weapon_id": 21, "name": "エンチャント剣のレシピ", "materials": [{"material_id": 7, "quantity": 3}, {"material_id": 6, "quantity": 2}]},
        {"weapon_id": 22, "name": "ドラゴンスレイヤーのレシピ", "materials": [{"material_id": 11, "quantity": 2}, {"material_id": 12, "quantity": 1}]},
        {"weapon_id": 23, "name": "炎の杖のレシピ", "materials": [{"material_id": 6, "quantity": 2}, {"material_id": 13, "quantity": 2}]},
        {"weapon_id": 24, "name": "氷の槍のレシピ", "materials": [{"material_id": 11, "quantity": 2}, {"material_id": 14, "quantity": 2}]},
        {"weapon_id": 25, "name": "雷の弓のレシピ", "materials": [{"material_id": 3, "quantity": 1}, {"material_id": 15, "quantity": 2}]},
        
        # エピック武器のレシピ (26-28)
        {"weapon_id": 26, "name": "聖剣エクスカリバーのレシピ", "materials": [{"material_id": 16, "quantity": 3}, {"material_id": 17, "quantity": 1}]},
        {"weapon_id": 27, "name": "破壊の斧のレシピ", "materials": [{"material_id": 16, "quantity": 4}, {"material_id": 10, "quantity": 2}]},
        {"weapon_id": 28, "name": "賢者の杖のレシピ", "materials": [{"material_id": 16, "quantity": 2}, {"material_id": 18, "quantity": 1}]},
        
        # レジェンダリー武器のレシピ (29-30)
        {"weapon_id": 29, "name": "神剣グラムのレシピ", "materials": [{"material_id": 19, "quantity": 3}, {"material_id": 20, "quantity": 2}]},
        {"weapon_id": 30, "name": "世界樹の弓のレシピ", "materials": [{"material_id": 20, "quantity": 3}, {"material_id": 17, "quantity": 2}]},
    ]
    
    db = SessionLocal()
    try:
        for recipe_data in recipes:
            recipe = CraftingRecipe(
                weapon_id=recipe_data["weapon_id"],
                name=recipe_data["name"],
                cost=1000,
                success_rate=0.8
            )
            db.add(recipe)
            db.flush()
            
            for material_data in recipe_data["materials"]:
                material = RecipeMaterial(
                    recipe_id=recipe.id,
                    material_id=material_data["material_id"],
                    quantity=material_data["quantity"]
                )
                db.add(material)
        
        db.commit()
        print(f"✓ レシピ {len(recipes)} 種を作成しました")
    finally:
        db.close()


def main():
    """メイン処理"""
    print("新しいマスターデータを作成します...")
    
    create_weapons()
    create_materials()
    create_recipes()
    
    print("\n✅ 武器・素材・レシピのマスターデータの作成が完了しました！")
    print("- 武器: 30種（コモン10, アンコモン10, レア5, エピック3, レジェンダリー2）")
    print("- 素材: 20種（各レアリティに対応）")
    print("- レシピ: 10種（レア以上の武器用）")

if __name__ == "__main__":
    main()