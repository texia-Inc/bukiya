-- 素材データを追加し、レシピテーブルを再作成

-- 基本的な素材データを挿入
INSERT INTO material_masters (name, category, rarity_id, description, base_price, stack_size, emoji, color_code) VALUES
-- Common素材
('鉄鉱石', 'metal', 'common', '武器作成の基本素材', 10, 999, '🪨', '#8D6E63'),
('銅鉱石', 'metal', 'common', '青銅武器の材料', 8, 999, '🟫', '#FF5722'),
('木材', 'organic', 'common', '基本的な素材', 5, 999, '🪵', '#795548'),
('石材', 'mineral', 'common', '建材や武器の補強材', 3, 999, '🪨', '#607D8B'),
('強化石', 'magic', 'common', 'エンチャントに使用する基本的な魔法石', 100, 999, '💎', '#4169E1'),
('布', 'organic', 'common', '防具や装飾に使用', 12, 999, '🧵', '#FFC107'),
('革', 'organic', 'common', '防具や武器の柄に使用', 18, 500, '🟤', '#8D6E63'),
('糸', 'organic', 'common', '縫製に使用する基本素材', 6, 999, '🧵', '#E0E0E0'),

-- Rare素材
('銀鉱石', 'metal', 'rare', '高級武器の材料', 50, 500, '⚪', '#C0C0C0'),
('ミスリル鉱石', 'metal', 'rare', '軽量で強力な幻の金属', 200, 100, '✨', '#E6E6FA'),
('古代の木材', 'organic', 'rare', '何百年も経た硬い木材。魔法伝導性が高い', 400, 100, '🌳', '#228B22'),
('魔法石', 'magic', 'rare', '魔力を蓄えた宝石', 150, 200, '💎', '#9C27B0'),
('精霊石', 'magic', 'rare', '精霊の力を宿した宝石。属性付与に使用', 700, 50, '💎', '#FF69B4'),
('マナエッセンス', 'magic', 'rare', '純粋な魔力の結晶。エンチャントに使用', 600, 100, '💙', '#00BFFF'),
('龍の鱗', 'monster', 'rare', 'ドラゴンから採取した硬い鱗', 800, 50, '🐉', '#FF4500'),

-- Epic素材
('アダマンタイト', 'metal', 'epic', '最高級の金属素材', 1000, 50, '💎', '#4A4A4A'),
('星の欠片', 'cosmic', 'epic', '天から降ってきた隕石の破片', 3200, 15, '⭐', '#FFD700'),
('生命の樹液', 'divine', 'epic', '世界樹から採取された神聖な樹液', 2800, 25, '🌱', '#00FF00'),
('フェニックスの羽', 'monster', 'epic', '不死鳥の羽根。復活の力を持つ', 5000, 10, '🔥', '#FF6347'),

-- Legendary素材
('世界樹の心臓', 'divine', 'legendary', '世界樹の中心部から取れる究極の素材', 20000, 1, '💚', '#00FF00'),
('運命の糸', 'fate', 'legendary', '運命を紡ぐ神秘的な糸', 14000, 6, '🧵', '#9370DB'),
('創世の石', 'cosmic', 'legendary', '世界創造時の力を宿す石', 50000, 1, '🌌', '#4B0082'),
('竜王の心臓', 'monster', 'legendary', '伝説の竜王から得られる最高の素材', 100000, 1, '❤️', '#DC143C');

-- crafting_recipesテーブルを再作成（連番IDに対応）
CREATE TABLE crafting_recipes (
    id SERIAL PRIMARY KEY,
    weapon_id INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    gold_cost INTEGER DEFAULT 0 NOT NULL,
    success_rate FLOAT DEFAULT 1.0 NOT NULL,
    required_level INTEGER DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT crafting_recipes_gold_cost_check CHECK (gold_cost >= 0),
    CONSTRAINT crafting_recipes_success_rate_check CHECK (success_rate >= 0 AND success_rate <= 1),
    CONSTRAINT crafting_recipes_required_level_check CHECK (required_level >= 1),
    
    FOREIGN KEY (weapon_id) REFERENCES weapon_masters(id) ON DELETE CASCADE
);

-- recipe_materialsテーブルを再作成（連番IDに対応）
CREATE TABLE recipe_materials (
    recipe_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    
    PRIMARY KEY (recipe_id, material_id),
    FOREIGN KEY (recipe_id) REFERENCES crafting_recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES material_masters(id) ON DELETE CASCADE
);

-- 基本的なレシピデータを挿入
INSERT INTO crafting_recipes (weapon_id, name, description, gold_cost, success_rate, required_level) VALUES
-- 基本武器のレシピ（weapon_id 1-5を想定）
(1, 'アルケインスタッフのレシピ', '秘術の力を宿した杖を作成する神秘レシピ', 750, 0.85, 7),
(2, 'エルフの弓のレシピ', 'エルフの技術で作られた精密な弓を作成', 500, 0.9, 5),
(3, 'クリスタルスタッフのレシピ', '水晶の力を秘めた杖を作成する高度なレシピ', 1200, 0.75, 10),
(4, 'コスモススタッフのレシピ', '宇宙の力を宿した究極の杖を作成', 5000, 0.5, 15),
(5, 'ドラゴンスレイヤーのレシピ', '竜殺しの伝説的武器を作成する禁断のレシピ', 10000, 0.3, 20);

-- レシピの必要素材を挿入
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
-- アルケインスタッフ（recipe_id=1）
(1, 3, 2),   -- 古代の木材 x2
(1, 5, 5),   -- 強化石 x5
(1, 14, 5),  -- マナエッセンス x5
(1, 13, 3),  -- 精霊石 x3

-- エルフの弓（recipe_id=2）
(2, 3, 3),   -- 古代の木材 x3
(2, 1, 5),   -- 鉄鉱石 x5
(2, 6, 10),  -- 布 x10
(2, 8, 5),   -- 糸 x5

-- クリスタルスタッフ（recipe_id=3）
(3, 12, 3),  -- 魔法石 x3
(3, 14, 10), -- マナエッセンス x10
(3, 17, 2),  -- アダマンタイト x2
(3, 18, 3),  -- 星の欠片 x3

-- コスモススタッフ（recipe_id=4）
(4, 18, 8),  -- 星の欠片 x8
(4, 19, 5),  -- 生命の樹液 x5
(4, 22, 1),  -- 運命の糸 x1
(4, 21, 1),  -- 世界樹の心臓 x1

-- ドラゴンスレイヤー（recipe_id=5）
(5, 17, 10), -- アダマンタイト x10
(5, 15, 5),  -- 龍の鱗 x5
(5, 24, 1),  -- 竜王の心臓 x1
(5, 23, 2);  -- 創世の石 x2

-- インデックスを作成
CREATE INDEX idx_crafting_recipes_weapon ON crafting_recipes(weapon_id);
CREATE INDEX idx_crafting_recipes_active ON crafting_recipes(is_active) WHERE is_active = true;
CREATE INDEX idx_recipe_materials_recipe ON recipe_materials(recipe_id);
CREATE INDEX idx_recipe_materials_material ON recipe_materials(material_id);

-- 結果確認
SELECT 'material_masters' as table_name, COUNT(*) as count FROM material_masters
UNION ALL
SELECT 'weapon_masters' as table_name, COUNT(*) as count FROM weapon_masters
UNION ALL
SELECT 'crafting_recipes' as table_name, COUNT(*) as count FROM crafting_recipes
UNION ALL
SELECT 'recipe_materials' as table_name, COUNT(*) as count FROM recipe_materials;