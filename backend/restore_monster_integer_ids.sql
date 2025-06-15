-- monster_mastersテーブルを文字列IDから連番IDに変更

-- 外部キー制約を一時的に無効化
SET session_replication_role = replica;

-- ===== monster_masters の移行 =====
-- 新しいテーブル構造を作成（連番IDに変更）
CREATE TABLE monster_masters_new (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    hp INTEGER NOT NULL CHECK (hp > 0),
    attack INTEGER NOT NULL CHECK (attack > 0),
    defense INTEGER NOT NULL CHECK (defense >= 0),
    speed INTEGER DEFAULT 100,
    attribute_id VARCHAR(20),
    resistances JSONB DEFAULT '{}'::jsonb,
    weaknesses TEXT[],
    immunities TEXT[],
    level_min INTEGER NOT NULL,
    level_max INTEGER NOT NULL CHECK (level_max >= level_min),
    base_success_rate NUMERIC(5,4) DEFAULT 0.7000,
    emoji VARCHAR(10),
    description TEXT,
    area_id VARCHAR(30) NOT NULL,
    spawn_rate NUMERIC(5,4) DEFAULT 0.1000,
    is_active BOOLEAN DEFAULT true,
    is_boss BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- データを新しいテーブルにコピー（名前順でソートして一貫した順序）
INSERT INTO monster_masters_new (
    name, hp, attack, defense, speed, attribute_id,
    resistances, weaknesses, immunities,
    level_min, level_max, base_success_rate,
    emoji, description, area_id, spawn_rate,
    is_active, is_boss, created_at
)
SELECT 
    name, hp, attack, defense, speed, attribute_id,
    resistances, weaknesses, immunities,
    level_min, level_max, base_success_rate,
    emoji, description, area_id, spawn_rate,
    is_active, is_boss, created_at
FROM monster_masters
ORDER BY name;

-- ===== monster_drop_tables の更新 =====
-- monster_drop_tablesテーブルのmonster_master_idを新しい連番IDに更新

-- 一時的なマッピングテーブルを作成
CREATE TEMP TABLE monster_id_mapping AS
SELECT 
    old.id as old_id,
    new.id as new_id,
    new.name
FROM monster_masters old
JOIN monster_masters_new new ON old.name = new.name;

-- monster_drop_tablesがINTEGER型のmonster_master_idを期待しているかチェック
-- まずテーブル構造を確認
DO $$
DECLARE
    table_exists boolean;
    column_type text;
BEGIN
    -- monster_drop_tablesテーブルが存在するかチェック
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'monster_drop_tables'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- monster_master_idカラムの型を取得
        SELECT data_type INTO column_type
        FROM information_schema.columns 
        WHERE table_name = 'monster_drop_tables' 
        AND column_name = 'monster_master_id';
        
        RAISE NOTICE 'monster_drop_tables exists, monster_master_id type: %', column_type;
        
        -- もし文字列型なら、一旦データを保存して新しいテーブルを作成
        IF column_type LIKE '%character%' OR column_type LIKE '%text%' THEN
            -- バックアップテーブルを作成
            DROP TABLE IF EXISTS monster_drop_tables_backup;
            CREATE TABLE monster_drop_tables_backup AS 
            SELECT * FROM monster_drop_tables;
            
            -- 古いテーブルを削除
            DROP TABLE monster_drop_tables;
            
            -- 新しいテーブルを作成（INTEGER型のmonster_master_id）
            CREATE TABLE monster_drop_tables (
                id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                monster_master_id INTEGER NOT NULL,
                drop_type VARCHAR(50) NOT NULL,
                drop_target_id VARCHAR(50) NOT NULL,
                drop_rate NUMERIC(10,4) NOT NULL DEFAULT 0.1,
                quantity_min INTEGER NOT NULL DEFAULT 1,
                quantity_max INTEGER NOT NULL DEFAULT 1,
                required_weapon_type VARCHAR(50),
                bonus_rate NUMERIC(10,4) NOT NULL DEFAULT 0.0,
                is_active BOOLEAN NOT NULL DEFAULT true,
                created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                
                FOREIGN KEY (monster_master_id) REFERENCES monster_masters_new(id) ON DELETE CASCADE
            );
            
            -- データを新しいIDで復元
            INSERT INTO monster_drop_tables (
                monster_master_id, drop_type, drop_target_id, drop_rate,
                quantity_min, quantity_max, required_weapon_type, bonus_rate,
                is_active, created_at
            )
            SELECT 
                mapping.new_id,
                backup.drop_type,
                backup.drop_target_id,
                backup.drop_rate,
                backup.quantity_min,
                backup.quantity_max,
                backup.required_weapon_type,
                backup.bonus_rate,
                backup.is_active,
                backup.created_at
            FROM monster_drop_tables_backup backup
            JOIN monster_id_mapping mapping ON backup.monster_master_id = mapping.old_id;
            
            RAISE NOTICE 'monster_drop_tables updated with new integer IDs';
        ELSE
            RAISE NOTICE 'monster_drop_tables already has integer monster_master_id';
        END IF;
    ELSE
        RAISE NOTICE 'monster_drop_tables does not exist';
    END IF;
END $$;

-- 古いmonster_mastersテーブルを削除し、新しいテーブルをリネーム
DROP TABLE monster_masters CASCADE;
ALTER TABLE monster_masters_new RENAME TO monster_masters;

-- インデックスを再作成
CREATE INDEX idx_monster_masters_active ON monster_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_monster_masters_area ON monster_masters(area_id);
CREATE INDEX idx_monster_masters_level ON monster_masters(level_min, level_max);

-- 外部キー制約を再有効化
SET session_replication_role = DEFAULT;

-- 結果確認
SELECT 'monster_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM monster_masters;

-- monster_drop_tablesの状況も確認
SELECT 'monster_drop_tables' as table_name, COUNT(*) as count FROM monster_drop_tables WHERE EXISTS (
    SELECT 1 FROM information_schema.tables WHERE table_name = 'monster_drop_tables'
);

-- 新しいIDでのデータサンプル
SELECT id, name, hp, attack, level_min, level_max FROM monster_masters ORDER BY id LIMIT 10;