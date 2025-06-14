#!/usr/bin/env python3
"""
シーズンマスターテーブルの作成とWeaponMasterテーブルのseason_id追加

使用方法:
python create_season_tables.py
"""

import os
import sys
from datetime import date

# プロジェクトルートをPythonパスに追加
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings
from app.models.season_master import SeasonMaster
from app.models.weapon_master import WeaponMaster
from app.core.database import Base

def create_season_tables():
    """シーズンテーブルを作成し、武器テーブルにseason_idを追加"""
    
    # データベース接続
    engine = create_engine(settings.DATABASE_URL)
    
    print("シーズン管理テーブルの作成を開始します...")
    
    try:
        with engine.connect() as conn:
            # トランザクション開始
            trans = conn.begin()
            
            try:
                # 1. season_mastersテーブルの作成
                print("1. season_mastersテーブルを作成しています...")
                
                create_seasons_table_sql = """
                CREATE TABLE IF NOT EXISTS season_masters (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    description TEXT,
                    start_date DATE NOT NULL,
                    end_date DATE,
                    display_order INTEGER NOT NULL DEFAULT 1,
                    is_active BOOLEAN NOT NULL DEFAULT TRUE,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                );
                """
                
                conn.execute(text(create_seasons_table_sql))
                
                # インデックスの作成
                print("2. season_mastersテーブルのインデックスを作成しています...")
                conn.execute(text("CREATE INDEX IF NOT EXISTS idx_season_masters_name ON season_masters(name);"))
                conn.execute(text("CREATE INDEX IF NOT EXISTS idx_season_masters_is_active ON season_masters(is_active);"))
                conn.execute(text("CREATE INDEX IF NOT EXISTS idx_season_masters_display_order ON season_masters(display_order);"))
                
                # 3. weapon_mastersテーブルにseason_idカラムを追加
                print("3. weapon_mastersテーブルにseason_idカラムを追加しています...")
                
                # カラムが既に存在するかチェック
                check_column_sql = """
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name='weapon_masters' AND column_name='season_id';
                """
                
                result = conn.execute(text(check_column_sql)).fetchone()
                
                if not result:
                    # season_idカラムを追加
                    add_season_id_sql = """
                    ALTER TABLE weapon_masters 
                    ADD COLUMN season_id INTEGER REFERENCES season_masters(id);
                    """
                    conn.execute(text(add_season_id_sql))
                    
                    # インデックスの作成
                    conn.execute(text("CREATE INDEX IF NOT EXISTS idx_weapon_masters_season_id ON weapon_masters(season_id);"))
                    print("   season_idカラムとインデックスを追加しました。")
                else:
                    print("   season_idカラムは既に存在します。")
                
                # 4. デフォルトシーズンの作成
                print("4. デフォルトシーズンを作成しています...")
                
                # 既にシーズンが存在するかチェック
                check_seasons_sql = "SELECT COUNT(*) FROM season_masters;"
                count_result = conn.execute(text(check_seasons_sql)).scalar()
                
                if count_result == 0:
                    # デフォルトシーズンを挿入
                    insert_default_season_sql = """
                    INSERT INTO season_masters (name, description, start_date, display_order, is_active)
                    VALUES 
                        ('シーズン1', '最初のシーズン。基本的な武器が含まれます。', '2024-01-01', 1, TRUE),
                        ('シーズン2', '第二のシーズン。より強力な武器が追加されます。', '2024-06-01', 2, TRUE),
                        ('限定イベント', 'イベント限定武器のシーズン', '2024-12-01', 3, FALSE);
                    """
                    conn.execute(text(insert_default_season_sql))
                    print("   デフォルトシーズンを作成しました。")
                else:
                    print("   シーズンデータは既に存在します。")
                
                # 5. updated_atトリガーの作成（PostgreSQL）
                print("5. updated_atトリガーを作成しています...")
                
                trigger_function_sql = """
                CREATE OR REPLACE FUNCTION update_season_masters_updated_at()
                RETURNS TRIGGER AS $$
                BEGIN
                    NEW.updated_at = NOW();
                    RETURN NEW;
                END;
                $$ LANGUAGE plpgsql;
                """
                
                trigger_sql = """
                DROP TRIGGER IF EXISTS season_masters_update_trigger ON season_masters;
                CREATE TRIGGER season_masters_update_trigger
                    BEFORE UPDATE ON season_masters
                    FOR EACH ROW
                    EXECUTE FUNCTION update_season_masters_updated_at();
                """
                
                conn.execute(text(trigger_function_sql))
                conn.execute(text(trigger_sql))
                print("   updated_atトリガーを作成しました。")
                
                # トランザクションをコミット
                trans.commit()
                print("\n✅ シーズン管理システムの作成が完了しました！")
                
                # 結果の確認
                print("\n📊 作成結果:")
                seasons_count = conn.execute(text("SELECT COUNT(*) FROM season_masters;")).scalar()
                print(f"   - シーズン数: {seasons_count}")
                
                # 作成されたシーズンの表示
                seasons_result = conn.execute(text("SELECT id, name, start_date, is_active FROM season_masters ORDER BY display_order;")).fetchall()
                print("   - 作成されたシーズン:")
                for season in seasons_result:
                    status = "有効" if season[3] else "無効"
                    print(f"     ID:{season[0]} {season[1]} (開始: {season[2]}, 状態: {status})")
                
            except Exception as e:
                trans.rollback()
                raise e
                
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        sys.exit(1)

if __name__ == "__main__":
    create_season_tables()