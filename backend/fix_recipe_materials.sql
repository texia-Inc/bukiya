-- レシピ素材の正しいIDで挿入

-- 既存のrecipe_materialsデータをクリア
DELETE FROM recipe_materials;

-- レシピの必要素材を正しいIDで挿入
INSERT INTO recipe_materials (recipe_id, material_id, quantity) VALUES
-- アルケインスタッフ（recipe_id=1）
(1, 11, 2),  -- 古代の木材 x2
(1, 5, 5),   -- 強化石 x5
(1, 14, 5),  -- マナエッセンス x5
(1, 13, 3),  -- 精霊石 x3

-- エルフの弓（recipe_id=2）
(2, 11, 3),  -- 古代の木材 x3
(2, 1, 5),   -- 鉄鉱石 x5
(2, 6, 10),  -- 布 x10
(2, 8, 5),   -- 糸 x5

-- クリスタルスタッフ（recipe_id=3）
(3, 12, 3),  -- 魔法石 x3
(3, 14, 10), -- マナエッセンス x10
(3, 16, 2),  -- アダマンタイト x2
(3, 17, 3),  -- 星の欠片 x3

-- コスモススタッフ（recipe_id=4）
(4, 17, 8),  -- 星の欠片 x8
(4, 18, 5),  -- 生命の樹液 x5
(4, 21, 1),  -- 運命の糸 x1
(4, 20, 1),  -- 世界樹の心臓 x1

-- ドラゴンスレイヤー（recipe_id=5）
(5, 16, 10), -- アダマンタイト x10
(5, 15, 5),  -- 龍の鱗 x5
(5, 23, 1),  -- 竜王の心臓 x1
(5, 22, 2);  -- 創世の石 x2

-- 結果確認
SELECT 'recipe_materials' as table_name, COUNT(*) as count FROM recipe_materials;