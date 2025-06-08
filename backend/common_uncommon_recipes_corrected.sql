-- ============================================================================
-- Common & Uncommon Weapon Recipes (Corrected Version)
-- ============================================================================
-- This file creates crafting recipes for Common (rarity_id=1) and Uncommon (rarity_id=2) weapons
-- using basic materials with appropriate success rates and costs.
-- Uses correct column names: weapon_id, material_id, quantity

-- Begin transaction
BEGIN;

-- ============================================================================
-- COMMON WEAPON RECIPES (rarity_id=1)
-- Success Rate: 95-100% | Gold Cost: 50-200G | Required Level: 1-5
-- Materials: 1-2 basic materials (2-20G value range)
-- ============================================================================

-- Sword Recipes (Common)
-- ブロンズソード (ID: 110) - Basic starting sword
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (110, 'ブロンズソードの製作', '基本的な銅の剣を作成します', 1.0, 50, 1, true, NOW(), NOW());

-- アイアンソード (ID: 111) - Iron sword
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (111, 'アイアンソードの製作', '鉄の剣を作成します', 0.95, 80, 3, true, NOW(), NOW());

-- ロングソード (ID: 116) - Long sword
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (116, 'ロングソードの製作', '長い剣を作成します', 0.98, 60, 1, true, NOW(), NOW());

-- Bow Recipes (Common)
-- ウッドボウ (ID: 130) - Basic wooden bow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (130, 'ウッドボウの製作', '木製の弓を作成します', 1.0, 40, 1, true, NOW(), NOW());

-- ショートボウ (ID: 131) - Short bow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (131, 'ショートボウの製作', '短い弓を作成します', 0.98, 50, 1, true, NOW(), NOW());

-- Staff Recipes (Common)
-- ウッドスタッフ (ID: 150) - Basic wooden staff
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (150, 'ウッドスタッフの製作', '木製の杖を作成します', 1.0, 35, 1, true, NOW(), NOW());

-- マジックワンド (ID: 151) - Magic wand
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (151, 'マジックワンドの製作', '魔法の杖を作成します', 0.95, 60, 1, true, NOW(), NOW());

-- Dagger Recipes (Common)
-- アイアンダガー (ID: 170) - Iron dagger
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (170, 'アイアンダガーの製作', '鉄の短剣を作成します', 1.0, 30, 1, true, NOW(), NOW());

-- Hammer Recipes (Common)
-- アイアンハンマー (ID: 190) - Iron hammer
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (190, 'アイアンハンマーの製作', '鉄のハンマーを作成します', 0.95, 70, 1, true, NOW(), NOW());

-- ============================================================================
-- UNCOMMON WEAPON RECIPES (rarity_id=2)
-- Success Rate: 85-95% | Gold Cost: 200-600G | Required Level: 3-10
-- Materials: 2-3 materials (mix of common + some uncommon materials)
-- ============================================================================

-- Sword Recipes (Uncommon)
-- グラディウス (ID: 129) - Gladius
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (129, 'グラディウスの製作', 'ローマ風の短剣を作成します', 0.90, 200, 3, true, NOW(), NOW());

-- シミター (ID: 121) - Scimitar
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (121, 'シミターの製作', '湾曲した剣を作成します', 0.88, 300, 4, true, NOW(), NOW());

-- スチールブレード (ID: 112) - Steel blade
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (112, 'スチールブレードの製作', '鋼鉄の刃を作成します', 0.85, 400, 5, true, NOW(), NOW());

-- バスタードソード (ID: 117) - Bastard sword
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (117, 'バスタードソードの製作', '両手剣を作成します', 0.85, 500, 6, true, NOW(), NOW());

-- Bow Recipes (Uncommon)
-- ロングボウ (ID: 132) - Long bow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (132, 'ロングボウの製作', '長弓を作成します', 0.90, 250, 4, true, NOW(), NOW());

-- ハンターボウ (ID: 142) - Hunter bow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (142, 'ハンターボウの製作', 'ハンター用の弓を作成します', 0.88, 300, 4, true, NOW(), NOW());

-- コンポジットボウ (ID: 133) - Composite bow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (133, 'コンポジットボウの製作', '複合材料の弓を作成します', 0.87, 350, 5, true, NOW(), NOW());

-- クロスボウ (ID: 140) - Crossbow
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (140, 'クロスボウの製作', 'クロスボウを作成します', 0.85, 400, 6, true, NOW(), NOW());

-- Staff Recipes (Uncommon)
-- アイアンロッド (ID: 152) - Iron rod
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (152, 'アイアンロッドの製作', '鉄の杖を作成します', 0.90, 200, 3, true, NOW(), NOW());

-- Dagger Recipes (Uncommon)
-- スチールダガー (ID: 171) - Steel dagger
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (171, 'スチールダガーの製作', '鋼鉄の短剣を作成します', 0.90, 150, 3, true, NOW(), NOW());

-- シルバーダガー (ID: 173) - Silver dagger
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (173, 'シルバーダガーの製作', '銀の短剣を作成します', 0.88, 200, 4, true, NOW(), NOW());

