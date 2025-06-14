"""
放置収入システム用のフィールドをplayersテーブルに追加するマイグレーションスクリプト
"""
import psycopg2
from datetime import datetime

# データベース接続設定
DB_CONFIG = {
    'host': 'postgres',
    'port': 5432,
    'database': 'bukiya_game',
    'user': 'bukiya_user',
    'password': 'bukiya_password'
}

def add_idle_income_fields():
    """放置収入システム用のフィールドを追加"""
    try:
        # データベース接続
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("📊 放置収入システム用フィールドを追加します...")
        
        # フィールドが既に存在するかチェック
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'players' 
            AND column_name IN ('idle_income_rate', 'idle_income_multiplier', 'last_idle_collection_time');
        """)
        existing_columns = [row[0] for row in cursor.fetchall()]
        
        # 放置収入レート（ゴールド/分）
        if 'idle_income_rate' not in existing_columns:
            cursor.execute("""
                ALTER TABLE players 
                ADD COLUMN idle_income_rate INTEGER DEFAULT 10 NOT NULL;
            """)
            print("✅ idle_income_rate フィールドを追加しました")
        else:
            print("ℹ️ idle_income_rate フィールドは既に存在します")
        
        # 放置収入倍率（100 = 1.00倍）
        if 'idle_income_multiplier' not in existing_columns:
            cursor.execute("""
                ALTER TABLE players 
                ADD COLUMN idle_income_multiplier INTEGER DEFAULT 100 NOT NULL;
            """)
            print("✅ idle_income_multiplier フィールドを追加しました")
        else:
            print("ℹ️ idle_income_multiplier フィールドは既に存在します")
        
        # 最終回収時間
        if 'last_idle_collection_time' not in existing_columns:
            cursor.execute("""
                ALTER TABLE players 
                ADD COLUMN last_idle_collection_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
            """)
            print("✅ last_idle_collection_time フィールドを追加しました")
        else:
            print("ℹ️ last_idle_collection_time フィールドは既に存在します")
        
        # 制約を追加
        try:
            cursor.execute("""
                ALTER TABLE players 
                ADD CONSTRAINT players_idle_income_rate_check 
                CHECK (idle_income_rate >= 0);
            """)
            print("✅ idle_income_rate チェック制約を追加しました")
        except psycopg2.errors.DuplicateObject:
            print("ℹ️ idle_income_rate チェック制約は既に存在します")
        
        try:
            cursor.execute("""
                ALTER TABLE players 
                ADD CONSTRAINT players_idle_income_multiplier_check 
                CHECK (idle_income_multiplier >= 1);
            """)
            print("✅ idle_income_multiplier チェック制約を追加しました")
        except psycopg2.errors.DuplicateObject:
            print("ℹ️ idle_income_multiplier チェック制約は既に存在します")
        
        # 変更をコミット
        conn.commit()
        
        # 既存プレイヤーのlast_idle_collection_timeを更新（まだNULLの場合）
        cursor.execute("""
            UPDATE players 
            SET last_idle_collection_time = created_at 
            WHERE last_idle_collection_time IS NULL;
        """)
        updated_rows = cursor.rowcount
        if updated_rows > 0:
            print(f"✅ {updated_rows}人のプレイヤーのlast_idle_collection_timeを初期化しました")
        
        conn.commit()
        
        # 結果確認
        cursor.execute("""
            SELECT COUNT(*) as player_count,
                   AVG(idle_income_rate) as avg_income_rate,
                   AVG(idle_income_multiplier) as avg_multiplier
            FROM players;
        """)
        result = cursor.fetchone()
        
        print(f"\n📈 データベース更新結果:")
        print(f"   プレイヤー数: {result[0]}")
        print(f"   平均収入レート: {result[1]:.1f} ゴールド/分")
        print(f"   平均倍率: {result[2]:.0f} ({result[2]/100:.2f}倍)")
        
        cursor.close()
        conn.close()
        
        print("\n🎉 放置収入システムのデータベース設定が完了しました！")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        raise

if __name__ == "__main__":
    add_idle_income_fields()