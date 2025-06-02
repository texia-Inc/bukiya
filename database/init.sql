-- 武器屋放置ゲーム データベーススキーマ設計
-- PostgreSQL 15+ 対応

-- ============================================
-- 1. プレイヤー関連テーブル
-- ============================================

-- プレイヤーアカウント
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    
    -- ゲーム進捗
    gold BIGINT DEFAULT 1000 CHECK (gold >= 0),
    gems INTEGER DEFAULT 50 CHECK (gems >= 0),
    shop_level INTEGER DEFAULT 1 CHECK (shop_level >= 1),
    reputation INTEGER DEFAULT 1 CHECK (reputation >= 0),
    
    -- メタデータ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 管理フラグ
    is_active BOOLEAN DEFAULT true,
    is_banned BOOLEAN DEFAULT false,
    ban_reason TEXT,
    
    -- インデックス用
    CONSTRAINT players_username_check CHECK (length(username) >= 3),
    CONSTRAINT players_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- プレイヤー統計（集計用）
CREATE TABLE player_statistics (
    player_id UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
    
    -- プレイ統計
    total_play_time_seconds BIGINT DEFAULT 0,
    session_count INTEGER DEFAULT 0,
    last_session_duration INTEGER DEFAULT 0,
    
    -- 経済統計
    total_gold_earned BIGINT DEFAULT 0,
    total_gold_spent BIGINT DEFAULT 0,
    total_gems_purchased INTEGER DEFAULT 0,
    total_gems_spent INTEGER DEFAULT 0,
    
    -- ゲーム統計
    weapons_crafted INTEGER DEFAULT 0,
    enchants_attempted INTEGER DEFAULT 0,
    enchants_succeeded INTEGER DEFAULT 0,
    trades_completed INTEGER DEFAULT 0,
    expeditions_sent INTEGER DEFAULT 0,
    
    -- 最高記録
    highest_weapon_attack INTEGER DEFAULT 0,
    highest_enchant_level INTEGER DEFAULT 0,
    max_daily_gold INTEGER DEFAULT 0,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. マスタデータテーブル
-- ============================================

-- 武器種マスタ
CREATE TABLE weapon_types (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    emoji VARCHAR(10),
    description TEXT,
    base_multiplier DECIMAL(4,2) DEFAULT 1.00,
    
    -- 特性
    attack_speed_modifier DECIMAL(4,2) DEFAULT 1.00,
    critical_rate_bonus INTEGER DEFAULT 0,
    special_effect VARCHAR(100),
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- レア度マスタ
CREATE TABLE rarity_levels (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    level INTEGER UNIQUE NOT NULL,
    color_code VARCHAR(7) NOT NULL,
    star_display VARCHAR(20) NOT NULL,
    
    -- ゲーム効果
    attack_multiplier DECIMAL(4,2) NOT NULL,
    max_enchant_level INTEGER NOT NULL,
    ability_slots INTEGER DEFAULT 0,
    
    -- ドロップ・価格
    base_drop_rate DECIMAL(6,4) DEFAULT 0.01,
    price_multiplier DECIMAL(4,2) DEFAULT 1.00,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 属性マスタ
CREATE TABLE attributes (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    emoji VARCHAR(10),
    color_code VARCHAR(7) NOT NULL,
    description TEXT,
    
    -- ゲーム効果
    damage_bonus INTEGER DEFAULT 0,
    effect_description TEXT,
    
    -- 相性関係（JSONで保存）
    effective_against TEXT[], -- 効果的な属性のリスト
    weak_against TEXT[], -- 弱い属性のリスト
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- アビリティマスタ
CREATE TABLE abilities (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    
    -- 効果
    effect_type VARCHAR(50) NOT NULL, -- 'attack_bonus', 'critical_rate', 'special_effect'
    effect_value INTEGER NOT NULL,
    effect_percentage BOOLEAN DEFAULT false,
    
    -- 条件
    required_weapon_types TEXT[], -- 適用可能な武器種
    required_rarity_level INTEGER DEFAULT 1,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    rarity VARCHAR(20) DEFAULT 'common',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. 武器関連テーブル
-- ============================================

-- 武器マスタ（武器の設計図）
CREATE TABLE weapon_masters (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    
    -- 基本設定
    weapon_type_id VARCHAR(20) NOT NULL REFERENCES weapon_types(id),
    rarity_id VARCHAR(20) NOT NULL REFERENCES rarity_levels(id),
    attribute_id VARCHAR(20) REFERENCES attributes(id),
    
    -- ステータス
    base_attack_min INTEGER NOT NULL CHECK (base_attack_min > 0),
    base_attack_max INTEGER NOT NULL CHECK (base_attack_max >= base_attack_min),
    enchant_growth_rate DECIMAL(4,2) DEFAULT 1.00,
    max_enchant_level INTEGER,
    
    -- 外観
    image_url VARCHAR(255),
    effect_color VARCHAR(7),
    description TEXT,
    
    -- 経済設定
    base_price_min INTEGER NOT NULL,
    base_price_max INTEGER NOT NULL,
    crafting_time_minutes INTEGER DEFAULT 30,
    
    -- 入手条件
    required_shop_level INTEGER DEFAULT 1,
    required_adventurer_level INTEGER DEFAULT 1,
    drop_rate DECIMAL(6,4) DEFAULT 0.0,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    is_test_only BOOLEAN DEFAULT false,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT weapon_masters_attack_check CHECK (base_attack_max >= base_attack_min),
    CONSTRAINT weapon_masters_price_check CHECK (base_price_max >= base_price_min)
);

-- 武器アビリティ関連（多対多）
CREATE TABLE weapon_master_abilities (
    weapon_master_id VARCHAR(50) REFERENCES weapon_masters(id) ON DELETE CASCADE,
    ability_id VARCHAR(50) REFERENCES abilities(id) ON DELETE CASCADE,
    slot_number INTEGER NOT NULL CHECK (slot_number >= 1),
    probability DECIMAL(5,4) DEFAULT 1.0000, -- アビリティ付与確率
    
    PRIMARY KEY (weapon_master_id, ability_id, slot_number),
    UNIQUE (weapon_master_id, slot_number)
);

-- プレイヤー所持武器（実際のアイテムインスタンス）
CREATE TABLE player_weapons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    weapon_master_id VARCHAR(50) NOT NULL REFERENCES weapon_masters(id),
    
    -- 個別ステータス
    base_attack INTEGER NOT NULL,
    enchant_level INTEGER DEFAULT 0 CHECK (enchant_level >= 0),
    current_durability INTEGER DEFAULT 100 CHECK (current_durability >= 0),
    max_durability INTEGER DEFAULT 100 CHECK (max_durability > 0),
    
    -- 付与されたアビリティ（実際に付いたもの）
    abilities JSONB DEFAULT '[]'::jsonb,
    
    -- カスタマイズ
    custom_name VARCHAR(100),
    is_favorite BOOLEAN DEFAULT false,
    
    -- メタデータ
    acquired_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    -- 管理
    is_equipped BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false, -- 誤削除防止
    
    CONSTRAINT player_weapons_durability_check CHECK (current_durability <= max_durability)
);

-- ============================================
-- 4. 素材関連テーブル
-- ============================================

-- 素材マスタ
CREATE TABLE material_masters (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    
    -- 分類
    category VARCHAR(50) NOT NULL, -- 'basic', 'magic', 'rare', 'special'
    rarity_id VARCHAR(20) NOT NULL REFERENCES rarity_levels(id),
    
    -- 特性
    attribute_id VARCHAR(20) REFERENCES attributes(id),
    effect_power INTEGER DEFAULT 0,
    description TEXT,
    
    -- 経済
    base_price INTEGER NOT NULL CHECK (base_price > 0),
    price_volatility DECIMAL(4,2) DEFAULT 0.1, -- 価格変動幅
    stack_size INTEGER DEFAULT 999,
    
    -- 外観
    emoji VARCHAR(10),
    color_code VARCHAR(7),
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- プレイヤー所持素材
CREATE TABLE player_materials (
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    material_master_id VARCHAR(50) REFERENCES material_masters(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    
    -- 取得統計
    total_acquired INTEGER DEFAULT 0,
    total_used INTEGER DEFAULT 0,
    last_acquired_at TIMESTAMP WITH TIME ZONE,
    
    PRIMARY KEY (player_id, material_master_id)
);

-- ============================================
-- 5. モンスター関連テーブル
-- ============================================

-- エリアマスタ
CREATE TABLE area_masters (
    id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- 要求条件
    required_shop_level INTEGER DEFAULT 1,
    required_adventurer_level INTEGER DEFAULT 1,
    
    -- 基本設定
    base_expedition_time_minutes INTEGER DEFAULT 60,
    danger_level INTEGER DEFAULT 1 CHECK (danger_level >= 1 AND danger_level <= 10),
    
    -- 外観
    background_image VARCHAR(255),
    theme_color VARCHAR(7),
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- モンスターマスタ
CREATE TABLE monster_masters (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    
    -- 基本ステータス
    hp INTEGER NOT NULL CHECK (hp > 0),
    attack INTEGER NOT NULL CHECK (attack > 0),
    defense INTEGER NOT NULL CHECK (defense >= 0),
    speed INTEGER DEFAULT 100,
    
    -- 属性・特性
    attribute_id VARCHAR(20) REFERENCES attributes(id),
    resistances JSONB DEFAULT '{}'::jsonb, -- 属性耐性
    weaknesses TEXT[], -- 弱点武器種
    immunities TEXT[], -- 無効化
    
    -- 戦闘設定
    level_min INTEGER NOT NULL,
    level_max INTEGER NOT NULL,
    base_success_rate DECIMAL(5,4) DEFAULT 0.7000,
    
    -- 外観
    emoji VARCHAR(10),
    description TEXT,
    
    -- 出現設定
    area_id VARCHAR(30) NOT NULL REFERENCES area_masters(id),
    spawn_rate DECIMAL(5,4) DEFAULT 0.1000,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    is_boss BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT monster_masters_level_check CHECK (level_max >= level_min)
);

-- ドロップテーブル
CREATE TABLE monster_drop_tables (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    monster_master_id VARCHAR(50) NOT NULL REFERENCES monster_masters(id) ON DELETE CASCADE,
    
    -- ドロップ対象
    drop_type VARCHAR(20) NOT NULL, -- 'material', 'weapon', 'gold'
    drop_target_id VARCHAR(50), -- material_master_id または weapon_master_id
    
    -- ドロップ設定
    quantity_min INTEGER DEFAULT 1,
    quantity_max INTEGER DEFAULT 1,
    drop_rate DECIMAL(5,4) NOT NULL,
    
    -- 条件
    required_weapon_type VARCHAR(20), -- 特定武器種使用時のボーナス
    bonus_rate DECIMAL(5,4) DEFAULT 0.0000,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT drop_tables_quantity_check CHECK (quantity_max >= quantity_min),
    CONSTRAINT drop_tables_rate_check CHECK (drop_rate >= 0 AND drop_rate <= 1)
);

-- ============================================
-- 6. レシピ・合成関連テーブル
-- ============================================

-- 合成レシピマスタ
CREATE TABLE crafting_recipes (
    id VARCHAR(50) PRIMARY KEY,
    result_weapon_master_id VARCHAR(50) NOT NULL REFERENCES weapon_masters(id),
    
    -- 合成設定
    success_rate DECIMAL(5,4) DEFAULT 1.0000,
    crafting_time_minutes INTEGER DEFAULT 30,
    required_gold INTEGER DEFAULT 0,
    
    -- 条件
    required_shop_level INTEGER DEFAULT 1,
    required_facility_level INTEGER DEFAULT 1,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    is_secret BOOLEAN DEFAULT false, -- 隠しレシピ
    unlock_condition TEXT, -- 解放条件の説明
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- レシピ必要素材
CREATE TABLE recipe_materials (
    recipe_id VARCHAR(50) REFERENCES crafting_recipes(id) ON DELETE CASCADE,
    material_master_id VARCHAR(50) REFERENCES material_masters(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    is_optional BOOLEAN DEFAULT false, -- オプション素材（品質向上用）
    
    PRIMARY KEY (recipe_id, material_master_id)
);

-- ============================================
-- 7. 冒険者システムテーブル
-- ============================================

-- 冒険者マスタ（NPCテンプレート）
CREATE TABLE adventurer_masters (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    
    -- 基本設定
    class VARCHAR(50) NOT NULL, -- 'warrior', 'mage', 'archer', 'rogue'
    level_min INTEGER DEFAULT 1,
    level_max INTEGER DEFAULT 100,
    
    -- 特性
    preferred_weapon_types TEXT[], -- 好む武器種
    budget_min INTEGER DEFAULT 100,
    budget_max INTEGER DEFAULT 10000,
    
    -- 性格・特徴
    personality VARCHAR(50), -- 'cautious', 'bold', 'cheap', 'generous'
    haggle_skill INTEGER DEFAULT 50, -- 交渉スキル（0-100）
    trust_base INTEGER DEFAULT 50, -- 基本信頼度
    
    -- 外観
    avatar_image VARCHAR(255),
    description TEXT,
    
    -- 出現設定
    spawn_rate DECIMAL(5,4) DEFAULT 0.1000,
    visit_frequency_hours INTEGER DEFAULT 4,
    
    -- 管理
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- プレイヤー-冒険者関係（信頼度等）
CREATE TABLE player_adventurer_relationships (
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    adventurer_master_id VARCHAR(50) REFERENCES adventurer_masters(id) ON DELETE CASCADE,
    
    -- 関係性
    trust_level INTEGER DEFAULT 0 CHECK (trust_level >= 0 AND trust_level <= 100),
    total_trades INTEGER DEFAULT 0,
    successful_expeditions INTEGER DEFAULT 0,
    failed_expeditions INTEGER DEFAULT 0,
    
    -- 経済
    total_gold_traded BIGINT DEFAULT 0,
    best_deal_margin INTEGER DEFAULT 0, -- 最高の取引マージン
    
    -- 時間
    first_met_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_interaction_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (player_id, adventurer_master_id)
);

-- ============================================
-- 8. アクティブゲームデータテーブル
-- ============================================

-- 進行中の活動（合成・派遣等）
CREATE TABLE active_processes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- プロセス情報
    process_type VARCHAR(50) NOT NULL, -- 'crafting', 'expedition', 'enchanting'
    status VARCHAR(20) DEFAULT 'in_progress', -- 'in_progress', 'completed', 'failed'
    
    -- 時間管理
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    duration_minutes INTEGER NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- プロセスデータ（JSONで柔軟に格納）
    process_data JSONB NOT NULL DEFAULT '{}'::jsonb,
    
    -- 結果
    result_data JSONB,
    rewards_claimed BOOLEAN DEFAULT false,
    
    CONSTRAINT active_processes_duration_check CHECK (duration_minutes > 0)
);

-- 冒険者訪問（一時的な状態）
CREATE TABLE adventurer_visits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    adventurer_master_id VARCHAR(50) NOT NULL REFERENCES adventurer_masters(id),
    
    -- 訪問情報
    visit_purpose VARCHAR(50) NOT NULL, -- 'buy_weapon', 'sell_materials'
    current_level INTEGER NOT NULL,
    available_gold INTEGER NOT NULL,
    
    -- 要求・提案
    weapon_requirements JSONB, -- 武器への要求条件
    material_offers JSONB, -- 持参素材とその価格
    
    -- 時間制限
    arrived_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- ステータス
    status VARCHAR(20) DEFAULT 'waiting', -- 'waiting', 'negotiating', 'completed', 'left'
    interaction_data JSONB DEFAULT '{}'::jsonb,
    
    CONSTRAINT visits_departure_check CHECK (departure_time > arrived_at)
);

-- ============================================
-- 9. トランザクション・ログテーブル
-- ============================================

-- 取引ログ
CREATE TABLE trade_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    
    -- 取引情報
    trade_type VARCHAR(50) NOT NULL, -- 'weapon_sale', 'material_purchase', 'enchant_payment'
    counterpart_type VARCHAR(50) NOT NULL, -- 'adventurer', 'system', 'shop'
    counterpart_id VARCHAR(50),
    
    -- 金額
    gold_amount INTEGER NOT NULL,
    gems_amount INTEGER DEFAULT 0,
    
    -- アイテム
    items_given JSONB DEFAULT '[]'::jsonb,
    items_received JSONB DEFAULT '[]'::jsonb,
    
    -- メタデータ
    success BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 管理操作ログ
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_user VARCHAR(100) NOT NULL,
    
    -- 操作情報
    action_type VARCHAR(50) NOT NULL, -- 'player_edit', 'item_grant', 'ban_player'
    target_type VARCHAR(50) NOT NULL, -- 'player', 'weapon', 'material'
    target_id VARCHAR(100),
    
    -- 変更内容
    old_values JSONB,
    new_values JSONB,
    reason TEXT,
    
    -- IP・セッション
    ip_address INET,
    session_id VARCHAR(255),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. インデックス設計
-- ============================================

-- プレイヤー関連
CREATE INDEX idx_players_email ON players(email);
CREATE INDEX idx_players_username ON players(username);
CREATE INDEX idx_players_last_login ON players(last_login);
CREATE INDEX idx_players_active ON players(is_active) WHERE is_active = true;

-- 武器関連
CREATE INDEX idx_player_weapons_player_id ON player_weapons(player_id);
CREATE INDEX idx_player_weapons_master_id ON player_weapons(weapon_master_id);
CREATE INDEX idx_player_weapons_equipped ON player_weapons(player_id, is_equipped) WHERE is_equipped = true;
CREATE INDEX idx_weapon_masters_active ON weapon_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_weapon_masters_rarity ON weapon_masters(rarity_id);
CREATE INDEX idx_weapon_masters_type ON weapon_masters(weapon_type_id);

-- 素材関連
CREATE INDEX idx_player_materials_player_id ON player_materials(player_id);
CREATE INDEX idx_player_materials_material_id ON player_materials(material_master_id);
CREATE INDEX idx_player_materials_quantity ON player_materials(quantity) WHERE quantity > 0;

-- モンスター・エリア関連
CREATE INDEX idx_monster_masters_area ON monster_masters(area_id);
CREATE INDEX idx_monster_masters_active ON monster_masters(is_active) WHERE is_active = true;
CREATE INDEX idx_monster_drops_monster ON monster_drop_tables(monster_master_id);
CREATE INDEX idx_monster_drops_type ON monster_drop_tables(drop_type, drop_target_id);

-- アクティブプロセス関連
CREATE INDEX idx_active_processes_player ON active_processes(player_id);
CREATE INDEX idx_active_processes_type ON active_processes(process_type);
CREATE INDEX idx_active_processes_status ON active_processes(status);
CREATE INDEX idx_active_processes_completion ON active_processes(completed_at) WHERE completed_at IS NOT NULL;

-- 冒険者関連
CREATE INDEX idx_adventurer_visits_player ON adventurer_visits(player_id);
CREATE INDEX idx_adventurer_visits_status ON adventurer_visits(status);
CREATE INDEX idx_adventurer_visits_departure ON adventurer_visits(departure_time);

-- ログ関連
CREATE INDEX idx_trade_logs_player ON trade_logs(player_id);
CREATE INDEX idx_trade_logs_created ON trade_logs(created_at);
CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_user);
CREATE INDEX idx_admin_logs_created ON admin_logs(created_at);

-- JSONB用インデックス
CREATE INDEX idx_player_weapons_abilities ON player_weapons USING GIN (abilities);
CREATE INDEX idx_active_processes_data ON active_processes USING GIN (process_data);
CREATE INDEX idx_active_processes_result ON active_processes USING GIN (result_data);

-- ============================================
-- 11. トリガー・関数
-- ============================================

-- updated_at自動更新関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_atトリガー
CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weapon_masters_updated_at BEFORE UPDATE ON weapon_masters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- プレイヤー統計更新関数（例）
CREATE OR REPLACE FUNCTION update_player_statistics()
RETURNS TRIGGER AS $$
BEGIN
    -- ゴールド変動時の統計更新
    IF TG_TABLE_NAME = 'players' AND OLD.gold != NEW.gold THEN
        UPDATE player_statistics 
        SET 
            total_gold_earned = total_gold_earned + GREATEST(NEW.gold - OLD.gold, 0),
            updated_at = CURRENT_TIMESTAMP
        WHERE player_id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_player_gold_statistics AFTER UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_player_statistics();
