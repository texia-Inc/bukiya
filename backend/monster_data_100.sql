-- 100 Monster Data Entries for 武器屋放置ゲーム
-- モンスターマスターデータ 100件

BEGIN;

-- === TIER 1 MONSTERS (Level 1-20) === 40 monsters

-- Forest Monsters (Level 1-10)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('青い粘液', 'normal', 1, 50, 8, 2, 'water', 'lightning', 'physical', '1', 150, 1, 5, 10, '森で最も弱いモンスター。初心者の練習相手', true),
('緑の粘液', 'normal', 2, 80, 12, 3, 'earth', 'fire', 'poison', '1', 140, 1, 8, 15, '少し強くなった粘液。緑色に変化している', true),
('森の蜘蛛', 'beast', 3, 120, 18, 8, 'poison', 'fire', 'dark', '1', 120, 2, 12, 25, '毒を持つ小さな蜘蛛。素早い動きが特徴', true),
('野ウサギ', 'beast', 4, 100, 22, 5, null, 'dark', 'light', '1', 110, 2, 15, 30, '可愛らしい外見だが意外と手強い', true),
('木の精', 'elemental', 5, 180, 25, 15, 'earth', 'fire', 'water', '1', 100, 3, 20, 40, '森を守る小さな精霊。回復能力を持つ', true),
('森のキノコ', 'normal', 6, 150, 20, 12, 'poison', 'fire', 'earth', '1', 90, 3, 18, 35, '毒胞子を撒き散らす危険なキノコ', true),
('野生のイノシシ', 'beast', 7, 250, 35, 20, null, 'ice', 'fire', '1', 80, 4, 25, 50, '突進攻撃が得意な森の住人', true),
('森のオオカミ', 'beast', 8, 220, 40, 18, null, 'fire', 'ice', '1', 70, 4, 30, 60, '群れで行動する賢いハンター', true),
('樹人の子', 'elemental', 9, 300, 30, 25, 'earth', 'fire', 'poison', '1', 60, 5, 35, 70, '古い樹木が目覚めた姿。防御力が高い', true),
('森のトロル', 'humanoid', 10, 400, 50, 30, 'earth', 'lightning', 'physical', '1', 50, 5, 45, 85, '森の奥深くに住む巨大なトロル', true),

-- Cave Monsters (Level 5-15)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('洞窟ネズミ', 'beast', 5, 120, 25, 8, 'dark', 'light', 'poison', '2', 120, 3, 18, 35, '洞窟に住む大きなネズミ。病気を媒介する', true),
('石ゴーレム', 'elemental', 6, 200, 20, 30, 'earth', 'water', 'physical', '2', 110, 3, 22, 40, '石でできた小さなゴーレム。硬い防御', true),
('洞窟グモ', 'beast', 7, 180, 35, 12, 'poison', 'fire', 'dark', '2', 100, 4, 28, 50, '巨大な洞窟蜘蛛。毒の糸を吐く', true),
('コウモリ群', 'flying', 8, 150, 45, 5, 'dark', 'light', 'physical', '2', 90, 4, 32, 55, '大量のコウモリが襲いかかる', true),
('鉱石トカゲ', 'beast', 9, 280, 40, 25, 'earth', 'ice', 'fire', '2', 80, 5, 38, 65, '鉱石のように硬い鱗を持つトカゲ', true),
('洞窟オーク', 'humanoid', 10, 350, 55, 20, 'dark', 'light', 'poison', '2', 70, 6, 45, 80, '武器を持った凶暴なオーク戦士', true),
('地底蛇', 'beast', 11, 320, 60, 15, 'poison', 'ice', 'fire', '2', 65, 6, 50, 90, '毒牙を持つ巨大な地底蛇', true),
('鉄ゴーレム', 'machine', 12, 450, 50, 40, 'earth', 'lightning', 'poison', '2', 60, 7, 55, 100, '鉄でできた強固なゴーレム', true),
('洞窟王オーク', 'humanoid', 13, 500, 70, 35, 'dark', 'light', 'physical', '2', 55, 8, 65, 115, 'オーク族の王。強力な武器を持つ', true),
('ミノタウロス', 'beast', 15, 600, 85, 45, 'earth', 'lightning', 'dark', '2', 40, 10, 80, 150, '牛頭の巨大な戦士。迷宮の番人', true),

