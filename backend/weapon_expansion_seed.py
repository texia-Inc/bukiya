#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('追加武器データを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 追加武器データ挿入（10個の武器）
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, description, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, required_shop_level, is_active, created_at, updated_at) VALUES
            ('bronze_sword_new', 'ブロンズソード', '初心者向けの青銅製の剣', 'sword', 1, 8, 12, 40, 60, 1, true, NOW(), NOW()),
            ('iron_sword_new', 'アイアンソード', '鉄製の丈夫な剣', 'sword', 1, 15, 20, 80, 120, 2, true, NOW(), NOW()),
            ('steel_blade', 'スチールブレード', '鋼鉄製の切れ味鋭い剣', 'sword', 2, 22, 28, 180, 220, 3, true, NOW(), NOW()),
            ('silver_sword_new', 'シルバーソード', '銀の力を宿した美しい剣', 'sword', 3, 30, 40, 450, 550, 5, true, NOW(), NOW()),
            ('flame_blade', 'フレイムブレード', '炎の力を宿った魔法の剣', 'sword', 4, 45, 55, 1000, 1400, 8, true, NOW(), NOW()),
            ('wooden_bow_new', 'ウッドボウ', '木製の基本的な弓', 'bow', 1, 6, 10, 30, 50, 1, true, NOW(), NOW()),
            ('long_bow', 'ロングボウ', '射程の長い戦闘用の弓', 'bow', 2, 18, 25, 140, 180, 4, true, NOW(), NOW()),
            ('magic_staff', 'マジックスタッフ', '魔法を増幅する杖', 'staff', 2, 12, 18, 100, 140, 3, true, NOW(), NOW()),
            ('fire_staff', 'ファイアスタッフ', '炎の力を増幅する赤い杖', 'staff', 3, 25, 35, 350, 450, 6, true, NOW(), NOW()),
            ('ice_dagger', 'アイスダガー', '氷の力を宿した冷徹な短剣', 'dagger', 3, 20, 26, 250, 310, 5, true, NOW(), NOW())
            ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            base_attack_min = EXCLUDED.base_attack_min,
            base_attack_max = EXCLUDED.base_attack_max,
            base_price_min = EXCLUDED.base_price_min,
            base_price_max = EXCLUDED.base_price_max,
            updated_at = NOW()
            """
            
            conn.execute(text(weapons_sql))
            conn.commit()
            print('追加武器マスター 10 件作成/更新')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            print(f'\n=== データ投入結果 ===')
            print(f'武器マスター総数: {weapon_count} 件')
            print('\n追加武器データ投入完了！')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()