-- ミッションテンプレートのサンプルデータ

-- 既存データをクリア
DELETE FROM mission_templates;

-- デイリーミッション
INSERT INTO mission_templates (name, description, mission_type, target_type, target_count, reward_gold, reward_exp, required_level, display_order, is_active, created_at, updated_at) VALUES
('武器を1個作成', '合成で武器を1個作成しよう', 'daily', 'craft_weapon', 1, 100, 50, 1, 1, true, NOW(), NOW()),
('武器を2個販売', '冒険者に武器を2個販売しよう', 'daily', 'sell_weapon', 2, 200, 75, 1, 2, true, NOW(), NOW()),
('500ゴールド獲得', '合計500ゴールドを獲得しよう', 'daily', 'earn_gold', 500, 150, 60, 1, 3, true, NOW(), NOW());

-- ウィークリーミッション
INSERT INTO mission_templates (name, description, mission_type, target_type, target_count, reward_gold, reward_exp, required_level, display_order, is_active, created_at, updated_at) VALUES
('武器を10個作成', '週間で武器を10個作成しよう', 'weekly', 'craft_weapon', 10, 1000, 500, 1, 1, true, NOW(), NOW()),
('武器を15個販売', '週間で武器を15個販売しよう', 'weekly', 'sell_weapon', 15, 1500, 750, 1, 2, true, NOW(), NOW()),
('5000ゴールド獲得', '週間で5000ゴールドを獲得しよう', 'weekly', 'earn_gold', 5000, 2000, 1000, 1, 3, true, NOW(), NOW());

-- アチーブメント
INSERT INTO mission_templates (name, description, mission_type, target_type, target_count, reward_gold, reward_exp, required_level, display_order, is_active, created_at, updated_at) VALUES
('初めての武器作成', '初めて武器を作成する', 'achievement', 'craft_weapon', 1, 500, 200, 1, 1, true, NOW(), NOW()),
('武器作成マスター', '武器を100個作成する', 'achievement', 'craft_weapon', 100, 10000, 5000, 1, 2, true, NOW(), NOW()),
('商売の天才', '武器を500個販売する', 'achievement', 'sell_weapon', 500, 25000, 10000, 5, 3, true, NOW(), NOW()),
('大富豪', '合計100,000ゴールドを獲得する', 'achievement', 'earn_gold', 100000, 50000, 20000, 10, 4, true, NOW(), NOW());