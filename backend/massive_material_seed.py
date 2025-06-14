#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('大量素材データを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 大量素材データ挿入（30個の素材）
            materials_sql = """
            INSERT INTO material_masters (id, name, description, rarity_id, base_price, stack_size, is_active, created_at, updated_at) VALUES
            -- Common素材 (15個)
            ('copper_ore', '銅鉱石', '基本的な銅の鉱石', '1', 3, 999, true, NOW(), NOW()),
            ('tin_ore', '錫鉱石', '青銅作成に必要な錫', '1', 4, 999, true, NOW(), NOW()),
            ('coal', '石炭', '燃料として使用する石炭', '1', 2, 999, true, NOW(), NOW()),
            ('粘土', '陶器作成に使用する粘土', 1, 1, 999, true, NOW(), NOW()),
            ('砂', '精製に使用する砂', 1, 1, 999, true, NOW(), NOW()),
            ('塩', '保存と精製に使用', 1, 3, 500, true, NOW(), NOW()),
            ('苔', '薬草の材料となる苔', 1, 2, 200, true, NOW(), NOW()),
            ('きのこ', '料理や薬の材料', 1, 5, 100, true, NOW(), NOW()),
            ('獣の毛皮', '防具作成の基本素材', 1, 12, 200, true, NOW(), NOW()),
            ('鳥の羽', '矢や装飾に使用', 1, 3, 300, true, NOW(), NOW()),
            ('骨', '武器の柄や道具に使用', 1, 6, 500, true, NOW(), NOW()),
            ('樹脂', '接着剤として使用', 1, 4, 200, true, NOW(), NOW()),
            ('砂鉄', '鉄の原料となる砂鉄', 1, 8, 999, true, NOW(), NOW()),
            ('竹', '軽量で丈夫な素材', 1, 7, 500, true, NOW(), NOW()),
            ('綿花', '布地の原料', 1, 6, 300, true, NOW(), NOW()),
            
            -- Uncommon素材 (8個)
            ('青銅インゴット', '銅と錫から作られた合金', 2, 35, 200, true, NOW(), NOW()),
            ('硬質木材', '特別に硬化処理された木材', 2, 28, 300, true, NOW(), NOW()),
            ('魔法の粉末', '魔法効果を持つ不思議な粉', 2, 45, 100, true, NOW(), NOW()),
            ('エルフの糸', 'エルフが紡いだ特殊な糸', 2, 55, 50, true, NOW(), NOW()),
            ('獣王の牙', '強力な獣の牙', 2, 80, 20, true, NOW(), NOW()),
            ('古代の石', '古代文明の遺物', 2, 65, 50, true, NOW(), NOW()),
            ('深海の真珠', '深海から採取された真珠', 2, 90, 30, true, NOW(), NOW()),
            ('風霊石', '風の精霊が宿る石', 2, 70, 40, true, NOW(), NOW()),
            
            -- Rare素材 (5個)
            ('ドラゴンの血', 'ドラゴンから採取した貴重な血', 3, 200, 10, true, NOW(), NOW()),
            ('星の欠片', '天から降ってきた隕石の破片', 3, 300, 5, true, NOW(), NOW()),
            ('時の砂', '時間を操る不思議な砂', 3, 250, 20, true, NOW(), NOW()),
            ('精霊の涙', '精霊が流した涙の結晶', 3, 180, 15, true, NOW(), NOW()),
            ('月光石', '月の光を蓄えた神秘的な石', 3, 220, 12, true, NOW(), NOW()),
            
            -- Epic素材 (2個)
            ('フェニックスの羽', '不死鳥の美しい羽', 4, 800, 3, true, NOW(), NOW()),
            ('虚無の結晶', '虚無の力を封じ込めた結晶', 4, 1000, 2, true, NOW(), NOW())
            """
            
            conn.execute(text(materials_sql))
            conn.commit()
            print('大量素材マスター 30 件作成/更新')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            material_count = result.scalar()
            
            print(f'\n=== データ投入結果 ===')
            print(f'素材マスター総数: {material_count} 件')
            print('\n大量素材データ投入完了！')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()