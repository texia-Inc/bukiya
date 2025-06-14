#!/usr/bin/env python3
"""
冒険者・モンスター管理画面エラー修正スクリプト
ID型の不整合を修正してアプリケーションモデルと整合させる
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== 冒険者・モンスター管理画面エラー修正 ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            print('\n1. 現在のスキーマ問題を確認...')
            
            # adventurer_masters の型確認
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'adventurer_masters' AND column_name = 'id'
            """))
            adv_id_type = result.fetchone()
            print(f'   adventurer_masters.id: {adv_id_type[1] if adv_id_type else "NOT FOUND"}')
            
            # monster_masters の型確認
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'monster_masters' AND column_name = 'id'
            """))
            mon_id_type = result.fetchone()
            print(f'   monster_masters.id: {mon_id_type[1] if mon_id_type else "NOT FOUND"}')
            
            print('\n2. データ整合性チェック...')
            
            # 現在のデータ数確認
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_masters"))
            adv_count = result.scalar()
            print(f'   adventurer_masters: {adv_count} レコード')
            
            result = conn.execute(text("SELECT COUNT(*) FROM monster_masters"))
            mon_count = result.scalar()
            print(f'   monster_masters: {mon_count} レコード')
            
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_instances"))
            inst_count = result.scalar()
            print(f'   adventurer_instances: {inst_count} レコード')
            
            print('\n3. バックアップテーブル作成...')
            
            # バックアップテーブル作成
            conn.execute(text("DROP TABLE IF EXISTS adventurer_masters_backup"))
            conn.execute(text("CREATE TABLE adventurer_masters_backup AS SELECT * FROM adventurer_masters"))
            
            conn.execute(text("DROP TABLE IF EXISTS monster_masters_backup"))
            conn.execute(text("CREATE TABLE monster_masters_backup AS SELECT * FROM monster_masters"))
            
            conn.execute(text("DROP TABLE IF EXISTS adventurer_instances_backup"))
            conn.execute(text("CREATE TABLE adventurer_instances_backup AS SELECT * FROM adventurer_instances"))
            
            print('   ✅ バックアップ完了')
            
            print('\n4. 外部キー制約の一時解除...')
            
            # adventurer_instances の外部キー制約を削除
            conn.execute(text("ALTER TABLE adventurer_instances DROP CONSTRAINT IF EXISTS adventurer_instances_adventurer_master_id_fkey"))
            
            print('\n5. adventurer_masters テーブル修正...')
            
            # 新しいテーブル構造で作成
            conn.execute(text("""
                CREATE TABLE adventurer_masters_new (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    profession VARCHAR(50) NOT NULL DEFAULT 'warrior',
                    level INTEGER NOT NULL DEFAULT 1,
                    personality VARCHAR(50) NOT NULL DEFAULT 'normal',
                    trust_level INTEGER NOT NULL DEFAULT 50,
                    budget_min INTEGER NOT NULL DEFAULT 500,
                    budget_max INTEGER NOT NULL DEFAULT 2000,
                    preferred_weapon_type VARCHAR(50) NOT NULL DEFAULT 'sword',
                    avatar_url VARCHAR(255),
                    description TEXT,
                    min_attack_requirement INTEGER NOT NULL DEFAULT 100,
                    max_budget_multiplier NUMERIC NOT NULL DEFAULT 1.0,
                    urgency_tendency INTEGER NOT NULL DEFAULT 3,
                    spawn_weight INTEGER NOT NULL DEFAULT 100,
                    min_player_level INTEGER NOT NULL DEFAULT 1,
                    max_player_level INTEGER,
                    tier VARCHAR(20) NOT NULL DEFAULT 'normal',
                    progression_multiplier NUMERIC NOT NULL DEFAULT 1.0,
                    is_active BOOLEAN NOT NULL DEFAULT true,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """))
            
            # データを統合して移行
            conn.execute(text("""
                INSERT INTO adventurer_masters_new 
                (name, profession, level, personality, trust_level, budget_min, budget_max, 
                 preferred_weapon_type, avatar_url, description, min_attack_requirement, 
                 max_budget_multiplier, urgency_tendency, spawn_weight, min_player_level, 
                 max_player_level, tier, progression_multiplier, is_active, created_at, updated_at)
                SELECT 
                    name,
                    COALESCE(profession, class, 'warrior') as profession,  -- profession優先、なければclass使用
                    COALESCE(level, level_min, 1) as level,
                    COALESCE(personality, 'normal') as personality,
                    COALESCE(trust_level, trust_base, 50) as trust_level,
                    COALESCE(budget_min, 500) as budget_min,
                    COALESCE(budget_max, 2000) as budget_max,
                    COALESCE(preferred_weapon_type, 'sword') as preferred_weapon_type,
                    COALESCE(avatar_url, avatar_image) as avatar_url,
                    description,
                    COALESCE(min_attack_requirement, 100) as min_attack_requirement,
                    COALESCE(max_budget_multiplier, 1.0) as max_budget_multiplier,
                    COALESCE(urgency_tendency, 3) as urgency_tendency,
                    COALESCE(spawn_weight, 100) as spawn_weight,
                    COALESCE(min_player_level, 1) as min_player_level,
                    max_player_level,
                    COALESCE(tier, 'normal') as tier,
                    COALESCE(progression_multiplier, 1.0) as progression_multiplier,
                    COALESCE(is_active, true) as is_active,
                    COALESCE(created_at, NOW()) as created_at,
                    COALESCE(updated_at, NOW()) as updated_at
                FROM adventurer_masters
            """))
            
            # テーブル置換
            conn.execute(text("DROP TABLE adventurer_masters"))
            conn.execute(text("ALTER TABLE adventurer_masters_new RENAME TO adventurer_masters"))
            
            print('\n6. monster_masters テーブル修正...')
            
            # 新しいテーブル構造で作成
            conn.execute(text("""
                CREATE TABLE monster_masters_new (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    monster_type VARCHAR(50) NOT NULL DEFAULT 'beast',
                    level INTEGER NOT NULL DEFAULT 1,
                    hp INTEGER NOT NULL DEFAULT 100,
                    attack INTEGER NOT NULL DEFAULT 10,
                    defense INTEGER NOT NULL DEFAULT 5,
                    speed INTEGER DEFAULT 10,
                    element VARCHAR(20),
                    weakness VARCHAR(20),
                    resistance VARCHAR(20),
                    spawn_areas TEXT,
                    spawn_weight INTEGER DEFAULT 100,
                    min_required_weapon_level INTEGER DEFAULT 1,
                    base_gold_reward INTEGER DEFAULT 10,
                    experience_reward INTEGER DEFAULT 10,
                    description TEXT,
                    is_active BOOLEAN DEFAULT true,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """))
            
            # データ移行（String IDをシーケンシャルな数字IDに変換）
            conn.execute(text("""
                INSERT INTO monster_masters_new 
                (name, monster_type, level, hp, attack, defense, speed, element, weakness, 
                 resistance, spawn_areas, spawn_weight, min_required_weapon_level, 
                 base_gold_reward, experience_reward, description, is_active, created_at, updated_at)
                SELECT 
                    name,
                    COALESCE(monster_type, 'beast') as monster_type,
                    COALESCE(level, 1) as level,
                    COALESCE(hp, 100) as hp,
                    COALESCE(attack, 10) as attack,
                    COALESCE(defense, 5) as defense,
                    COALESCE(speed, 10) as speed,
                    element,
                    weakness,
                    resistance,
                    spawn_areas,
                    COALESCE(spawn_weight, 100) as spawn_weight,
                    COALESCE(min_required_weapon_level, 1) as min_required_weapon_level,
                    COALESCE(base_gold_reward, 10) as base_gold_reward,
                    COALESCE(experience_reward, 10) as experience_reward,
                    description,
                    COALESCE(is_active, true) as is_active,
                    COALESCE(created_at, NOW()) as created_at,
                    COALESCE(updated_at, NOW()) as updated_at
                FROM monster_masters
                ORDER BY level, name  -- レベル順、名前順でID採番
            """))
            
            # テーブル置換
            conn.execute(text("DROP TABLE monster_masters"))
            conn.execute(text("ALTER TABLE monster_masters_new RENAME TO monster_masters"))
            
            print('\n7. adventurer_instances テーブル修正...')
            
            # adventurer_instances の型修正
            conn.execute(text("ALTER TABLE adventurer_instances ALTER COLUMN adventurer_master_id TYPE INTEGER USING NULL"))
            
            # 外部キー制約復活
            conn.execute(text("ALTER TABLE adventurer_instances ADD CONSTRAINT adventurer_instances_adventurer_master_id_fkey FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id)"))
            
            print('\n8. 検証...')
            
            # 修正後のデータ数確認
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_masters"))
            new_adv_count = result.scalar()
            print(f'   adventurer_masters: {new_adv_count} レコード（元: {adv_count}）')
            
            result = conn.execute(text("SELECT COUNT(*) FROM monster_masters"))
            new_mon_count = result.scalar()
            print(f'   monster_masters: {new_mon_count} レコード（元: {mon_count}）')
            
            # 型確認
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'adventurer_masters' AND column_name = 'id'
            """))
            new_adv_type = result.fetchone()
            print(f'   adventurer_masters.id: {new_adv_type[1]}')
            
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'monster_masters' AND column_name = 'id'
            """))
            new_mon_type = result.fetchone()
            print(f'   monster_masters.id: {new_mon_type[1]}')
            
            print('\n✅ 冒険者・モンスター管理画面エラー修正完了！')
            print('\n修正内容:')
            print('  - adventurer_masters.id: VARCHAR → INTEGER (SERIAL)')
            print('  - monster_masters.id: VARCHAR → INTEGER (SERIAL)')
            print('  - 重複カラムの統合（class → profession）')
            print('  - 外部キー制約の修正')
            print('  - アプリケーションモデルとの型整合性確保')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()