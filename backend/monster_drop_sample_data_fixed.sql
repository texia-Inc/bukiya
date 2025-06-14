-- Monster Drop Sample Data (Fixed)
-- モンスタードロップサンプルデータ（修正版）

BEGIN;

-- モンスターID1（森のゴブリン）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
-- 基本素材のドロップ
(1, 'material', 1, 0.60, 1, 3, 0, 0, true, NOW()), -- 鉄鉱石
(1, 'material', 10, 0.40, 1, 2, 0, 0, true, NOW()), -- 木の枝
(1, 'material', 11, 0.25, 1, 1, 0, 0, true, NOW()), -- 動物の毛皮
(1, 'material', 14, 0.15, 1, 1, 0, 0, true, NOW()); -- 炭

-- モンスターID2（青い粘液）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(2, 'material', 19, 0.80, 1, 2, 0, 0, true, NOW()), -- 樹液
(2, 'material', 10, 0.30, 1, 1, 0, 0, true, NOW()); -- 木の枝

-- モンスターID3（緑の粘液）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(3, 'material', 19, 0.70, 1, 2, 0, 0, true, NOW()), -- 樹液
(3, 'material', 12, 0.45, 1, 3, 0, 0, true, NOW()), -- 粘土
(3, 'material', 1, 0.20, 1, 1, 0, 0, true, NOW()); -- 鉄鉱石

-- モンスターID4（森の蜘蛛）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(4, 'material', 20, 0.85, 2, 5, 0, 0, true, NOW()), -- 蜘蛛の糸
(4, 'material', 7, 0.35, 1, 2, 0, 0, true, NOW()), -- 毒草
(4, 'material', 11, 0.20, 1, 1, 0, 0, true, NOW()); -- 動物の毛皮

-- モンスターID5（野ウサギ）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(5, 'material', 11, 0.70, 1, 2, 0, 0, true, NOW()), -- 動物の毛皮
(5, 'material', 17, 0.30, 1, 1, 0, 0, true, NOW()); -- 骨

-- モンスターID11（洞窟ネズミ）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(11, 'material', 11, 0.60, 1, 2, 0, 0, true, NOW()), -- 動物の毛皮
(11, 'material', 18, 0.40, 1, 3, 0, 0, true, NOW()); -- 小石

-- モンスターID15（ミノタウロス）のドロップ設定
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(15, 'material', 17, 0.70, 2, 4, 0, 0, true, NOW()), -- 骨
(15, 'material', 1, 0.50, 2, 3, 0, 0, true, NOW()), -- 鉄鉱石
(15, 'material', 2, 0.25, 1, 1, 0, 0, true, NOW()), -- 魔法の水晶
(15, 'material', 6, 0.10, 1, 1, 10, 15, true, NOW()); -- ミスリル鉱石（高条件ドロップ）

-- 高レベルモンスターのドロップ設定
-- モンスターID37（古代樹の番人）
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(37, 'material', 3, 0.80, 2, 4, 0, 0, true, NOW()), -- 古代の木材
(37, 'material', 8, 0.40, 1, 3, 0, 0, true, NOW()), -- 聖なる水
(37, 'material', 6, 0.25, 1, 1, 15, 20, true, NOW()); -- ミスリル鉱石

-- モンスターID50（森の王）
INSERT INTO monster_drop_tables (monster_id, item_type, item_id, drop_rate, min_quantity, max_quantity, required_weapon_enchant, required_adventurer_level, is_active, created_at) VALUES
(50, 'material', 3, 0.90, 3, 5, 0, 0, true, NOW()), -- 古代の木材
(50, 'material', 8, 0.60, 2, 3, 0, 0, true, NOW()), -- 聖なる水
(50, 'material', 4, 0.30, 1, 2, 0, 0, true, NOW()), -- 希少な宝石
(50, 'material', 6, 0.15, 1, 1, 20, 25, true, NOW()); -- ミスリル鉱石（超高条件）

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