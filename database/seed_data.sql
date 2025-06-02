-- 武器屋放置ゲーム 初期データ投入
-- MVPに必要な基本マスタデータ

-- ============================================
-- 1. 武器種の初期データ
-- ============================================
INSERT INTO weapon_types (id, name, emoji, description, base_multiplier, attack_speed_modifier, critical_rate_bonus, display_order) VALUES
('sword', '剣', '⚔️', 'バランスの取れた近接武器', 1.00, 1.00, 0, 1),
('bow', '弓', '🏹', '遠距離攻撃に特化した武器', 0.90, 1.20, 10, 2),
('staff', '杖', '🪄', '魔法攻撃に特化した武器', 0.80, 0.90, 0, 3);

-- ============================================
-- 2. レア度の初期データ
-- ============================================
INSERT INTO rarity_levels (id, name, level, color_code, star_display, attack_multiplier, max_enchant_level, ability_slots, base_drop_rate, price_multiplier) VALUES
('common', 'Common', 1, '#808080', '★☆☆☆☆', 1.00, 10, 0, 0.6000, 1.00),
('rare', 'Rare', 2, '#0080FF', '★★☆☆☆', 1.25, 15, 1, 0.2500, 2.50),
('epic', 'Epic', 3, '#8040FF', '★★★☆☆', 1.50, 20, 2, 0.1000, 5.00);

-- ============================================
-- 3. 属性の初期データ（MVPでは使用しないが将来拡張用）
-- ============================================
INSERT INTO attributes (id, name, emoji, color_code, damage_bonus, effect_description, effective_against, weak_against) VALUES
('fire', '火', '🔥', '#FF4500', 15, '火属性ダメージを追加', ARRAY['ice', 'plant'], ARRAY['water', 'earth']),
('ice', '氷', '❄️', '#00BFFF', 10, '氷属性ダメージを追加', ARRAY['fire', 'earth'], ARRAY['fire']),
('lightning', '雷', '⚡', '#FFD700', 20, '雷属性ダメージを追加', ARRAY['water', 'metal'], ARRAY['earth']);

-- ============================================
-- 4. エリアの初期データ
-- ============================================
INSERT INTO area_masters (id, name, description, required_shop_level, required_adventurer_level, base_expedition_time_minutes, danger_level, theme_color, display_order) VALUES
('forest', '森林', '初心者向けの平和な森林エリア', 1, 1, 60, 1, '#228B22', 1),
('cave', '洞窟', '中級者向けの薄暗い洞窟エリア', 5, 10, 120, 3, '#696969', 2),
('mountain', '山岳', '上級者向けの険しい山岳エリア', 10, 20, 240, 5, '#8B4513', 3);

-- ============================================
-- 5. 基本アビリティ（MVPでは簡略化）
-- ============================================
INSERT INTO abilities (id, name, description, effect_type, effect_value, effect_percentage, required_weapon_types, required_rarity_level, rarity) VALUES
('attack_boost_small', '攻撃力上昇（小）', '攻撃力を5%上昇させる', 'attack_bonus', 5, true, ARRAY['sword', 'bow', 'staff'], 1, 'common'),
('critical_boost', 'クリティカル率上昇', 'クリティカル率を10%上昇させる', 'critical_rate', 10, true, ARRAY['sword', 'bow'], 2, 'rare'),
('fire_damage', '火炎ダメージ', '攻撃時に追加火属性ダメージ', 'special_effect', 25, false, ARRAY['sword', 'staff'], 2, 'rare');

-- ============================================
-- 6. 素材マスタ（MVP用基本素材）
-- ============================================
INSERT INTO material_masters (id, name, category, rarity_id, description, base_price, price_volatility, stack_size, emoji, color_code) VALUES
-- 基本素材
('iron_ore', '鉄鉱石', 'basic', 'common', '武器作成の基本素材', 50, 0.1, 999, '⛏️', '#C0C0C0'),
('copper_ore', '銅鉱石', 'basic', 'common', '初級武器の材料', 30, 0.1, 999, '🟫', '#B87333'),
('wood', '木材', 'basic', 'common', '弓や杖の材料', 20, 0.1, 999, '🪵', '#8B4513'),
('stone', '石材', 'basic', 'common', '基礎的な建材', 15, 0.1, 999, '🪨', '#808080'),
('enhancement_stone', '強化石', 'magic', 'common', 'エンチャントに使用する石', 100, 0.2, 999, '💎', '#4169E1'),

