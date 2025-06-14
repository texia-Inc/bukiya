#!/usr/bin/env python3
"""
シンプルなモンスタードロップテーブル作成
基本的なドロップデータを投入
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== シンプルモンスタードロップシード ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # 既存のドロップデータをクリア
            print('1. 既存ドロップデータをクリア...')
            conn.execute(text("DELETE FROM monster_drop_tables"))
            
            print('2. 基本的なドロップデータを投入...')
            
            # 基本的なモンスタードロップパターン
            drop_sql = """
            INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, drop_rate, quantity_min, quantity_max, is_active) VALUES
            
            -- 低レベルモンスター: Common素材とCommon武器
            ('slime_blue', 'material', 'iron_ore', 0.5, 1, 2, true),
            ('slime_blue', 'material', 'wood', 0.3, 1, 1, true),
            ('slime_blue', 'weapon', 'iron_sword_common', 0.01, 1, 1, true),
            ('slime_blue', 'gold', NULL, 0.9, 10, 30, true),
            
            ('slime_green', 'material', 'stone', 0.6, 1, 3, true),
            ('slime_green', 'material', 'hemp', 0.4, 1, 2, true),
            ('slime_green', 'weapon', 'wooden_bow_common', 0.01, 1, 1, true),
            ('slime_green', 'gold', NULL, 0.9, 15, 40, true),
            
            ('spider_forest', 'material', 'bone', 0.7, 1, 2, true),
            ('spider_forest', 'material', 'leather', 0.5, 1, 1, true),
            ('spider_forest', 'weapon', 'wooden_staff_common', 0.01, 1, 1, true),
            ('spider_forest', 'gold', NULL, 0.9, 20, 50, true),
            
            ('rabbit_wild', 'material', 'fur', 0.8, 1, 3, true),
            ('rabbit_wild', 'material', 'feather', 0.6, 1, 2, true),
            ('rabbit_wild', 'weapon', 'hunter_bow_common', 0.02, 1, 1, true),
            ('rabbit_wild', 'gold', NULL, 0.9, 25, 60, true),
            
            ('spirit_tree', 'material', 'ancient_wood', 0.4, 1, 1, true),
            ('spirit_tree', 'material', 'resin', 0.7, 1, 2, true),
            ('spirit_tree', 'weapon', 'mage_staff_common', 0.02, 1, 1, true),
            ('spirit_tree', 'gold', NULL, 0.9, 30, 70, true),
            
            -- 中レベルモンスター: Rare素材とRare武器  
            ('wolf_forest', 'material', 'silver_ore', 0.3, 1, 1, true),
            ('wolf_forest', 'material', 'beast_fang', 0.5, 1, 2, true),
            ('wolf_forest', 'weapon', 'silver_sword_rare', 0.03, 1, 1, true),
            ('wolf_forest', 'gold', NULL, 0.9, 80, 150, true),
            
            ('bear_forest', 'material', 'dragon_scale', 0.2, 1, 1, true),
            ('bear_forest', 'material', 'magic_crystal', 0.4, 1, 1, true),
            ('bear_forest', 'weapon', 'magic_bow_rare', 0.03, 1, 1, true),
            ('bear_forest', 'gold', NULL, 0.9, 100, 200, true),
            
            ('treeling', 'material', 'spirit_gem', 0.3, 1, 1, true),
            ('treeling', 'material', 'mana_essence', 0.5, 1, 1, true),
            ('treeling', 'weapon', 'arcane_staff_rare', 0.03, 1, 1, true),
            ('treeling', 'gold', NULL, 0.9, 120, 250, true),
            
            -- 高レベルモンスター: Epic素材と武器
            ('god_false', 'material', 'adamantite_ore', 0.3, 1, 1, true),
            ('god_false', 'material', 'star_fragment', 0.2, 1, 1, true),
            ('god_false', 'weapon', 'flame_sword_epic', 0.05, 1, 1, true),
            ('god_false', 'material', 'chaos_crystal', 0.1, 1, 1, true),
            ('god_false', 'weapon', 'excalibur_legendary', 0.02, 1, 1, true),
            ('god_false', 'gold', NULL, 0.9, 1000, 3000, true)
            """
            
            conn.execute(text(drop_sql))
            
            print('3. ドロップデータ検証...')
            
            # ドロップエントリ数の確認
            result = conn.execute(text("SELECT COUNT(*) FROM monster_drop_tables"))
            drop_count = result.scalar()
            print(f'   総ドロップエントリ: {drop_count}')
            
            # アイテムタイプ別分布
            result = conn.execute(text("""
                SELECT drop_type, COUNT(*) as count 
                FROM monster_drop_tables 
                GROUP BY drop_type 
                ORDER BY drop_type
            """))
            
            print('\n   アイテムタイプ別分布:')
            for row in result:
                print(f'     {row[0]}: {row[1]}エントリ')
            
            # レアドロップ確認
            result = conn.execute(text("""
                SELECT drop_type, drop_target_id, drop_rate 
                FROM monster_drop_tables 
                WHERE drop_type = 'weapon' AND drop_rate >= 0.05
                ORDER BY drop_rate DESC
            """))
            
            print('\n   高確率武器ドロップ:')
            for row in result:
                print(f'     {row[1]}: {row[2]*100}%')
            
            print('\n✅ シンプルモンスタードロップシード完了！')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()