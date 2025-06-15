#!/usr/bin/env python3
"""
マスターデータを完全にリセットするスクリプト
武器・素材・レシピ・モンスターのデータをクリアします
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import SessionLocal
from sqlalchemy import text

def clear_master_data():
    """マスターデータをクリア"""
    db = SessionLocal()
    try:
        print("データベースのマスターデータをクリアしています...")
        
        # カスケード削除でマスターデータをクリア
        clear_queries = [
            # マスターデータをカスケード削除（外部キー制約を考慮）
            "DELETE FROM weapon_masters CASCADE",
            "DELETE FROM material_masters CASCADE",
            "DELETE FROM monster_masters CASCADE", 
            "DELETE FROM crafting_recipes CASCADE",
            
            # 残りのデータをクリア
            "DELETE FROM adventurer_purchases",
            "DELETE FROM adventurer_instances", 
            "DELETE FROM adventurer_characters",
            "DELETE FROM player_weapons",
            "DELETE FROM player_materials",
            "DELETE FROM active_crafting",
            "DELETE FROM player_missions",
            "DELETE FROM mission_monster_drops",
            
            # シーケンスをリセット
            "ALTER SEQUENCE weapon_masters_id_seq RESTART WITH 1",
            "ALTER SEQUENCE material_masters_id_seq RESTART WITH 1", 
            "ALTER SEQUENCE monster_masters_id_seq RESTART WITH 1",
            "ALTER SEQUENCE crafting_recipes_id_seq RESTART WITH 1"
        ]
        
        for query in clear_queries:
            try:
                db.execute(text(query))
                print(f"✓ {query.split()[1] if 'DELETE' in query else query}")
            except Exception as e:
                print(f"✗ Error executing {query}: {e}")
        
        db.commit()
        print("マスターデータのクリアが完了しました。")
    
    finally:
        db.close()

if __name__ == "__main__":
    clear_master_data()