-- 中級素材
('silver_ore', '銀鉱石', 'basic', 'rare', '中級武器の材料', 200, 0.15, 999, '⚪', '#C0C0C0'),
('magic_crystal', '魔法石', 'magic', 'rare', '魔法武器の核となる石', 500, 0.2, 999, '🔮', '#9370DB'),
('rare_ore', 'レア鉱石', 'rare', 'rare', '希少な鉱石', 800, 0.25, 999, '💠', '#FF6347'),

-- 上級素材
('gold_ore', '金鉱石', 'basic', 'epic', '最高級武器の材料', 1500, 0.3, 999, '🟨', '#FFD700'),
('ancient_stone', '古代石', 'special', 'epic', '古代の力を宿した石', 3000, 0.4, 999, '🗿', '#8A2BE2');

-- ============================================
-- 7. 武器マスタ（MVP用基本武器）
-- ============================================

-- Common 剣
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('iron_sword_common', '鉄の剣', 'sword', 'common', 50, 80, 200, 300, 5, 1, '基本的な鉄製の剣'),
('steel_sword_common', '鋼の剣', 'sword', 'common', 80, 120, 400, 600, 10, 2, '鋼で作られた丈夫な剣'),
('knight_sword_common', '騎士の剣', 'sword', 'common', 100, 150, 600, 900, 15, 3, '騎士が愛用する剣');

-- Common 弓
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('wooden_bow_common', '木の弓', 'bow', 'common', 45, 75, 180, 270, 5, 1, '木製の基本的な弓'),
('hunter_bow_common', 'ハンターボウ', 'bow', 'common', 75, 110, 360, 540, 10, 2, '狩人が使う実用的な弓'),
('longbow_common', 'ロングボウ', 'bow', 'common', 90, 135, 540, 810, 15, 3, '長距離射撃に適した弓');

-- Common 杖
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('wooden_staff_common', '木の杖', 'staff', 'common', 40, 70, 160, 240, 5, 1, '木製の基本的な杖'),
('mage_staff_common', '魔法使いの杖', 'staff', 'common', 70, 100, 320, 480, 10, 2, '魔法使いが愛用する杖'),
('crystal_staff_common', 'クリスタルスタッフ', 'staff', 'common', 85, 125, 480, 720, 15, 3, '水晶を埋め込んだ杖');

-- Rare 剣
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('silver_sword_rare', '銀の剣', 'sword', 'rare', 120, 200, 1000, 1500, 30, 5, '銀で作られた美しい剣'),
('magic_sword_rare', 'マジックソード', 'sword', 'rare', 180, 280, 1800, 2700, 45, 7, '魔法の力を宿した剣'),
('blessed_sword_rare', '祝福の剣', 'sword', 'rare', 220, 320, 2500, 3750, 60, 8, '聖なる力で祝福された剣');

-- Rare 弓
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('silver_bow_rare', '銀の弓', 'bow', 'rare', 110, 180, 900, 1350, 30, 5, '銀で装飾された美しい弓'),
('magic_bow_rare', 'マジックボウ', 'bow', 'rare', 160, 250, 1600, 2400, 45, 7, '魔法の矢を放つ弓'),
('elven_bow_rare', 'エルフの弓', 'bow', 'rare', 200, 290, 2250, 3375, 60, 8, 'エルフの技術で作られた弓');

-- Rare 杖
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('silver_staff_rare', '銀の杖', 'staff', 'rare', 100, 160, 800, 1200, 30, 5, '銀で装飾された杖'),
('arcane_staff_rare', 'アルケインスタッフ', 'staff', 'rare', 150, 230, 1500, 2250, 45, 7, '秘術の力を宿した杖'),
('wisdom_staff_rare', '賢者の杖', 'staff', 'rare', 180, 270, 2000, 3000, 60, 8, '賢者が愛用した杖');

-- Epic 剣
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('flame_sword_epic', '炎の剣', 'sword', 'epic', 350, 450, 8000, 12000, 120, 10, '炎の力を宿した伝説の剣'),
('dragon_slayer_epic', 'ドラゴンスレイヤー', 'sword', 'epic', 400, 550, 12000, 18000, 180, 12, 'ドラゴンを倒すために作られた剣');

