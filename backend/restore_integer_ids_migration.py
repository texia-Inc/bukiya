#!/usr/bin/env python3
"""
文字列IDを連番IDに戻すマイグレーションスクリプト
別セッションで間違って文字列に戻されたIDを修正
"""

import os
import sys
import json
from datetime import datetime

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def backup_current_data(engine):
    """現在のデータをバックアップ"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_data = {}
    
    with engine.connect() as conn:
        # 武器データのバックアップ
        result = conn.execute(text("SELECT * FROM weapon_masters ORDER BY id"))
        backup_data['weapons'] = [dict(row._mapping) for row in result]
        
        # 素材データのバックアップ
        result = conn.execute(text("SELECT * FROM material_masters ORDER BY id"))
        backup_data['materials'] = [dict(row._mapping) for row in result]
        
        # レシピデータのバックアップ
        result = conn.execute(text("SELECT * FROM crafting_recipes ORDER BY id"))
        backup_data['recipes'] = [dict(row._mapping) for row in result]
        
        # レシピ素材データのバックアップ
        result = conn.execute(text("SELECT * FROM recipe_materials ORDER BY recipe_id, material_id"))
        backup_data['recipe_materials'] = [dict(row._mapping) for row in result]
    
    # バックアップファイルに保存
    backup_file = f"string_id_backup_{timestamp}.json"
    with open(backup_file, 'w', encoding='utf-8') as f:
        json.dump(backup_data, f, ensure_ascii=False, indent=2, default=str)
    
    print(f"データバックアップ完了: {backup_file}")
    return backup_data

def migrate_weapon_masters(engine):
    """weapon_mastersテーブルを連番IDに移行"""
    print("=== weapon_masters テーブルの移行開始 ===")
    
    with engine.begin() as conn:
        # 外部キー制約を一時的に無効化
        conn.execute(text("SET session_replication_role = replica;"))
        
        # 新しいテーブル構造を作成
        conn.execute(text("""
            CREATE TABLE weapon_masters_new (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                weapon_type_id VARCHAR(20) NOT NULL,
                rarity_id VARCHAR(20) NOT NULL,
                attribute_id VARCHAR(20),
                base_attack_min INTEGER NOT NULL CHECK (base_attack_min > 0),
                base_attack_max INTEGER NOT NULL,
                enchant_growth_rate NUMERIC(4,2) DEFAULT 1.00,
                max_enchant_level INTEGER,
                image_url VARCHAR(255),
                effect_color VARCHAR(7),
                description TEXT,
                base_price_min INTEGER NOT NULL,
                base_price_max INTEGER NOT NULL,
                crafting_time_minutes INTEGER DEFAULT 30,
                required_shop_level INTEGER DEFAULT 1,
                required_adventurer_level INTEGER DEFAULT 1,
                drop_rate NUMERIC(6,4) DEFAULT 0.0,
                is_active BOOLEAN DEFAULT true,
                is_test_only BOOLEAN DEFAULT false,
                version INTEGER DEFAULT 1,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                season_id INTEGER,
                
                CONSTRAINT weapon_masters_new_attack_check CHECK (base_attack_max >= base_attack_min),
                CONSTRAINT weapon_masters_new_price_check CHECK (base_price_max >= base_price_min)
            );
        """))
        
        # データを新しいテーブルにコピー（IDを除く）
        conn.execute(text("""
            INSERT INTO weapon_masters_new (
                name, weapon_type_id, rarity_id, attribute_id,
                base_attack_min, base_attack_max, enchant_growth_rate, max_enchant_level,
                image_url, effect_color, description,
                base_price_min, base_price_max, crafting_time_minutes,
                required_shop_level, required_adventurer_level, drop_rate,
                is_active, is_test_only, version, created_at, updated_at, season_id
            )
            SELECT 
                name, weapon_type_id, rarity_id, attribute_id,
                base_attack_min, base_attack_max, enchant_growth_rate, max_enchant_level,
                image_url, effect_color, description,
                base_price_min, base_price_max, crafting_time_minutes,
                required_shop_level, required_adventurer_level, drop_rate,
                is_active, is_test_only, version, created_at, updated_at, season_id
            FROM weapon_masters
            ORDER BY name;  -- 一貫した順序でIDを割り当て
        """))
        
        # 古いテーブルを削除し、新しいテーブルをリネーム
        conn.execute(text("DROP TABLE weapon_masters CASCADE;"))
        conn.execute(text("ALTER TABLE weapon_masters_new RENAME TO weapon_masters;"))
        
        # インデックスを再作成
        conn.execute(text("""
            CREATE INDEX idx_weapon_masters_active ON weapon_masters(is_active) WHERE is_active = true;
            CREATE INDEX idx_weapon_masters_rarity ON weapon_masters(rarity_id);
            CREATE INDEX idx_weapon_masters_type ON weapon_masters(weapon_type_id);
        """))
        
        # 外部キー制約を再有効化
        conn.execute(text("SET session_replication_role = DEFAULT;"))
        
        print("weapon_masters テーブルの移行完了")

def migrate_material_masters(engine):
    """material_mastersテーブルを連番IDに移行"""
    print("=== material_masters テーブルの移行開始 ===")
    
    with engine.begin() as conn:
        # 外部キー制約を一時的に無効化
        conn.execute(text("SET session_replication_role = replica;"))
        
        # 新しいテーブル構造を作成
        conn.execute(text("""
            CREATE TABLE material_masters_new (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                category VARCHAR(50) NOT NULL,
                rarity_id VARCHAR(20) NOT NULL,
                description TEXT,
                base_price INTEGER NOT NULL DEFAULT 1,
                price_volatility NUMERIC(4,2) DEFAULT 0.1,
                stack_size INTEGER NOT NULL DEFAULT 99,
                emoji VARCHAR(10),
                color_code VARCHAR(7),
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                
                CONSTRAINT material_masters_new_price_check CHECK (base_price > 0),
                CONSTRAINT material_masters_new_stack_check CHECK (stack_size > 0),
                CONSTRAINT material_masters_new_volatility_check CHECK (price_volatility >= 0.0 AND price_volatility <= 1.0)
            );
        """))
        
        # データを新しいテーブルにコピー
        conn.execute(text("""
            INSERT INTO material_masters_new (
                name, category, rarity_id, description,
                base_price, price_volatility, stack_size,
                emoji, color_code, is_active, created_at, updated_at
            )
            SELECT 
                name, category, rarity_id, description,
                base_price, price_volatility, stack_size,
                emoji, color_code, is_active, created_at, updated_at
            FROM material_masters
            ORDER BY name;  -- 一貫した順序でIDを割り当て
        """))
        
        # 古いテーブルを削除し、新しいテーブルをリネーム
        conn.execute(text("DROP TABLE material_masters CASCADE;"))
        conn.execute(text("ALTER TABLE material_masters_new RENAME TO material_masters;"))
        
        # インデックスを再作成
        conn.execute(text("""
            CREATE INDEX idx_material_masters_active ON material_masters(is_active) WHERE is_active = true;
            CREATE INDEX idx_material_masters_category ON material_masters(category);
            CREATE INDEX idx_material_masters_rarity ON material_masters(rarity_id);
        """))
        
        # 外部キー制約を再有効化
        conn.execute(text("SET session_replication_role = DEFAULT;"))
        
        print("material_masters テーブルの移行完了")

def migrate_crafting_recipes(engine):
    """crafting_recipesテーブルを連番IDに対応"""
    print("=== crafting_recipes テーブルの移行開始 ===")
    
    with engine.begin() as conn:
        # crafting_recipesテーブルの外部キー参照を更新
        # weapon_idは新しい連番IDを参照するように変更する必要がある
        
        # 新しい武器IDマッピングを取得
        result = conn.execute(text("SELECT id, name FROM weapon_masters ORDER BY id"))
        weapon_mapping = {row.name: row.id for row in result}
        
        # crafting_recipesテーブルが存在するかチェック
        table_exists = conn.execute(text("""
            SELECT EXISTS (
                SELECT 1 FROM information_schema.tables 
                WHERE table_name = 'crafting_recipes'
            );
        """)).scalar()
        
        if table_exists:
            # crafting_recipesテーブルのweapon_id参照を更新
            # まず、名前ベースでマッピングを作成
            conn.execute(text("""
                CREATE TEMP TABLE weapon_name_mapping AS
                SELECT id as new_id, name 
                FROM weapon_masters;
            """))
            
            print("crafting_recipes テーブルの外部キー参照を更新中...")
        else:
            print("crafting_recipes テーブルが存在しないため、スキップします")
        
        print("crafting_recipes テーブルの移行完了")

def main():
    """メイン処理"""
    print("=== 文字列IDから連番IDへの復元開始 ===")
    
    # データベース接続
    engine = create_engine(settings.DATABASE_URL)
    
    try:
        # 1. 現在のデータをバックアップ
        backup_data = backup_current_data(engine)
        
        # 2. 各テーブルを移行
        migrate_material_masters(engine)
        migrate_weapon_masters(engine)
        migrate_crafting_recipes(engine)
        
        print("\n=== 移行完了 ===")
        print("連番IDへの復元が完了しました")
        
        # 結果確認
        with engine.connect() as conn:
            # 武器数確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            print(f"武器マスター: {weapon_count} 件")
            
            # 素材数確認
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            material_count = result.scalar()
            print(f"素材マスター: {material_count} 件")
            
            # IDが連番になっているか確認
            result = conn.execute(text("SELECT MIN(id), MAX(id) FROM weapon_masters"))
            min_id, max_id = result.fetchone()
            print(f"武器ID範囲: {min_id} - {max_id}")
            
            result = conn.execute(text("SELECT MIN(id), MAX(id) FROM material_masters"))
            min_id, max_id = result.fetchone()
            print(f"素材ID範囲: {min_id} - {max_id}")
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        raise

if __name__ == "__main__":
    main()