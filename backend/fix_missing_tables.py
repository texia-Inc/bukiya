#!/usr/bin/env python3
"""
不足しているテーブルとカラムを修正するスクリプト
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from sqlalchemy import text

def fix_missing_tables():
    """不足しているテーブルとカラムを作成"""
    db = SessionLocal()
    try:
        print("不足しているテーブルとカラムを修正します...")
        
        # season_mastersテーブルを作成
        season_masters_sql = """
        CREATE TABLE IF NOT EXISTS season_masters (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            start_date DATE NOT NULL,
            end_date DATE,
            display_order INTEGER NOT NULL DEFAULT 1,
            is_active BOOLEAN NOT NULL DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        CREATE INDEX IF NOT EXISTS idx_season_masters_name ON season_masters(name);
        CREATE INDEX IF NOT EXISTS idx_season_masters_is_active ON season_masters(is_active);
        """
        
        # playersテーブルにshop_expカラムを追加
        add_shop_exp_sql = """
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS shop_exp INTEGER DEFAULT 0;
        """
        
        # 基本的なシーズンデータを挿入
        insert_seasons_sql = """
        INSERT INTO season_masters (name, description, start_date, display_order) VALUES 
        ('通常シーズン', '基本的な武器が登場するシーズン', '2024-01-01', 1),
        ('春シーズン', '春の特別武器が登場するシーズン', '2024-03-01', 2),
        ('夏シーズン', '夏の特別武器が登場するシーズン', '2024-06-01', 3),
        ('秋シーズン', '秋の特別武器が登場するシーズン', '2024-09-01', 4),
        ('冬シーズン', '冬の特別武器が登場するシーズン', '2024-12-01', 5)
        ON CONFLICT DO NOTHING;
        """
        
        print("season_mastersテーブルを作成中...")
        db.execute(text(season_masters_sql))
        print("✓ season_mastersテーブルを作成しました")
        
        print("playersテーブルにshop_expカラムを追加中...")
        db.execute(text(add_shop_exp_sql))
        print("✓ shop_expカラムを追加しました")
        
        print("基本シーズンデータを挿入中...")
        db.execute(text(insert_seasons_sql))
        print("✓ 基本シーズンデータを挿入しました")
        
        db.commit()
        print("\n✅ テーブル修正が完了しました！")
        
    except Exception as e:
        print(f"✗ エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_missing_tables()