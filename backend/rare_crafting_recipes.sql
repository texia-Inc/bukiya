-- Rare+ Crafting Recipes with Complex Material Requirements
-- レア以上の武器の複雑なクラフティングレシピ

-- === RARE WEAPONS (rarity_id: 3) ===

-- Rare Sword Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(113, 'シルバーソード製作', '聖なる力を宿したシルバーソードを鍛造', 800, 0.75, 10, true),
(118, 'クリスタルソード製作', '魔法の水晶を核とした美しい剣を製作', 1200, 0.70, 12, true),
(120, 'カタナ製作', '伝統的な日本刀の製法で極限まで鍛えた刀', 1000, 0.65, 15, true),
(123, 'アイスブレード製作', '永久凍土の氷を刃に宿した冷気の剣', 1300, 0.68, 13, true);

-- Rare Bow Recipes  
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(134, 'エルヴンボウ製作', '古代エルフの秘技で作られた精密な弓', 900, 0.72, 11, true),
(135, 'ウィンドボウ製作', '風の精霊と契約した魔法の弓', 1000, 0.68, 12, true),
(141, 'リカーブボウ製作', '反りを活かした強力な狩猟弓', 1100, 0.70, 14, true);

-- Rare Staff Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(153, 'ファイアスタッフ製作', '炎の石を頂点に据えた炎属性の杖', 800, 0.75, 10, true),
(154, 'アイススタッフ製作', '氷の結晶で作られた氷属性の杖', 760, 0.76, 9, true),
(155, 'サンダースタッフ製作', '雷の欠片を核とした雷属性の杖', 840, 0.73, 11, true);

-- Rare Dagger Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(175, 'フレイムダガー製作', '炎の石を刃に埋め込んだ短剣', 600, 0.78, 8, true),
(181, 'クリスタルダガー製作', '魔法の水晶で作られた透明な短剣', 760, 0.72, 10, true),
(186, 'ルーンダガー製作', '古代文字が刻まれた神秘的な短剣', 800, 0.70, 12, true);

-- Rare Hammer Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(193, 'サンダーハンマー製作', '雷の力を宿した破壊的なハンマー', 1000, 0.68, 13, true),
(194, 'アースクラッシャー製作', '大地の怒りを込めた重いハンマー', 1200, 0.65, 15, true),
(195, 'フレイムハンマー製作', '炎の石で作られた燃え盛るハンマー', 1100, 0.67, 14, true);

-- === EPIC WEAPONS (rarity_id: 4) ===

-- Epic Sword Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(114, 'フレイムブレード製作', '永遠の炎を刃に宿した伝説の剣', 2400, 0.55, 20, true),
(119, 'ドラゴンスレイヤー製作', '古龍の心臓と純白の金属で作る龍殺しの剣', 4000, 0.45, 25, true),
(122, 'ダマスカスブレード製作', '伝説の鍛冶師の魂が宿った完璧な剣', 3000, 0.50, 22, true),
(127, 'デモンスレイヤー製作', '聖騎士の光で悪魔を滅する聖剣', 3600, 0.48, 24, true);

-- Epic Bow Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(136, 'フレイムボウ製作', '永遠の炎で強化された炎の弓', 2000, 0.58, 18, true),
(138, 'サンダーボウ製作', '雷の欠片と星霊の涙で作る雷撃の弓', 2200, 0.55, 19, true),
(143, 'シャドウボウ製作', '盗賊の影と虚空の破片で作る闇の弓', 2600, 0.52, 21, true);

-- Epic Staff Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(156, 'クリスタルロッド製作', '混沌の結晶と光の欠片で作る万能の杖', 1600, 0.62, 16, true),
(157, 'アークメイジスタッフ製作', '魔導師の知恵を核とした大魔法使いの杖', 2400, 0.55, 20, true),
(165, 'ネクロスタッフ製作', '深淵の水と霊魂の石で作る死霊術師の杖', 2200, 0.58, 19, true);

-- Epic Dagger Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(178, 'ドラゴンファング製作', '古龍の心臓の一部で作った龍牙の短剣', 1800, 0.60, 17, true),
(180, 'ヴァンパイアファング製作', '生命の樹液と深淵の水で作る吸血鬼の牙', 1900, 0.58, 18, true),
(185, 'カース・ダガー製作', '混沌の結晶に呪いを込めた呪術の短剣', 2000, 0.56, 19, true);

