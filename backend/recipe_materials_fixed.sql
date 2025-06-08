-- Recipe Materials for Common/Uncommon Weapons Only (Fixed)
-- コモン・アンコモン武器のレシピ素材のみ (修正版)

BEGIN;

-- === COMMON WEAPON MATERIALS (recipes 47-55) ===

-- ブロンズソード (recipe_id: 47)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(47, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 1),
(47, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2);

-- アイアンソード (recipe_id: 48)  
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(48, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 3),
(48, (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 2);

-- ロングソード (recipe_id: 49)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(49, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(49, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- ウッドボウ (recipe_id: 50)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(50, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 3),
(50, (SELECT id FROM material_masters WHERE name = '麻紐' LIMIT 1), 2);

-- ショートボウ (recipe_id: 51)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(51, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 2),
(51, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- ウッドスタッフ (recipe_id: 52)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(52, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- マジックワンド (recipe_id: 53)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(53, (SELECT id FROM material_masters WHERE name = '木の枝' LIMIT 1), 1),
(53, (SELECT id FROM material_masters WHERE name = '樹液' LIMIT 1), 1);

-- アイアンダガー (recipe_id: 54)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(54, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 1),
(54, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- アイアンハンマー (recipe_id: 55)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(55, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 3),
(55, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- === UNCOMMON WEAPON MATERIALS (recipes 56-69) ===

-- グラディウス (recipe_id: 56)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(56, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(56, (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 1),
(56, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 1);

-- シミター (recipe_id: 57)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(57, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(57, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(57, (SELECT id FROM material_masters WHERE name = '硫黄' LIMIT 1), 1);

-- スチールブレード (recipe_id: 58)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(58, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(58, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- バスタードソード (recipe_id: 59)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(59, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(59, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(59, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1);

-- ロングボウ (recipe_id: 60)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(60, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(60, (SELECT id FROM material_masters WHERE name = '骨' LIMIT 1), 1),
(60, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 2);

-- ハンターボウ (recipe_id: 61)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(61, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(61, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 2),
(61, (SELECT id FROM material_masters WHERE name = '風の羽根' LIMIT 1), 1);

-- コンポジットボウ (recipe_id: 62)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(62, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(62, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(62, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 2);

-- クロスボウ (recipe_id: 63)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(63, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(63, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(63, (SELECT id FROM material_masters WHERE name = '黒曜石' LIMIT 1), 1);

-- アイアンロッド (recipe_id: 64)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(64, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 2),
(64, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1);

-- スチールダガー (recipe_id: 65)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(65, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(65, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 1);

-- シルバーダガー (recipe_id: 66)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(66, (SELECT id FROM material_masters WHERE name = '鉄鉱石' LIMIT 1), 1),
(66, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(66, (SELECT id FROM material_masters WHERE name = '水銀' LIMIT 1), 1);

-- スピードダガー (recipe_id: 67)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(67, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(67, (SELECT id FROM material_masters WHERE name = '風の羽根' LIMIT 1), 1),
(67, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 1);

-- スチールハンマー (recipe_id: 68)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(68, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(68, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1);

-- ウォーハンマー (recipe_id: 69)
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(69, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(69, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(69, (SELECT id FROM material_masters WHERE name = '黒曜石' LIMIT 1), 1);

COMMIT;

-- Verification Query
SELECT 
    'Recipe Materials Updated' as status,
    COUNT(*) as total_materials_added
FROM recipe_materials 
WHERE recipe_id >= 47;