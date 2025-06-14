-- Monster Drop Sample Data
-- モンスタードロップサンプルデータ

BEGIN;

-- モンスターID1（森のゴブリン）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
-- 基本素材のドロップ
(1, 'material', (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 0.60, 1, 3, 0, 0, true, NOW()),
(1, 'material', (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 0.40, 1, 2, 0, 0, true, NOW()),
(1, 'material', (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 0.25, 1, 1, 0, 0, true, NOW()),
(1, 'material', (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 0.15, 1, 1, 0, 0, true, NOW());

-- モンスターID2（青い粘液）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(2, 'material', (SELECT id FROM material_masters WHERE name = '樹液' LIMIT 1), 0.80, 1, 2, 0, 0, true, NOW()),
(2, 'material', (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 0.30, 1, 1, 0, 0, true, NOW());

-- モンスターID3（緑の粘液）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(3, 'material', (SELECT id FROM material_masters WHERE name = '樹液' LIMIT 1), 0.70, 1, 2, 0, 0, true, NOW()),
(3, 'material', (SELECT id FROM material_masters WHERE name = '粘土' LIMIT 1), 0.45, 1, 3, 0, 0, true, NOW()),
(3, 'material', (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 0.20, 1, 1, 0, 0, true, NOW());

-- モンスターID4（森の蜘蛛）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(4, 'material', (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 0.85, 2, 5, 0, 0, true, NOW()),
(4, 'material', (SELECT id FROM material_masters WHERE name = '毒袋' LIMIT 1), 0.35, 1, 2, 0, 0, true, NOW()),
(4, 'material', (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 0.20, 1, 1, 0, 0, true, NOW());

-- モンスターID10（森のトロル）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(10, 'material', (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 0.45, 1, 2, 0, 0, true, NOW()),
(10, 'material', (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 0.60, 1, 3, 0, 0, true, NOW()),
(10, 'material', (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 0.30, 1, 2, 0, 0, true, NOW()),
(10, 'material', (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 0.15, 1, 1, 5, 10, true, NOW()); -- 条件付きドロップ

-- モンスターID15（ミノタウロス）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(15, 'material', (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 0.70, 2, 4, 0, 0, true, NOW()),
(15, 'material', (SELECT id FROM material_masters WHERE name = 'アダマンタイト鉱石' LIMIT 1), 0.25, 1, 1, 0, 0, true, NOW()),
(15, 'material', (SELECT id FROM material_masters WHERE name = '戦士の誇り' LIMIT 1), 0.10, 1, 1, 10, 15, true, NOW()); -- 高条件ドロップ

-- 高レベルモンスターのドロップ設定例
-- モンスターID50（古代樹の番人）
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(50, 'material', (SELECT id FROM material_masters WHERE name = '生命の樹液' LIMIT 1), 0.60, 1, 2, 0, 0, true, NOW()),
(50, 'material', (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 0.40, 1, 3, 0, 0, true, NOW()),
(50, 'material', (SELECT id FROM material_masters WHERE name = '光の欠片' LIMIT 1), 0.25, 1, 1, 15, 20, true, NOW());

COMMIT;

-- 検証用クエリ
SELECT 
    'ドロップテーブル作成完了' as status,
    COUNT(*) as total_drops,
    COUNT(DISTINCT monster_id) as monsters_with_drops
FROM monster_drop_tables;

-- モンスター別ドロップ設定確認
SELECT 
    m.name as monster_name,
    m.level as monster_level,
    mt.name as material_name,
    dt.drop_rate * 100 as drop_rate_percent,
    dt.min_quantity,
    dt.max_quantity,
    CASE 
        WHEN dt.required_weapon_enchant > 0 OR dt.required_adventurer_level > 0 
        THEN CONCAT('武器+', dt.required_weapon_enchant, ', 冒険者Lv', dt.required_adventurer_level)
        ELSE '条件なし'
    END as conditions
FROM monster_drop_tables dt
JOIN monster_masters m ON dt.monster_id = m.id
LEFT JOIN material_masters mt ON dt.item_type = 'material' AND dt.item_id = mt.id
ORDER BY m.level, dt.drop_rate DESC;