-- Epic Hammer Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(197, 'ドラゴンハンマー製作', '古龍の心臓と純白の金属で作る龍の力を持つハンマー', 3000, 0.50, 22, true),
(198, 'ソウルクラッシャー製作', '霊魂の石と戦士の誇りで作る魂を砕くハンマー', 2600, 0.53, 21, true),
(203, 'ジャイアントハンマー製作', 'アダマンタイト鉱石で作る巨人族の巨大ハンマー', 3600, 0.48, 25, true);

-- === LEGENDARY WEAPONS (rarity_id: 5) ===

-- Legendary Sword Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(115, 'エクスカリバー製作', '創世の欠片と神の血で作る王者の剣', 10000, 0.30, 30, true),
(125, 'ミスリルソード製作', '真理の結晶と運命の糸で織りなす秘銀の剣', 8000, 0.35, 28, true),
(128, 'ヴォイドブレード製作', '虚空の破片と終焉の金属で作る虚無の剣', 12000, 0.25, 35, true);

-- Legendary Bow Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(139, 'ドラゴンボウ製作', '古龍の心臓とフェニックスの羽で作る伝説の弓', 7000, 0.38, 27, true),
(146, 'フェニックスボウ製作', 'フェニックスの羽と永遠の炎で作る不死鳥の弓', 8000, 0.35, 28, true),
(147, 'ヴォイドボウ製作', '虚空の破片と時の砂で作る次元を射抜く弓', 10000, 0.30, 32, true);

-- Legendary Staff Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(158, 'ドラゴンスタッフ製作', '古龍の心臓と魔導師の知恵で作る龍の杖', 6000, 0.40, 25, true),
(163, 'スタッフ・オブ・パワー製作', '真理の結晶と創世の欠片で作る力の杖', 7000, 0.35, 28, true),
(164, 'ヴォイドスタッフ製作', '虚空の破片と終焉の金属で作る虚無の杖', 8000, 0.32, 30, true);

-- Legendary Dagger Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(182, 'ミスリルダガー製作', '真理の結晶で作る秘銀の短剣', 4000, 0.45, 22, true),
(183, 'ヴォイドダガー製作', '虚空の破片と盗賊の影で作る虚無の短剣', 5000, 0.40, 25, true);

-- Legendary Hammer Recipes
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level, is_active) VALUES
(200, 'ミスリルハンマー製作', '真理の結晶と戦士の誇りで作る秘銀のハンマー', 6000, 0.40, 25, true),
(201, 'ヴォイドハンマー製作', '虚空の破片と終焉の金属で作る虚無のハンマー', 8000, 0.35, 28, true),
(206, 'カオスハンマー製作', '混沌の結晶と創世の欠片で作る混沌のハンマー', 10000, 0.30, 32, true),
(209, 'ゴッドハンマー製作', '神の血と完璧の象徴で作る神々のハンマー', 25000, 0.15, 40, true);

-- Now insert the material requirements for each recipe

-- === RARE WEAPON MATERIALS ===

-- シルバーソード (ID: 113) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 113), (SELECT id FROM material_masters WHERE name = '鋼鉄塊'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 113), (SELECT id FROM material_masters WHERE name = '聖なる水'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 113), (SELECT id FROM material_masters WHERE name = '象牙'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 113), (SELECT id FROM material_masters WHERE name = '古代の木材'), 2);

-- クリスタルソード (ID: 118) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 118), (SELECT id FROM material_masters WHERE name = '魔法の水晶'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 118), (SELECT id FROM material_masters WHERE name = '鋼鉄塊'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 118), (SELECT id FROM material_masters WHERE name = '妖精の粉'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 118), (SELECT id FROM material_masters WHERE name = 'プラチナ鉱石'), 1);

-- カタナ (ID: 120) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 120), (SELECT id FROM material_masters WHERE name = '鋼鉄塊'), 4),
((SELECT id FROM crafting_recipes WHERE weapon_id = 120), (SELECT id FROM material_masters WHERE name = '炭'), 5),
((SELECT id FROM crafting_recipes WHERE weapon_id = 120), (SELECT id FROM material_masters WHERE name = '古代の木材'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 120), (SELECT id FROM material_masters WHERE name = '蜘蛛の糸'), 3);