-- スピードダガー (ID: 189) - Speed dagger
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (189, 'スピードダガーの製作', '素早い短剣を作成します', 0.87, 300, 4, true, NOW(), NOW());

-- Hammer Recipes (Uncommon)
-- スチールハンマー (ID: 191) - Steel hammer
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (191, 'スチールハンマーの製作', '鋼鉄のハンマーを作成します', 0.88, 250, 4, true, NOW(), NOW());

-- ウォーハンマー (ID: 192) - War hammer
INSERT INTO crafting_recipes (weapon_id, name, description, success_rate, gold_cost, required_level, is_active, created_at, updated_at)
VALUES (192, 'ウォーハンマーの製作', '戦用ハンマーを作成します', 0.85, 400, 5, true, NOW(), NOW());

-- ============================================================================
-- RECIPE MATERIALS ASSIGNMENT
-- ============================================================================

-- Common Weapon Materials (Basic materials: 2-25G value)
-- Materials used: 木の枝(10), 鉄鉱石(1), 粘土(12), 動物の毛皮(11), 炭(14), 麻紐(16), 骨(17), 古代の木材(3), 樹液(19), 蜘蛛の糸(20)

-- ブロンズソード - Simple materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 2 FROM crafting_recipes r WHERE r.weapon_id = 110; -- 鉄鉱石 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 10, 1 FROM crafting_recipes r WHERE r.weapon_id = 110; -- 木の枝 x1

-- アイアンソード - Iron + carbon for steel-like properties
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 3 FROM crafting_recipes r WHERE r.weapon_id = 111; -- 鉄鉱石 x3

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 14, 2 FROM crafting_recipes r WHERE r.weapon_id = 111; -- 炭 x2

-- ロングソード - Wood + iron for longer blade
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 3, 1 FROM crafting_recipes r WHERE r.weapon_id = 116; -- 古代の木材 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 2 FROM crafting_recipes r WHERE r.weapon_id = 116; -- 鉄鉱石 x2

-- ウッドボウ - Basic wood bow
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 10, 3 FROM crafting_recipes r WHERE r.weapon_id = 130; -- 木の枝 x3

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 16, 2 FROM crafting_recipes r WHERE r.weapon_id = 130; -- 麻紐 x2

-- ショートボウ - Wood + leather grip
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 10, 2 FROM crafting_recipes r WHERE r.weapon_id = 131; -- 木の枝 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 11, 1 FROM crafting_recipes r WHERE r.weapon_id = 131; -- 動物の毛皮 x1

-- ウッドスタッフ - Simple wooden staff
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 3, 1 FROM crafting_recipes r WHERE r.weapon_id = 150; -- 古代の木材 x1

-- マジックワンド - Wood + basic magic material
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 10, 1 FROM crafting_recipes r WHERE r.weapon_id = 151; -- 木の枝 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 19, 1 FROM crafting_recipes r WHERE r.weapon_id = 151; -- 樹液 x1

-- アイアンダガー - Simple iron dagger
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 1 FROM crafting_recipes r WHERE r.weapon_id = 170; -- 鉄鉱石 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 11, 1 FROM crafting_recipes r WHERE r.weapon_id = 170; -- 動物の毛皮 x1

-- アイアンハンマー - Iron + wood handle
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 3 FROM crafting_recipes r WHERE r.weapon_id = 190; -- 鉄鉱石 x3

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 3, 1 FROM crafting_recipes r WHERE r.weapon_id = 190; -- 古代の木材 x1

-- ============================================================================
-- UNCOMMON WEAPON MATERIALS (Mix of common + some uncommon materials)
-- Using materials in 10-120G range for more challenging recipes
-- ============================================================================

-- グラディウス - Iron + bone for decorative handle
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 2 FROM crafting_recipes r WHERE r.weapon_id = 129; -- 鉄鉱石 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 17, 1 FROM crafting_recipes r WHERE r.weapon_id = 129; -- 骨 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 20, 1 FROM crafting_recipes r WHERE r.weapon_id = 129; -- 蜘蛛の糸 x1

-- シミター - Steel + magical enhancement
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 1 FROM crafting_recipes r WHERE r.weapon_id = 121; -- 鋼鉄塊 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 2, 1 FROM crafting_recipes r WHERE r.weapon_id = 121; -- 魔法の水晶 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 21, 1 FROM crafting_recipes r WHERE r.weapon_id = 121; -- 硫黄 x1

-- スチールブレード - Steel + ancient wood
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 2 FROM crafting_recipes r WHERE r.weapon_id = 112; -- 鋼鉄塊 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 112; -- 古代の木材 x1

-- バスタードソード - Steel + high-grade materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 2 FROM crafting_recipes r WHERE r.weapon_id = 117; -- 鋼鉄塊 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 23, 1 FROM crafting_recipes r WHERE r.weapon_id = 117; -- 魔法の水晶 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 117; -- 古代の木材 x1

