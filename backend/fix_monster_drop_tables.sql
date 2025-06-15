-- monster_drop_tablesを修正して連番IDに対応

-- 現在のmonster_drop_tablesの状況を確認
SELECT 'Before fix' as status, COUNT(*) as total, 
       COUNT(*) FILTER (WHERE drop_target_id IS NULL) as null_target_ids,
       COUNT(*) FILTER (WHERE drop_type = 'gold') as gold_drops
FROM monster_drop_tables;

-- バックアップテーブルが存在するか確認
SELECT 'Backup table' as status, COUNT(*) as count FROM monster_drop_tables_backup 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'monster_drop_tables_backup');

-- monster_drop_tablesを再作成（NULLを許可するように修正）
DROP TABLE IF EXISTS monster_drop_tables;

CREATE TABLE monster_drop_tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    monster_master_id INTEGER NOT NULL,
    drop_type VARCHAR(50) NOT NULL,
    drop_target_id VARCHAR(50), -- NULL許可（goldドロップの場合）
    drop_rate NUMERIC(10,4) NOT NULL DEFAULT 0.1,
    quantity_min INTEGER NOT NULL DEFAULT 1,
    quantity_max INTEGER NOT NULL DEFAULT 1,
    required_weapon_type VARCHAR(50),
    bonus_rate NUMERIC(10,4) NOT NULL DEFAULT 0.0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (monster_master_id) REFERENCES monster_masters(id) ON DELETE CASCADE
);

-- バックアップデータが存在する場合のみ復元
INSERT INTO monster_drop_tables (
    monster_master_id, drop_type, drop_target_id, drop_rate,
    quantity_min, quantity_max, required_weapon_type, bonus_rate,
    is_active, created_at
)
SELECT 
    mapping.new_id,
    backup.drop_type,
    backup.drop_target_id, -- NULLも許可
    backup.drop_rate,
    backup.quantity_min,
    backup.quantity_max,
    backup.required_weapon_type,
    backup.bonus_rate,
    backup.is_active,
    backup.created_at
FROM monster_drop_tables_backup backup
JOIN (
    SELECT 
        CASE old_monster_id
            WHEN 'slime' THEN 1
            WHEN 'goblin' THEN 2  
            WHEN 'wolf' THEN 3
            WHEN 'orc' THEN 4
            WHEN 'troll' THEN 5
            WHEN 'dragon_whelp' THEN 6
            ELSE NULL
        END as new_id,
        old_monster_id
    FROM (
        SELECT DISTINCT monster_master_id as old_monster_id 
        FROM monster_drop_tables_backup
    ) t
) mapping ON backup.monster_master_id = mapping.old_monster_id
WHERE mapping.new_id IS NOT NULL;

-- バックアップテーブルが存在しない場合、基本的なドロップデータを作成
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, drop_rate, quantity_min, quantity_max)
SELECT * FROM (VALUES
    -- スライム（ID: 4）のドロップ
    (4, 'gold', NULL, 0.95, 10, 25),
    (4, 'material', '1', 0.3, 1, 2),   -- 鉄鉱石
    (4, 'material', '5', 0.2, 1, 1),   -- 強化石
    
    -- ゴブリン（ID: 3）のドロップ  
    (3, 'gold', NULL, 0.9, 20, 40),
    (3, 'material', '1', 0.4, 1, 3),   -- 鉄鉱石
    (3, 'material', '2', 0.25, 1, 2),  -- 銅鉱石
    
    -- ウルフ（ID: 1）のドロップ
    (1, 'gold', NULL, 0.85, 35, 60),
    (1, 'material', '7', 0.6, 1, 2),   -- 革
    (1, 'material', '1', 0.3, 1, 2),   -- 鉄鉱石
    
    -- オーク（ID: 2）のドロップ
    (2, 'gold', NULL, 0.8, 50, 90),
    (2, 'material', '1', 0.5, 2, 4),   -- 鉄鉱石
    (2, 'material', '9', 0.15, 1, 1),  -- 銀鉱石
    
    -- トロール（ID: 5）のドロップ
    (5, 'gold', NULL, 0.75, 100, 200),
    (5, 'material', '9', 0.4, 1, 2),   -- 銀鉱石
    (5, 'material', '12', 0.2, 1, 1),  -- 魔法石
    
    -- ドラゴンの幼体（ID: 6）のドロップ
    (6, 'gold', NULL, 0.7, 200, 500),
    (6, 'material', '15', 0.8, 1, 3),  -- 龍の鱗
    (6, 'material', '12', 0.3, 1, 2)   -- 魔法石
) AS drops(monster_master_id, drop_type, drop_target_id, drop_rate, quantity_min, quantity_max)
WHERE NOT EXISTS (SELECT 1 FROM monster_drop_tables LIMIT 1);

-- インデックスを作成
CREATE INDEX idx_monster_drop_tables_monster ON monster_drop_tables(monster_master_id);
CREATE INDEX idx_monster_drop_tables_type ON monster_drop_tables(drop_type);
CREATE INDEX idx_monster_drop_tables_active ON monster_drop_tables(is_active) WHERE is_active = true;

-- バックアップテーブルを削除
DROP TABLE IF EXISTS monster_drop_tables_backup;

-- 結果確認
SELECT 'After fix' as status, COUNT(*) as total,
       COUNT(*) FILTER (WHERE drop_target_id IS NULL) as null_target_ids,
       COUNT(*) FILTER (WHERE drop_type = 'gold') as gold_drops,
       COUNT(*) FILTER (WHERE drop_type = 'material') as material_drops
FROM monster_drop_tables;

-- 各モンスターのドロップ数を確認
SELECT 
    mm.id,
    mm.name,
    COUNT(mdt.*) as drop_count
FROM monster_masters mm
LEFT JOIN monster_drop_tables mdt ON mm.id = mdt.monster_master_id
GROUP BY mm.id, mm.name
ORDER BY mm.id;