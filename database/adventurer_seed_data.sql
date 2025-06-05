-- 冒険者マスターデータの投入

-- 既存のデータをクリア（開発用）
TRUNCATE TABLE adventurer_masters CASCADE;
TRUNCATE TABLE quest_area_masters CASCADE;

-- 冒険者マスターデータ
INSERT INTO adventurer_masters (
    name, profession, level, personality, trust_level, 
    budget_min, budget_max, preferred_weapon_type, 
    description, min_attack_requirement, max_budget_multiplier, 
    urgency_tendency, spawn_weight, min_player_level, max_player_level, 
    is_active, created_at, updated_at
) VALUES
-- 初心者向け冒険者
('新米剣士アレン', 'warrior', 5, 'friendly', 30, 
 500, 1500, 'sword', 
 '冒険を始めたばかりの熱血剣士。安くて使いやすい武器を求めている。', 
 50, 1.5, 2, 30, 1, 10, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('見習い弓使いリリー', 'archer', 6, 'stingy', 20, 
 400, 1200, 'bow', 
 'お金に厳しい見習い弓使い。値切り交渉が得意。', 
 60, 1.2, 1, 25, 1, 10, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('駆け出し魔法使いミナ', 'mage', 7, 'normal', 25, 
 600, 1800, 'staff', 
 '魔法学院の生徒。そこそこの杖を探している。', 
 70, 1.3, 3, 25, 1, 15, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 中級者向け冒険者
('熟練戦士ガルド', 'warrior', 15, 'normal', 50, 
 1500, 5000, 'sword', 
 '経験豊富な戦士。品質の良い武器には相応の金額を払う。', 
 150, 2.0, 3, 20, 10, 25, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('狩人マスターエリオット', 'archer', 18, 'generous', 60, 
 2000, 6000, 'bow', 
 '気前の良い狩人。良い弓には惜しみなく金を出す。', 
 180, 2.5, 2, 20, 10, 30, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('大魔道士セレナ', 'mage', 20, 'normal', 55, 
 2500, 8000, 'staff', 
 '高位の魔法使い。強力な杖を求めている。', 
 200, 2.2, 4, 15, 15, 35, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

-- 上級者向け冒険者
('英雄ローランド', 'warrior', 30, 'generous', 80, 
 5000, 20000, 'sword', 
 '伝説の英雄。最高級の武器のみを求める。', 
 300, 3.0, 4, 10, 25, 50, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('影の暗殺者シャドウ', 'thief', 28, 'stingy', 40, 
 3000, 15000, 'dagger', 
 '謎多き暗殺者。短剣の品質にはうるさい。', 
 250, 1.8, 5, 10, 20, 45, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('竜騎士アーサー', 'warrior', 35, 'normal', 70, 
 8000, 30000, 'axe', 
 '竜と共に戦う騎士。巨大な武器を好む。', 
 400, 2.5, 3, 5, 30, NULL, 
 true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- クエストエリアマスターデータ
INSERT INTO quest_area_masters (
    name, area_type, difficulty, required_level, duration_minutes,
    background_color, description, display_order, is_active,
    created_at, updated_at
) VALUES
('始まりの森', 'forest', 1, 1, 30,
 '#228B22', '初心者向けの安全な森。基本的な素材が手に入る。', 1, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('風の草原', 'plain', 1, 3, 45,
 '#90EE90', '広大な草原地帯。様々な動物が生息している。', 2, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('古の洞窟', 'cave', 2, 5, 60,
 '#696969', '鉱石が豊富な洞窟。暗闇に潜む危険もある。', 3, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('霧の湿地', 'swamp', 2, 8, 75,
 '#556B2F', '毒を持つ生物が多い危険な湿地帯。', 4, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('灼熱の砂漠', 'desert', 3, 10, 90,
 '#DEB887', '過酷な環境の砂漠。レアな素材が眠っている。', 5, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('氷結の山脈', 'mountain', 3, 15, 120,
 '#87CEEB', '極寒の山岳地帯。氷属性の素材が豊富。', 6, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('魔境の森', 'dark_forest', 4, 20, 150,
 '#2F4F4F', '魔物が蠢く危険な森。高級素材の宝庫。', 7, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

('竜の谷', 'valley', 5, 30, 240,
 '#8B0000', '伝説の竜が住むという谷。最高級の素材が手に入る。', 8, true,
 CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);