-- Epic 弓
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('storm_bow_epic', '嵐の弓', 'bow', 'epic', 320, 420, 7200, 10800, 120, 10, '嵐の力を宿した弓'),
('phoenix_bow_epic', 'フェニックスボウ', 'bow', 'epic', 380, 500, 11400, 17100, 180, 12, '不死鳥の力を宿した弓');

-- Epic 杖
INSERT INTO weapon_masters (id, name, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, crafting_time_minutes, required_shop_level, description) VALUES
('archmage_staff_epic', '大魔法使いの杖', 'staff', 'epic', 300, 400, 6400, 9600, 120, 10, '大魔法使いが使った伝説の杖'),
('cosmos_staff_epic', 'コスモススタッフ', 'staff', 'epic', 360, 480, 10800, 16200, 180, 12, '宇宙の力を宿した杖');

-- ============================================
-- 8. 合成レシピ（MVP用基本レシピ）
-- ============================================

-- Common 武器レシピ
INSERT INTO crafting_recipes (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level) VALUES
('recipe_iron_sword', 'iron_sword_common', 1.0000, 5, 100, 1),
('recipe_steel_sword', 'steel_sword_common', 1.0000, 10, 200, 2),
('recipe_knight_sword', 'knight_sword_common', 1.0000, 15, 300, 3),
('recipe_wooden_bow', 'wooden_bow_common', 1.0000, 5, 90, 1),
('recipe_hunter_bow', 'hunter_bow_common', 1.0000, 10, 180, 2),
('recipe_longbow', 'longbow_common', 1.0000, 15, 270, 3),
('recipe_wooden_staff', 'wooden_staff_common', 1.0000, 5, 80, 1),
('recipe_mage_staff', 'mage_staff_common', 1.0000, 10, 160, 2),
('recipe_crystal_staff', 'crystal_staff_common', 1.0000, 15, 240, 3);

-- Rare 武器レシピ
INSERT INTO crafting_recipes (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level) VALUES
('recipe_silver_sword', 'silver_sword_rare', 0.9000, 30, 500, 5),
('recipe_magic_sword', 'magic_sword_rare', 0.8500, 45, 900, 7),
('recipe_blessed_sword', 'blessed_sword_rare', 0.8000, 60, 1250, 8),
('recipe_silver_bow', 'silver_bow_rare', 0.9000, 30, 450, 5),
('recipe_magic_bow', 'magic_bow_rare', 0.8500, 45, 800, 7),
('recipe_elven_bow', 'elven_bow_rare', 0.8000, 60, 1125, 8),
('recipe_silver_staff', 'silver_staff_rare', 0.9000, 30, 400, 5),
('recipe_arcane_staff', 'arcane_staff_rare', 0.8500, 45, 750, 7),
('recipe_wisdom_staff', 'wisdom_staff_rare', 0.8000, 60, 1000, 8);

-- Epic 武器レシピ
INSERT INTO crafting_recipes (id, result_weapon_master_id, success_rate, crafting_time_minutes, required_gold, required_shop_level) VALUES
('recipe_flame_sword', 'flame_sword_epic', 0.7000, 120, 4000, 10),
('recipe_dragon_slayer', 'dragon_slayer_epic', 0.6000, 180, 6000, 12),
('recipe_storm_bow', 'storm_bow_epic', 0.7000, 120, 3600, 10),
('recipe_phoenix_bow', 'phoenix_bow_epic', 0.6000, 180, 5700, 12),
('recipe_archmage_staff', 'archmage_staff_epic', 0.7000, 120, 3200, 10),
('recipe_cosmos_staff', 'cosmos_staff_epic', 0.6000, 180, 5400, 12);

-- ============================================
-- 9. レシピ必要素材
-- ============================================

-- Common 剣レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_iron_sword', 'iron_ore', 3),
('recipe_iron_sword', 'wood', 1),
('recipe_steel_sword', 'iron_ore', 5),
('recipe_steel_sword', 'copper_ore', 2),
('recipe_knight_sword', 'iron_ore', 7),
('recipe_knight_sword', 'silver_ore', 1);

