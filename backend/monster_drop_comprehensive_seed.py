#!/usr/bin/env python3
"""
包括的モンスタードロップシードデータ
全100体のモンスターに対して適切なドロップテーブルを作成します。

機能:
1. レベル帯に応じた適切な素材ドロップ
2. 各モンスターに1%の確率で次のレアリティ武器ドロップ
3. バランスの取れたドロップ率設定
4. モンスタータイプに応じた特殊ドロップ
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from app.models.adventurer_master import MonsterMaster, MonsterDropTable
from app.models.material_master import MaterialMaster
from app.models.weapon_master import WeaponMaster
from app.models.rarity_level import RarityLevel
from sqlalchemy import text
from typing import Dict, List, Tuple
import random

def get_rarity_for_level(level: int) -> int:
    """レベルに応じて適切なレアリティを返す"""
    if level <= 10:
        return 1  # Common
    elif level <= 25:
        return 2  # Uncommon
    elif level <= 50:
        return 3  # Rare
    elif level <= 75:
        return 4  # Epic
    else:
        return 5  # Legendary

def get_weapon_rarity_for_drop(monster_level: int) -> int:
    """モンスターレベルに応じて次のレアリティ武器を返す"""
    base_rarity = get_rarity_for_level(monster_level)
    # 次のレアリティにする（最大5まで）
    return min(base_rarity + 1, 5)

class MonsterDropSeeder:
    def __init__(self):
        self.db = SessionLocal()
        self.materials_by_rarity = {}
        self.weapons_by_rarity = {}
        self.monsters = []
        
    def load_data(self):
        """必要なデータを読み込む"""
        print("データベースからデータを読み込み中...")
        
        # 素材をレアリティ別に分類
        materials = self.db.query(MaterialMaster).filter(MaterialMaster.is_active == True).all()
        for material in materials:
            if material.rarity_id not in self.materials_by_rarity:
                self.materials_by_rarity[material.rarity_id] = []
            self.materials_by_rarity[material.rarity_id].append(material)
        
        # 武器をレアリティ別に分類
        weapons = self.db.query(WeaponMaster).filter(WeaponMaster.is_active == True).all()
        for weapon in weapons:
            if weapon.rarity_id not in self.weapons_by_rarity:
                self.weapons_by_rarity[weapon.rarity_id] = []
            self.weapons_by_rarity[weapon.rarity_id].append(weapon)
        
        # モンスター情報を取得
        self.monsters = self.db.query(MonsterMaster).filter(MonsterMaster.is_active == True).order_by(MonsterMaster.level).all()
        
        print(f"読み込み完了:")
        print(f"  - 素材: {sum(len(mats) for mats in self.materials_by_rarity.values())}個")
        print(f"  - 武器: {sum(len(weapons) for weapons in self.weapons_by_rarity.values())}個")
        print(f"  - モンスター: {len(self.monsters)}体")
        
    def clear_existing_drops(self):
        """既存のドロップデータを削除"""
        print("既存のドロップデータを削除中...")
        deleted_count = self.db.query(MonsterDropTable).delete()
        self.db.commit()
        print(f"削除完了: {deleted_count}件")
        
    def get_material_drops_for_monster(self, monster: MonsterMaster) -> List[Dict]:
        """モンスターに適したマテリアルドロップを生成"""
        drops = []
        level = monster.level
        
        # 基本レアリティを決定
        base_rarity = get_rarity_for_level(level)
        
        # コモン素材 (高確率)
        if 1 in self.materials_by_rarity:
            common_materials = random.sample(
                self.materials_by_rarity[1], 
                min(3, len(self.materials_by_rarity[1]))
            )
            for i, material in enumerate(common_materials):
                drop_rate = 0.70 - (i * 0.15)  # 70%, 55%, 40%
                drops.append({
                    "item_type": "material",
                    "item_id": material.id,
                    "drop_rate": drop_rate,
                    "min_quantity": 1,
                    "max_quantity": 2 + (level // 10)
                })
        
        # 基本レアリティ素材 (中確率)
        if base_rarity in self.materials_by_rarity and base_rarity > 1:
            base_materials = random.sample(
                self.materials_by_rarity[base_rarity],
                min(2, len(self.materials_by_rarity[base_rarity]))
            )
            for i, material in enumerate(base_materials):
                drop_rate = 0.35 - (i * 0.10)  # 35%, 25%
                drops.append({
                    "item_type": "material",
                    "item_id": material.id,
                    "drop_rate": drop_rate,
                    "min_quantity": 1,
                    "max_quantity": 1 + (level // 20)
                })
        
        # 高レアリティ素材 (低確率)
        higher_rarity = min(base_rarity + 1, 5)
        if higher_rarity in self.materials_by_rarity:
            rare_material = random.choice(self.materials_by_rarity[higher_rarity])
            drops.append({
                "item_type": "material",
                "item_id": rare_material.id,
                "drop_rate": 0.15,
                "min_quantity": 1,
                "max_quantity": 1
            })
        
        # 特殊素材（高レベルモンスターのみ）
        if level >= 50 and higher_rarity + 1 <= 5 and (higher_rarity + 1) in self.materials_by_rarity:
            super_rare_material = random.choice(self.materials_by_rarity[higher_rarity + 1])
            drops.append({
                "item_type": "material",
                "item_id": super_rare_material.id,
                "drop_rate": 0.05,
                "min_quantity": 1,
                "max_quantity": 1,
                "required_weapon_enchant": max(5, level // 10),
                "required_adventurer_level": max(10, level - 5)
            })
        
        return drops
    
    def get_weapon_drop_for_monster(self, monster: MonsterMaster) -> Dict:
        """モンスターの1%武器ドロップを生成"""
        weapon_rarity = get_weapon_rarity_for_drop(monster.level)
        
        if weapon_rarity not in self.weapons_by_rarity:
            return None
        
        # 適切なレベル範囲の武器を選択
        suitable_weapons = [
            weapon for weapon in self.weapons_by_rarity[weapon_rarity]
            if weapon.required_level <= monster.level + 5  # モンスターレベル+5まで
        ]
        
        if not suitable_weapons:
            # 適切な武器がない場合は、そのレアリティの最低レベル武器を選択
            suitable_weapons = sorted(
                self.weapons_by_rarity[weapon_rarity],
                key=lambda w: w.required_level
            )[:3]  # 最低レベルの3つから選択
        
        if suitable_weapons:
            weapon = random.choice(suitable_weapons)
            return {
                "item_type": "weapon",
                "item_id": weapon.id,
                "drop_rate": 0.01,  # 1%
                "min_quantity": 1,
                "max_quantity": 1
            }
        
        return None
    
    def create_drops_for_monster(self, monster: MonsterMaster):
        """指定されたモンスターのドロップを作成"""
        drops_to_create = []
        
        # マテリアルドロップを追加
        material_drops = self.get_material_drops_for_monster(monster)
        drops_to_create.extend(material_drops)
        
        # 武器ドロップを追加
        weapon_drop = self.get_weapon_drop_for_monster(monster)
        if weapon_drop:
            drops_to_create.append(weapon_drop)
        
        # データベースに保存
        for drop_data in drops_to_create:
            drop = MonsterDropTable(
                monster_id=monster.id,
                item_type=drop_data["item_type"],
                item_id=drop_data["item_id"],
                drop_rate=drop_data["drop_rate"],
                min_quantity=drop_data["min_quantity"],
                max_quantity=drop_data["max_quantity"],
                required_weapon_enchant=drop_data.get("required_weapon_enchant", 0),
                required_adventurer_level=drop_data.get("required_adventurer_level", 1),
                is_active=True
            )
            self.db.add(drop)
    
    def create_all_drops(self):
        """全モンスターのドロップを作成"""
        print("全モンスターのドロップテーブルを作成中...")
        
        created_count = 0
        for i, monster in enumerate(self.monsters, 1):
            print(f"進行状況: {i}/{len(self.monsters)} - {monster.name} (Lv.{monster.level})")
            
            try:
                self.create_drops_for_monster(monster)
                created_count += 1
                
                # 10体ごとにコミット
                if i % 10 == 0:
                    self.db.commit()
                    print(f"  -> {i}体のドロップ作成完了")
                    
            except Exception as e:
                print(f"  -> エラー: {monster.name} - {e}")
                continue
        
        # 最終コミット
        self.db.commit()
        print(f"\n全{created_count}体のモンスタードロップ作成完了！")
        
    def generate_summary(self):
        """作成結果のサマリーを表示"""
        print("\n=== ドロップテーブル作成結果 ===")
        
        # 総ドロップ数
        total_drops = self.db.query(MonsterDropTable).count()
        print(f"総ドロップエントリー数: {total_drops}")
        
        # アイテムタイプ別
        result = self.db.execute(text("""
            SELECT item_type, COUNT(*) as count, AVG(drop_rate) * 100 as avg_rate
            FROM monster_drop_tables 
            GROUP BY item_type
        """))
        
        print("\nアイテムタイプ別統計:")
        for row in result.fetchall():
            print(f"  {row[0]}: {row[1]}件 (平均ドロップ率: {row[2]:.1f}%)")
        
        # レアリティ別武器ドロップ
        result = self.db.execute(text("""
            SELECT r.name, COUNT(*) as count
            FROM monster_drop_tables mdt
            JOIN weapon_masters wm ON mdt.item_type = 'weapon' AND mdt.item_id = wm.id
            JOIN rarity_levels r ON wm.rarity_id = r.id
            GROUP BY r.id, r.name
            ORDER BY r.id
        """))
        
        print("\nレアリティ別武器ドロップ:")
        for row in result.fetchall():
            print(f"  {row[0]}: {row[1]}件")
        
        # モンスターレベル帯別統計
        result = self.db.execute(text("""
            SELECT 
                CASE 
                    WHEN mm.level <= 20 THEN 'Tier 1 (1-20)'
                    WHEN mm.level <= 50 THEN 'Tier 2 (21-50)'
                    WHEN mm.level <= 80 THEN 'Tier 3 (51-80)'
                    ELSE 'Tier 4 (81-100)'
                END as tier,
                COUNT(DISTINCT mm.id) as monsters,
                COUNT(mdt.id) as total_drops,
                ROUND(AVG(mdt.drop_rate) * 100, 1) as avg_drop_rate
            FROM monster_masters mm
            JOIN monster_drop_tables mdt ON mm.id = mdt.monster_id
            GROUP BY 
                CASE 
                    WHEN mm.level <= 20 THEN 'Tier 1 (1-20)'
                    WHEN mm.level <= 50 THEN 'Tier 2 (21-50)'
                    WHEN mm.level <= 80 THEN 'Tier 3 (51-80)'
                    ELSE 'Tier 4 (81-100)'
                END
            ORDER BY tier
        """))
        
        print("\nティア別統計:")
        for row in result.fetchall():
            print(f"  {row[0]}: {row[1]}体のモンスター, {row[2]}ドロップ (平均率: {row[3]}%)")
    
    def run(self):
        """メイン実行関数"""
        try:
            print("=== 包括的モンスタードロップシードデータ作成開始 ===\n")
            
            # データ読み込み
            self.load_data()
            
            # 既存データ削除
            self.clear_existing_drops()
            
            # 新規ドロップ作成
            self.create_all_drops()
            
            # 結果サマリー
            self.generate_summary()
            
            print("\n=== 処理完了 ===")
            
        except Exception as e:
            print(f"エラーが発生しました: {e}")
            import traceback
            traceback.print_exc()
            self.db.rollback()
        finally:
            self.db.close()

def main():
    seeder = MonsterDropSeeder()
    seeder.run()

if __name__ == "__main__":
    main()