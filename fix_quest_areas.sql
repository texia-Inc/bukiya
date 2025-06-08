-- クエストエリアテーブル修正スクリプト
-- このスクリプトを実行してquest_area_mastersテーブルを作成し、データを投入します

-- クエストエリアマスターテーブル
CREATE TABLE IF NOT EXISTS quest_area_masters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    area_type VARCHAR(50) NOT NULL,
    difficulty INTEGER NOT NULL DEFAULT 1,
    required_level INTEGER NOT NULL DEFAULT 1,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    image_url VARCHAR(255),
    background_color VARCHAR(7) NOT NULL DEFAULT '#4CAF50',
    description TEXT,
    unlock_condition VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 更新トリガー関数（既に存在する場合はスキップ）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- トリガー作成
DROP TRIGGER IF EXISTS update_quest_area_masters_updated_at ON quest_area_masters;
CREATE TRIGGER update_quest_area_masters_updated_at
BEFORE UPDATE ON quest_area_masters
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 既存のデータをクリア（開発用）
TRUNCATE TABLE quest_area_masters CASCADE;

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

-- 確認
SELECT id, name, required_level, duration_minutes FROM quest_area_masters ORDER BY display_order;