-- ロングボウ - Advanced wood + quality string
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 132; -- 古代の木材 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 20, 2 FROM crafting_recipes r WHERE r.weapon_id = 132; -- 蜘蛛の糸 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 17, 1 FROM crafting_recipes r WHERE r.weapon_id = 132; -- 骨 x1

-- ハンターボウ - Specialized hunting bow
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 142; -- 古代の木材 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 11, 2 FROM crafting_recipes r WHERE r.weapon_id = 142; -- 動物の毛皮 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 33, 1 FROM crafting_recipes r WHERE r.weapon_id = 142; -- 風の羽根 x1

-- コンポジットボウ - Composite materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 133; -- 古代の木材 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 1 FROM crafting_recipes r WHERE r.weapon_id = 133; -- 鋼鉄塊 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 20, 2 FROM crafting_recipes r WHERE r.weapon_id = 133; -- 蜘蛛の糸 x2

-- クロスボウ - Mechanical crossbow
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 2 FROM crafting_recipes r WHERE r.weapon_id = 140; -- 鋼鉄塊 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 140; -- 古代の木材 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 38, 1 FROM crafting_recipes r WHERE r.weapon_id = 140; -- 黒曜石 x1

-- アイアンロッド - Iron staff with magic
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 2 FROM crafting_recipes r WHERE r.weapon_id = 152; -- 鉄鉱石 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 2, 1 FROM crafting_recipes r WHERE r.weapon_id = 152; -- 魔法の水晶 x1

-- スチールダガー - Steel dagger
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 1 FROM crafting_recipes r WHERE r.weapon_id = 171; -- 鋼鉄塊 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 11, 1 FROM crafting_recipes r WHERE r.weapon_id = 171; -- 動物の毛皮 x1

-- シルバーダガー - Silver-enhanced dagger
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 1, 1 FROM crafting_recipes r WHERE r.weapon_id = 173; -- 鉄鉱石 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 2, 1 FROM crafting_recipes r WHERE r.weapon_id = 173; -- 魔法の水晶 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 37, 1 FROM crafting_recipes r WHERE r.weapon_id = 173; -- 水銀 x1

-- スピードダガー - Speed-enhanced dagger
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 1 FROM crafting_recipes r WHERE r.weapon_id = 189; -- 鋼鉄塊 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 33, 1 FROM crafting_recipes r WHERE r.weapon_id = 189; -- 風の羽根 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 20, 1 FROM crafting_recipes r WHERE r.weapon_id = 189; -- 蜘蛛の糸 x1

-- スチールハンマー - Steel hammer
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 2 FROM crafting_recipes r WHERE r.weapon_id = 191; -- 鋼鉄塊 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 191; -- 古代の木材 x1

-- ウォーハンマー - War hammer with obsidian
INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 22, 2 FROM crafting_recipes r WHERE r.weapon_id = 192; -- 鋼鉄塊 x2

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 38, 1 FROM crafting_recipes r WHERE r.weapon_id = 192; -- 黒曜石 x1

INSERT INTO recipe_materials (recipe_id, material_id, quantity)
SELECT r.id, 26, 1 FROM crafting_recipes r WHERE r.weapon_id = 192; -- 古代の木材 x1

-- Commit transaction
COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Run separately after the main script)
-- ============================================================================

-- Count recipes created
SELECT 'Total Recipes Created' as category, COUNT(*) as count FROM crafting_recipes;

-- Show sample recipes with materials
SELECT 
    wm.name as weapon_name,
    cr.name as recipe_name,
    cr.success_rate,
    cr.gold_cost,
    cr.required_level,
    STRING_AGG(mm.name || ' x' || rm.quantity, ', ') as materials
FROM crafting_recipes cr
JOIN weapon_masters wm ON cr.weapon_id = wm.id
JOIN recipe_materials rm ON cr.id = rm.recipe_id
JOIN material_masters mm ON rm.material_id = mm.id
WHERE wm.rarity_id IN (1, 2)
GROUP BY wm.name, cr.name, cr.success_rate, cr.gold_cost, cr.required_level, wm.rarity_id
ORDER BY wm.rarity_id, cr.required_level, wm.name;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Created recipes for:
-- 
-- COMMON WEAPONS (9 recipes):
-- - ブロンズソード, アイアンソード, ロングソード (Swords)
-- - ウッドボウ, ショートボウ (Bows) 
-- - ウッドスタッフ, マジックワンド (Staves)
-- - アイアンダガー (Dagger)
-- - アイアンハンマー (Hammer)
--
-- UNCOMMON WEAPONS (15 recipes):
-- - グラディウス, シミター, スチールブレード, バスタードソード (Swords)
-- - ロングボウ, ハンターボウ, コンポジットボウ, クロスボウ (Bows)
-- - アイアンロッド (Staff)
-- - スチールダガー, シルバーダガー, スピードダガー (Daggers)
-- - スチールハンマー, ウォーハンマー (Hammers)
--
-- Total: 24 recipes with appropriate material requirements
-- ============================================================================