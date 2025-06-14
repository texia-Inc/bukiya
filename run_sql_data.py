#!/usr/bin/env python3
"""
SQLファイルの内容を直接実行してデータを投入
"""
import asyncio
import asyncpg
import os

async def run_sql_file(file_path):
    DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        conn = await asyncpg.connect(DATABASE_URL)
        
        try:
            print(f"🔄 実行中: {file_path}")
            
            # SQLの内容を実行
            await conn.execute(sql_content)
            
            print(f"✅ 完了: {file_path}")
            
        except Exception as e:
            print(f"❌ エラー: {file_path} - {e}")
        finally:
            await conn.close()
            
    except FileNotFoundError:
        print(f"❌ ファイルが見つかりません: {file_path}")
    except Exception as e:
        print(f"❌ ファイル読み込みエラー: {file_path} - {e}")

async def main():
    sql_files = [
        "monster_data_100_fixed.sql",
        "materials_insert_fixed.sql", 
        "common_uncommon_recipes_corrected.sql",
        "rare_crafting_recipes.sql"
    ]
    
    for sql_file in sql_files:
        await run_sql_file(sql_file)
        await asyncio.sleep(1)  # 少し待機

if __name__ == "__main__":
    asyncio.run(main())