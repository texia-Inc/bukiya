#!/usr/bin/env python3
"""
素材ターゲティングシステム用のテーブル作成・更新スクリプト
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def create_material_targeting_system():
    """素材ターゲティングシステムのテーブルを作成"""
    
    engine = create_engine(settings.DATABASE_URL)
    
    # AdventurerQuestテーブルに素材ターゲティング機能を追加
    alter_sql = """
    -- AdventurerQuestテーブルに素材ターゲティング関連のカラムを追加
    ALTER TABLE adventurer_quests 
    ADD COLUMN IF NOT EXISTS target_material_id INTEGER REFERENCES material_masters(id),
    ADD COLUMN IF NOT EXISTS target_material_boost DOUBLE PRECISION DEFAULT 1.0,
    ADD COLUMN IF NOT EXISTS target_cost INTEGER DEFAULT 0;

    -- 素材ターゲティング統計テーブル
    CREATE TABLE IF NOT EXISTS material_targeting_stats (
        id SERIAL PRIMARY KEY,
        player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        material_id INTEGER NOT NULL REFERENCES material_masters(id),
        total_targeted INTEGER DEFAULT 0,
        total_obtained INTEGER DEFAULT 0,
        success_rate DOUBLE PRECISION DEFAULT 0.0,
        total_cost_spent INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        UNIQUE(player_id, material_id)
    );

    -- 素材ターゲティング設定テーブル（プレイヤーの設定保存）
    CREATE TABLE IF NOT EXISTS material_targeting_presets (
        id SERIAL PRIMARY KEY,
        player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
        preset_name VARCHAR(50) NOT NULL,
        quest_area_id INTEGER NOT NULL REFERENCES quest_area_masters(id),
        target_material_id INTEGER NOT NULL REFERENCES material_masters(id),
        boost_level INTEGER DEFAULT 1 CHECK (boost_level BETWEEN 1 AND 3),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    -- インデックス作成
    CREATE INDEX IF NOT EXISTS idx_adventurer_quests_target_material 
    ON adventurer_quests(target_material_id);
    
    CREATE INDEX IF NOT EXISTS idx_material_targeting_stats_player_material
    ON material_targeting_stats(player_id, material_id);
    
    CREATE INDEX IF NOT EXISTS idx_material_targeting_presets_player
    ON material_targeting_presets(player_id);
    """
    
    try:
        with engine.connect() as conn:
            # 各SQL文を個別に実行
            statements = alter_sql.strip().split(';')
            for statement in statements:
                if statement.strip():
                    print(f"実行中: {statement.strip()[:100]}...")
                    conn.execute(text(statement))
                    conn.commit()
        
        print("✅ 素材ターゲティングシステムのテーブル作成/更新が完了しました")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        return False
    
    return True

def seed_material_targeting_data():
    """素材ターゲティング関連の初期データを挿入"""
    
    engine = create_engine(settings.DATABASE_URL)
    
    # 素材ターゲティングのコスト設定データ
    seed_sql = """
    -- 素材ターゲティングのコスト設定（マスターデータとして追加）
    INSERT INTO material_masters (id, name, description, rarity_id, base_price, max_stack, image_url, is_active)
    VALUES 
    (1001, '素材探索指示書', '冒険者に特定素材の探索を指示する', 1, 50, 10, 'targeting_scroll.png', true),
    (1002, '高級探索指示書', '冒険者により効果的な素材探索を指示', 2, 150, 5, 'targeting_scroll_rare.png', true),
    (1003, '特級探索指示書', '冒険者に最高効率の素材探索を指示', 3, 500, 3, 'targeting_scroll_epic.png', true)
    ON CONFLICT (id) DO NOTHING;
    
    -- 各クエストエリアの主要素材情報をコメントとして記録
    UPDATE quest_area_masters SET description = description || 
    CASE 
        WHEN name LIKE '%森%' THEN ' (主要素材: 木材系)'
        WHEN name LIKE '%鉱山%' THEN ' (主要素材: 鉱石系)'
        WHEN name LIKE '%洞窟%' THEN ' (主要素材: 宝石系)'
        WHEN name LIKE '%湖%' THEN ' (主要素材: 水系)'
        ELSE ''
    END
    WHERE description IS NOT NULL;
    """
    
    try:
        with engine.connect() as conn:
            statements = seed_sql.strip().split(';')
            for statement in statements:
                if statement.strip():
                    conn.execute(text(statement))
            conn.commit()
        
        print("✅ 素材ターゲティングの初期データ挿入が完了しました")
        
    except Exception as e:
        print(f"❌ 初期データ挿入でエラーが発生しました: {e}")
        return False
    
    return True

if __name__ == "__main__":
    print("🎯 素材ターゲティングシステムの構築を開始します...")
    
    # テーブル作成
    if create_material_targeting_system():
        print("📊 テーブル作成完了")
        
        # 初期データ挿入
        if seed_material_targeting_data():
            print("🎉 素材ターゲティングシステムの構築が完了しました！")
            print()
            print("新機能:")
            print("1. 冒険者派遣時に狙い素材を指定可能")
            print("2. 指定素材のドロップ率が1.5-3.0倍に向上")
            print("3. コスト: 50-500ゴールド（ブーストレベルにより変動）")
            print("4. 統計情報で成功率を確認可能")
        else:
            print("❌ 初期データ挿入に失敗しました")
    else:
        print("❌ テーブル作成に失敗しました")