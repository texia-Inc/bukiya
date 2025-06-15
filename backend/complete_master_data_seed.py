#!/usr/bin/env python3
"""
完全なマスターデータ作成スクリプト
武器30種、素材20種を作成（必要なマスターデータも含む）
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from sqlalchemy import text

def create_complete_data():
    """完全なマスターデータを作成"""
    db = SessionLocal()
    try:
        print("完全なマスターデータを作成します...")
        
        # 不足しているレアリティレベルを追加
        rarities_sql = """
        INSERT INTO rarity_levels (id, name, level, color_code, star_display, attack_multiplier, max_enchant_level, ability_slots, base_drop_rate, price_multiplier, is_active) 
        VALUES 
        ('uncommon', 'Uncommon', 5, '#00FF00', '★★☆☆☆', 1.15, 12, 0, 0.4000, 1.50, true),
        ('legendary', 'Legendary', 6, '#FF8000', '★★★★★', 2.00, 30, 3, 0.0100, 10.00, true)
        ON CONFLICT (id) DO NOTHING;
        """
        
        # 不足している武器タイプを追加
        weapon_types_sql = """
        INSERT INTO weapon_types (id, name, emoji, description, base_multiplier, attack_speed_modifier, critical_rate_bonus, special_effect, is_active, display_order) 
        VALUES 
        ('axe', '斧', '🪓', '高攻撃力の重い武器', 1.10, 1.20, 0, null, true, 4),
        ('hammer', 'ハンマー', '🔨', '鈍器系の重い武器', 1.15, 1.30, 0, null, true, 5),
        ('dagger', '短剣', '🗡️', '素早い軽い武器', 0.85, 0.80, 0, null, true, 6),
        ('spear', '槍', '⚔️', 'リーチの長い武器', 1.05, 1.10, 0, null, true, 7),
        ('shield', '盾', '🛡️', '防御に特化した装備', 0.50, 1.50, 0, null, true, 8),
        ('whip', '鞭', '🔗', '特殊攻撃の武器', 0.90, 1.00, 0, null, true, 9),
        ('sling', '投石器', '🏹', '投射武器', 0.95, 0.90, 0, null, true, 10)
        ON CONFLICT (id) DO NOTHING;
        """
        
        # 武器データ（修正版）
        weapons_sql = """
        INSERT INTO weapon_masters (
            id, name, weapon_type_id, rarity_id, 
            base_attack_min, base_attack_max, 
            base_price_min, base_price_max, 
            required_shop_level, description
        ) VALUES 
        ('w001', '木の剣', 'sword', 'common', 8, 12, 80, 120, 1, '初心者向けの木製の剣'),
        ('w002', '鉄の剣', 'sword', 'common', 12, 18, 120, 180, 1, '基本的な鉄製の剣'),
        ('w003', '銅の斧', 'axe', 'common', 10, 14, 100, 140, 1, '銅でできた重い斧'),
        ('w004', '石の槌', 'hammer', 'common', 15, 21, 150, 210, 2, '石でできた鈍器'),
        ('w005', '短剣', 'dagger', 'common', 6, 10, 60, 100, 1, '素早い攻撃ができる短剣'),
        ('w006', '木の弓', 'bow', 'common', 11, 17, 110, 170, 2, '遠距離攻撃用の弓'),
        ('w007', '鉄の槍', 'spear', 'common', 13, 19, 130, 190, 2, '長いリーチの槍'),
        ('w008', '銅の盾', 'shield', 'common', 3, 7, 150, 250, 1, '防御に特化した盾'),
        ('w009', '皮の鞭', 'whip', 'common', 7, 11, 70, 110, 1, 'しなやかな皮の鞭'),
        ('w010', '石の投石器', 'sling', 'common', 9, 13, 90, 130, 1, '石を投げる道具'),
        
        ('w011', '鋼鉄の剣', 'sword', 'uncommon', 20, 30, 400, 600, 3, '鋼で鍛えられた剣'),
        ('w012', '魔法の杖', 'staff', 'uncommon', 18, 26, 480, 720, 3, '魔力を込めた杖'),
        ('w013', '銀の剣', 'sword', 'uncommon', 23, 33, 560, 840, 4, '銀でできた美しい剣'),
        ('w014', '戦斧', 'axe', 'uncommon', 25, 35, 640, 960, 4, '戦場で使われる大きな斧'),
        ('w015', '長弓', 'bow', 'uncommon', 19, 29, 440, 660, 3, '遠距離専用の長い弓'),
        ('w016', '鉄の盾', 'shield', 'uncommon', 12, 18, 360, 540, 3, '頑丈な鉄の盾'),
        ('w017', '双剣', 'sword', 'uncommon', 21, 31, 520, 780, 4, '二刀流用の双剣'),
        ('w018', 'クロスボウ', 'bow', 'uncommon', 22, 32, 600, 900, 4, '機械式の弩'),
        ('w019', 'メイス', 'hammer', 'uncommon', 24, 34, 640, 960, 4, '重い鉄球のついた棍棒'),
        ('w020', '投げナイフ', 'dagger', 'uncommon', 16, 24, 320, 480, 3, '投擲用のナイフ'),
        
        ('w021', 'エンチャント剣', 'sword', 'rare', 36, 54, 1600, 2400, 6, '魔法で強化された剣'),
        ('w022', 'ドラゴンスレイヤー', 'sword', 'rare', 40, 60, 2000, 3000, 7, 'ドラゴンを倒すための剣'),
        ('w023', '炎の杖', 'staff', 'rare', 34, 50, 1440, 2160, 6, '炎の魔法を操る杖'),
        ('w024', '氷の槍', 'spear', 'rare', 38, 58, 1760, 2640, 7, '氷の力を宿した槍'),
        ('w025', '雷の弓', 'bow', 'rare', 37, 55, 1680, 2520, 6, '雷の力を持つ弓'),
        
        ('w026', '聖剣エクスカリバー', 'sword', 'epic', 64, 96, 6400, 9600, 10, '伝説の聖剣'),
        ('w027', '破壊の斧', 'axe', 'epic', 68, 102, 7200, 10800, 10, '全てを破壊する斧'),
        ('w028', '賢者の杖', 'staff', 'epic', 60, 90, 6000, 9000, 9, '賢者の知恵が込められた杖'),
        
        ('w029', '神剣グラム', 'sword', 'legendary', 120, 180, 40000, 60000, 15, '神々が作った最強の剣'),
        ('w030', '世界樹の弓', 'bow', 'legendary', 112, 168, 36000, 54000, 15, '世界樹から作られた神弓');
        """
        
        # 素材データ
        materials_sql = """
        INSERT INTO material_masters (id, name, category, rarity_id, base_price, description) VALUES 
        ('m001', '鉄鉱石', 'METAL', 'common', 10, '基本的な鉄の原料'),
        ('m002', '銅鉱石', 'METAL', 'common', 8, '銅を精製する原料'),
        ('m003', '木材', 'ORGANIC', 'common', 5, '武器の柄に使用する木'),
        ('m004', '皮革', 'ORGANIC', 'common', 12, '防具や装飾に使用'),
        ('m005', '石材', 'MINERAL', 'common', 6, '重い武器の材料'),
        ('m006', '魔石', 'MAGICAL', 'uncommon', 50, '魔法の力を持つ石'),
        ('m007', '銀鉱石', 'METAL', 'uncommon', 45, '高級な銀の原料'),
        ('m008', 'クリスタル', 'MINERAL', 'uncommon', 40, '透明で美しい水晶'),
        ('m009', '妖精の粉', 'MAGICAL', 'uncommon', 60, '妖精が落とした魔法の粉'),
        ('m010', '獣の骨', 'ORGANIC', 'uncommon', 35, '強い魔獣の骨'),
        ('m011', 'ミスリル鉱石', 'METAL', 'rare', 200, '伝説の金属の原料'),
        ('m012', 'ドラゴンの鱗', 'ORGANIC', 'rare', 250, 'ドラゴンの硬い鱗'),
        ('m013', '炎の結晶', 'MAGICAL', 'rare', 180, '炎の魔力が込められた結晶'),
        ('m014', '氷の結晶', 'MAGICAL', 'rare', 180, '氷の魔力が込められた結晶'),
        ('m015', '雷の結晶', 'MAGICAL', 'rare', 180, '雷の魔力が込められた結晶'),
        ('m016', 'オリハルコン', 'METAL', 'epic', 1000, '神話の金属'),
        ('m017', 'フェニックスの羽', 'ORGANIC', 'epic', 1200, '不死鳥の羽根'),
        ('m018', '虹色の宝石', 'MINERAL', 'epic', 800, '七色に輝く宝石'),
        ('m019', '天使の涙', 'MAGICAL', 'legendary', 5000, '天使が流した涙の結晶'),
        ('m020', '神の欠片', 'MAGICAL', 'legendary', 8000, '神の力の欠片');
        """
        
        print("レアリティレベルを追加中...")
        db.execute(text(rarities_sql))
        print("✓ レアリティレベルを追加しました")
        
        print("武器タイプを追加中...")
        db.execute(text(weapon_types_sql))
        print("✓ 武器タイプを追加しました")
        
        print("武器データを作成中...")
        db.execute(text(weapons_sql))
        print("✓ 武器 30種を作成しました")
        
        print("素材データを作成中...")
        db.execute(text(materials_sql))
        print("✓ 素材 20種を作成しました")
        
        db.commit()
        print("\n✅ 完全なマスターデータの作成が完了しました！")
        print("- 武器: 30種（コモン10, アンコモン10, レア5, エピック3, レジェンダリー2）")
        print("- 素材: 20種（各レアリティに対応）")
        print("- レアリティレベル: 5種（common, uncommon, rare, epic, legendary）")
        print("- 武器タイプ: 10種（sword, bow, staff, axe, hammer, dagger, spear, shield, whip, sling）")
        
    except Exception as e:
        print(f"✗ エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_complete_data()