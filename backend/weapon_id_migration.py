#!/usr/bin/env python3
"""
武器IDを文字列から整数連番に移行するスクリプト

実行前に必ずデータベースのバックアップを取ってください！
"""

import psycopg2
from psycopg2.extras import RealDictCursor
import json
from datetime import datetime

# データベース接続設定
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'bukiya_game',
    'user': 'bukiya_user',
    'password': 'bukiya_password'
}

def create_id_mapping():
    """既存の文字列IDを整数IDにマッピング"""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # 既存の武器を取得（作成順にソート）
        cur.execute("""
            SELECT id, name, created_at 
            FROM weapon_masters 
            ORDER BY created_at, id
        """)
        weapons = cur.fetchall()
        
        # IDマッピングを作成
        id_mapping = {}
        for i, weapon in enumerate(weapons, 1):
            id_mapping[weapon['id']] = i
            
        return id_mapping
        
    finally:
        cur.close()
        conn.close()

def save_mapping(mapping):
    """マッピングをJSONファイルに保存（ロールバック用）"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"weapon_id_mapping_{timestamp}.json"
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(mapping, f, ensure_ascii=False, indent=2)
    
    print(f"IDマッピングを保存しました: {filename}")
    return filename

def migrate_weapon_ids():
    """武器ID移行メイン処理"""
    print("=== 武器ID移行開始 ===")
    
    # IDマッピング作成
    print("1. IDマッピング作成中...")
    id_mapping = create_id_mapping()
    mapping_file = save_mapping(id_mapping)
    
    print(f"マッピング例:")
    for old_id, new_id in list(id_mapping.items())[:5]:
        print(f"  {old_id} → {new_id}")
    print(f"  ... 全{len(id_mapping)}件")
    
    # データベース移行
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        print("\\n2. データベース移行実行中...")
        
        # トランザクション開始
        cur.execute("BEGIN;")
        
        # 一時的に外部キー制約を無効化
        print("  - 外部キー制約を一時的に無効化")
        cur.execute("SET session_replication_role = replica;")
        
        # 新しいIDカラムを追加
        print("  - weapon_mastersに新しいIDカラムを追加")
        cur.execute("""
            ALTER TABLE weapon_masters 
            ADD COLUMN id_new INTEGER;
        """)
        
        # 新しいIDを設定
        print("  - 新しいIDを設定中...")
        for old_id, new_id in id_mapping.items():
            cur.execute("""
                UPDATE weapon_masters 
                SET id_new = %s 
                WHERE id = %s
            """, (new_id, old_id))
        
        # 参照テーブルに新しいIDカラムを追加
        reference_tables = [
            ('player_weapons', 'weapon_master_id'),
            ('crafting_recipes', 'weapon_id')
        ]
        
        for table, column in reference_tables:
            print(f"  - {table}に新しいIDカラムを追加")
            cur.execute(f"""
                ALTER TABLE {table} 
                ADD COLUMN {column}_new INTEGER;
            """)
            
            # 新しいIDでマッピング
            print(f"  - {table}の参照を更新中...")
            for old_id, new_id in id_mapping.items():
                cur.execute(f"""
                    UPDATE {table} 
                    SET {column}_new = %s 
                    WHERE {column} = %s
                """, (new_id, old_id))
        
        # 外部キー制約を明示的に削除
        print("  - 既存の外部キー制約を削除中...")
        cur.execute("ALTER TABLE crafting_recipes DROP CONSTRAINT IF EXISTS crafting_recipes_weapon_id_fkey;")
        cur.execute("ALTER TABLE player_weapons DROP CONSTRAINT IF EXISTS player_weapons_weapon_master_id_fkey;")
        
        # 参照テーブルのIDカラムを置換
        for table, column in reference_tables:
            print(f"  - {table}のIDカラムを置換中...")
            cur.execute(f"ALTER TABLE {table} DROP COLUMN {column};")
            cur.execute(f"ALTER TABLE {table} RENAME COLUMN {column}_new TO {column};")
        
        # 古いIDカラムを削除して新しいIDカラムをリネーム
        print("  - weapon_mastersのIDカラムを置換中...")
        cur.execute("ALTER TABLE weapon_masters DROP COLUMN id;")
        cur.execute("ALTER TABLE weapon_masters RENAME COLUMN id_new TO id;")
        cur.execute("ALTER TABLE weapon_masters ADD PRIMARY KEY (id);")
        
        # 外部キー制約を再作成
        print("  - 外部キー制約を再作成中...")
        cur.execute("""
            ALTER TABLE crafting_recipes 
            ADD CONSTRAINT crafting_recipes_weapon_id_fkey 
            FOREIGN KEY (weapon_id) REFERENCES weapon_masters(id)
        """)
        cur.execute("""
            ALTER TABLE player_weapons 
            ADD CONSTRAINT player_weapons_weapon_master_id_fkey 
            FOREIGN KEY (weapon_master_id) REFERENCES weapon_masters(id)
        """)
        
        # 外部キー制約を再有効化
        print("  - 外部キー制約を再有効化")
        cur.execute("SET session_replication_role = DEFAULT;")
        
        # コミット
        cur.execute("COMMIT;")
        print("\\n3. 移行完了！")
        
        # 確認
        print("\\n4. 移行結果確認...")
        cur.execute("SELECT id, name FROM weapon_masters ORDER BY id LIMIT 10;")
        results = cur.fetchall()
        for result in results:
            print(f"  ID: {result[0]} - {result[1]}")
            
    except Exception as e:
        print(f"\\nエラーが発生しました: {e}")
        cur.execute("ROLLBACK;")
        print("ロールバックしました。")
        raise
        
    finally:
        cur.close()
        conn.close()

def verify_migration():
    """移行結果の検証"""
    print("\\n=== 移行検証 ===")
    
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        # 武器データ確認
        cur.execute("SELECT COUNT(*) FROM weapon_masters;")
        weapon_count = cur.fetchone()[0]
        print(f"武器数: {weapon_count}")
        
        # 参照データ確認
        cur.execute("SELECT COUNT(*) FROM player_weapons WHERE weapon_master_id IS NOT NULL;")
        player_weapons_count = cur.fetchone()[0]
        print(f"プレイヤー武器参照: {player_weapons_count}件")
        
        cur.execute("SELECT COUNT(*) FROM crafting_recipes WHERE weapon_id IS NOT NULL;")
        recipes_count = cur.fetchone()[0]
        print(f"レシピ武器参照: {recipes_count}件")
        
        # データ整合性確認
        cur.execute("""
            SELECT COUNT(*) FROM player_weapons pw
            LEFT JOIN weapon_masters wm ON pw.weapon_master_id = wm.id
            WHERE wm.id IS NULL AND pw.weapon_master_id IS NOT NULL
        """)
        orphaned_player_weapons = cur.fetchone()[0]
        
        cur.execute("""
            SELECT COUNT(*) FROM crafting_recipes cr
            LEFT JOIN weapon_masters wm ON cr.weapon_id = wm.id
            WHERE wm.id IS NULL AND cr.weapon_id IS NOT NULL
        """)
        orphaned_recipes = cur.fetchone()[0]
        
        if orphaned_player_weapons == 0 and orphaned_recipes == 0:
            print("✅ データ整合性: OK")
        else:
            print(f"❌ データ整合性エラー: プレイヤー武器{orphaned_player_weapons}件、レシピ{orphaned_recipes}件")
            
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    print("武器ID移行スクリプトを開始します...")
    print("⚠️  実行前に必ずデータベースのバックアップを取ってください！")
    
    response = input("続行しますか？ (yes/no): ")
    if response.lower() == 'yes':
        migrate_weapon_ids()
        verify_migration()
        print("\\n🎉 武器ID移行が完了しました！")
    else:
        print("移行をキャンセルしました。")