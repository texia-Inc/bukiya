-- 固有冒険者キャラクターシステムのテーブル作成
-- 名前ありキャラクター（育成対象）と名前なしキャラクター（ランダム訪問者）を分離

-- 【新規】固有冒険者キャラクターマスターテーブル
CREATE TABLE IF NOT EXISTS adventurer_characters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,                    -- 固有名前「エリオット」
    title VARCHAR(100),                           -- 称号「炎の剣士」
    profession VARCHAR(20) NOT NULL,              -- 職業「warrior」
    rarity VARCHAR(20) NOT NULL DEFAULT 'common', -- レアリティ「common」「rare」「epic」「legendary」
    base_level INTEGER NOT NULL DEFAULT 1,       -- 基礎レベル
    max_level INTEGER NOT NULL DEFAULT 50,       -- 最大レベル
    max_trust_level INTEGER NOT NULL DEFAULT 100, -- 最大信頼度
    
    -- 解放条件
    unlock_player_level INTEGER NOT NULL DEFAULT 1,   -- プレイヤーレベル条件
    unlock_condition TEXT,                             -- その他解放条件（JSON）
    
    -- 基礎能力値（JSON形式で柔軟に拡張可能）
    base_stats JSONB DEFAULT '{"attack": 10, "defense": 5, "speed": 8, "magic": 3}',
    growth_rates JSONB DEFAULT '{"attack": 1.2, "defense": 1.1, "speed": 1.0, "magic": 1.0}',
    
    -- 武器・戦闘設定
    preferred_weapon_types TEXT[] DEFAULT '{}',        -- 得意武器タイプの配列
    elemental_affinity VARCHAR(20),                    -- 属性親和性「fire」「ice」「thunder」
    
    -- ストーリー・個性
    personality VARCHAR(50) NOT NULL DEFAULT 'normal', -- 性格
    backstory TEXT,                                    -- バックストーリー
    quote TEXT,                                        -- 決め台詞
    
    -- 見た目・UI
    avatar_url VARCHAR(255),                           -- アバター画像URL
    color_theme VARCHAR(7) DEFAULT '#4CAF50',          -- テーマカラー
    voice_type VARCHAR(20),                            -- 音声タイプ
    
    -- 特殊能力・スキル（JSON形式）
    special_abilities JSONB DEFAULT '[]',              -- 特殊スキルリスト
    passive_skills JSONB DEFAULT '[]',                 -- パッシブスキル
    
    -- ドラゴン討伐関連
    dragon_battle_eligible BOOLEAN DEFAULT FALSE,      -- ドラゴン討伐参加可能
    leadership_bonus INTEGER DEFAULT 0,                -- リーダーシップボーナス
    team_synergy JSONB DEFAULT '{}',                   -- チーム相性
    
    -- 出現・管理設定
    is_story_character BOOLEAN DEFAULT FALSE,          -- メインストーリーキャラ
    unlock_order INTEGER DEFAULT 0,                    -- 解放順序
    is_limited_time BOOLEAN DEFAULT FALSE,             -- 期間限定キャラ
    availability_start DATE,                           -- 入手可能開始日
    availability_end DATE,                             -- 入手可能終了日
    
    -- システム情報
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 【新規】プレイヤーと固有キャラクターの絆・関係テーブル
CREATE TABLE IF NOT EXISTS player_character_bonds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    character_id INTEGER NOT NULL REFERENCES adventurer_characters(id),
    
    -- 関係レベル
    trust_level INTEGER NOT NULL DEFAULT 0,           -- 信頼度 0-100
    friendship_level INTEGER NOT NULL DEFAULT 1,      -- 絆レベル 1-10
    total_trust_points INTEGER DEFAULT 0,             -- 累積信頼ポイント
    
    -- 交流履歴
    total_interactions INTEGER DEFAULT 0,             -- 総交流回数
    total_weapon_gifts INTEGER DEFAULT 0,             -- 武器プレゼント回数
    total_quests_together INTEGER DEFAULT 0,          -- 一緒にしたクエスト数
    total_dragon_battles INTEGER DEFAULT 0,           -- ドラゴン討伐参加回数
    
    -- ステータス・進捗
    current_level INTEGER DEFAULT 1,                  -- 現在レベル
    current_experience INTEGER DEFAULT 0,             -- 現在経験値
    is_unlocked BOOLEAN DEFAULT FALSE,                -- 解放済みフラグ
    is_favorited BOOLEAN DEFAULT FALSE,               -- お気に入り設定
    
    -- 装備・カスタマイズ
    equipped_weapon_id UUID REFERENCES player_weapons(id), -- 装備中武器
    custom_nickname VARCHAR(50),                       -- プレイヤーが付けたあだ名
    
    -- 会話・イベント進捗（JSON形式）
    conversation_flags JSONB DEFAULT '{}',            -- 会話フラグ
    story_progress JSONB DEFAULT '{}',                 -- ストーリー進捗
    special_events JSONB DEFAULT '[]',                 -- 特別イベント履歴
    
    -- 時間情報
    unlock_date TIMESTAMP WITH TIME ZONE,             -- 解放日時
    last_interaction_at TIMESTAMP WITH TIME ZONE,     -- 最後の交流日時
    last_level_up_at TIMESTAMP WITH TIME ZONE,        -- 最後のレベルアップ日時
    
    -- ユニーク制約
    UNIQUE(player_id, character_id),
    
    -- システム情報
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 【既存テーブル改修】冒険者インスタンステーブルに新フィールド追加
-- 名前ありキャラクターと名前なしキャラクターを区別

