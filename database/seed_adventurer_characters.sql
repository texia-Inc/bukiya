-- 固有冒険者キャラクターの初期シードデータ
-- 名前ありキャラクター（育成対象）の基本セット

-- 初期10人の固有冒険者キャラクター
INSERT INTO adventurer_characters (
    name, title, profession, rarity, base_level, max_level,
    unlock_player_level, base_stats, growth_rates,
    preferred_weapon_types, elemental_affinity, personality,
    backstory, quote, color_theme,
    special_abilities, dragon_battle_eligible, leadership_bonus,
    unlock_order, is_active
) VALUES 
-- 1. 初心者向けキャラクター（プレイヤーレベル1で解放）
(
    'エリオット', '新米剣士', 'warrior', 'common', 1, 30,
    1, 
    '{"attack": 12, "defense": 8, "speed": 6, "magic": 2}',
    '{"attack": 1.3, "defense": 1.2, "speed": 1.0, "magic": 0.8}',
    '{"sword", "hammer"}', 'fire', 'determined',
    '街の出身の若い剣士。正義感が強く、困った人を放っておけない性格。',
    '俺が君を守る！', '#E57373',
    '[{"name": "勇猛果敢", "description": "攻撃力10%アップ", "type": "passive"}]',
    true, 5, 1, true
),

(
    'リリア', '森の弓使い', 'archer', 'common', 1, 30,
    1,
    '{"attack": 10, "defense": 5, "speed": 12, "magic": 5}',
    '{"attack": 1.2, "defense": 1.0, "speed": 1.4, "magic": 1.1}',
    '{"bow", "dagger"}', 'wind', 'calm',
    '森で育った静かな弓使い。動物と話せると噂されている。',
    '自然の声が聞こえるの', '#81C784',
    '[{"name": "狙い撃ち", "description": "クリティカル率15%アップ", "type": "passive"}]',
    true, 0, 2, true
),

-- 2. 中級キャラクター（プレイヤーレベル3-5で解放）
(
    'マリン', '学院の魔法使い', 'mage', 'rare', 3, 40,
    3,
    '{"attack": 6, "defense": 4, "speed": 8, "magic": 15}',
    '{"attack": 0.9, "defense": 0.9, "speed": 1.1, "magic": 1.5}',
    '{"staff"}', 'ice', 'intelligent',
    '魔法学院の優秀な生徒。常に新しい魔法の研究に熱中している。',
    '知識こそ力よ', '#64B5F6',
    '[{"name": "魔力増幅", "description": "魔法攻撃30%アップ", "type": "passive"}, {"name": "氷の盾", "description": "防御力20%アップ", "type": "active"}]',
    true, 10, 3, true
),

(
    'ガレス', '鉄の守護者', 'paladin', 'rare', 4, 40,
    4,
    '{"attack": 8, "defense": 16, "speed": 4, "magic": 8}',
    '{"attack": 1.1, "defense": 1.5, "speed": 0.8, "magic": 1.2}',
    '{"sword", "hammer"}', 'light', 'protective',
    '神殿騎士団の盾持ち。仲間を守ることに命を懸けている。',
    '私が盾となろう', '#FFB74D',
    '[{"name": "鉄壁", "description": "全体防御力15%アップ", "type": "team"}, {"name": "回復の光", "description": "HP回復スキル", "type": "active"}]',
    true, 15, 4, true
),

(
    'シャドウ', '影の暗殺者', 'rogue', 'rare', 2, 35,
    5,
    '{"attack": 14, "defense": 6, "speed": 16, "magic": 4}',
    '{"attack": 1.4, "defense": 1.0, "speed": 1.6, "magic": 1.0}',
    '{"dagger"}', 'dark', 'mysterious',
    '正体不明の暗殺者。過去は謎に包まれているが、義理堅い一面も。',
    '...（無言）', '#757575',
    '[{"name": "影歩き", "description": "回避率25%アップ", "type": "passive"}, {"name": "致命の一撃", "description": "クリティカル時ダメージ2倍", "type": "passive"}]',
    true, 0, 5, true
),

-- 3. 上級キャラクター（プレイヤーレベル7-10で解放）
(
    'アイリス', '竜騎士の末裔', 'warrior', 'epic', 8, 50,
    7,
    '{"attack": 18, "defense": 12, "speed": 10, "magic": 6}',
    '{"attack": 1.5, "defense": 1.3, "speed": 1.2, "magic": 1.1}',
    '{"sword", "spear"}', 'thunder', 'noble',
    '古い竜騎士の血を引く貴族。プライドは高いが、実力も本物。',
    '竜の血が騒ぐわ', '#9C27B0',
    '[{"name": "竜の血脈", "description": "ドラゴン戦で全能力20%アップ", "type": "conditional"}, {"name": "雷鳴剣", "description": "雷属性攻撃", "type": "active"}]',
    true, 20, 6, true
),

