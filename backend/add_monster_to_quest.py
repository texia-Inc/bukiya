#!/usr/bin/env python3
"""
AdventurerQuest テーブルに monster_id カラムを追加するマイグレーション
"""
from sqlalchemy import text
from app.core.database import engine

def main():
    print("AdventurerQuestテーブルにmonster_idカラムを追加中...")
    
    with engine.connect() as connection:
        try:
            # monster_idカラムを追加
            connection.execute(text("""
                ALTER TABLE adventurer_quests 
                ADD COLUMN IF NOT EXISTS monster_id INTEGER 
                REFERENCES monster_masters(id);
            """))
            
            connection.commit()
            print("✅ monster_idカラムの追加が完了しました")
            
        except Exception as e:
            print(f"❌ エラーが発生しました: {e}")
            connection.rollback()

if __name__ == "__main__":
    main()