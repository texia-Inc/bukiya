#!/usr/bin/env python3
"""
データベースマイグレーション: shop_exp カラムを追加
"""

import os
import sys
from sqlalchemy import create_engine, text
from app.core.config import settings

def add_shop_exp_column():
    """プレイヤーテーブルにshop_expカラムを追加"""
    # ローカルホストのURLを使用
    db_url = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"
    engine = create_engine(db_url)
    
    try:
        with engine.connect() as connection:
            # トランザクション開始
            trans = connection.begin()
            
            try:
                # カラムが既に存在するかチェック
                result = connection.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name='players' AND column_name='shop_exp'
                """))
                
                if result.fetchone() is None:
                    print("Adding shop_exp column to players table...")
                    
                    # shop_expカラムを追加
                    connection.execute(text("""
                        ALTER TABLE players 
                        ADD COLUMN shop_exp INTEGER NOT NULL DEFAULT 0
                    """))
                    
                    # チェック制約を追加
                    connection.execute(text("""
                        ALTER TABLE players 
                        ADD CONSTRAINT players_shop_exp_check 
                        CHECK (shop_exp >= 0)
                    """))
                    
                    print("✅ shop_exp column added successfully")
                else:
                    print("✅ shop_exp column already exists")
                
                # コミット
                trans.commit()
                print("✅ Migration completed successfully")
                
            except Exception as e:
                print(f"❌ Error during migration: {e}")
                trans.rollback()
                raise
                
    except Exception as e:
        print(f"❌ Database connection error: {e}")
        return False
        
    return True

if __name__ == "__main__":
    print("=== Shop Experience Migration ===")
    print("Using localhost database connection")
    
    if add_shop_exp_column():
        print("Migration completed successfully!")
        sys.exit(0)
    else:
        print("Migration failed!")
        sys.exit(1)