-- area_mastersテーブルを文字列IDから連番IDに変更

-- 外部キー制約を一時的に無効化
SET session_replication_role = replica;

-- ===== area_masters の移行 =====
-- 新しいテーブル構造を作成（連番IDに変更）
CREATE TABLE area_masters_new (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    required_shop_level INTEGER DEFAULT 1,
    required_adventurer_level INTEGER DEFAULT 1,
    base_expedition_time_minutes INTEGER DEFAULT 60,
    danger_level INTEGER DEFAULT 1 CHECK (danger_level >= 1 AND danger_level <= 10),
    background_image VARCHAR(255),
    theme_color VARCHAR(7),
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- データを新しいテーブルにコピー（display_order順でソートして一貫した順序）
INSERT INTO area_masters_new (
    name, description, required_shop_level, required_adventurer_level,
    base_expedition_time_minutes, danger_level, background_image,
    theme_color, is_active, display_order, created_at
)
SELECT 
    name, description, required_shop_level, required_adventurer_level,
    base_expedition_time_minutes, danger_level, background_image,
    theme_color, is_active, display_order, created_at
FROM area_masters
ORDER BY display_order, name;

-- ===== 関連テーブルの更新処理 =====

-- 一時的なマッピングテーブルを作成
CREATE TEMP TABLE area_id_mapping AS
SELECT 
    old.id as old_id,
    new.id as new_id,
    new.name
FROM area_masters old
JOIN area_masters_new new ON old.name = new.name;

-- マッピング結果を確認
SELECT 'Area ID Mapping' as info, old_id, new_id, name FROM area_id_mapping ORDER BY new_id;

-- monster_mastersテーブルのarea_id更新
DO $$
DECLARE
    table_exists boolean;
    column_type text;
BEGIN
    -- monster_mastersテーブルが存在するかチェック
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'monster_masters'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- area_idカラムの型を取得
        SELECT data_type INTO column_type
        FROM information_schema.columns 
        WHERE table_name = 'monster_masters' 
        AND column_name = 'area_id';
        
        RAISE NOTICE 'monster_masters exists, area_id type: %', column_type;
        
        -- 外部キー制約を削除
        ALTER TABLE monster_masters DROP CONSTRAINT IF EXISTS monster_masters_area_id_fkey;
        
        -- 文字列型の場合、データを新しいIDで更新
        IF column_type LIKE '%character%' OR column_type LIKE '%text%' THEN
            -- 各古いIDを新しいIDにマッピング
            UPDATE monster_masters 
            SET area_id = mapping.new_id::text
            FROM area_id_mapping mapping 
            WHERE monster_masters.area_id = mapping.old_id;
            
            -- カラムの型をINTEGERに変更
            ALTER TABLE monster_masters 
            ALTER COLUMN area_id TYPE INTEGER USING area_id::INTEGER;
            
            RAISE NOTICE 'monster_masters.area_id updated to INTEGER type';
        ELSE
            -- 既にINTEGER型の場合は値のみ更新
            UPDATE monster_masters 
            SET area_id = mapping.new_id
            FROM area_id_mapping mapping 
            WHERE monster_masters.area_id::text = mapping.old_id;
            
            RAISE NOTICE 'monster_masters.area_id values updated';
        END IF;
    ELSE
        RAISE NOTICE 'monster_masters table does not exist';
    END IF;
END $$;

-- adventurer_questsテーブルのquest_area_id更新（quest_area_mastersテーブルがあるかも確認）
DO $$
DECLARE
    table_exists boolean;
    quest_area_table_exists boolean;
BEGIN
    -- adventurer_questsテーブルが存在するかチェック
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'adventurer_quests'
    ) INTO table_exists;
    
    -- quest_area_mastersテーブルが存在するかチェック
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'quest_area_masters'
    ) INTO quest_area_table_exists;
    
    IF table_exists THEN
        RAISE NOTICE 'adventurer_quests table exists';
        
        -- quest_area_mastersが存在する場合、そちらがquest_area_idの参照先かもしれない
        IF quest_area_table_exists THEN
            RAISE NOTICE 'quest_area_masters table also exists - quest_area_id might reference that table instead of area_masters';
        ELSE
            -- quest_area_mastersが存在しない場合、area_mastersを参照している可能性
            -- 外部キー制約を確認
            RAISE NOTICE 'quest_area_masters does not exist - adventurer_quests.quest_area_id might need updating';
        END IF;
    ELSE
        RAISE NOTICE 'adventurer_quests table does not exist';
    END IF;
END $$;

-- 古いarea_mastersテーブルを削除し、新しいテーブルをリネーム
DROP TABLE area_masters CASCADE;
ALTER TABLE area_masters_new RENAME TO area_masters;

-- インデックスを再作成
CREATE INDEX idx_area_masters_active ON area_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_area_masters_display_order ON area_masters(display_order);
CREATE INDEX idx_area_masters_danger_level ON area_masters(danger_level);

-- 外部キー制約を再作成
-- monster_mastersとの外部キー制約を再作成
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'monster_masters') THEN
        ALTER TABLE monster_masters 
        ADD CONSTRAINT monster_masters_area_id_fkey 
        FOREIGN KEY (area_id) REFERENCES area_masters(id);
        RAISE NOTICE 'monster_masters foreign key constraint added';
    END IF;
END $$;

-- 外部キー制約を再有効化
SET session_replication_role = DEFAULT;

-- 結果確認
SELECT 'area_masters' as table_name, COUNT(*) as count, MIN(id) as min_id, MAX(id) as max_id FROM area_masters;

-- 関連テーブルの状況確認
SELECT 'monster_masters' as table_name, 
       COUNT(*) as total,
       COUNT(*) FILTER (WHERE area_id IS NOT NULL) as with_area_id
FROM monster_masters 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'monster_masters');

-- 新しいIDでのデータサンプル
SELECT id, name, danger_level, required_shop_level FROM area_masters ORDER BY id;

-- monster_mastersのarea_id確認
SELECT 'monster_masters area_id' as info, id, name, area_id 
FROM monster_masters 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'monster_masters')
ORDER BY id LIMIT 10;