-- Common 弓レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_wooden_bow', 'wood', 4),
('recipe_wooden_bow', 'stone', 2),
('recipe_hunter_bow', 'wood', 6),
('recipe_hunter_bow', 'iron_ore', 2),
('recipe_longbow', 'wood', 8),
('recipe_longbow', 'silver_ore', 1);

-- Common 杖レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_wooden_staff', 'wood', 3),
('recipe_wooden_staff', 'stone', 3),
('recipe_mage_staff', 'wood', 5),
('recipe_mage_staff', 'magic_crystal', 1),
('recipe_crystal_staff', 'wood', 6),
('recipe_crystal_staff', 'magic_crystal', 2);

-- Rare 剣レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_silver_sword', 'silver_ore', 5),
('recipe_silver_sword', 'iron_ore', 3),
('recipe_magic_sword', 'silver_ore', 4),
('recipe_magic_sword', 'magic_crystal', 3),
('recipe_blessed_sword', 'silver_ore', 6),
('recipe_blessed_sword', 'rare_ore', 2);

-- Rare 弓レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_silver_bow', 'silver_ore', 4),
('recipe_silver_bow', 'wood', 8),
('recipe_magic_bow', 'silver_ore', 3),
('recipe_magic_bow', 'magic_crystal', 4),
('recipe_elven_bow', 'silver_ore', 5),
('recipe_elven_bow', 'rare_ore', 3);

-- Rare 杖レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_silver_staff', 'silver_ore', 3),
('recipe_silver_staff', 'magic_crystal', 3),
('recipe_arcane_staff', 'silver_ore', 2),
('recipe_arcane_staff', 'magic_crystal', 5),
('recipe_wisdom_staff', 'silver_ore', 4),
('recipe_wisdom_staff', 'rare_ore', 4);

-- Epic 武器レシピ
INSERT INTO recipe_materials (recipe_id, material_master_id, quantity) VALUES
('recipe_flame_sword', 'gold_ore', 5),
('recipe_flame_sword', 'rare_ore', 8),
('recipe_flame_sword', 'ancient_stone', 2),
('recipe_dragon_slayer', 'gold_ore', 8),
('recipe_dragon_slayer', 'rare_ore', 12),
('recipe_dragon_slayer', 'ancient_stone', 3),
('recipe_storm_bow', 'gold_ore', 4),
('recipe_storm_bow', 'rare_ore', 10),
('recipe_storm_bow', 'ancient_stone', 2),
('recipe_phoenix_bow', 'gold_ore', 7),
('recipe_phoenix_bow', 'rare_ore', 15),
('recipe_phoenix_bow', 'ancient_stone', 3),
('recipe_archmage_staff', 'gold_ore', 3),
('recipe_archmage_staff', 'magic_crystal', 12),
('recipe_archmage_staff', 'ancient_stone', 2),
('recipe_cosmos_staff', 'gold_ore', 6),
('recipe_cosmos_staff', 'magic_crystal', 18),
('recipe_cosmos_staff', 'ancient_stone', 3);

-- ============================================
-- 10. モンスターマスタ（MVP用基本モンスター）
-- ============================================
INSERT INTO monster_masters (id, name, hp, attack, defense, level_min, level_max, base_success_rate, emoji, description, area_id, spawn_rate) VALUES
-- 森林エリア（初級）
('slime', 'スライム', 50, 20, 5, 1, 5, 0.9000, '🟢', '森に住む平和なスライム', 'forest', 0.4000),
('goblin', 'ゴブリン', 80, 35, 10, 3, 8, 0.8500, '👹', '小さいが狡猾な緑の怪物', 'forest', 0.3000),
('wolf', 'ウルフ', 120, 50, 15, 5, 12, 0.8000, '🐺', '森の王者である野生の狼', 'forest', 0.2000),

-- 洞窟エリア（中級）
('orc', 'オーク', 200, 80, 25, 10, 18, 0.7500, '👺', '洞窟に住む凶暴な戦士', 'cave', 0.3500),
('troll', 'トロール', 350, 120, 40, 15, 25, 0.7000, '🧌', '巨大で力強い洞窟の番人', 'cave', 0.2000),

-- 山岳エリア（上級）
('dragon_whelp', 'ドラゴンの幼体', 500, 180, 60, 20, 35, 0.6000, '🐲', '成長途中の若いドラゴン', 'mountain', 0.1500);