-- Mountain Monsters (Level 10-20)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('雪ウサギ', 'beast', 10, 200, 35, 20, 'ice', 'fire', 'water', '3', 100, 6, 40, 75, '雪山に住む白いウサギ。氷の魔法を使う', true),
('氷の精霊', 'elemental', 12, 300, 45, 25, 'ice', 'fire', 'water', '3', 90, 7, 55, 105, '氷を操る美しい精霊', true),
('雪男', 'humanoid', 14, 550, 65, 40, 'ice', 'fire', 'physical', '3', 80, 9, 70, 130, '雪山の伝説的存在。巨大で力強い', true),
('氷ドラゴン幼体', 'dragon', 16, 700, 80, 50, 'ice', 'fire', 'water', '3', 70, 12, 90, 180, '氷のドラゴンの子供。強力なブレス攻撃', true),
('山岳オーガ', 'humanoid', 18, 800, 95, 60, 'earth', 'lightning', 'poison', '3', 60, 15, 110, 220, '山に住む巨大なオーガ。岩を投げる', true),
('グリフォン', 'flying', 20, 650, 110, 45, 'wind', 'lightning', 'earth', '3', 50, 18, 130, 280, '鷲と獅子の合成獣。空から襲撃する', true),

-- Desert Monsters (Level 8-18)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('砂虫', 'beast', 8, 180, 40, 10, 'earth', 'water', 'fire', '4', 90, 5, 32, 60, '砂の中から突然現れる巨大な虫', true),
('砂漠トカゲ', 'beast', 10, 250, 50, 30, 'fire', 'water', 'earth', '4', 80, 6, 42, 80, '砂漠に適応した大型トカゲ', true),
('ミイラ戦士', 'undead', 12, 400, 55, 35, 'dark', 'light', 'poison', '4', 70, 8, 58, 110, '古代の戦士が蘇った姿', true),
('砂嵐の精', 'elemental', 14, 350, 70, 25, 'wind', 'earth', 'fire', '4', 60, 10, 72, 140, '砂嵐を操る危険な精霊', true),
('ファラオの番犬', 'undead', 16, 600, 85, 50, 'dark', 'light', 'fire', '4', 50, 13, 88, 170, '古代王の墓を守る犬の亡霊', true),
('砂漠の王蛇', 'beast', 18, 750, 100, 40, 'poison', 'ice', 'fire', '4', 40, 16, 105, 200, '砂漠最強の巨大蛇。猛毒を持つ', true),

-- Ocean Monsters (Level 5-15)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('海藻スライム', 'aquatic', 5, 150, 20, 15, 'water', 'lightning', 'ice', '5', 110, 3, 20, 40, '海藻が絡まったスライム状の生物', true),
('小魚群', 'aquatic', 7, 120, 35, 8, 'water', 'lightning', 'poison', '5', 100, 4, 28, 55, '小さな魚が群れで襲ってくる', true),
('海カニ', 'aquatic', 9, 280, 45, 35, 'water', 'lightning', 'ice', '5', 90, 5, 36, 70, '巨大なハサミを持つ危険なカニ', true),
('人魚の戦士', 'aquatic', 11, 350, 60, 25, 'water', 'lightning', 'fire', '5', 80, 7, 48, 95, '三叉槍を持つ人魚族の戦士', true),
('海蛇', 'aquatic', 13, 450, 75, 30, 'water', 'lightning', 'earth', '5', 70, 9, 62, 125, '海の深淵から現れる巨大な蛇', true),
('クラーケン幼体', 'aquatic', 15, 600, 90, 40, 'water', 'lightning', 'fire', '5', 50, 12, 78, 155, '伝説の海魔の子供。触手攻撃が得意', true),

-- === TIER 2 MONSTERS (Level 21-50) === 35 monsters

