"""
訪問者スポーンクールダウン制御用のフィールドをplayersテーブルに追加するマイグレーションスクリプト
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

def add_visitor_cooldown_field():
    """訪問者スポーンクールダウン制御用のフィールドを追加"""
    try:
        # データベース接続
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("🕐 訪問者スポーンクールダウン制御フィールドを追加します...")
        
        # フィールドが既に存在するかチェック
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'players' 
            AND column_name = 'last_visitor_spawn_time';
        """)
        existing_columns = [row[0] for row in cursor.fetchall()]
        
        # 最終訪問者スポーン時間
        if 'last_visitor_spawn_time' not in existing_columns:
            cursor.execute("""
                ALTER TABLE players 
                ADD COLUMN last_visitor_spawn_time TIMESTAMP WITH TIME ZONE;
            """)
            print("✅ last_visitor_spawn_time フィールドを追加しました")
        else:
            print("ℹ️ last_visitor_spawn_time フィールドは既に存在します")
        
        # 変更をコミット
        conn.commit()
        
        # 既存プレイヤーのスポーン時間を初期化（NULLのままで初回スポーン可能）
        cursor.execute("""
            SELECT COUNT(*) as total_players,
                   COUNT(last_visitor_spawn_time) as players_with_spawn_time
            FROM players;
        """)
        result = cursor.fetchone()
        total_players = result[0]
        players_with_spawn_time = result[1]
        players_without_spawn_time = total_players - players_with_spawn_time
        
        print(f"\n📊 データベース更新結果:")
        print(f"   総プレイヤー数: {total_players}")
        print(f"   スポーン時間設定済み: {players_with_spawn_time}")
        print(f"   初回スポーン可能: {players_without_spawn_time}")
        
        # サンプルのクールダウン時間計算をテスト
        print(f"\n⚙️ クールダウン計算例:")
        for level in [1, 5, 10, 15]:
            base_cooldown_min = 30
            base_cooldown_max = 90
            level_reduction = min(15, level * 2)
            min_cooldown = max(15, base_cooldown_min - level_reduction)
            max_cooldown = max(15, base_cooldown_max - level_reduction)
            print(f"   レベル{level}: {min_cooldown}～{max_cooldown}分")
        
        cursor.close()
        conn.close()
        
        print("\n🎉 訪問者スポーンクールダウン制御の設定が完了しました！")
        print("\n📝 実装されたルール:")
        print("   • 基本クールダウン: 30-90分（ランダム）")
        print("   • レベル補正: -2分/レベル（最大-15分）")
        print("   • 最短クールダウン: 15分")
        print("   • 初回スポーン: 制限なし")
        print("   • ジェム即時スポーン: 100ジェム/回")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        if 'conn' in locals():
            conn.rollback()
            conn.close()
        raise

if __name__ == "__main__":
    add_visitor_cooldown_field()