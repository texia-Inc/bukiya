#!/usr/bin/env python3
"""
playersテーブルに不足しているカラムを追加するスクリプト
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from sqlalchemy import text

def fix_players_table():
    """playersテーブルに不足しているカラムを追加"""
    db = SessionLocal()
    try:
        print("playersテーブルに不足しているカラムを追加します...")
        
        # 不足しているカラムを追加
        add_columns_sql = """
        -- 放置収入システム関連
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS idle_income_rate INTEGER DEFAULT 10;
        
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS idle_income_multiplier INTEGER DEFAULT 100;
        
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS last_idle_collection_time TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- 訪問者スポーン制御
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS last_visitor_spawn_time TIMESTAMP WITH TIME ZONE;
        
        -- 既存のカラムのデフォルト値を設定（もし存在しない場合）
        ALTER TABLE players 
        ADD COLUMN IF NOT EXISTS reputation INTEGER DEFAULT 1;
        """
        
        print("不足しているカラムを追加中...")
        db.execute(text(add_columns_sql))
        print("✓ playersテーブルのカラムを追加しました")
        
        db.commit()
        print("\n✅ playersテーブルの修正が完了しました！")
        
    except Exception as e:
        print(f"✗ エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_players_table()