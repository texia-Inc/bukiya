#!/usr/bin/env python3
"""
データベースマイグレーション: device_sessions テーブルを作成
"""

import os
import sys
from sqlalchemy import create_engine, text

def create_device_sessions_table():
    """device_sessionsテーブルを作成"""
    # ローカルホストのURLを使用
    db_url = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"
    engine = create_engine(db_url)
    
    try:
        with engine.connect() as connection:
            # トランザクション開始
            trans = connection.begin()
            
            try:
                # テーブルが既に存在するかチェック
                result = connection.execute(text("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_name = 'device_sessions'
                    );
                """))
                
                if not result.scalar():
                    print("Creating device_sessions table...")
                    
                    # device_sessionsテーブルを作成
                    connection.execute(text("""
                        CREATE TABLE device_sessions (
                            id SERIAL PRIMARY KEY,
                            device_id VARCHAR(255) NOT NULL,
                            player_id INTEGER,
                            device_name VARCHAR(255),
                            device_model VARCHAR(255),
                            platform VARCHAR(50),
                            platform_version VARCHAR(50),
                            app_version VARCHAR(50),
                            is_active BOOLEAN NOT NULL DEFAULT TRUE,
                            is_trusted BOOLEAN NOT NULL DEFAULT FALSE,
                            last_used_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            expires_at TIMESTAMP WITH TIME ZONE,
                            ip_address VARCHAR(45),
                            user_agent TEXT,
                            refresh_token_hash VARCHAR(255),
                            created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
                        );
                        
                        CREATE INDEX idx_device_sessions_device_id ON device_sessions(device_id);
                        CREATE INDEX idx_device_sessions_player_id ON device_sessions(player_id);
                        CREATE INDEX idx_device_sessions_is_active ON device_sessions(is_active);
                    """))
                    
                    print("✅ device_sessions table created successfully")
                else:
                    print("✅ device_sessions table already exists")
                
                # コミット
                trans.commit()
                print("✅ Migration completed successfully")
                
            except Exception as e:
                print(f"❌ Error during migration: {e}")
                trans.rollback()
                raise
                
    except Exception as e:
        print(f"❌ Database connection error: {e}")
        return False
        
    return True

if __name__ == "__main__":
    print("=== Device Sessions Migration ===")
    print("Using localhost database connection")
    
    if create_device_sessions_table():
        print("Migration completed successfully!")
        sys.exit(0)
    else:
        print("Migration failed!")
        sys.exit(1) 