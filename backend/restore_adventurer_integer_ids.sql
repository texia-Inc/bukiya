-- adventurer_mastersテーブルを文字列IDから連番IDに変更

-- 外部キー制約を一時的に無効化
SET session_replication_role = replica;

-- ===== adventurer_masters の移行 =====
-- 新しいテーブル構造を作成（連番IDに変更）
CREATE TABLE adventurer_masters_new (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    profession VARCHAR(50) NOT NULL,
    preferred_weapon_type VARCHAR(50),
    budget_min INTEGER DEFAULT 100,
    budget_max INTEGER DEFAULT 10000,
    personality VARCHAR(50),
    avatar_url VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    level INTEGER DEFAULT 1,
    trust_level INTEGER DEFAULT 50,
    min_attack_requirement INTEGER DEFAULT 100,
    max_budget_multiplier DOUBLE PRECISION DEFAULT 1.0,
    urgency_tendency INTEGER DEFAULT 3,
    spawn_weight INTEGER DEFAULT 100,
    min_player_level INTEGER DEFAULT 1,
    max_player_level INTEGER,
    tier VARCHAR(20) DEFAULT 'normal',
    progression_multiplier DOUBLE PRECISION DEFAULT 1.0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- データを新しいテーブルにコピー（名前順でソートして一貫した順序）
INSERT INTO adventurer_masters_new (
    name, profession, preferred_weapon_type, budget_min, budget_max,
    personality, avatar_url, description, is_active, created_at,
    level, trust_level, min_attack_requirement, max_budget_multiplier,
    urgency_tendency, spawn_weight, min_player_level, max_player_level,
    tier, progression_multiplier, updated_at
)
SELECT 
    name, profession, preferred_weapon_type, budget_min, budget_max,
    personality, avatar_url, description, is_active, created_at,
    level, trust_level, min_attack_requirement, max_budget_multiplier,
    urgency_tendency, spawn_weight, min_player_level, max_player_level,
    tier, progression_multiplier, updated_at
FROM adventurer_masters
ORDER BY name;

-- ===== 関連テーブルの更新処理 =====

-- 一時的なマッピングテーブルを作成
CREATE TEMP TABLE adventurer_id_mapping AS
SELECT 
    old.id as old_id,
    new.id as new_id,
    new.name
FROM adventurer_masters old
JOIN adventurer_masters_new new ON old.name = new.name;

-- adventurer_instancesテーブルの更新
DO $$
DECLARE
    table_exists boolean;
    column_type text;
BEGIN
    -- adventurer_instancesテーブルが存在するかチェック
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'adventurer_instances'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- adventurer_master_idカラムの型を取得
        SELECT data_type INTO column_type
        FROM information_schema.columns 
        WHERE table_name = 'adventurer_instances' 
        AND column_name = 'adventurer_master_id';
        
        RAISE NOTICE 'adventurer_instances exists, adventurer_master_id type: %', column_type;
        
        -- カラムの型を確認して適切に処理
        IF column_type LIKE '%character%' OR column_type LIKE '%text%' THEN
            -- 文字列型の場合、INTEGER型に変更
            
            -- 一時的にNULL許可に変更
            ALTER TABLE adventurer_instances ALTER COLUMN adventurer_master_id DROP NOT NULL;
            
            -- 既存データを新しいIDで更新
            UPDATE adventurer_instances 
            SET adventurer_master_id = mapping.new_id::text
            FROM adventurer_id_mapping mapping 
            WHERE adventurer_instances.adventurer_master_id = mapping.old_id;
            
            -- カラムの型をINTEGERに変更
            ALTER TABLE adventurer_instances 
            ALTER COLUMN adventurer_master_id TYPE INTEGER USING adventurer_master_id::INTEGER;
            
            RAISE NOTICE 'adventurer_instances.adventurer_master_id updated to INTEGER type';
        ELSE
            -- 既にINTEGER型の場合は値のみ更新
            UPDATE adventurer_instances 
            SET adventurer_master_id = mapping.new_id
            FROM adventurer_id_mapping mapping 
            WHERE adventurer_instances.adventurer_master_id::text = mapping.old_id;
            
            RAISE NOTICE 'adventurer_instances.adventurer_master_id values updated';
        END IF;
    ELSE
        RAISE NOTICE 'adventurer_instances table does not exist';
    END IF;
END $$;

-- adventurer_visitsテーブルの更新
DO $$
DECLARE
    table_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'adventurer_visits'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- 型をチェックして適切に更新
        UPDATE adventurer_visits 
        SET adventurer_master_id = mapping.new_id::text
        FROM adventurer_id_mapping mapping 
        WHERE adventurer_visits.adventurer_master_id = mapping.old_id;
        
        -- カラムの型をINTEGERに変更
        ALTER TABLE adventurer_visits 
        ALTER COLUMN adventurer_master_id TYPE INTEGER USING adventurer_master_id::INTEGER;
        
        RAISE NOTICE 'adventurer_visits updated';
    ELSE
        RAISE NOTICE 'adventurer_visits table does not exist';
    END IF;
END $$;

-- player_adventurer_relationshipsテーブルの更新
DO $$
DECLARE
    table_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'player_adventurer_relationships'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- 型をチェックして適切に更新
        UPDATE player_adventurer_relationships 
        SET adventurer_master_id = mapping.new_id::text
        FROM adventurer_id_mapping mapping 
        WHERE player_adventurer_relationships.adventurer_master_id = mapping.old_id;
        
        -- カラムの型をINTEGERに変更
        ALTER TABLE player_adventurer_relationships 
        ALTER COLUMN adventurer_master_id TYPE INTEGER USING adventurer_master_id::INTEGER;
        
        RAISE NOTICE 'player_adventurer_relationships updated';
    ELSE
        RAISE NOTICE 'player_adventurer_relationships table does not exist';
    END IF;
END $$;

-- 古いadventurer_mastersテーブルを削除し、新しいテーブルをリネーム
DROP TABLE adventurer_masters CASCADE;
ALTER TABLE adventurer_masters_new RENAME TO adventurer_masters;

-- インデックスを再作成
CREATE INDEX idx_adventurer_masters_active ON adventurer_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_adventurer_masters_profession ON adventurer_masters(profession);
CREATE INDEX idx_adventurer_masters_level ON adventurer_masters(min_player_level, max_player_level);

-- 外部キー制約を再作成
ALTER TABLE adventurer_instances 
ADD CONSTRAINT adventurer_instances_adventurer_master_id_fkey 
FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id);

-- 他の外部キー制約も再作成（テーブルが存在する場合）
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'adventurer_visits') THEN
        ALTER TABLE adventurer_visits 
        ADD CONSTRAINT adventurer_visits_adventurer_master_id_fkey 
        FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'player_adventurer_relationships') THEN
        ALTER TABLE player_adventurer_relationships 
        ADD CONSTRAINT player_adventurer_relationships_adventurer_master_id_fkey 
        FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 外部キー制約を再有効化
SET session_replication_role = DEFAULT;

-- 結果確認
SELECT 'adventurer_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM adventurer_masters;

-- 関連テーブルの状況確認
SELECT 'adventurer_instances' as table_name, 
       COUNT(*) as total,
       COUNT(*) FILTER (WHERE adventurer_master_id IS NOT NULL) as with_master_id
FROM adventurer_instances 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'adventurer_instances');

-- 新しいIDでのデータサンプル
SELECT id, name, profession, budget_min, budget_max FROM adventurer_masters ORDER BY id;