#!/usr/bin/env python3
"""
強化された素材シードデータ（直接SQL版）
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from sqlalchemy import text

def create_enhanced_materials():
    db = SessionLocal()
    
    try:
        # 現在の素材数を確認
        result = db.execute(text("SELECT COUNT(*) FROM material_masters"))
        current_count = result.scalar()
        print(f"現在の素材数: {current_count}")
        
        # 既存の素材名を取得（重複回避）
        result = db.execute(text("SELECT name FROM material_masters"))
        existing_names = {row[0] for row in result.fetchall()}
        
        # 新しい素材データ
        new_materials = [
            # === 基本素材 (Common) ===
            ("木の枝", "よく乾燥した丈夫な木の枝", 1, 5, "wood"),
            ("動物の毛皮", "狩猟で得られる丈夫な毛皮", 1, 12, "leather"),
            ("粘土", "陶器や鋳型作りに使える良質な粘土", 1, 8, "earth"),
            ("砂", "研磨や鋳造に使える細かい砂", 1, 3, "earth"),
            ("炭", "鍛冶の燃料として使われる木炭", 1, 10, "fuel"),
            ("羊毛", "防具の裏地に使える柔らかい羊毛", 1, 15, "fiber"),
            ("麻紐", "武器の柄巻きに使える丈夫な紐", 1, 7, "fiber"),
            ("骨", "装飾や小さな部品に使える動物の骨", 1, 18, "bone"),
            ("小石", "研磨剤として使える小さな石", 1, 2, "stone"),
            ("樹液", "接着剤として使える天然の樹液", 1, 20, "liquid"),
            
            # === 中級素材 (Rare) ===
            ("鋼鉄塊", "高品質な鋼鉄の塊", 2, 80, "metal"),
            ("魔法の水晶", "魔力を宿した透明な水晶", 2, 120, "crystal"),
            ("竜の鱗", "強固な防御力を持つ竜の鱗", 2, 200, "scale"),
            ("精霊の羽", "軽量で魔力伝導性の高い羽", 2, 150, "feather"),
            ("古代の木材", "何百年も経た硬い木材", 2, 100, "wood"),
            ("妖精の粉", "エンチャント効果を高める魔法の粉", 2, 180, "powder"),
            ("星の金属", "隕石から採取された特殊金属", 2, 250, "metal"),
            ("深海の真珠", "深海から採取された美しい真珠", 2, 160, "gem"),
            ("炎の石", "火属性の魔力を秘めた赤い石", 2, 140, "stone"),
            ("氷の結晶", "永久に溶けない氷の結晶", 2, 130, "crystal"),
            ("雷の欠片", "雷の力を封じ込めた結晶片", 2, 170, "crystal"),
            ("風の羽根", "風属性の魔力を持つ特殊な羽根", 2, 110, "feather"),
            ("聖なる水", "浄化の力を持つ聖水", 2, 90, "liquid"),
            ("悪魔の角", "強大な魔力を秘めた悪魔の角", 2, 220, "horn"),
            ("ガーディアンの核", "古代ガーディアンの動力源", 2, 300, "core"),
            
            # === 高級素材 (Epic) ===
            ("アダマンタイト鉱石", "伝説的な硬度を持つ希少鉱石", 3, 500, "metal"),
            ("フェニックスの羽", "不死鳥の美しく強力な羽", 3, 800, "feather"),
            ("古龍の心臓", "古い龍の強大な生命力を持つ心臓", 3, 1200, "organ"),
            ("時の砂", "時間の流れを操る神秘の砂", 3, 900, "sand"),
            ("虚空の破片", "次元の裂け目から得られる謎の物質", 3, 1000, "void"),
            ("生命の樹液", "世界樹から採取された神聖な樹液", 3, 700, "liquid"),
            ("星霊の涙", "星の精霊が流した純粋な涙", 3, 1100, "liquid"),
            ("混沌の結晶", "秩序と混沌が混ざり合った結晶", 3, 950, "crystal"),
            ("神獣の毛", "神聖な獣の金色に輝く毛", 3, 600, "fiber"),
            ("霊魂の石", "魂の力を宿した神秘的な石", 3, 850, "stone"),
            ("純白の金属", "一切の不純物を含まない純粋な金属", 3, 1300, "metal"),
            ("深淵の水", "深淵から湧き出る漆黒の水", 3, 750, "liquid"),
            ("光の欠片", "純粋な光の力を封じ込めた結晶", 3, 1150, "crystal"),
            
            # === 伝説素材 (Legendary) ===
            ("創世の欠片", "世界創造時に残された原初の物質", 4, 5000, "primordial"),
            ("神の血", "神々の血液から精製された聖なる液体", 4, 8000, "divine"),
            ("終焉の金属", "世界の終わりを告げる黒い金属", 4, 6000, "metal"),
            ("永遠の炎", "決して消えることのない神の炎", 4, 7500, "flame"),
            ("運命の糸", "運命を紡ぐ神秘的な糸", 4, 4500, "thread"),
            ("真理の結晶", "全ての真理を映し出す完璧な結晶", 4, 10000, "crystal"),
            
            # === 特殊・専用素材 ===
            ("鍛冶師の魂", "伝説の鍛冶師の魂が宿った結晶", 3, 2000, "soul"),
            ("戦士の誇り", "勇敢な戦士の誇りが具現化した物質", 3, 1800, "spirit"),
            ("魔導師の知恵", "賢い魔導師の知識が結晶化したもの", 3, 2200, "wisdom"),
            ("盗賊の影", "熟練盗賊の影の技が物質化したもの", 3, 1600, "shadow"),
            ("聖騎士の光", "聖なる騎士の正義の心が光となったもの", 3, 2500, "light"),
            
            # === エンチャント専用素材 ===
            ("強化の粉末", "武器強化に特化した魔法の粉末", 2, 300, "enhancement"),
            ("安定の石", "エンチャントの成功率を高める石", 2, 400, "stabilizer"),
            ("保護の護符", "破壊を防ぐ魔法の護符", 3, 1500, "protection"),
            ("集中の宝石", "魔力を集中させる特殊な宝石", 2, 350, "focus"),
            ("完璧の象徴", "100%の成功を約束する伝説の品", 4, 15000, "perfection"),
            
            # === 追加の基本・中級素材 ===
            ("蜘蛛の糸", "強靭で柔軟性のある蜘蛛の糸", 1, 25, "fiber"),
            ("硫黄", "錬金術に使われる黄色い鉱物", 1, 30, "chemical"),
            ("水銀", "液体金属として知られる特殊な物質", 2, 85, "liquid"),
            ("黒曜石", "鋭い刃を作れる火山ガラス", 2, 70, "stone"),
            ("象牙", "装飾品作りに使われる高級素材", 2, 180, "bone"),
        ]
        
        added_count = 0
        for name, description, rarity_id, base_price, material_type in new_materials:
            if name not in existing_names:
                try:
                    db.execute(text("""
                        INSERT INTO material_masters (name, description, rarity_id, base_price, material_type, created_at, updated_at)
                        VALUES (:name, :description, :rarity_id, :base_price, :material_type, NOW(), NOW())
                    """), {
                        "name": name,
                        "description": description,
                        "rarity_id": rarity_id,
                        "base_price": base_price,
                        "material_type": material_type
                    })
                    added_count += 1
                    print(f"追加: {name} (Rarity: {rarity_id}, Price: {base_price})")
                except Exception as e:
                    print(f"エラー ({name}): {e}")
            else:
                print(f"スキップ: {name} (既存)")
        
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