ALTER TABLE adventurer_instances 
ADD COLUMN IF NOT EXISTS is_named_character BOOLEAN DEFAULT FALSE;

ALTER TABLE adventurer_instances 
ADD COLUMN IF NOT EXISTS character_id INTEGER REFERENCES adventurer_characters(id);

ALTER TABLE adventurer_instances 
ADD COLUMN IF NOT EXISTS generic_name VARCHAR(100);

-- name フィールドの説明を更新（既存データ保持のため削除はしない）
COMMENT ON COLUMN adventurer_instances.name IS '旧形式の名前フィールド（後方互換性のため保持）';
COMMENT ON COLUMN adventurer_instances.generic_name IS '名前なしキャラクター用の汎用名前（例：訪問中の戦士）';
COMMENT ON COLUMN adventurer_instances.is_named_character IS '固有キャラクターかどうかのフラグ';
COMMENT ON COLUMN adventurer_instances.character_id IS '固有キャラクターの場合のキャラクターID';

-- 【新規】キャラクター解放ログテーブル
CREATE TABLE IF NOT EXISTS character_unlock_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    character_id INTEGER NOT NULL REFERENCES adventurer_characters(id),
    unlock_method VARCHAR(50) NOT NULL,               -- 解放方法「level_up」「quest_complete」「event」
    unlock_condition_met TEXT,                        -- 満たした解放条件の詳細
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 【新規】キャラクター会話ログテーブル
CREATE TABLE IF NOT EXISTS character_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    character_id INTEGER NOT NULL REFERENCES adventurer_characters(id),
    conversation_type VARCHAR(50) NOT NULL,           -- 会話タイプ「greeting」「gift」「quest」
    conversation_text TEXT,                           -- 会話内容
    trust_gained INTEGER DEFAULT 0,                   -- 獲得した信頼度
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_adventurer_characters_profession ON adventurer_characters(profession);
CREATE INDEX IF NOT EXISTS idx_adventurer_characters_rarity ON adventurer_characters(rarity);
CREATE INDEX IF NOT EXISTS idx_adventurer_characters_unlock_level ON adventurer_characters(unlock_player_level);
CREATE INDEX IF NOT EXISTS idx_adventurer_characters_active ON adventurer_characters(is_active);

CREATE INDEX IF NOT EXISTS idx_player_character_bonds_player ON player_character_bonds(player_id);
CREATE INDEX IF NOT EXISTS idx_player_character_bonds_character ON player_character_bonds(character_id);
CREATE INDEX IF NOT EXISTS idx_player_character_bonds_unlocked ON player_character_bonds(is_unlocked);
CREATE INDEX IF NOT EXISTS idx_player_character_bonds_trust ON player_character_bonds(trust_level);

CREATE INDEX IF NOT EXISTS idx_adventurer_instances_character_type ON adventurer_instances(is_named_character);
CREATE INDEX IF NOT EXISTS idx_adventurer_instances_character_id ON adventurer_instances(character_id);

CREATE INDEX IF NOT EXISTS idx_character_unlock_logs_player ON character_unlock_logs(player_id);
CREATE INDEX IF NOT EXISTS idx_character_conversations_player_char ON character_conversations(player_id, character_id);

-- 更新時刻トリガーの設定
DROP TRIGGER IF EXISTS update_adventurer_characters_updated_at ON adventurer_characters;
CREATE TRIGGER update_adventurer_characters_updated_at
BEFORE UPDATE ON adventurer_characters
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_player_character_bonds_updated_at ON player_character_bonds;
CREATE TRIGGER update_player_character_bonds_updated_at
BEFORE UPDATE ON player_character_bonds
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- テーブルコメント
COMMENT ON TABLE adventurer_characters IS '固有冒険者キャラクターマスターデータ（名前あり・育成対象）';
COMMENT ON TABLE player_character_bonds IS 'プレイヤーと固有キャラクターの絆・関係データ';
COMMENT ON TABLE character_unlock_logs IS 'キャラクター解放履歴ログ';
COMMENT ON TABLE character_conversations IS 'キャラクターとの会話履歴ログ';