-- Advanced Forest (Level 21-30)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('古代樹の番人', 'elemental', 22, 900, 120, 80, 'earth', 'fire', 'water', '1', 60, 20, 150, 320, '千年を生きる古代樹の化身', true),
('森の魔女', 'humanoid', 24, 750, 140, 60, 'dark', 'light', 'poison', '1', 55, 22, 170, 380, '呪いの魔法を使う恐ろしい魔女', true),
('エンシェント・ウルフ', 'beast', 26, 1100, 160, 70, 'dark', 'light', 'ice', '1', 50, 25, 190, 450, '古代から生きる巨大な狼', true),
('森の王', 'elemental', 28, 1300, 150, 100, 'earth', 'fire', 'dark', '1', 45, 28, 210, 520, '森を統べる偉大な精霊王', true),
('ドリュアド', 'elemental', 30, 1000, 180, 85, 'earth', 'fire', 'water', '1', 40, 30, 230, 600, '木々の声を聞く美しい森の精', true),

-- Deep Cave (Level 25-35)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('ダークエルフ', 'humanoid', 25, 800, 150, 55, 'dark', 'light', 'poison', '2', 55, 24, 180, 420, '地底に住む邪悪なエルフ族', true),
('アダマンゴーレム', 'machine', 27, 1400, 130, 120, 'earth', 'water', 'physical', '2', 50, 26, 200, 480, 'アダマンタイト製の最強ゴーレム', true),
('地底竜', 'dragon', 30, 1600, 200, 90, 'earth', 'ice', 'fire', '2', 45, 30, 250, 650, '地底深くに住む古いドラゴン', true),
('シャドウナイト', 'undead', 32, 1200, 220, 100, 'dark', 'light', 'physical', '2', 40, 32, 280, 720, '闇の力に支配された死の騎士', true),
('洞窟ドラゴン', 'dragon', 35, 1800, 250, 110, 'dark', 'light', 'fire', '2', 35, 35, 320, 850, '洞窟の王として君臨するドラゴン', true),

-- High Mountain (Level 30-40)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_Gold_reward, experience_reward, description, is_active) VALUES
('フロストジャイアント', 'humanoid', 30, 1500, 180, 120, 'ice', 'fire', 'water', '3', 45, 30, 250, 650, '氷の巨人族。氷の武器を振るう', true),
('氷の女王', 'elemental', 33, 1200, 220, 90, 'ice', 'fire', 'dark', '3', 40, 33, 290, 750, '雪山を支配する美しくも恐ろしい女王', true),
('ホワイトドラゴン', 'dragon', 36, 2000, 280, 130, 'ice', 'fire', 'water', '3', 35, 36, 340, 900, '白銀に輝く氷のドラゴン', true),
('雪崩の巨人', 'elemental', 38, 1800, 250, 150, 'ice', 'fire', 'earth', '3', 30, 38, 370, 980, '雪崩を起こす恐ろしい氷の巨人', true),
('マウンテンキング', 'humanoid', 40, 2200, 300, 140, 'earth', 'wind', 'fire', '3', 25, 40, 400, 1100, '山々の王として君臨する巨大な王', true),

-- Deep Desert (Level 28-38)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('ファラオ', 'undead', 28, 1300, 170, 110, 'dark', 'light', 'poison', '4', 45, 28, 220, 580, '古代エジプトの王が蘇った姿', true),
('砂漠の悪魔', 'demon', 31, 1100, 210, 80, 'fire', 'water', 'ice', '4', 40, 31, 270, 700, '砂漠に封印されていた強力な悪魔', true),
('サンドワーム', 'beast', 34, 1700, 190, 100, 'earth', 'water', 'wind', '4', 35, 34, 310, 820, '砂漠の地下に住む巨大なワーム', true),
('スフィンクス', 'beast', 36, 1500, 240, 120, 'earth', 'water', 'dark', '4', 30, 36, 340, 900, '謎かけを出す神話の獣', true),
('砂漠の神', 'elemental', 38, 1900, 260, 130, 'fire', 'water', 'ice', '4', 25, 38, 370, 980, '砂漠を統べる古代の神', true),

