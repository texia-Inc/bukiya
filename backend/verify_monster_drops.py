#!/usr/bin/env python3
"""
モンスタードロップテーブル検証スクリプト
作成されたドロップデータの整合性と品質をチェックします。
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
from typing import Dict, List

class MonsterDropVerifier:
    def __init__(self):
        self.db = SessionLocal()
        
    def verify_drop_data_integrity(self):
        """ドロップデータの整合性をチェック"""
        print("=== ドロップデータ整合性チェック ===")
        
        issues = []
        
        # 1. 存在しないアイテムIDをチェック
        result = self.db.execute(text("""
            SELECT mdt.id, mdt.monster_id, mdt.item_type, mdt.item_id
            FROM monster_drop_tables mdt
            LEFT JOIN material_masters mm ON mdt.item_type = 'material' AND mdt.item_id = mm.id
            LEFT JOIN weapon_masters wm ON mdt.item_type = 'weapon' AND mdt.item_id = wm.id
            WHERE (mdt.item_type = 'material' AND mm.id IS NULL)
               OR (mdt.item_type = 'weapon' AND wm.id IS NULL)
        """))
        
        invalid_items = result.fetchall()
        if invalid_items:
            issues.append(f"存在しないアイテムID: {len(invalid_items)}件")
            for item in invalid_items[:5]:  # 最初の5件を表示
                print(f"  - Monster {item[1]}: {item[2]} ID {item[3]} が存在しません")
        
        # 2. ドロップ率の異常値をチェック
        result = self.db.execute(text("""
            SELECT monster_id, COUNT(*) as count, SUM(drop_rate) as total_rate
            FROM monster_drop_tables
            WHERE drop_rate < 0 OR drop_rate > 1
            GROUP BY monster_id
        """))
        
        invalid_rates = result.fetchall()
        if invalid_rates:
            issues.append(f"異常なドロップ率: {len(invalid_rates)}体のモンスター")
        
        # 3. 数量の異常値をチェック
        result = self.db.execute(text("""
            SELECT COUNT(*) 
            FROM monster_drop_tables
            WHERE min_quantity <= 0 OR max_quantity <= 0 OR min_quantity > max_quantity
        """))
        
        invalid_quantities = result.scalar()
        if invalid_quantities > 0:
            issues.append(f"異常な数量設定: {invalid_quantities}件")
        
        if issues:
            print("❌ 検出された問題:")
            for issue in issues:
                print(f"  - {issue}")
        else:
            print("✅ データ整合性に問題なし")
        
        return len(issues) == 0
    
    def verify_weapon_drop_distribution(self):
        """武器ドロップの分布をチェック"""
        print("\n=== 武器ドロップ分布チェック ===")
        
        # モンスターレベル別の武器レアリティ分布
        result = self.db.execute(text("""
            SELECT 
                mm.level,
                mm.name as monster_name,
                r.name as weapon_rarity,
                wm.name as weapon_name,
                mdt.drop_rate * 100 as drop_rate_percent
            FROM monster_drop_tables mdt
            JOIN monster_masters mm ON mdt.monster_id = mm.id
            JOIN weapon_masters wm ON mdt.item_type = 'weapon' AND mdt.item_id = wm.id
            JOIN rarity_levels r ON wm.rarity_id = r.id
            ORDER BY mm.level, r.id
        """))
        
        weapon_drops = result.fetchall()
        
        if not weapon_drops:
            print("❌ 武器ドロップが設定されていません")
            return False
        
        print(f"✅ 武器ドロップ設定数: {len(weapon_drops)}件")
        
        # レベル帯別の武器レアリティ分布をチェック
        level_rarity_map = {}
        for drop in weapon_drops:
            level_tier = self.get_level_tier(drop[0])
            rarity = drop[2]
            
            if level_tier not in level_rarity_map:
                level_rarity_map[level_tier] = {}
            if rarity not in level_rarity_map[level_tier]:
                level_rarity_map[level_tier][rarity] = 0
            level_rarity_map[level_tier][rarity] += 1
        
        print("\nレベル帯別武器レアリティ分布:")
        for tier, rarities in level_rarity_map.items():
            print(f"  {tier}:")
            for rarity, count in rarities.items():
                print(f"    {rarity}: {count}件")
        
        # 1%ドロップ率のチェック
        non_one_percent = [drop for drop in weapon_drops if abs(drop[4] - 1.0) > 0.01]
        if non_one_percent:
            print(f"\n⚠️ 1%以外の武器ドロップ率: {len(non_one_percent)}件")
            for drop in non_one_percent[:3]:
                print(f"  - {drop[1]} -> {drop[3]}: {drop[4]:.2f}%")
        else:
            print("\n✅ 全ての武器ドロップが1%に設定されています")
        
        return True
    
    def verify_material_drop_balance(self):
        """マテリアルドロップのバランスをチェック"""
        print("\n=== マテリアルドロップバランスチェック ===")
        
        # モンスターあたりのマテリアルドロップ数
        result = self.db.execute(text("""
            SELECT 
                mm.level,
                mm.name,
                COUNT(*) as material_drop_count,
                AVG(mdt.drop_rate) * 100 as avg_drop_rate,
                MAX(mdt.drop_rate) * 100 as max_drop_rate
            FROM monster_drop_tables mdt
            JOIN monster_masters mm ON mdt.monster_id = mm.id
            WHERE mdt.item_type = 'material'
            GROUP BY mm.id, mm.level, mm.name
            ORDER BY mm.level
        """))
        
        material_stats = result.fetchall()
        
        if not material_stats:
            print("❌ マテリアルドロップが設定されていません")
            return False
        
        # 統計計算
        total_monsters = len(material_stats)
        avg_materials_per_monster = sum(stat[2] for stat in material_stats) / total_monsters
        avg_drop_rate = sum(stat[3] for stat in material_stats) / total_monsters
        
        print(f"✅ マテリアルドロップ統計:")
        print(f"  - 設定済みモンスター数: {total_monsters}")
        print(f"  - モンスターあたり平均マテリアル数: {avg_materials_per_monster:.1f}")
        print(f"  - 平均ドロップ率: {avg_drop_rate:.1f}%")
        
        # バランスチェック
        issues = []
        
        # マテリアル数が極端に少ない/多いモンスター
        for stat in material_stats:
            if stat[2] < 2:
                issues.append(f"{stat[1]} (Lv.{stat[0]}): マテリアル数が少ない ({stat[2]})")
            elif stat[2] > 8:
                issues.append(f"{stat[1]} (Lv.{stat[0]}): マテリアル数が多すぎる ({stat[2]})")
        
        # ドロップ率が極端に低い/高いモンスター
        for stat in material_stats:
            if stat[4] > 90:  # 最大ドロップ率が90%超
                issues.append(f"{stat[1]} (Lv.{stat[0]}): 高すぎるドロップ率 ({stat[4]:.1f}%)")
            elif stat[4] < 10:  # 最大ドロップ率が10%未満
                issues.append(f"{stat[1]} (Lv.{stat[0]}): 低すぎるドロップ率 ({stat[4]:.1f}%)")
        
        if issues:
            print(f"\n⚠️ 検出されたバランス問題 ({len(issues)}件):")
            for issue in issues[:5]:  # 最初の5件を表示
                print(f"  - {issue}")
            if len(issues) > 5:
                print(f"  ... 他{len(issues) - 5}件")
        else:
            print("\n✅ マテリアルドロップバランスに問題なし")
        
        return len(issues) == 0
    
    def verify_progression_logic(self):
        """プログレッション論理をチェック"""
        print("\n=== プログレッション論理チェック ===")
        
        # レベル帯別のドロップレアリティ分布
        result = self.db.execute(text("""
            SELECT 
                CASE 
                    WHEN mm.level <= 20 THEN 'Tier 1 (1-20)'
                    WHEN mm.level <= 50 THEN 'Tier 2 (21-50)'
                    WHEN mm.level <= 80 THEN 'Tier 3 (51-80)'
                    ELSE 'Tier 4 (81-100)'
                END as tier,
                r.name as rarity,
                COUNT(*) as count
            FROM monster_drop_tables mdt
            JOIN monster_masters mm ON mdt.monster_id = mm.id
            JOIN material_masters mat ON mdt.item_type = 'material' AND mdt.item_id = mat.id
            JOIN rarity_levels r ON mat.rarity_id = r.id
            GROUP BY 
                CASE 
                    WHEN mm.level <= 20 THEN 'Tier 1 (1-20)'
                    WHEN mm.level <= 50 THEN 'Tier 2 (21-50)'
                    WHEN mm.level <= 80 THEN 'Tier 3 (51-80)'
                    ELSE 'Tier 4 (81-100)'
                END,
                r.id, r.name
            ORDER BY tier, r.id
        """))
        
        progression_data = {}
        for row in result.fetchall():
            tier, rarity, count = row
            if tier not in progression_data:
                progression_data[tier] = {}
            progression_data[tier][rarity] = count
        
        print("レベル帯別マテリアルレアリティ分布:")
        for tier, rarities in progression_data.items():
            print(f"  {tier}:")
            total = sum(rarities.values())
            for rarity, count in rarities.items():
                percentage = (count / total) * 100 if total > 0 else 0
                print(f"    {rarity}: {count}件 ({percentage:.1f}%)")
        
        # プログレッション論理のチェック
        issues = []
        
        # 低レベル帯で高レアリティが多すぎないかチェック
        if 'Tier 1 (1-20)' in progression_data:
            tier1 = progression_data['Tier 1 (1-20)']
            total_tier1 = sum(tier1.values())
            high_rarity_count = tier1.get('レア', 0) + tier1.get('エピック', 0) + tier1.get('レジェンダリー', 0)
            if high_rarity_count / total_tier1 > 0.3:  # 30%以上
                issues.append("Tier 1で高レアリティマテリアルが多すぎます")
        
        # 高レベル帯でコモンが多すぎないかチェック
        if 'Tier 4 (81-100)' in progression_data:
            tier4 = progression_data['Tier 4 (81-100)']
            total_tier4 = sum(tier4.values())
            common_count = tier4.get('コモン', 0)
            if common_count / total_tier4 > 0.5:  # 50%以上
                issues.append("Tier 4でコモンマテリアルが多すぎます")
        
        if issues:
            print(f"\n⚠️ プログレッション問題:")
            for issue in issues:
                print(f"  - {issue}")
        else:
            print("\n✅ プログレッション論理に問題なし")
        
        return len(issues) == 0
    
    def get_level_tier(self, level: int) -> str:
        """レベルからティアを取得"""
        if level <= 20:
            return "Tier 1 (1-20)"
        elif level <= 50:
            return "Tier 2 (21-50)"
        elif level <= 80:
            return "Tier 3 (51-80)"
        else:
            return "Tier 4 (81-100)"
    
    def generate_sample_drops(self, monster_count: int = 5):
        """サンプルドロップ例を生成"""
        print(f"\n=== サンプルドロップ例 (ランダム{monster_count}体) ===")
        
        result = self.db.execute(text(f"""
            SELECT DISTINCT mm.id, mm.name, mm.level
            FROM monster_masters mm
            JOIN monster_drop_tables mdt ON mm.id = mdt.monster_id
            ORDER BY RANDOM()
            LIMIT {monster_count}
        """))
        
        sample_monsters = result.fetchall()
        
        for monster_id, monster_name, monster_level in sample_monsters:
            print(f"\n{monster_name} (Lv.{monster_level}):")
            
            # このモンスターのドロップを取得
            result = self.db.execute(text("""
                SELECT 
                    mdt.item_type,
                    CASE 
                        WHEN mdt.item_type = 'material' THEN mm.name
                        WHEN mdt.item_type = 'weapon' THEN wm.name
                    END as item_name,
                    CASE 
                        WHEN mdt.item_type = 'material' THEN r1.name
                        WHEN mdt.item_type = 'weapon' THEN r2.name
                    END as rarity,
                    mdt.drop_rate * 100 as drop_rate,
                    mdt.min_quantity,
                    mdt.max_quantity
                FROM monster_drop_tables mdt
                LEFT JOIN material_masters mm ON mdt.item_type = 'material' AND mdt.item_id = mm.id
                LEFT JOIN weapon_masters wm ON mdt.item_type = 'weapon' AND mdt.item_id = wm.id
                LEFT JOIN rarity_levels r1 ON mm.rarity_id = r1.id
                LEFT JOIN rarity_levels r2 ON wm.rarity_id = r2.id
                WHERE mdt.monster_id = :monster_id
                ORDER BY mdt.drop_rate DESC
            """), {"monster_id": monster_id})
            
            drops = result.fetchall()
            
            for drop in drops:
                item_type, item_name, rarity, drop_rate, min_qty, max_qty = drop
                qty_text = f"{min_qty}-{max_qty}" if min_qty != max_qty else str(min_qty)
                print(f"  - {item_name} ({rarity}) [{item_type}]: {drop_rate:.1f}% (数量: {qty_text})")
    
    def run_verification(self):
        """全体的な検証を実行"""
        print("=== モンスタードロップテーブル検証開始 ===\n")
        
        results = {
            "integrity": self.verify_drop_data_integrity(),
            "weapon_distribution": self.verify_weapon_drop_distribution(),
            "material_balance": self.verify_material_drop_balance(),
            "progression": self.verify_progression_logic()
        }
        
        self.generate_sample_drops()
        
        # 総合結果
        print(f"\n=== 検証結果サマリー ===")
        all_passed = all(results.values())
        
        for check, passed in results.items():
            status = "✅ PASS" if passed else "❌ FAIL"
            print(f"{check.upper().replace('_', ' ')}: {status}")
        
        overall_status = "✅ 全チェック合格" if all_passed else "⚠️ 一部問題あり"
        print(f"\n総合結果: {overall_status}")
        
        return all_passed
    
    def __del__(self):
        if hasattr(self, 'db'):
            self.db.close()

def main():
    verifier = MonsterDropVerifier()
    verifier.run_verification()

if __name__ == "__main__":
    main()