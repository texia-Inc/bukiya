-- 文字列IDから連番IDに戻すSQLスクリプト
-- 別セッションで間違って文字列に戻されたIDを修正

-- 外部キー制約を一時的に無効化
SET session_replication_role = replica;

-- ===== material_masters の移行 =====
-- 新しいテーブル構造を作成
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

-- データを新しいテーブルにコピー（名前順でソートして一貫した順序）
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
ORDER BY name;

-- 古いテーブルを削除し、新しいテーブルをリネーム
DROP TABLE material_masters CASCADE;
ALTER TABLE material_masters_new RENAME TO material_masters;

-- インデックスを再作成
CREATE INDEX idx_material_masters_active ON material_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_material_masters_category ON material_masters(category);
CREATE INDEX idx_material_masters_rarity ON material_masters(rarity_id);

-- ===== weapon_masters の移行 =====
-- 新しいテーブル構造を作成
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

-- データを新しいテーブルにコピー（名前順でソートして一貫した順序）
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
ORDER BY name;

-- 古いテーブルを削除し、新しいテーブルをリネーム
DROP TABLE weapon_masters CASCADE;
ALTER TABLE weapon_masters_new RENAME TO weapon_masters;

-- インデックスを再作成
CREATE INDEX idx_weapon_masters_active ON weapon_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_weapon_masters_rarity ON weapon_masters(rarity_id);
CREATE INDEX idx_weapon_masters_type ON weapon_masters(weapon_type_id);

-- ===== recipe_materials の移行 =====
-- recipe_materialsテーブルが存在する場合は削除（外部キー参照が壊れるため）
DROP TABLE IF EXISTS recipe_materials CASCADE;

-- ===== crafting_recipes の移行 =====
-- crafting_recipesテーブルが存在する場合は削除（外部キー参照が壊れるため）
DROP TABLE IF EXISTS crafting_recipes CASCADE;

-- 外部キー制約を再有効化
SET session_replication_role = DEFAULT;

-- 結果確認
SELECT 'material_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM material_masters
UNION ALL
SELECT 'weapon_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM weapon_masters;