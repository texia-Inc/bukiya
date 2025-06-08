-- Fix recipe materials for remaining recipes
-- 重複エラーを避けるため、recipe_idを直接指定

-- Clear any existing recipe materials first (optional - for clean slate)
DELETE FROM recipe_materials WHERE recipe_id >= 3;

-- === RARE WEAPON MATERIALS ===

-- シルバーソード (recipe_id: 3) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(3, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 3),
(3, (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 2),
(3, (SELECT id FROM material_masters WHERE name = '象牙' LIMIT 1), 1),
(3, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2);

-- クリスタルソード (recipe_id: 4) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(4, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 2),
(4, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(4, (SELECT id FROM material_masters WHERE name = '妖精の粉' LIMIT 1), 1),
(4, (SELECT id FROM material_masters WHERE name = 'プラチナ鉱石' LIMIT 1), 1);

-- カタナ (recipe_id: 5) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(5, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 4),
(5, (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 5),
(5, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2),
(5, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 3);

-- アイスブレード (recipe_id: 6) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(6, (SELECT id FROM material_masters WHERE name = '氷の結晶' LIMIT 1), 3),
(6, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(6, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(6, (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 2);

-- エルヴンボウ (recipe_id: 7) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(7, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 3),
(7, (SELECT id FROM material_masters WHERE name = '精霊の羽' LIMIT 1), 2),
(7, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 4),
(7, (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 1);

-- ウィンドボウ (recipe_id: 8) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(8, (SELECT id FROM material_masters WHERE name = '風の羽根' LIMIT 1), 3),
(8, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2),
(8, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(8, (SELECT id FROM material_masters WHERE name = '妖精の粉' LIMIT 1), 2);

-- リカーブボウ (recipe_id: 9) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(9, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 3),
(9, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 2),
(9, (SELECT id FROM material_masters WHERE name = '動物の毛皮' LIMIT 1), 2),
(9, (SELECT id FROM material_masters WHERE name = '蜘蛛の糸' LIMIT 1), 5);

-- ファイアスタッフ (recipe_id: 10) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(10, (SELECT id FROM material_masters WHERE name = '炎の石' LIMIT 1), 2),
(10, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(10, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(10, (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 3);

-- アイススタッフ (recipe_id: 11) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(11, (SELECT id FROM material_masters WHERE name = '氷の結晶' LIMIT 1), 2),
(11, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(11, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(11, (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 1);

-- サンダースタッフ (recipe_id: 12) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(12, (SELECT id FROM material_masters WHERE name = '雷の欠片' LIMIT 1), 2),
(12, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 1),
(12, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(12, (SELECT id FROM material_masters WHERE name = '水銀' LIMIT 1), 1);

-- フレイムダガー (recipe_id: 13) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(13, (SELECT id FROM material_masters WHERE name = '炎の石' LIMIT 1), 1),
(13, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(13, (SELECT id FROM material_masters WHERE name = '麻紐' LIMIT 1), 2),
(13, (SELECT id FROM material_masters WHERE name = '炭' LIMIT 1), 2);

-- クリスタルダガー (recipe_id: 14) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(14, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(14, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(14, (SELECT id FROM material_masters WHERE name = '妖精の粉' LIMIT 1), 1),
(14, (SELECT id FROM material_masters WHERE name = '麻紐' LIMIT 1), 1);

-- ルーンダガー (recipe_id: 15) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(15, (SELECT id FROM material_masters WHERE name = '魔法の水晶' LIMIT 1), 1),
(15, (SELECT id FROM material_masters WHERE name = '象牙' LIMIT 1), 1),
(15, (SELECT id FROM material_masters WHERE name = '鋼鉄塊' LIMIT 1), 1),
(15, (SELECT id FROM material_masters WHERE name = '深海の真珠' LIMIT 1), 1);

-- === EPIC WEAPON MATERIALS ===

-- フレイムブレード (recipe_id: 19) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(19, (SELECT id FROM material_masters WHERE name = '永遠の炎' LIMIT 1), 1),
(19, (SELECT id FROM material_masters WHERE name = 'アダマンタイト鉱石' LIMIT 1), 2),
(19, (SELECT id FROM material_masters WHERE name = '炎の石' LIMIT 1), 3),
(19, (SELECT id FROM material_masters WHERE name = '鍛冶師の魂' LIMIT 1), 1);

-- ドラゴンスレイヤー (recipe_id: 20) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(20, (SELECT id FROM material_masters WHERE name = '古龍の心臓' LIMIT 1), 1),
(20, (SELECT id FROM material_masters WHERE name = '純白の金属' LIMIT 1), 2),
(20, (SELECT id FROM material_masters WHERE name = 'ドラゴンの鱗' LIMIT 1), 3),
(20, (SELECT id FROM material_masters WHERE name = '戦士の誇り' LIMIT 1), 1);

-- ダマスカスブレード (recipe_id: 21) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(21, (SELECT id FROM material_masters WHERE name = '鍛冶師の魂' LIMIT 1), 1),
(21, (SELECT id FROM material_masters WHERE name = 'アダマンタイト鉱石' LIMIT 1), 3),
(21, (SELECT id FROM material_masters WHERE name = '時の砂' LIMIT 1), 2),
(21, (SELECT id FROM material_masters WHERE name = '光の欠片' LIMIT 1), 1);

-- デモンスレイヤー (recipe_id: 22) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(22, (SELECT id FROM material_masters WHERE name = '聖騎士の光' LIMIT 1), 1),
(22, (SELECT id FROM material_masters WHERE name = '純白の金属' LIMIT 1), 2),
(22, (SELECT id FROM material_masters WHERE name = '聖なる水' LIMIT 1), 5),
(22, (SELECT id FROM material_masters WHERE name = '悪魔の角' LIMIT 1), 1);

-- フレイムボウ (recipe_id: 23) materials  
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(23, (SELECT id FROM material_masters WHERE name = '永遠の炎' LIMIT 1), 1),
(23, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 3),
(23, (SELECT id FROM material_masters WHERE name = '炎の石' LIMIT 1), 2),
(23, (SELECT id FROM material_masters WHERE name = 'フェニックスの羽' LIMIT 1), 1);

-- サンダーボウ (recipe_id: 24) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(24, (SELECT id FROM material_masters WHERE name = '雷の欠片' LIMIT 1), 3),
(24, (SELECT id FROM material_masters WHERE name = '星霊の涙' LIMIT 1), 1),
(24, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2),
(24, (SELECT id FROM material_masters WHERE name = '星の金属' LIMIT 1), 1);

-- シャドウボウ (recipe_id: 25) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(25, (SELECT id FROM material_masters WHERE name = '盗賊の影' LIMIT 1), 1),
(25, (SELECT id FROM material_masters WHERE name = '虚空の破片' LIMIT 1), 1),
(25, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2),
(25, (SELECT id FROM material_masters WHERE name = '深淵の水' LIMIT 1), 2);

-- === LEGENDARY WEAPON MATERIALS ===

-- エクスカリバー (recipe_id: 35) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(35, (SELECT id FROM material_masters WHERE name = '創世の欠片' LIMIT 1), 1),
(35, (SELECT id FROM material_masters WHERE name = '神の血' LIMIT 1), 1),
(35, (SELECT id FROM material_masters WHERE name = '真理の結晶' LIMIT 1), 1),
(35, (SELECT id FROM material_masters WHERE name = '聖騎士の光' LIMIT 1), 2),
(35, (SELECT id FROM material_masters WHERE name = '完璧の象徴' LIMIT 1), 1);

-- ミスリルソード (recipe_id: 36) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(36, (SELECT id FROM material_masters WHERE name = '真理の結晶' LIMIT 1), 1),
(36, (SELECT id FROM material_masters WHERE name = '運命の糸' LIMIT 1), 2),
(36, (SELECT id FROM material_masters WHERE name = 'ミスリル鉱石' LIMIT 1), 3),
(36, (SELECT id FROM material_masters WHERE name = '魔導師の知恵' LIMIT 1), 1);

-- ヴォイドブレード (recipe_id: 37) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(37, (SELECT id FROM material_masters WHERE name = '虚空の破片' LIMIT 1), 2),
(37, (SELECT id FROM material_masters WHERE name = '終焉の金属' LIMIT 1), 1),
(37, (SELECT id FROM material_masters WHERE name = '深淵の水' LIMIT 1), 3),
(37, (SELECT id FROM material_masters WHERE name = '創世の欠片' LIMIT 1), 1);

-- ドラゴンボウ (recipe_id: 38) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(38, (SELECT id FROM material_masters WHERE name = '古龍の心臓' LIMIT 1), 1),
(38, (SELECT id FROM material_masters WHERE name = 'フェニックスの羽' LIMIT 1), 2),
(38, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 3),
(38, (SELECT id FROM material_masters WHERE name = 'ドラゴンの鱗' LIMIT 1), 2);

-- フェニックスボウ (recipe_id: 39) materials
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(39, (SELECT id FROM material_masters WHERE name = 'フェニックスの羽' LIMIT 1), 3),
(39, (SELECT id FROM material_masters WHERE name = '永遠の炎' LIMIT 1), 1),
(39, (SELECT id FROM material_masters WHERE name = '生命の樹液' LIMIT 1), 2),
(39, (SELECT id FROM material_masters WHERE name = '古代の木材' LIMIT 1), 2);

-- ゴッドハンマー (recipe_id: 49) materials - Ultimate recipe
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
(49, (SELECT id FROM material_masters WHERE name = '神の血' LIMIT 1), 2),
(49, (SELECT id FROM material_masters WHERE name = '完璧の象徴' LIMIT 1), 1),
(49, (SELECT id FROM material_masters WHERE name = '創世の欠片' LIMIT 1), 2),
(49, (SELECT id FROM material_masters WHERE name = '真理の結晶' LIMIT 1), 3),
(49, (SELECT id FROM material_masters WHERE name = '永遠の炎' LIMIT 1), 1),
(49, (SELECT id FROM material_masters WHERE name = '終焉の金属' LIMIT 1), 1);