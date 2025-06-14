#!/usr/bin/env python3
"""
adventurer_questsテーブルのtarget_material_idカラムを文字列から整数に変更し、
外部キー制約を追加するスクリプト
"""

import psycopg2
from sqlalchemy import create_engine, text
import os

def main():
    # データベース接続設定
    DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game')
    
    engine = create_engine(DATABASE_URL)
    
    try:
        with engine.connect() as conn:
            # トランザクション開始
            trans = conn.begin()
            
            try:
                print("1. 現在のtarget_material_idの状況を確認...")
                result = conn.execute(text("""
                    SELECT target_material_id, COUNT(*) 
                    FROM adventurer_quests 
                    WHERE target_material_id IS NOT NULL 
                    GROUP BY target_material_id
                """))
                rows = result.fetchall()
                if rows:
                    print(f"既存データ: {rows}")
                else:
                    print("データなし - 安全に変更可能")
                
                print("2. target_material_idカラムの型をINTEGERに変更...")
                conn.execute(text("""
                    ALTER TABLE adventurer_quests 
                    ALTER COLUMN target_material_id TYPE INTEGER 
                    USING CASE 
                        WHEN target_material_id IS NULL THEN NULL
                        WHEN target_material_id ~ '^[0-9]+$' THEN target_material_id::INTEGER
                        ELSE NULL
                    END
                """))
                
                print("3. material_mastersへの外部キー制約を追加...")
                conn.execute(text("""
                    ALTER TABLE adventurer_quests 
                    ADD CONSTRAINT adventurer_quests_target_material_id_fkey 
                    FOREIGN KEY (target_material_id) REFERENCES material_masters(id)
                """))
                
                print("4. 同様にquest_rewardsテーブルのitem_idも確認...")
                # quest_rewardsテーブルの構造確認
                result = conn.execute(text("""
                    SELECT column_name, data_type 
                    FROM information_schema.columns 
                    WHERE table_name = 'quest_rewards' 
                    AND column_name = 'item_id'
                """))
                column_info = result.fetchone()
                print(f"quest_rewards.item_id: {column_info}")
                
                # コミット
                trans.commit()
                print("✅ adventurer_questsテーブルの修正完了!")
                
            except Exception as e:
                trans.rollback()
                print(f"❌ エラーが発生したためロールバック: {e}")
                raise
                
    except Exception as e:
        print(f"❌ データベース接続エラー: {e}")
        return False
    
    return True

if __name__ == "__main__":
    main()