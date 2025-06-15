-- adventurer_masters関連テーブルの型変更を修正

-- 外部キー制約を一時的に無効化
SET session_replication_role = replica;

-- ===== adventurer_instancesテーブルの修正 =====
-- 既存の外部キー制約を削除
ALTER TABLE adventurer_instances DROP CONSTRAINT IF EXISTS adventurer_instances_adventurer_master_id_fkey;

-- adventurer_master_idカラムの型をINTEGERに変更
-- まず、データを確認
SELECT 'Before adventurer_instances fix' as status, 
       COUNT(*) as total,
       COUNT(*) FILTER (WHERE adventurer_master_id IS NOT NULL) as with_master_id
FROM adventurer_instances;

-- 既存データがある場合、マッピングして更新
DO $$
DECLARE
    rec record;
BEGIN
    -- 各古いIDを新しいIDにマッピング
    FOR rec IN 
        SELECT 
            CASE old_id
                WHEN 'archer_anna' THEN 1
                WHEN 'warrior_rick' THEN 2
                WHEN 'rogue_jack' THEN 3
                WHEN 'paladin_marcus' THEN 4
                WHEN 'mage_elena' THEN 5
                ELSE NULL
            END as new_id,
            old_id
        FROM (
            SELECT DISTINCT adventurer_master_id as old_id 
            FROM adventurer_instances 
            WHERE adventurer_master_id IS NOT NULL
        ) t
    LOOP
        IF rec.new_id IS NOT NULL THEN
            UPDATE adventurer_instances 
            SET adventurer_master_id = rec.new_id::text
            WHERE adventurer_master_id = rec.old_id;
            
            RAISE NOTICE 'Updated % to %', rec.old_id, rec.new_id;
        END IF;
    END LOOP;
END $$;

-- カラムの型をINTEGERに変更
ALTER TABLE adventurer_instances 
ALTER COLUMN adventurer_master_id TYPE INTEGER USING 
CASE 
    WHEN adventurer_master_id ~ '^[0-9]+$' THEN adventurer_master_id::INTEGER
    ELSE NULL
END;

-- ===== adventurer_visitsテーブルの修正 =====
DO $$
DECLARE
    table_exists boolean;
    rec record;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'adventurer_visits'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- 外部キー制約を削除
        ALTER TABLE adventurer_visits DROP CONSTRAINT IF EXISTS adventurer_visits_adventurer_master_id_fkey;
        
        -- データをマッピング
        FOR rec IN 
            SELECT 
                CASE old_id
                    WHEN 'archer_anna' THEN 1
                    WHEN 'warrior_rick' THEN 2
                    WHEN 'rogue_jack' THEN 3
                    WHEN 'paladin_marcus' THEN 4
                    WHEN 'mage_elena' THEN 5
                    ELSE NULL
                END as new_id,
                old_id
            FROM (
                SELECT DISTINCT adventurer_master_id as old_id 
                FROM adventurer_visits 
                WHERE adventurer_master_id IS NOT NULL
            ) t
        LOOP
            IF rec.new_id IS NOT NULL THEN
                UPDATE adventurer_visits 
                SET adventurer_master_id = rec.new_id::text
                WHERE adventurer_master_id = rec.old_id;
            END IF;
        END LOOP;
        
        -- カラムの型をINTEGERに変更
        ALTER TABLE adventurer_visits 
        ALTER COLUMN adventurer_master_id TYPE INTEGER USING 
        CASE 
            WHEN adventurer_master_id ~ '^[0-9]+$' THEN adventurer_master_id::INTEGER
            ELSE NULL
        END;
        
        RAISE NOTICE 'adventurer_visits table updated';
    END IF;
END $$;

-- ===== player_adventurer_relationshipsテーブルの修正 =====
DO $$
DECLARE
    table_exists boolean;
    rec record;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'player_adventurer_relationships'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- 外部キー制約を削除
        ALTER TABLE player_adventurer_relationships DROP CONSTRAINT IF EXISTS player_adventurer_relationships_adventurer_master_id_fkey;
        
        -- データをマッピング
        FOR rec IN 
            SELECT 
                CASE old_id
                    WHEN 'archer_anna' THEN 1
                    WHEN 'warrior_rick' THEN 2
                    WHEN 'rogue_jack' THEN 3
                    WHEN 'paladin_marcus' THEN 4
                    WHEN 'mage_elena' THEN 5
                    ELSE NULL
                END as new_id,
                old_id
            FROM (
                SELECT DISTINCT adventurer_master_id as old_id 
                FROM player_adventurer_relationships 
                WHERE adventurer_master_id IS NOT NULL
            ) t
        LOOP
            IF rec.new_id IS NOT NULL THEN
                UPDATE player_adventurer_relationships 
                SET adventurer_master_id = rec.new_id::text
                WHERE adventurer_master_id = rec.old_id;
            END IF;
        END LOOP;
        
        -- カラムの型をINTEGERに変更
        ALTER TABLE player_adventurer_relationships 
        ALTER COLUMN adventurer_master_id TYPE INTEGER USING 
        CASE 
            WHEN adventurer_master_id ~ '^[0-9]+$' THEN adventurer_master_id::INTEGER
            ELSE NULL
        END;
        
        RAISE NOTICE 'player_adventurer_relationships table updated';
    END IF;
END $$;

-- 外部キー制約を再有効化
SET session_replication_role = DEFAULT;

-- 外部キー制約を再作成
ALTER TABLE adventurer_instances 
ADD CONSTRAINT adventurer_instances_adventurer_master_id_fkey 
FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id);

-- 他のテーブルの外部キー制約も再作成（テーブルが存在する場合）
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'adventurer_visits') THEN
        ALTER TABLE adventurer_visits 
        ADD CONSTRAINT adventurer_visits_adventurer_master_id_fkey 
        FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id);
        RAISE NOTICE 'adventurer_visits foreign key constraint added';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'player_adventurer_relationships') THEN
        ALTER TABLE player_adventurer_relationships 
        ADD CONSTRAINT player_adventurer_relationships_adventurer_master_id_fkey 
        FOREIGN KEY (adventurer_master_id) REFERENCES adventurer_masters(id) ON DELETE CASCADE;
        RAISE NOTICE 'player_adventurer_relationships foreign key constraint added';
    END IF;
END $$;

-- 結果確認
SELECT 'After fix adventurer_instances' as status, 
       COUNT(*) as total,
       COUNT(*) FILTER (WHERE adventurer_master_id IS NOT NULL) as with_master_id
FROM adventurer_instances;

-- adventurer_mastersの確認
SELECT 'adventurer_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM adventurer_masters;

-- サンプルデータ表示
SELECT id, name, profession, budget_min, budget_max FROM adventurer_masters ORDER BY id;