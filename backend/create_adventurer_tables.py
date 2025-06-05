"""
冒険者システムのテーブル作成スクリプト
"""
import psycopg2
from psycopg2 import sql
import os
from dotenv import load_dotenv

load_dotenv()

# データベース接続情報
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/bukiya_db")

def create_adventurer_tables():
    """冒険者システムのテーブルを作成"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()
    
    try:
        # 冒険者インスタンステーブル
        cur.execute("""
            CREATE TABLE IF NOT EXISTS adventurer_instances (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_master_id VARCHAR(50) NOT NULL REFERENCES adventurer_masters(id),
                player_id UUID REFERENCES players(id) ON DELETE SET NULL,
                name VARCHAR(100) NOT NULL,
                level INTEGER NOT NULL DEFAULT 1,
                trust_level INTEGER NOT NULL DEFAULT 0,
                status VARCHAR(20) NOT NULL DEFAULT 'idle',
                current_quest_id UUID,
                visit_start_time TIMESTAMP WITH TIME ZONE,
                visit_end_time TIMESTAMP WITH TIME ZONE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # 冒険者の武器リクエストテーブル
        cur.execute("""
            CREATE TABLE IF NOT EXISTS adventurer_requests (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                weapon_type VARCHAR(50) NOT NULL,
                min_attack INTEGER NOT NULL,
                max_budget INTEGER NOT NULL,
                preferred_rarity VARCHAR(20),
                urgency INTEGER NOT NULL DEFAULT 3,
                description TEXT,
                deadline TIMESTAMP WITH TIME ZONE NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pending',
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # 冒険者のクエスト履歴テーブル
        cur.execute("""
            CREATE TABLE IF NOT EXISTS adventurer_quests (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                quest_area_id VARCHAR(50) NOT NULL REFERENCES quest_area_masters(id),
                player_weapon_id UUID REFERENCES player_weapons(id),
                status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
                start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                end_time TIMESTAMP WITH TIME ZONE,
                success BOOLEAN,
                gold_earned INTEGER DEFAULT 0,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # クエスト報酬テーブル
        cur.execute("""
            CREATE TABLE IF NOT EXISTS quest_rewards (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_quest_id UUID NOT NULL REFERENCES adventurer_quests(id) ON DELETE CASCADE,
                item_type VARCHAR(20) NOT NULL,
                item_id VARCHAR(50) NOT NULL,
                quantity INTEGER NOT NULL DEFAULT 1,
                buyback_price INTEGER,
                buyback_deadline TIMESTAMP WITH TIME ZONE,
                is_bought BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # 冒険者と武器の購入履歴テーブル
        cur.execute("""
            CREATE TABLE IF NOT EXISTS adventurer_purchases (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                adventurer_instance_id UUID NOT NULL REFERENCES adventurer_instances(id) ON DELETE CASCADE,
                player_weapon_id UUID NOT NULL REFERENCES player_weapons(id),
                price INTEGER NOT NULL,
                purchased_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # インデックスの作成
        cur.execute("""
            CREATE INDEX IF NOT EXISTS idx_adventurer_instances_player_id ON adventurer_instances(player_id);
            CREATE INDEX IF NOT EXISTS idx_adventurer_instances_status ON adventurer_instances(status);
            CREATE INDEX IF NOT EXISTS idx_adventurer_requests_adventurer_id ON adventurer_requests(adventurer_instance_id);
            CREATE INDEX IF NOT EXISTS idx_adventurer_quests_adventurer_id ON adventurer_quests(adventurer_instance_id);
            CREATE INDEX IF NOT EXISTS idx_adventurer_quests_status ON adventurer_quests(status);
            CREATE INDEX IF NOT EXISTS idx_quest_rewards_quest_id ON quest_rewards(adventurer_quest_id);
            CREATE INDEX IF NOT EXISTS idx_quest_rewards_buyback ON quest_rewards(is_bought, buyback_deadline);
        """)
        
        # 更新時刻を自動更新するトリガー
        cur.execute("""
            CREATE OR REPLACE FUNCTION update_updated_at_column()
            RETURNS TRIGGER AS $$
            BEGIN
                NEW.updated_at = CURRENT_TIMESTAMP;
                RETURN NEW;
            END;
            $$ language 'plpgsql';
        """)
        
        # 各テーブルにトリガーを設定
        tables = ['adventurer_instances', 'adventurer_requests', 'adventurer_quests']
        for table in tables:
            trigger_name = f"update_{table}_updated_at"
            cur.execute(f"""
                DROP TRIGGER IF EXISTS {trigger_name} ON {table};
                CREATE TRIGGER {trigger_name}
                BEFORE UPDATE ON {table}
                FOR EACH ROW
                EXECUTE FUNCTION update_updated_at_column();
            """)
        
        conn.commit()
        print("冒険者システムのテーブルを作成しました。")
        
    except Exception as e:
        conn.rollback()
        print(f"エラーが発生しました: {e}")
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    create_adventurer_tables()