-- Deep Ocean (Level 25-35)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('深海の魔女', 'aquatic', 25, 950, 160, 70, 'water', 'lightning', 'ice', '5', 50, 25, 180, 420, '深海に住む恐ろしい魔女', true),
('巨大イカ', 'aquatic', 28, 1300, 180, 90, 'water', 'lightning', 'fire', '5', 45, 28, 220, 580, '深海の巨大な頭足類', true),
('海竜', 'dragon', 31, 1600, 220, 100, 'water', 'lightning', 'earth', '5', 40, 31, 270, 700, '海の王者として君臨するドラゴン', true),
('海神の使者', 'aquatic', 33, 1400, 240, 110, 'water', 'lightning', 'dark', '5', 35, 33, 300, 780, '海神に仕える強力な使者', true),
('リヴァイアサン', 'dragon', 35, 2000, 280, 120, 'water', 'lightning', 'fire', '5', 30, 35, 330, 850, '海の最深部に住む伝説の海竜', true),

-- Volcano (Level 35-45)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('マグマスライム', 'elemental', 35, 1200, 200, 80, 'fire', 'water', 'ice', '6', 35, 35, 320, 850, '溶岩でできた灼熱のスライム', true),
('炎の悪魔', 'demon', 38, 1500, 260, 90, 'fire', 'water', 'ice', '6', 30, 38, 370, 980, '火山に住む炎を操る悪魔', true),
('溶岩ゴーレム', 'elemental', 40, 1800, 240, 140, 'fire', 'water', 'ice', '6', 25, 40, 400, 1100, '溶岩でできた巨大なゴーレム', true),
('火山竜', 'dragon', 43, 2200, 320, 130, 'fire', 'water', 'ice', '6', 20, 43, 450, 1250, '火山の主として君臨する炎のドラゴン', true),
('イフリート', 'elemental', 45, 2000, 350, 120, 'fire', 'water', 'ice', '6', 15, 45, 500, 1400, '炎の精霊王。最強の火属性モンスター', true),

-- === TIER 3 MONSTERS (Level 51-80) === 20 monsters

-- Sky Realm (Level 51-65)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('天空の守護者', 'flying', 52, 2500, 380, 160, 'wind', 'earth', 'lightning', '7', 25, 52, 550, 1600, '雲上界を守る翼ある戦士', true),
('雷鳥', 'flying', 55, 2200, 420, 140, 'lightning', 'earth', 'water', '7', 20, 55, 600, 1800, '雷を操る神話の巨鳥', true),
('ワイバーン', 'dragon', 58, 2800, 450, 180, 'wind', 'earth', 'ice', '7', 18, 58, 650, 2000, '空を支配する亜竜種', true),
('嵐の王', 'elemental', 62, 3000, 480, 200, 'lightning', 'earth', 'fire', '7', 15, 62, 720, 2300, '嵐を司る偉大な精霊王', true),
('エンシェントドラゴン', 'dragon', 65, 3500, 550, 220, 'wind', 'earth', 'dark', '7', 12, 65, 800, 2600, '古代から空に君臨する偉大なドラゴン', true),

-- Dungeon (Level 55-70)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('ダンジョンロード', 'humanoid', 56, 2600, 400, 180, 'dark', 'light', 'poison', '8', 20, 56, 620, 1900, 'ダンジョンを支配する邪悪な領主', true),
('リッチ', 'undead', 60, 2400, 480, 160, 'dark', 'light', 'fire', '8', 18, 60, 700, 2200, '強力な魔法を使う不死の魔法使い', true),
('ダークナイト', 'undead', 63, 3200, 520, 220, 'dark', 'light', 'poison', '8', 15, 63, 760, 2400, '闇の力に堕ちた伝説の騎士', true),
('ボーンドラゴン', 'undead', 67, 3000, 580, 200, 'dark', 'light', 'fire', '8', 12, 67, 840, 2700, '骨だけになったドラゴンの亡霊', true),
('デスロード', 'undead', 70, 3800, 620, 240, 'dark', 'light', 'physical', '8', 10, 70, 900, 3000, '死を司る恐ろしい支配者', true),

