#!/usr/bin/env python3
"""
シンプルなマスターデータ作成スクリプト
武器30種、素材20種のみを作成
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from sqlalchemy import text

def create_simple_data():
    """シンプルなマスターデータを作成"""
    db = SessionLocal()
    try:
        print("シンプルなマスターデータを作成します...")
        
        # 武器データを直接SQL INSERTで作成
        weapons_sql = """
        INSERT INTO weapon_masters (
            id, name, weapon_type_id, rarity_id, 
            base_attack_min, base_attack_max, 
            base_price_min, base_price_max, 
            required_shop_level, description
        ) VALUES 
        ('w001', '木の剣', 'SWORD', 'COMMON', 8, 12, 80, 120, 1, '初心者向けの木製の剣'),
        ('w002', '鉄の剣', 'SWORD', 'COMMON', 12, 18, 120, 180, 1, '基本的な鉄製の剣'),
        ('w003', '銅の斧', 'AXE', 'COMMON', 10, 14, 100, 140, 1, '銅でできた重い斧'),
        ('w004', '石の槌', 'HAMMER', 'COMMON', 15, 21, 150, 210, 2, '石でできた鈍器'),
        ('w005', '短剣', 'DAGGER', 'COMMON', 6, 10, 60, 100, 1, '素早い攻撃ができる短剣'),
        ('w006', '木の弓', 'BOW', 'COMMON', 11, 17, 110, 170, 2, '遠距離攻撃用の弓'),
        ('w007', '鉄の槍', 'SPEAR', 'COMMON', 13, 19, 130, 190, 2, '長いリーチの槍'),
        ('w008', '銅の盾', 'SHIELD', 'COMMON', 3, 7, 150, 250, 1, '防御に特化した盾'),
        ('w009', '皮の鞭', 'WHIP', 'COMMON', 7, 11, 70, 110, 1, 'しなやかな皮の鞭'),
        ('w010', '石の投石器', 'SLING', 'COMMON', 9, 13, 90, 130, 1, '石を投げる道具'),
        
        ('w011', '鋼鉄の剣', 'SWORD', 'UNCOMMON', 20, 30, 400, 600, 3, '鋼で鍛えられた剣'),
        ('w012', '魔法の杖', 'STAFF', 'UNCOMMON', 18, 26, 480, 720, 3, '魔力を込めた杖'),
        ('w013', '銀の剣', 'SWORD', 'UNCOMMON', 23, 33, 560, 840, 4, '銀でできた美しい剣'),
        ('w014', '戦斧', 'AXE', 'UNCOMMON', 25, 35, 640, 960, 4, '戦場で使われる大きな斧'),
        ('w015', '長弓', 'BOW', 'UNCOMMON', 19, 29, 440, 660, 3, '遠距離専用の長い弓'),
        ('w016', '鉄の盾', 'SHIELD', 'UNCOMMON', 12, 18, 360, 540, 3, '頑丈な鉄の盾'),
        ('w017', '双剣', 'SWORD', 'UNCOMMON', 21, 31, 520, 780, 4, '二刀流用の双剣'),
        ('w018', 'クロスボウ', 'BOW', 'UNCOMMON', 22, 32, 600, 900, 4, '機械式の弩'),
        ('w019', 'メイス', 'HAMMER', 'UNCOMMON', 24, 34, 640, 960, 4, '重い鉄球のついた棍棒'),
        ('w020', '投げナイフ', 'DAGGER', 'UNCOMMON', 16, 24, 320, 480, 3, '投擲用のナイフ'),
        
        ('w021', 'エンチャント剣', 'SWORD', 'RARE', 36, 54, 1600, 2400, 6, '魔法で強化された剣'),
        ('w022', 'ドラゴンスレイヤー', 'SWORD', 'RARE', 40, 60, 2000, 3000, 7, 'ドラゴンを倒すための剣'),
        ('w023', '炎の杖', 'STAFF', 'RARE', 34, 50, 1440, 2160, 6, '炎の魔法を操る杖'),
        ('w024', '氷の槍', 'SPEAR', 'RARE', 38, 58, 1760, 2640, 7, '氷の力を宿した槍'),
        ('w025', '雷の弓', 'BOW', 'RARE', 37, 55, 1680, 2520, 6, '雷の力を持つ弓'),
        
        ('w026', '聖剣エクスカリバー', 'SWORD', 'EPIC', 64, 96, 6400, 9600, 10, '伝説の聖剣'),
        ('w027', '破壊の斧', 'AXE', 'EPIC', 68, 102, 7200, 10800, 10, '全てを破壊する斧'),
        ('w028', '賢者の杖', 'STAFF', 'EPIC', 60, 90, 6000, 9000, 9, '賢者の知恵が込められた杖'),
        
        ('w029', '神剣グラム', 'SWORD', 'LEGENDARY', 120, 180, 40000, 60000, 15, '神々が作った最強の剣'),
        ('w030', '世界樹の弓', 'BOW', 'LEGENDARY', 112, 168, 36000, 54000, 15, '世界樹から作られた神弓');
        """
        
        # 素材データを直接SQL INSERTで作成
        materials_sql = """
        INSERT INTO material_masters (id, name, rarity_id, description) VALUES 
        ('m001', '鉄鉱石', 'COMMON', '基本的な鉄の原料'),
        ('m002', '銅鉱石', 'COMMON', '銅を精製する原料'),
        ('m003', '木材', 'COMMON', '武器の柄に使用する木'),
        ('m004', '皮革', 'COMMON', '防具や装飾に使用'),
        ('m005', '石材', 'COMMON', '重い武器の材料'),
        ('m006', '魔石', 'UNCOMMON', '魔法の力を持つ石'),
        ('m007', '銀鉱石', 'UNCOMMON', '高級な銀の原料'),
        ('m008', 'クリスタル', 'UNCOMMON', '透明で美しい水晶'),
        ('m009', '妖精の粉', 'UNCOMMON', '妖精が落とした魔法の粉'),
        ('m010', '獣の骨', 'UNCOMMON', '強い魔獣の骨'),
        ('m011', 'ミスリル鉱石', 'RARE', '伝説の金属の原料'),
        ('m012', 'ドラゴンの鱗', 'RARE', 'ドラゴンの硬い鱗'),
        ('m013', '炎の結晶', 'RARE', '炎の魔力が込められた結晶'),
        ('m014', '氷の結晶', 'RARE', '氷の魔力が込められた結晶'),
        ('m015', '雷の結晶', 'RARE', '雷の魔力が込められた結晶'),
        ('m016', 'オリハルコン', 'EPIC', '神話の金属'),
        ('m017', 'フェニックスの羽', 'EPIC', '不死鳥の羽根'),
        ('m018', '虹色の宝石', 'EPIC', '七色に輝く宝石'),
        ('m019', '天使の涙', 'LEGENDARY', '天使が流した涙の結晶'),
        ('m020', '神の欠片', 'LEGENDARY', '神の力の欠片');
        """
        
        print("武器データを作成中...")
        db.execute(text(weapons_sql))
        print("✓ 武器 30種を作成しました")
        
        print("素材データを作成中...")
        db.execute(text(materials_sql))
        print("✓ 素材 20種を作成しました")
        
        db.commit()
        print("\n✅ シンプルなマスターデータの作成が完了しました！")
        print("- 武器: 30種（コモン10, アンコモン10, レア5, エピック3, レジェンダリー2）")
        print("- 素材: 20種（各レアリティに対応）")
        
    except Exception as e:
        print(f"✗ エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_simple_data()