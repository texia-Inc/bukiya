#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('スキーマを元のシードデータに合わせて修正中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 1. レアリティテーブルを元の形式に修正
            print('レアリティテーブルを修正中...')
            
            # 既存のrarity_levelsテーブルを削除して再作成
            conn.execute(text("""
            DROP TABLE IF EXISTS rarity_levels CASCADE;
            CREATE TABLE rarity_levels (
                id VARCHAR(20) PRIMARY KEY,
                name VARCHAR(50) NOT NULL,
                level INTEGER NOT NULL,
                color_code VARCHAR(7),
                star_display VARCHAR(10),
                attack_multiplier DECIMAL(3,2) DEFAULT 1.00,
                max_enchant_level INTEGER DEFAULT 10,
                ability_slots INTEGER DEFAULT 0,
                base_drop_rate DECIMAL(6,4) DEFAULT 0.6000,
                price_multiplier DECIMAL(3,2) DEFAULT 1.00,
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
            """))
            
            # 元のレアリティデータを投入
            conn.execute(text("""
            INSERT INTO rarity_levels (id, name, level, color_code, star_display, attack_multiplier, max_enchant_level, ability_slots, base_drop_rate, price_multiplier) VALUES
            ('common', 'Common', 1, '#808080', '★☆☆☆☆', 1.00, 10, 0, 0.6000, 1.00),
            ('rare', 'Rare', 2, '#0080FF', '★★☆☆☆', 1.25, 15, 1, 0.2500, 2.50),
            ('epic', 'Epic', 3, '#8040FF', '★★★☆☆', 1.50, 20, 2, 0.1000, 5.00);
            """))
            print('レアリティテーブル修正完了')
            
            # 2. 素材マスターテーブルを元の形式に修正
            print('素材マスターテーブルを修正中...')
            
            # 既存のmaterial_mastersテーブルを削除して再作成
            conn.execute(text("""
            DROP TABLE IF EXISTS material_masters CASCADE;
            CREATE TABLE material_masters (
                id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                category VARCHAR(20),
                rarity_id VARCHAR(20) NOT NULL,
                description TEXT,
                base_price INTEGER NOT NULL,
                price_volatility DECIMAL(3,2) DEFAULT 0.1,
                stack_size INTEGER DEFAULT 999,
                emoji VARCHAR(10),
                color_code VARCHAR(7),
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                FOREIGN KEY (rarity_id) REFERENCES rarity_levels(id)
            );
            """))
            print('素材マスターテーブル修正完了')
            
            # 3. 武器マスターテーブルを元の形式に修正
            print('武器マスターテーブルを修正中...')
            
            # 既存のweapon_mastersテーブルを削除して再作成
            conn.execute(text("""
            DROP TABLE IF EXISTS weapon_masters CASCADE;
            CREATE TABLE weapon_masters (
                id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                weapon_type_id VARCHAR(20) NOT NULL,
                rarity_id VARCHAR(20) NOT NULL,
                base_attack_min INTEGER NOT NULL,
                base_attack_max INTEGER NOT NULL,
                base_price_min INTEGER NOT NULL,
                base_price_max INTEGER NOT NULL,
                crafting_time_minutes INTEGER DEFAULT 30,
                required_shop_level INTEGER DEFAULT 1,
                description TEXT,
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                FOREIGN KEY (weapon_type_id) REFERENCES weapon_types(id),
                FOREIGN KEY (rarity_id) REFERENCES rarity_levels(id),
                CHECK (base_attack_min > 0),
                CHECK (base_attack_max >= base_attack_min),
                CHECK (base_price_max >= base_price_min)
            );
            """))
            print('武器マスターテーブル修正完了')
            
            # 4. レシピテーブルを作成
            print('レシピテーブルを作成中...')
            
            conn.execute(text("""
            CREATE TABLE IF NOT EXISTS crafting_recipes (
                id VARCHAR(50) PRIMARY KEY,
                result_weapon_master_id VARCHAR(50) NOT NULL,
                success_rate DECIMAL(5,4) DEFAULT 1.0000,
                crafting_time_minutes INTEGER DEFAULT 30,
                required_gold INTEGER DEFAULT 0,
                required_shop_level INTEGER DEFAULT 1,
                is_active BOOLEAN DEFAULT true,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                FOREIGN KEY (result_weapon_master_id) REFERENCES weapon_masters(id)
            );
            """))
            
            conn.execute(text("""
            CREATE TABLE IF NOT EXISTS recipe_materials (
                id SERIAL PRIMARY KEY,
                recipe_id VARCHAR(50) NOT NULL,
                material_id VARCHAR(50) NOT NULL,
                required_quantity INTEGER NOT NULL DEFAULT 1,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                FOREIGN KEY (recipe_id) REFERENCES crafting_recipes(id) ON DELETE CASCADE,
                FOREIGN KEY (material_id) REFERENCES material_masters(id),
                UNIQUE(recipe_id, material_id)
            );
            """))
            print('レシピテーブル作成完了')
            
            conn.commit()
            print('\n✅ スキーマ修正完了！元のシードデータに対応したスキーマになりました。')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()