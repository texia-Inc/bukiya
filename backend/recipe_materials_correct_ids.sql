-- Recipe Materials for Common/Uncommon Weapons (Correct IDs)
-- コモン・アンコモン武器のレシピ素材 (正しいID)

BEGIN;

-- === COMMON WEAPON MATERIALS ===

-- ブロンズソード (recipe_id: 74)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(74, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 1),
(74, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2);

-- アイアンソード (recipe_id: 75)  
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(75, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 3),
(75, (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 2);

-- ロングソード (recipe_id: 76)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(76, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(76, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- ウッドボウ (recipe_id: 77)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(77, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 3),
(77, (SELECT id FROM material_masters WHERE name = '麻紐' LIMIT 1), 2);

-- ショートボウ (recipe_id: 78)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(78, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 2),
(78, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- ウッドスタッフ (recipe_id: 79)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(79, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- マジックワンド (recipe_id: 80)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(80, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 1),
(80, (SELECT id FROM material_masters WHERE name = '樹液' LIMIT 1), 1);

-- アイアンダガー (recipe_id: 81)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(81, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 1),
(81, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- アイアンハンマー (recipe_id: 82)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(82, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 3),
(82, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- === UNCOMMON WEAPON MATERIALS ===

-- グラディウス (recipe_id: 83)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(83, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(83, (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 1),
(83, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 1);

-- シミター (recipe_id: 84)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(84, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(84, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(84, (SELECT id FROM material_masters WHERE name = '硫黄' LIMIT 1), 1);

-- スチールブレード (recipe_id: 85)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(85, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(85, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- バスタードソード (recipe_id: 86)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(86, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(86, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(86, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1);

-- ロングボウ (recipe_id: 87)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(87, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(87, (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 1),
(87, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 2);

-- ハンターボウ (recipe_id: 88)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(88, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(88, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 2),
(88, (SELECT id FROM material_masters WHERE name = '風の羽根' LIMIT 1), 1);

-- コンポジットボウ (recipe_id: 89)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(89, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(89, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(89, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 2);

-- クロスボウ (recipe_id: 90)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(90, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(90, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(90, (SELECT id FROM material_masters WHERE name = '黒曜石' LIMIT 1), 1);

-- アイアンロッド (recipe_id: 91)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(91, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(91, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1);

-- スチールダガー (recipe_id: 92)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(92, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(92, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- シルバーダガー (recipe_id: 93)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(93, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 1),
(93, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(93, (SELECT id FROM material_masters WHERE name = '水銀' LIMIT 1), 1);

-- スピードダガー (recipe_id: 94)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(94, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(94, (SELECT id FROM material_masters WHERE name = '風の羽根' LIMIT 1), 1),
(94, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 1);

-- スチールハンマー (recipe_id: 95)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(95, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(95, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- ウォーハンマー (recipe_id: 96)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(96, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(96, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(96, (SELECT id FROM material_masters WHERE name = '黒曜石' LIMIT 1), 1);

COMMIT;

-- Verification Query
SELECT 
    'Recipe Materials Updated' as status,
    COUNT(*) as total_materials_added
FROM recipe_materials 
WHERE recipe_id >= 74;