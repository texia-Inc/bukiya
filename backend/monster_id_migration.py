#!/usr/bin/env python3
"""
モンスターIDを文字列から整数連番に移行するスクリプト

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

def check_monster_references():
    """モンスターIDを参照するテーブルを確認"""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    reference_tables = []
    
    try:
        # 発見された参照テーブル
        confirmed_refs = [
            ('monster_drop_tables', 'monster_master_id'),
            ('adventurer_quests', 'monster_id'),
        ]
        
        for table, column in confirmed_refs:
            try:
                cur.execute(f"SELECT COUNT(*) FROM {table} WHERE {column} IS NOT NULL;")
                count = cur.fetchone()[0]
                if count > 0:
                    reference_tables.append((table, column, count))
                    print(f"  {table}.{column}: {count}件")
            except Exception as e:
                print(f"  {table}.{column}: エラー ({e})")
        
        return reference_tables
        
    finally:
        cur.close()
        conn.close()

def create_monster_id_mapping():
    """既存の文字列IDを整数IDにマッピング"""
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # 既存のモンスターを取得（作成順にソート）
        cur.execute("""
            SELECT id, name, created_at 
            FROM monster_masters 
            ORDER BY created_at, id
        """)
        monsters = cur.fetchall()
        
        # IDマッピングを作成
        id_mapping = {}
        for i, monster in enumerate(monsters, 1):
            id_mapping[monster['id']] = i
            
        return id_mapping
        
    finally:
        cur.close()
        conn.close()

def save_monster_mapping(mapping):
    """マッピングをJSONファイルに保存（ロールバック用）"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"monster_id_mapping_{timestamp}.json"
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(mapping, f, ensure_ascii=False, indent=2)
    
    print(f"IDマッピングを保存しました: {filename}")
    return filename

def migrate_monster_ids():
    """モンスターID移行メイン処理"""
    print("=== モンスターID移行開始 ===")
    
    # 現在のモンスターデータ確認
    print("1. 現在のモンスターデータ確認中...")
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    cur.execute('SELECT COUNT(*) FROM monster_masters;')
    monster_count = cur.fetchone()[0]
    print(f"モンスター数: {monster_count}")
    
    cur.execute('SELECT id, name FROM monster_masters ORDER BY id LIMIT 10;')
    monsters = cur.fetchall()
    print("モンスターID例:")
    for monster in monsters:
        print(f"  {monster[0]} - {monster[1]}")
    
    cur.close()
    conn.close()
    
    # 参照テーブル確認
    print("\\n2. 参照テーブル確認中...")
    reference_tables = check_monster_references()
    
    if not reference_tables:
        print("  参照テーブルが見つかりませんでした。")
    
    # IDマッピング作成
    print("\\n3. IDマッピング作成中...")
    id_mapping = create_monster_id_mapping()
    mapping_file = save_monster_mapping(id_mapping)
    
    print(f"マッピング例:")
    for old_id, new_id in list(id_mapping.items())[:5]:
        print(f"  {old_id} → {new_id}")
    print(f"  ... 全{len(id_mapping)}件")
    
    # データベース移行
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        print("\\n4. データベース移行実行中...")
        
        # トランザクション開始
        cur.execute("BEGIN;")
        
        # 一時的に外部キー制約を無効化
        print("  - 外部キー制約を一時的に無効化")
        cur.execute("SET session_replication_role = replica;")
        
        # 新しいIDカラムを追加
        print("  - monster_mastersに新しいIDカラムを追加")
        cur.execute("""
            ALTER TABLE monster_masters 
            ADD COLUMN id_new INTEGER;
        """)
        
        # 新しいIDを設定
        print("  - 新しいIDを設定中...")
        for old_id, new_id in id_mapping.items():
            cur.execute("""
                UPDATE monster_masters 
                SET id_new = %s 
                WHERE id = %s
            """, (new_id, old_id))
        
        # 参照テーブルに新しいIDカラムを追加
        for table, column, count in reference_tables:
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
        
        # 既存の外部キー制約を削除
        print("  - 既存の外部キー制約を削除中...")
        cur.execute("ALTER TABLE monster_drop_tables DROP CONSTRAINT IF EXISTS monster_drop_tables_monster_master_id_fkey;")
        cur.execute("ALTER TABLE adventurer_quests DROP CONSTRAINT IF EXISTS adventurer_quests_monster_id_fkey;")
        
        # 参照テーブルのIDカラムを置換
        for table, column, count in reference_tables:
            print(f"  - {table}のIDカラムを置換中...")
            cur.execute(f"ALTER TABLE {table} DROP COLUMN {column};")
            cur.execute(f"ALTER TABLE {table} RENAME COLUMN {column}_new TO {column};")
        
        # 古いIDカラムを削除して新しいIDカラムをリネーム
        print("  - monster_mastersのIDカラムを置換中...")
        cur.execute("ALTER TABLE monster_masters DROP COLUMN id;")
        cur.execute("ALTER TABLE monster_masters RENAME COLUMN id_new TO id;")
        cur.execute("ALTER TABLE monster_masters ADD PRIMARY KEY (id);")
        
        # 外部キー制約を再作成
        print("  - 外部キー制約を再作成中...")
        cur.execute("""
            ALTER TABLE monster_drop_tables 
            ADD CONSTRAINT monster_drop_tables_monster_master_id_fkey 
            FOREIGN KEY (monster_master_id) REFERENCES monster_masters(id)
        """)
        cur.execute("""
            ALTER TABLE adventurer_quests 
            ADD CONSTRAINT adventurer_quests_monster_id_fkey 
            FOREIGN KEY (monster_id) REFERENCES monster_masters(id)
        """)
        
        # 外部キー制約を再有効化
        print("  - 外部キー制約を再有効化")
        cur.execute("SET session_replication_role = DEFAULT;")
        
        # コミット
        cur.execute("COMMIT;")
        print("\\n5. 移行完了！")
        
        # 確認
        print("\\n6. 移行結果確認...")
        cur.execute("SELECT id, name FROM monster_masters ORDER BY id LIMIT 10;")
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

def verify_monster_migration():
    """移行結果の検証"""
    print("\\n=== 移行検証 ===")
    
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    try:
        # モンスターデータ確認
        cur.execute("SELECT COUNT(*) FROM monster_masters;")
        monster_count = cur.fetchone()[0]
        print(f"モンスター数: {monster_count}")
        
        # 参照データ確認
        reference_tables = check_monster_references()
        
        # データ整合性確認
        orphaned_count = 0
        for table, column, count in reference_tables:
            try:
                cur.execute(f"""
                    SELECT COUNT(*) FROM {table} ref
                    LEFT JOIN monster_masters mm ON ref.{column} = mm.id
                    WHERE mm.id IS NULL AND ref.{column} IS NOT NULL
                """)
                orphaned = cur.fetchone()[0]
                orphaned_count += orphaned
                if orphaned > 0:
                    print(f"❌ {table}: {orphaned}件の孤立参照")
            except Exception as e:
                print(f"⚠️  {table}の整合性チェックに失敗: {e}")
        
        if orphaned_count == 0:
            print("✅ データ整合性: OK")
        else:
            print(f"❌ データ整合性エラー: 計{orphaned_count}件の孤立参照")
            
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    print("モンスターID移行スクリプトを開始します...")
    print("⚠️  実行前に必ずデータベースのバックアップを取ってください！")
    
    response = input("続行しますか？ (yes/no): ")
    if response.lower() == 'yes':
        migrate_monster_ids()
        verify_monster_migration()
        print("\\n🎉 モンスターID移行が完了しました！")
    else:
        print("移行をキャンセルしました。")