-- アイスブレード (ID: 123) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 123), (SELECT id FROM material_masters WHERE name = '氷の結晶'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 123), (SELECT id FROM material_masters WHERE name = '鋼鉄塊'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 123), (SELECT id FROM material_masters WHERE name = '魔法の水晶'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 123), (SELECT id FROM material_masters WHERE name = '聖なる水'), 2);

-- エルヴンボウ (ID: 134) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 134), (SELECT id FROM material_masters WHERE name = '古代の木材'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 134), (SELECT id FROM material_masters WHERE name = '精霊の羽'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 134), (SELECT id FROM material_masters WHERE name = '蜘蛛の糸'), 4),
((SELECT id FROM crafting_recipes WHERE weapon_id = 134), (SELECT id FROM material_masters WHERE name = '聖なる水'), 1);

-- ウィンドボウ (ID: 135) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 135), (SELECT id FROM material_masters WHERE name = '風の羽根'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 135), (SELECT id FROM material_masters WHERE name = '古代の木材'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 135), (SELECT id FROM material_masters WHERE name = '魔法の水晶'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 135), (SELECT id FROM material_masters WHERE name = '妖精の粉'), 2);

-- ファイアスタッフ (ID: 153) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 153), (SELECT id FROM material_masters WHERE name = '炎の石'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 153), (SELECT id FROM material_masters WHERE name = '古代の木材'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 153), (SELECT id FROM material_masters WHERE name = '魔法の水晶'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 153), (SELECT id FROM material_masters WHERE name = '炭'), 3);

-- === EPIC WEAPON MATERIALS ===

-- フレイムブレード (ID: 114) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 114), (SELECT id FROM material_masters WHERE name = '永遠の炎'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 114), (SELECT id FROM material_masters WHERE name = 'アダマンタイト鉱石'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 114), (SELECT id FROM material_masters WHERE name = '炎の石'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 114), (SELECT id FROM material_masters WHERE name = '鍛冶師の魂'), 1);

-- ドラゴンスレイヤー (ID: 119) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 119), (SELECT id FROM material_masters WHERE name = '古龍の心臓'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 119), (SELECT id FROM material_masters WHERE name = '純白の金属'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 119), (SELECT id FROM material_masters WHERE name = 'ドラゴンの鱗'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 119), (SELECT id FROM material_masters WHERE name = '戦士の誇り'), 1);

-- ダマスカスブレード (ID: 122) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 122), (SELECT id FROM material_masters WHERE name = '鍛冶師の魂'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 122), (SELECT id FROM material_masters WHERE name = 'アダマンタイト鉱石'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 122), (SELECT id FROM material_masters WHERE name = '時の砂'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 122), (SELECT id FROM material_masters WHERE name = '光の欠片'), 1);

-- === LEGENDARY WEAPON MATERIALS ===

-- エクスカリバー (ID: 115) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 115), (SELECT id FROM material_masters WHERE name = '創世の欠片'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 115), (SELECT id FROM material_masters WHERE name = '神の血'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 115), (SELECT id FROM material_masters WHERE name = '真理の結晶'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 115), (SELECT id FROM material_masters WHERE name = '聖騎士の光'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 115), (SELECT id FROM material_masters WHERE name = '完璧の象徴'), 1);

-- ミスリルソード (ID: 125) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 125), (SELECT id FROM material_masters WHERE name = '真理の結晶'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 125), (SELECT id FROM material_masters WHERE name = '運命の糸'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 125), (SELECT id FROM material_masters WHERE name = 'ミスリル鉱石'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 125), (SELECT id FROM material_masters WHERE name = '魔導師の知恵'), 1);

-- ヴォイドブレード (ID: 128) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 128), (SELECT id FROM material_masters WHERE name = '虚空の破片'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 128), (SELECT id FROM material_masters WHERE name = '終焉の金属'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 128), (SELECT id FROM material_masters WHERE name = '深淵の水'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 128), (SELECT id FROM material_masters WHERE name = '創世の欠片'), 1);

-- ゴッドハンマー (ID: 209) materials - Ultimate recipe
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '神の血'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '完璧の象徴'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '創世の欠片'), 2),
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '真理の結晶'), 3),
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '永遠の炎'), 1),
((SELECT id FROM crafting_recipes WHERE weapon_id = 209), (SELECT id FROM material_masters WHERE name = '終焉の金属'), 1);