-- Castle (Level 60-75)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('堕落騎士', 'humanoid', 61, 2800, 450, 190, 'dark', 'light', 'fire', '9', 18, 61, 720, 2250, '名誉を捨てた騎士の成れの果て', true),
('魔王の側近', 'demon', 65, 3200, 520, 180, 'dark', 'light', 'ice', '9', 15, 65, 800, 2600, '魔王に仕える強力な悪魔', true),
('ガーゴイル王', 'flying', 68, 3500, 480, 250, 'earth', 'wind', 'water', '9', 12, 68, 860, 2800, '石像の王。城を守る最強の番人', true),
('ドラゴンナイト', 'humanoid', 72, 3800, 580, 220, 'fire', 'ice', 'water', '9', 10, 72, 940, 3200, 'ドラゴンと契約した伝説の騎士', true),
('魔王', 'demon', 75, 4500, 650, 280, 'dark', 'light', 'fire', '9', 8, 75, 1000, 3500, '城に住む恐ろしい魔王', true),

-- Abyss (Level 70-80)
INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('深淵の使者', 'demon', 72, 3600, 560, 200, 'dark', 'light', 'fire', '10', 12, 72, 940, 3200, '深淵から這い出てきた恐ろしい使者', true),
('ヴォイドドラゴン', 'dragon', 76, 4200, 620, 240, 'dark', 'light', 'fire', '10', 10, 76, 1050, 3700, '虚無の力を操る漆黒のドラゴン', true),
('深淵王', 'demon', 78, 4500, 680, 260, 'dark', 'light', 'physical', '10', 8, 78, 1100, 3900, '深淵を統べる絶対的な支配者', true),
('エルドリッチ・ホラー', 'demon', 80, 5000, 720, 280, 'dark', 'light', 'fire', '10', 6, 80, 1200, 4200, '人知を超えた恐怖の存在', true),

-- === TIER 4 ENDGAME BOSSES (Level 81-100) === 5 monsters

INSERT INTO monster_masters (name, monster_type, level, hp, attack, defense, element, weakness, resistance, spawn_areas, spawn_weight, min_required_weapon_level, base_gold_reward, experience_reward, description, is_active) VALUES
('古代神の化身', 'elemental', 85, 6000, 800, 350, 'light', 'dark', 'physical', '10', 5, 85, 1500, 5000, '古代神が現世に降臨した姿', true),
('終焉の竜王', 'dragon', 90, 7500, 900, 400, 'dark', 'light', 'fire', '10', 4, 90, 1800, 6000, '全てのドラゴンの頂点に立つ王', true),
('創世の守護者', 'machine', 95, 8500, 850, 500, 'light', 'dark', 'lightning', '10', 3, 95, 2200, 7500, '世界創造時から存在する古の守護者', true),
('混沌の具現体', 'demon', 98, 9000, 1000, 450, 'dark', 'light', 'fire', '10', 2, 98, 2500, 8500, '混沌そのものが形を成した存在', true),
('世界樹の意志', 'elemental', 100, 10000, 1200, 600, 'earth', 'fire', 'dark', '10', 1, 100, 3000, 10000, '世界樹が意志を持って立ち上がった最終形態', true);

COMMIT;

-- Verification queries
SELECT 
    '=== MONSTER DATA SUMMARY ===' as info,
    COUNT(*) as total_monsters,
    MIN(level) as min_level,
    MAX(level) as max_level,
    AVG(level)::integer as avg_level
FROM monster_masters 
WHERE id > 1;

SELECT 
    monster_type,
    COUNT(*) as count,
    MIN(level) as min_level,
    MAX(level) as max_level
FROM monster_masters 
WHERE id > 1
GROUP BY monster_type 
ORDER BY monster_type;

SELECT 
    CASE 
        WHEN level <= 20 THEN 'Tier 1 (1-20)'
        WHEN level <= 50 THEN 'Tier 2 (21-50)'
        WHEN level <= 80 THEN 'Tier 3 (51-80)'
        ELSE 'Tier 4 (81-100)'
    END as tier,
    COUNT(*) as count
FROM monster_masters 
WHERE id > 1
GROUP BY 
    CASE 
        WHEN level <= 20 THEN 'Tier 1 (1-20)'
        WHEN level <= 50 THEN 'Tier 2 (21-50)'
        WHEN level <= 80 THEN 'Tier 3 (51-80)'
        ELSE 'Tier 4 (81-100)'
    END
ORDER BY tier;