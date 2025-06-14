#!/usr/bin/env python3
"""
quest_rewardsテーブルのitem_idを修正し、一貫性を保つスクリプト
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
                print("=== Step 1: 現在のquest_rewardsの状況確認 ===")
                result = conn.execute(text("""
                    SELECT item_type, item_id, COUNT(*) as count
                    FROM quest_rewards 
                    GROUP BY item_type, item_id 
                    ORDER BY item_type, item_id
                """))
                
                print("現在のデータ:")
                for row in result.fetchall():
                    print(f"  {row[0]}: {row[1]} ({row[2]} records)")
                
                print("\n=== Step 2: 古い材料IDを新しい整数IDにマッピング ===")
                # 手動で古いID→新しいIDのマッピングを作成
                material_mapping = {
                    'ancient_wood': '3',    # 古代の木材
                    'bone': '6',           # 骨
                    'dragon_scale': '17',  # 竜の鱗
                    'fur': '27',           # 毛皮
                    'hemp': '30',          # 麻
                    'iron_ore': '33',      # 鉄鉱石
                    'leather': '34',       # 革
                    'resin': '42',         # 樹脂
                    'stone': '50',         # 石材
                    'wood': '57',          # 木材
                }
                
                print("材料IDマッピング:")
                for old_id, new_id in material_mapping.items():
                    print(f"  {old_id} -> {new_id}")
                
                print("\n=== Step 3: quest_rewardsの古い材料IDを更新 ===")
                for old_id, new_id in material_mapping.items():
                    result = conn.execute(text("""
                        UPDATE quest_rewards 
                        SET item_id = :new_id
                        WHERE item_type = 'material' AND item_id = :old_id
                    """), {"new_id": new_id, "old_id": old_id})
                    
                    if result.rowcount > 0:
                        print(f"  更新: {old_id} -> {new_id} ({result.rowcount} records)")
                
                print("\n=== Step 4: item_idカラムをNULLABLEに変更 ===")
                conn.execute(text("""
                    ALTER TABLE quest_rewards 
                    ALTER COLUMN item_id DROP NOT NULL
                """))
                print("item_idカラムをNULLABLEに変更完了")
                
                print("\n=== Step 5: ゴールド報酬のitem_idをNULLに設定 ===")
                result = conn.execute(text("""
                    UPDATE quest_rewards 
                    SET item_id = NULL
                    WHERE item_type = 'gold' AND item_id IS NOT NULL
                """))
                print(f"ゴールド報酬のitem_id修正: {result.rowcount} records")
                
                print("\n=== Step 6: 更新後の状況確認 ===")
                result = conn.execute(text("""
                    SELECT item_type, item_id, COUNT(*) as count
                    FROM quest_rewards 
                    GROUP BY item_type, item_id 
                    ORDER BY item_type, item_id
                """))
                
                print("更新後のデータ:")
                for row in result.fetchall():
                    item_id_display = row[1] if row[1] is not None else "NULL"
                    print(f"  {row[0]}: {item_id_display} ({row[2]} records)")
                
                print("\n=== Step 7: 整合性チェック ===")
                # 材料報酬で無効なitem_idをチェック
                result = conn.execute(text("""
                    SELECT qr.item_id, COUNT(*) as count
                    FROM quest_rewards qr
                    LEFT JOIN material_masters mm ON qr.item_id = mm.id::text
                    WHERE qr.item_type = 'material' 
                    AND qr.item_id IS NOT NULL
                    AND mm.id IS NULL
                    GROUP BY qr.item_id
                """))
                
                invalid_materials = result.fetchall()
                if invalid_materials:
                    print("⚠️  無効な材料ID:")
                    for row in invalid_materials:
                        print(f"  {row[0]} ({row[1]} records)")
                else:
                    print("✅ 全ての材料IDが有効です")
                
                # コミット
                trans.commit()
                print("\n✅ quest_rewardsテーブルの修正完了!")
                
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