-- ============================================
-- 11. ドロップテーブル
-- ============================================

-- スライムのドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('slime', 'material', 'iron_ore', 1, 2, 0.6000),
('slime', 'material', 'copper_ore', 1, 3, 0.4000),
('slime', 'gold', NULL, 10, 30, 0.8000);

-- ゴブリンのドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('goblin', 'material', 'iron_ore', 2, 4, 0.5000),
('goblin', 'material', 'wood', 1, 3, 0.6000),
('goblin', 'material', 'enhancement_stone', 1, 1, 0.2000),
('goblin', 'gold', NULL, 20, 60, 0.9000);

-- ウルフのドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('wolf', 'material', 'iron_ore', 3, 6, 0.4000),
('wolf', 'material', 'silver_ore', 1, 2, 0.3000),
('wolf', 'material', 'enhancement_stone', 1, 2, 0.4000),
('wolf', 'gold', NULL, 40, 100, 0.9500);

-- オークのドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('orc', 'material', 'silver_ore', 2, 4, 0.5000),
('orc', 'material', 'magic_crystal', 1, 2, 0.3000),
('orc', 'material', 'rare_ore', 1, 1, 0.1500),
('orc', 'gold', NULL, 80, 200, 0.9500);

-- トロールのドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('troll', 'material', 'silver_ore', 3, 6, 0.6000),
('troll', 'material', 'magic_crystal', 2, 4, 0.4000),
('troll', 'material', 'rare_ore', 1, 2, 0.2500),
('troll', 'gold', NULL, 150, 350, 0.9500);

-- ドラゴンの幼体のドロップ
INSERT INTO monster_drop_tables (monster_master_id, drop_type, drop_target_id, quantity_min, quantity_max, drop_rate) VALUES
('dragon_whelp', 'material', 'gold_ore', 1, 3, 0.4000),
('dragon_whelp', 'material', 'rare_ore', 2, 5, 0.6000),
('dragon_whelp', 'material', 'ancient_stone', 1, 1, 0.2000),
('dragon_whelp', 'gold', NULL, 300, 800, 0.9500);

-- ============================================
-- 12. 冒険者マスタ（MVP用基本冒険者）
-- ============================================
INSERT INTO adventurer_masters (id, name, class, level_min, level_max, preferred_weapon_types, budget_min, budget_max, personality, haggle_skill, trust_base, description, spawn_rate, visit_frequency_hours) VALUES
('warrior_rick', '戦士リック', 'warrior', 1, 30, ARRAY['sword'], 500, 3000, 'cautious', 60, 50, '慎重な性格の若い戦士', 0.2000, 4),
('archer_anna', '弓使いアンナ', 'archer', 1, 25, ARRAY['bow'], 400, 2500, 'bold', 70, 55, '大胆で活発な弓使い', 0.2000, 5),
('mage_elena', '魔法使いエリナ', 'mage', 1, 35, ARRAY['staff'], 600, 4000, 'generous', 40, 60, '寛大で知的な魔法使い', 0.1500, 6),
('rogue_jack', '盗賊ジャック', 'rogue', 5, 20, ARRAY['sword', 'bow'], 300, 2000, 'cheap', 85, 40, 'ケチで狡猾な盗賊', 0.2500, 3),
('paladin_marcus', '聖騎士マーカス', 'paladin', 10, 40, ARRAY['sword'], 1000, 6000, 'generous', 50, 70, '正義感の強い聖騎士', 0.1000, 8);

-- ============================================
-- 13. 管理者用テストプレイヤー作成
-- ============================================
INSERT INTO players (id, username, email, password_hash, gold, gems, shop_level, reputation) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'admin_test', 'admin@bukiya.local', '$2b$12$LQv3c1yqBwEFxDcTxOQxqOeDAOGNcqxvA/j2d1Xa.6adc4a4Gqbuy', 10000, 500, 5, 50);

-- テストプレイヤーの統計初期化
INSERT INTO player_statistics (player_id) VALUES
('550e8400-e29b-41d4-a716-446655440000');

-- テストプレイヤーに基本素材を付与
INSERT INTO player_materials (player_id, material_master_id, quantity, total_acquired) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'iron_ore', 50, 50),
('550e8400-e29b-41d4-a716-446655440000', 'copper_ore', 30, 30),
('550e8400-e29b-41d4-a