(
    'セージ', '賢者の弟子', 'mage', 'epic', 6, 45,
    8,
    '{"attack": 4, "defense": 6, "speed": 7, "magic": 20}',
    '{"attack": 0.8, "defense": 1.0, "speed": 1.0, "magic": 1.7}',
    '{"staff", "book"}', 'arcane', 'wise',
    '伝説の賢者に師事した魔法使い。古代魔法の知識を持つ。',
    '魔法の真理を求めて', '#3F51B5',
    '[{"name": "古代魔法", "description": "特殊魔法使用可能", "type": "unique"}, {"name": "魔力回復", "description": "戦闘中MP回復", "type": "passive"}]',
    true, 25, 7, true
),

(
    'ヴァルキリー', '戦乙女', 'paladin', 'epic', 10, 50,
    9,
    '{"attack": 15, "defense": 13, "speed": 12, "magic": 12}',
    '{"attack": 1.4, "defense": 1.3, "speed": 1.3, "magic": 1.3}',
    '{"sword", "spear"}', 'light', 'heroic',
    '神々に選ばれし戦乙女。美しくも強く、戦場では無敵の存在。',
    '神々の加護があらんことを', '#FF9800',
    '[{"name": "神の祝福", "description": "チーム全体の能力15%アップ", "type": "team"}, {"name": "復活の奇跡", "description": "一度だけ戦闘不能から復活", "type": "ultimate"}]',
    true, 30, 8, true
),

-- 4. 伝説級キャラクター（プレイヤーレベル12-15で解放）
(
    'ドラゴンスレイヤー', '竜殺しの英雄', 'warrior', 'legendary', 15, 60,
    12,
    '{"attack": 25, "defense": 18, "speed": 15, "magic": 10}',
    '{"attack": 1.8, "defense": 1.4, "speed": 1.3, "magic": 1.2}',
    '{"sword", "greatsword"}', 'dragon', 'legendary',
    '数々のドラゴンを倒してきた伝説の英雄。その剣技は神の域に達している。',
    'ドラゴンよ、覚悟せよ', '#D32F2F',
    '[{"name": "竜殺し", "description": "ドラゴンに対して攻撃力3倍", "type": "conditional"}, {"name": "英雄の剣技", "description": "必殺技の威力2倍", "type": "ultimate"}]',
    true, 50, 9, true
),

(
    'アルケミスト', '錬金術師', 'mage', 'legendary', 12, 55,
    15,
    '{"attack": 8, "defense": 10, "speed": 9, "magic": 25}',
    '{"attack": 1.0, "defense": 1.1, "speed": 1.0, "magic": 2.0}',
    '{"staff", "catalyst"}', 'arcane', 'genius',
    '錬金術の頂点に立つ天才。あらゆる魔法薬と魔法装置を作り出せる。',
    '全ては等価交換よ', '#7B1FA2',
    '[{"name": "錬金術", "description": "アイテム効果2倍", "type": "passive"}, {"name": "賢者の石", "description": "究極の錬金術", "type": "ultimate"}]',
    true, 40, 10, true
);

-- 各キャラクターの特殊なテーマカラーやボイス設定
UPDATE adventurer_characters SET 
    voice_type = CASE 
        WHEN name = 'エリオット' THEN 'young_male'
        WHEN name = 'リリア' THEN 'soft_female' 
        WHEN name = 'マリン' THEN 'intelligent_female'
        WHEN name = 'ガレス' THEN 'deep_male'
        WHEN name = 'シャドウ' THEN 'whisper_male'
        WHEN name = 'アイリス' THEN 'noble_female'
        WHEN name = 'セージ' THEN 'wise_male'
        WHEN name = 'ヴァルキリー' THEN 'heroic_female'
        WHEN name = 'ドラゴンスレイヤー' THEN 'legendary_male'
        WHEN name = 'アルケミスト' THEN 'mysterious_female'
    END;

-- チーム相性の設定（JSON形式）
UPDATE adventurer_characters SET team_synergy = 
    CASE name
        WHEN 'エリオット' THEN '{"リリア": 1.2, "ガレス": 1.15}'
        WHEN 'リリア' THEN '{"エリオット": 1.2, "マリン": 1.1}'
        WHEN 'マリン' THEN '{"リリア": 1.1, "セージ": 1.25}'
        WHEN 'ガレス' THEN '{"エリオット": 1.15, "ヴァルキリー": 1.3}'
        WHEN 'シャドウ' THEN '{"アイリス": 1.1, "ドラゴンスレイヤー": 1.2}'
        WHEN 'アイリス' THEN '{"シャドウ": 1.1, "ヴァルキリー": 1.2}'
        WHEN 'セージ' THEN '{"マリン": 1.25, "アルケミスト": 1.4}'
        WHEN 'ヴァルキリー' THEN '{"ガレス": 1.3, "アイリス": 1.2}'
        WHEN 'ドラゴンスレイヤー' THEN '{"シャドウ": 1.2, "全員": 1.1}'
        WHEN 'アルケミスト' THEN '{"セージ": 1.4, "全員": 1.05}'
        ELSE '{}'
    END::jsonb;

-- ストーリーフラグの設定
UPDATE adventurer_characters SET 
    is_story_character = CASE 
        WHEN name IN ('エリオット', 'リリア', 'ドラゴンスレイヤー') THEN true
        ELSE false
    END;