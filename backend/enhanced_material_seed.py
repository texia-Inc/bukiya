#!/usr/bin/env python3
"""
強化された素材シードデータ
現在の9個の素材に加えて、50個の新しい素材を追加
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from app.models.material_master import MaterialMaster
from sqlalchemy import text

def create_enhanced_materials():
    db = SessionLocal()
    
    try:
        # 現在の素材数を確認
        result = db.execute(text("SELECT COUNT(*) FROM material_masters"))
        current_count = result.scalar()
        print(f"現在の素材数: {current_count}")
        
        # 新しい素材データ
        new_materials = [
            # === 基本素材 (Common) ===
            {"name": "木の枝", "description": "よく乾燥した丈夫な木の枝", "rarity_id": 1, "base_price": 5, "material_type": "wood"},
            {"name": "動物の毛皮", "description": "狩猟で得られる丈夫な毛皮", "rarity_id": 1, "base_price": 12, "material_type": "leather"},
            {"name": "粘土", "description": "陶器や鋳型作りに使える良質な粘土", "rarity_id": 1, "base_price": 8, "material_type": "earth"},
            {"name": "砂", "description": "研磨や鋳造に使える細かい砂", "rarity_id": 1, "base_price": 3, "material_type": "earth"},
            {"name": "炭", "description": "鍛冶の燃料として使われる木炭", "rarity_id": 1, "base_price": 10, "material_type": "fuel"},
            {"name": "羊毛", "description": "防具の裏地に使える柔らかい羊毛", "rarity_id": 1, "base_price": 15, "material_type": "fiber"},
            {"name": "麻紐", "description": "武器の柄巻きに使える丈夫な紐", "rarity_id": 1, "base_price": 7, "material_type": "fiber"},
            {"name": "骨", "description": "装飾や小さな部品に使える動物の骨", "rarity_id": 1, "base_price": 18, "material_type": "bone"},
            {"name": "小石", "description": "研磨剤として使える小さな石", "rarity_id": 1, "base_price": 2, "material_type": "stone"},
            {"name": "樹液", "description": "接着剤として使える天然の樹液", "rarity_id": 1, "base_price": 20, "material_type": "liquid"},
            
            # === 中級素材 (Rare) ===
            {"name": "鋼鉄塊", "description": "高品質な鋼鉄の塊", "rarity_id": 2, "base_price": 80, "material_type": "metal"},
            {"name": "魔法の水晶", "description": "魔力を宿した透明な水晶", "rarity_id": 2, "base_price": 120, "material_type": "crystal"},
            {"name": "竜の鱗", "description": "強固な防御力を持つ竜の鱗", "rarity_id": 2, "base_price": 200, "material_type": "scale"},
            {"name": "精霊の羽", "description": "軽量で魔力伝導性の高い羽", "rarity_id": 2, "base_price": 150, "material_type": "feather"},
            {"name": "古代の木材", "description": "何百年も経た硬い木材", "rarity_id": 2, "base_price": 100, "material_type": "wood"},
            {"name": "妖精の粉", "description": "エンチャント効果を高める魔法の粉", "rarity_id": 2, "base_price": 180, "material_type": "powder"},
            {"name": "星の金属", "description": "隕石から採取された特殊金属", "rarity_id": 2, "base_price": 250, "material_type": "metal"},
            {"name": "深海の真珠", "description": "深海から採取された美しい真珠", "rarity_id": 2, "base_price": 160, "material_type": "gem"},
            {"name": "炎の石", "description": "火属性の魔力を秘めた赤い石", "rarity_id": 2, "base_price": 140, "material_type": "stone"},
            {"name": "氷の結晶", "description": "永久に溶けない氷の結晶", "rarity_id": 2, "base_price": 130, "material_type": "crystal"},
            {"name": "雷の欠片", "description": "雷の力を封じ込めた結晶片", "rarity_id": 2, "base_price": 170, "material_type": "crystal"},
            {"name": "風の羽根", "description": "風属性の魔力を持つ特殊な羽根", "rarity_id": 2, "base_price": 110, "material_type": "feather"},
            {"name": "聖なる水", "description": "浄化の力を持つ聖水", "rarity_id": 2, "base_price": 90, "material_type": "liquid"},
            {"name": "悪魔の角", "description": "強大な魔力を秘めた悪魔の角", "rarity_id": 2, "base_price": 220, "material_type": "horn"},
            {"name": "ガーディアンの核", "description": "古代ガーディアンの動力源", "rarity_id": 2, "base_price": 300, "material_type": "core"},
            
            # === 高級素材 (Epic) ===
            {"name": "アダマンタイト鉱石", "description": "伝説的な硬度を持つ希少鉱石", "rarity_id": 3, "base_price": 500, "material_type": "metal"},
            {"name": "フェニックスの羽", "description": "不死鳥の美しく強力な羽", "rarity_id": 3, "base_price": 800, "material_type": "feather"},
            {"name": "古龍の心臓", "description": "古い龍の強大な生命力を持つ心臓", "rarity_id": 3, "base_price": 1200, "material_type": "organ"},
            {"name": "時の砂", "description": "時間の流れを操る神秘の砂", "rarity_id": 3, "base_price": 900, "material_type": "sand"},
            {"name": "虚空の破片", "description": "次元の裂け目から得られる謎の物質", "rarity_id": 3, "base_price": 1000, "material_type": "void"},
            {"name": "生命の樹液", "description": "世界樹から採取された神聖な樹液", "rarity_id": 3, "base_price": 700, "material_type": "liquid"},
            {"name": "星霊の涙", "description": "星の精霊が流した純粋な涙", "rarity_id": 3, "base_price": 1100, "material_type": "liquid"},
            {"name": "混沌の結晶", "description": "秩序と混沌が混ざり合った結晶", "rarity_id": 3, "base_price": 950, "material_type": "crystal"},
            {"name": "神獣の毛", "description": "神聖な獣の金色に輝く毛", "rarity_id": 3, "base_price": 600, "material_type": "fiber"},
            {"name": "霊魂の石", "description": "魂の力を宿した神秘的な石", "rarity_id": 3, "base_price": 850, "material_type": "stone"},
            {"name": "純白の金属", "description": "一切の不純物を含まない純粋な金属", "rarity_id": 3, "base_price": 1300, "material_type": "metal"},
            {"name": "深淵の水", "description": "深淵から湧き出る漆黒の水", "rarity_id": 3, "base_price": 750, "material_type": "liquid"},
            {"name": "光の欠片", "description": "純粋な光の力を封じ込めた結晶", "rarity_id": 3, "base_price": 1150, "material_type": "crystal"},
            
            # === 伝説素材 (Legendary) ===
            {"name": "創世の欠片", "description": "世界創造時に残された原初の物質", "rarity_id": 4, "base_price": 5000, "material_type": "primordial"},
            {"name": "神の血", "description": "神々の血液から精製された聖なる液体", "rarity_id": 4, "base_price": 8000, "material_type": "divine"},
            {"name": "終焉の金属", "description": "世界の終わりを告げる黒い金属", "rarity_id": 4, "base_price": 6000, "material_type": "metal"},
            {"name": "永遠の炎", "description": "決して消えることのない神の炎", "rarity_id": 4, "base_price": 7500, "material_type": "flame"},
            {"name": "運命の糸", "description": "運命を紡ぐ神秘的な糸", "rarity_id": 4, "base_price": 4500, "material_type": "thread"},
            {"name": "真理の結晶", "description": "全ての真理を映し出す完璧な結晶", "rarity_id": 4, "base_price": 10000, "material_type": "crystal"},
            
            # === 特殊・専用素材 ===
            {"name": "鍛冶師の魂", "description": "伝説の鍛冶師の魂が宿った結晶", "rarity_id": 3, "base_price": 2000, "material_type": "soul"},
            {"name": "戦士の誇り", "description": "勇敢な戦士の誇りが具現化した物質", "rarity_id": 3, "base_price": 1800, "material_type": "spirit"},
            {"name": "魔導師の知恵", "description": "賢い魔導師の知識が結晶化したもの", "rarity_id": 3, "base_price": 2200, "material_type": "wisdom"},
            {"name": "盗賊の影", "description": "熟練盗賊の影の技が物質化したもの", "rarity_id": 3, "base_price": 1600, "material_type": "shadow"},
            {"name": "聖騎士の光", "description": "聖なる騎士の正義の心が光となったもの", "rarity_id": 3, "base_price": 2500, "material_type": "light"},
            
            # === エンチャント専用素材 ===
            {"name": "強化の粉末", "description": "武器強化に特化した魔法の粉末", "rarity_id": 2, "base_price": 300, "material_type": "enhancement"},
            {"name": "安定の石", "description": "エンチャントの成功率を高める石", "rarity_id": 2, "base_price": 400, "material_type": "stabilizer"},
            {"name": "保護の護符", "description": "破壊を防ぐ魔法の護符", "rarity_id": 3, "base_price": 1500, "material_type": "protection"},
            {"name": "集中の宝石", "description": "魔力を集中させる特殊な宝石", "rarity_id": 2, "base_price": 350, "material_type": "focus"},
            {"name": "完璧の象徴", "description": "100%の成功を約束する伝説の品", "rarity_id": 4, "base_price": 15000, "material_type": "perfection"},
        ]
        
        # 既存の素材名を取得（重複回避）
        result = db.execute(text("SELECT name FROM material_masters"))
        existing_names = {row[0] for row in result.fetchall()}
        
        added_count = 0
        for material_data in new_materials:
            if material_data["name"] not in existing_names:
                material = MaterialMaster(
                    name=material_data["name"],
                    description=material_data["description"],
                    rarity_id=material_data["rarity_id"],
                    base_price=material_data["base_price"],
                    material_type=material_data["material_type"]
                )
                db.add(material)
                added_count += 1
                print(f"追加: {material_data['name']} (Rarity: {material_data['rarity_id']}, Price: {material_data['base_price']})")
            else:
                print(f"スキップ: {material_data['name']} (既存)")
        
        db.commit()
        print(f"\n合計 {added_count} 個の新しい素材を追加しました！")
        
        # 最終的な素材数を確認
        result = db.execute(text("SELECT COUNT(*) FROM material_masters"))
        final_count = result.scalar()
        print(f"最終素材数: {final_count}")
        
        # レアリティ別の分布を表示
        result = db.execute(text("""
            SELECT r.name, COUNT(*) as count 
            FROM material_masters m 
            JOIN rarity_levels r ON m.rarity_id = r.id 
            GROUP BY r.id, r.name 
            ORDER BY r.id
        """))
        print("\nレアリティ別分布:")
        for row in result.fetchall():
            print(f"  {row[0]}: {row[1]}個")
            
    except Exception as e:
        print(f"エラー: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_enhanced_materials()