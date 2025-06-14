#!/usr/bin/env python3
"""
100体のモンスターデータを投入する包括的シード
現在のテーブル構造に完全対応
"""

from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('100体のモンスターデータを投入中...')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # 現在のモンスター数を確認
            result = conn.execute(text("SELECT COUNT(*) FROM monster_masters"))
            current_count = result.scalar()
            print(f"現在のモンスター数: {current_count}")
            
            # エリアマスターを確認
            try:
                result = conn.execute(text("SELECT id, name FROM area_masters LIMIT 5"))
                areas = list(result)
                print(f"利用可能なエリア: {len(areas)} 個")
                if areas:
                    for area in areas:
                        print(f"  {area[0]}: {area[1]}")
                # 必要なエリアを作成（既存チェック付き）
                print("必要なエリアを作成中...")
                conn.execute(text("""
                INSERT INTO area_masters (id, name, description, required_shop_level, danger_level, is_active) VALUES
                ('forest', '森林エリア', '初心者向けの森林地帯', 1, 1, true),
                ('cave', '洞窟エリア', '中級者向けの洞窟', 5, 3, true),
                ('mountain', '山岳エリア', '上級者向けの山岳地帯', 10, 5, true),
                ('volcano', '火山エリア', '高レベル向けの火山地帯', 15, 7, true),
                ('abyss', '深淵エリア', '最高難易度の深淵', 20, 10, true)
                ON CONFLICT (id) DO NOTHING
                """))
                print("必要なエリアを確保しました")
            except Exception as e:
                print(f"エリア確認エラー（続行します）: {e}")
            
            # 100体のモンスターデータ
            monsters_data = [
                # === 森林エリア (Level 1-10) === 20体
                ('slime_blue', '青い粘液', 'forest', 1, 1, 50, 8, 2, 80, 'water', 'lightning', 'physical', 'normal', 5, 10, '初心者向けの弱いモンスター'),
                ('slime_green', '緑の粘液', 'forest', 2, 2, 80, 12, 3, 90, 'earth', 'fire', 'poison', 'normal', 8, 15, '少し強くなった粘液'),
                ('spider_forest', '森の蜘蛛', 'forest', 3, 3, 120, 18, 8, 110, 'poison', 'fire', 'dark', 'beast', 12, 25, '毒を持つ小さな蜘蛛'),
                ('rabbit_wild', '野ウサギ', 'forest', 4, 4, 100, 22, 5, 150, 'normal', 'dark', 'light', 'beast', 15, 30, '可愛らしいが意外と手強い'),
                ('spirit_tree', '木の精', 'forest', 5, 5, 180, 25, 15, 60, 'earth', 'fire', 'water', 'elemental', 20, 40, '森を守る小さな精霊'),
                ('mushroom_poison', '森のキノコ', 'forest', 6, 6, 150, 20, 12, 70, 'poison', 'fire', 'earth', 'plant', 18, 35, '毒胞子を撒き散らす'),
                ('boar_wild', '野生のイノシシ', 'forest', 7, 7, 250, 35, 20, 80, 'normal', 'ice', 'fire', 'beast', 25, 50, '突進攻撃が得意'),
                ('wolf_forest', '森のオオカミ', 'forest', 8, 8, 220, 40, 18, 120, 'normal', 'fire', 'ice', 'beast', 30, 60, '群れで行動する賢いハンター'),
                ('treeling', '樹人の子', 'forest', 9, 9, 300, 30, 25, 50, 'earth', 'fire', 'poison', 'elemental', 35, 70, '古い樹木が目覚めた姿'),
                ('troll_forest', '森のトロル', 'forest', 10, 10, 400, 50, 30, 60, 'earth', 'lightning', 'physical', 'humanoid', 45, 85, '森の奥深くに住む巨大なトロル'),
                ('bee_giant', '巨大ミツバチ', 'forest', 3, 4, 90, 25, 5, 140, 'wind', 'fire', 'poison', 'insect', 14, 28, '大きな針を持つミツバチ'),
                ('snake_grass', '草ヘビ', 'forest', 5, 6, 130, 28, 10, 100, 'poison', 'ice', 'fire', 'beast', 22, 42, '草に紛れる毒蛇'),
                ('owl_great', '大フクロウ', 'forest', 7, 8, 180, 35, 12, 130, 'wind', 'lightning', 'dark', 'bird', 28, 55, '夜行性の大型フクロウ'),
                ('bear_forest', '森グマ', 'forest', 8, 9, 350, 45, 25, 70, 'normal', 'fire', 'ice', 'beast', 38, 75, '森の主とも呼ばれる大型熊'),
                ('pixie_mischief', 'いたずら妖精', 'forest', 4, 5, 80, 30, 8, 160, 'light', 'dark', 'earth', 'fairy', 16, 32, '魔法を使ういたずら好きな妖精'),
                ('mushroom_king', 'キノコ王', 'forest', 9, 10, 280, 35, 20, 50, 'poison', 'fire', 'light', 'plant', 42, 80, '森のキノコたちの王'),
                ('stag_giant', '巨大シカ', 'forest', 6, 7, 200, 32, 15, 90, 'earth', 'fire', 'water', 'beast', 24, 48, '立派な角を持つ巨大なシカ'),
                ('sprite_water', '水の精霊', 'forest', 5, 6, 120, 22, 18, 80, 'water', 'lightning', 'fire', 'elemental', 20, 40, '森の泉に住む水精霊'),
                ('badger_giant', '巨大アナグマ', 'forest', 7, 8, 240, 38, 22, 85, 'earth', 'lightning', 'water', 'beast', 32, 60, '穴掘りが得意な大型アナグマ'),
                ('ent_young', '若い樹人', 'forest', 10, 10, 450, 40, 35, 40, 'earth', 'fire', 'ice', 'elemental', 50, 90, '成長途中の樹人'),
                
                # === 洞窟エリア (Level 8-18) === 25体
                ('rat_cave', '洞窟ネズミ', 'cave', 8, 9, 150, 35, 12, 110, 'dark', 'light', 'poison', 'beast', 28, 50, '洞窟に住む大きなネズミ'),
                ('golem_stone', '石ゴーレム', 'cave', 10, 11, 300, 25, 40, 60, 'earth', 'water', 'physical', 'elemental', 40, 70, '石でできた小さなゴーレム'),
                ('spider_cave', '洞窟グモ', 'cave', 12, 13, 220, 45, 15, 120, 'poison', 'fire', 'light', 'beast', 45, 80, '巨大な洞窟蜘蛛'),
                ('bat_swarm', 'コウモリ群', 'cave', 11, 12, 180, 55, 8, 150, 'dark', 'light', 'wind', 'flying', 42, 75, '大量のコウモリ'),
                ('lizard_ore', '鉱石トカゲ', 'cave', 14, 15, 380, 48, 30, 90, 'earth', 'ice', 'lightning', 'beast', 55, 95, '鉱石のように硬い鱗'),
                ('orc_cave', '洞窟オーク', 'cave', 15, 16, 450, 65, 25, 80, 'dark', 'light', 'holy', 'humanoid', 65, 110, '武器を持った凶暴なオーク'),
                ('snake_pit', '地底蛇', 'cave', 16, 17, 380, 70, 18, 100, 'poison', 'ice', 'fire', 'beast', 70, 120, '毒牙を持つ巨大な地底蛇'),
                ('golem_iron', '鉄ゴーレム', 'cave', 17, 18, 550, 55, 45, 50, 'earth', 'lightning', 'fire', 'machine', 75, 130, '鉄でできた強固なゴーレム'),
                ('orc_king', '洞窟王オーク', 'cave', 18, 18, 650, 80, 40, 70, 'dark', 'light', 'holy', 'boss', 85, 150, 'オーク族の王'),
                ('crystal_spider', '水晶蜘蛛', 'cave', 13, 14, 250, 50, 20, 105, 'crystal', 'physical', 'dark', 'beast', 50, 85, '水晶の体を持つ美しい蜘蛛'),
                ('mole_giant', '巨大モグラ', 'cave', 9, 10, 200, 30, 25, 80, 'earth', 'light', 'water', 'beast', 35, 60, '地中を素早く移動する'),
                ('ghost_miner', '鉱夫の霊', 'cave', 12, 13, 180, 40, 5, 90, 'undead', 'holy', 'physical', 'ghost', 48, 80, '事故で亡くなった鉱夫の霊'),
                ('golem_copper', '銅ゴーレム', 'cave', 11, 12, 320, 35, 35, 65, 'earth', 'acid', 'lightning', 'elemental', 42, 75, '銅でできたゴーレム'),
                ('salamander_fire', 'ファイアサラマンダー', 'cave', 14, 15, 280, 60, 20, 110, 'fire', 'water', 'ice', 'reptile', 58, 100, '炎を吐く両生類'),
                ('skeleton_warrior', 'スケルトン戦士', 'cave', 15, 16, 300, 55, 15, 95, 'undead', 'holy', 'physical', 'undead', 62, 105, '武器を持った骸骨戦士'),
                ('worm_rock', 'ロックワーム', 'cave', 16, 17, 420, 45, 35, 70, 'earth', 'fire', 'acid', 'beast', 68, 115, '岩を食べる巨大なミミズ'),
                ('gargoyle_stone', 'ストーンガーゴイル', 'cave', 17, 18, 480, 50, 40, 60, 'earth', 'holy', 'dark', 'demon', 72, 125, '石の翼を持つ悪魔'),
                ('minotaur_young', '若いミノタウロス', 'cave', 18, 18, 600, 75, 30, 85, 'earth', 'lightning', 'holy', 'beast', 80, 140, '牛頭の獣人'),
                ('slime_metal', 'メタルスライム', 'cave', 10, 11, 100, 20, 50, 200, 'metal', 'acid', 'physical', 'rare', 100, 200, '非常に硬く逃げ足が速い'),
                ('dwarf_zombie', 'ドワーフゾンビ', 'cave', 13, 14, 280, 48, 20, 75, 'undead', 'holy', 'fire', 'undead', 52, 90, 'ゾンビ化したドワーフ'),
                ('crystal_golem', 'クリスタルゴーレム', 'cave', 16, 17, 400, 40, 45, 55, 'crystal', 'physical', 'dark', 'elemental', 70, 120, '美しい水晶でできたゴーレム'),
                ('cave_troll', '洞窟トロル', 'cave', 17, 18, 700, 70, 35, 60, 'earth', 'fire', 'holy', 'humanoid', 78, 135, '洞窟に住む大型トロル'),
                ('phantom_bat', 'ファントムバット', 'cave', 14, 15, 200, 65, 10, 140, 'dark', 'light', 'holy', 'undead', 56, 95, '幽霊のようなコウモリ'),
                ('earth_elemental', 'アースエレメンタル', 'cave', 15, 16, 500, 45, 50, 50, 'earth', 'wind', 'water', 'elemental', 65, 110, '大地の力を宿した精霊'),
                ('cave_dragon', '洞窟ドラゴン', 'cave', 18, 18, 800, 90, 45, 80, 'earth', 'ice', 'holy', 'dragon', 90, 160, '洞窟に住む小さなドラゴン'),
                
                # === 山岳エリア (Level 18-28) === 25体
                ('eagle_giant', '巨大ワシ', 'mountain', 18, 19, 320, 75, 20, 140, 'wind', 'lightning', 'earth', 'bird', 75, 130, '山の頂上に住む巨大なワシ'),
                ('goat_mountain', '山ヤギ', 'mountain', 19, 20, 280, 65, 25, 120, 'earth', 'fire', 'water', 'beast', 70, 125, '険しい山を駆け回るヤギ'),
                ('giant_snow', '雪男', 'mountain', 20, 21, 600, 80, 35, 70, 'ice', 'fire', 'lightning', 'humanoid', 85, 150, '雪山に住む巨大な雪男'),
                ('griffin_young', '若いグリフィン', 'mountain', 22, 23, 450, 90, 30, 110, 'wind', 'earth', 'dark', 'mythical', 95, 170, 'ワシとライオンの合体獣'),
                ('dragon_ice', 'アイスドラゴン', 'mountain', 25, 26, 800, 100, 50, 90, 'ice', 'fire', 'physical', 'dragon', 120, 200, '氷の息を吐く中型ドラゴン'),
                ('yeti_alpha', 'アルファイエティ', 'mountain', 24, 25, 700, 95, 40, 85, 'ice', 'fire', 'lightning', 'beast', 110, 185, 'イエティたちのリーダー'),
                ('harpy_mountain', 'マウンテンハーピー', 'mountain', 21, 22, 380, 85, 25, 125, 'wind', 'lightning', 'holy', 'mythical', 90, 160, '美しい声で誘惑する鳥女'),
                ('troll_frost', 'フロストトロル', 'mountain', 23, 24, 650, 85, 45, 75, 'ice', 'fire', 'holy', 'humanoid', 105, 180, '氷の力を操るトロル'),
                ('mammoth_ice', 'アイスマンモス', 'mountain', 26, 27, 900, 90, 55, 60, 'ice', 'fire', 'lightning', 'beast', 125, 210, '氷河期の巨大マンモス'),
                ('phoenix_dark', 'ダークフェニックス', 'mountain', 28, 28, 600, 110, 35, 100, 'dark', 'holy', 'water', 'mythical', 140, 240, '闇に堕ちた不死鳥'),
                ('wolf_dire', 'ダイアウルフ', 'mountain', 19, 20, 350, 70, 22, 130, 'ice', 'fire', 'holy', 'beast', 78, 135, '巨大な狼の祖先'),
                ('bear_cave', 'ケイブベア', 'mountain', 20, 21, 550, 75, 35, 80, 'earth', 'fire', 'ice', 'beast', 82, 145, '洞窟に住む巨大な熊'),
                ('giant_stone', 'ストーンジャイアント', 'mountain', 24, 25, 800, 70, 60, 50, 'earth', 'wind', 'lightning', 'giant', 115, 190, '石でできた巨人'),
                ('wyvern_frost', 'フロストワイバーン', 'mountain', 25, 26, 650, 95, 40, 105, 'ice', 'fire', 'earth', 'dragon', 118, 195, '氷の翼を持つワイバーン'),
                ('elemental_ice', 'アイスエレメンタル', 'mountain', 22, 23, 400, 65, 45, 70, 'ice', 'fire', 'physical', 'elemental', 98, 165, '氷の精霊'),
                ('giant_spider', 'ジャイアントスパイダー', 'mountain', 21, 22, 380, 80, 25, 110, 'poison', 'fire', 'ice', 'beast', 88, 155, '山に住む巨大蜘蛛'),
                ('lich_mountain', 'マウンテンリッチ', 'mountain', 27, 28, 550, 120, 30, 60, 'undead', 'holy', 'fire', 'undead', 135, 230, '山頂の古城に住むリッチ'),
                ('golem_mithril', 'ミスリルゴーレム', 'mountain', 26, 27, 700, 80, 70, 45, 'metal', 'acid', 'lightning', 'machine', 128, 215, 'ミスリルでできた高級ゴーレム'),
                ('cyclops_one_eye', '一つ目巨人', 'mountain', 25, 26, 750, 100, 50, 65, 'earth', 'lightning', 'holy', 'giant', 122, 205, '一つ目の巨人'),
                ('dragon_earth', 'アースドラゴン', 'mountain', 27, 28, 850, 105, 55, 80, 'earth', 'wind', 'water', 'dragon', 138, 235, '大地を操るドラゴン'),
                ('angel_fallen', '堕天使', 'mountain', 28, 28, 500, 125, 25, 120, 'dark', 'holy', 'light', 'angel', 145, 250, '天から堕ちた天使'),
                ('behemoth_mountain', 'マウンテンベヒーモス', 'mountain', 26, 27, 900, 95, 60, 55, 'earth', 'fire', 'ice', 'beast', 130, 220, '山岳地帯の巨大獣'),
                ('sphinx_riddle', 'リドルスフィンクス', 'mountain', 24, 25, 600, 85, 40, 90, 'wind', 'dark', 'physical', 'mythical', 112, 185, '謎かけを出すスフィンクス'),
                ('roc_giant', 'ジャイアントロック', 'mountain', 27, 28, 750, 110, 35, 130, 'wind', 'lightning', 'earth', 'bird', 132, 225, '伝説の巨大鳥'),
                ('titan_lesser', 'レッサータイタン', 'mountain', 28, 28, 1000, 120, 70, 40, 'earth', 'lightning', 'holy', 'titan', 150, 260, '小さなタイタン'),
                
                # === 火山エリア (Level 28-38) === 20体
                ('salamander_lava', 'ラバサラマンダー', 'volcano', 28, 29, 450, 110, 40, 100, 'fire', 'water', 'ice', 'reptile', 125, 210, '溶岩に住むトカゲ'),
                ('phoenix_fire', 'ファイアフェニックス', 'volcano', 32, 33, 600, 140, 35, 120, 'fire', 'water', 'ice', 'mythical', 160, 280, '炎の不死鳥'),
                ('dragon_fire', 'ファイアドラゴン', 'volcano', 35, 36, 1000, 150, 60, 85, 'fire', 'water', 'ice', 'dragon', 180, 320, '炎を吐く強力なドラゴン'),
                ('elemental_fire', 'ファイアエレメンタル', 'volcano', 30, 31, 500, 120, 35, 90, 'fire', 'water', 'ice', 'elemental', 145, 250, '炎の精霊'),
                ('ifrit_lesser', 'レッサーイフリート', 'volcano', 34, 35, 700, 145, 45, 95, 'fire', 'water', 'holy', 'demon', 175, 310, '下級の炎の悪魔'),
                ('golem_magma', 'マグマゴーレム', 'volcano', 33, 34, 800, 125, 70, 50, 'fire', 'water', 'earth', 'elemental', 170, 300, '溶岩でできたゴーレム'),
                ('demon_fire', 'ファイアデーモン', 'volcano', 36, 37, 650, 160, 40, 110, 'fire', 'holy', 'ice', 'demon', 190, 340, '炎を操る中級悪魔'),
                ('wyrm_lava', 'ラバワーム', 'volcano', 31, 32, 600, 115, 50, 80, 'fire', 'water', 'ice', 'dragon', 155, 270, '溶岩の中を泳ぐワーム'),
                ('giant_fire', 'ファイアジャイアント', 'volcano', 37, 38, 1100, 140, 80, 60, 'fire', 'water', 'ice', 'giant', 200, 360, '炎の巨人'),
                ('balrog_young', 'ヤングバルログ', 'volcano', 38, 38, 900, 170, 55, 100, 'fire', 'water', 'holy', 'demon', 220, 400, '若いバルログ'),
                ('hound_hell', 'ヘルハウンド', 'volcano', 29, 30, 400, 105, 30, 125, 'fire', 'water', 'holy', 'beast', 140, 240, '地獄の犬'),
                ('djinn_fire', 'ファイアジン', 'volcano', 32, 33, 550, 135, 25, 115, 'fire', 'water', 'earth', 'elemental', 165, 290, '炎のジン'),
                ('spider_lava', 'ラバスパイダー', 'volcano', 30, 31, 350, 125, 35, 105, 'fire', 'water', 'ice', 'beast', 148, 255, '溶岩に住む蜘蛛'),
                ('chimera_fire', 'ファイアキメラ', 'volcano', 35, 36, 750, 155, 45, 95, 'fire', 'water', 'ice', 'mythical', 185, 330, '炎を吐くキメラ'),
                ('titan_fire', 'ファイアタイタン', 'volcano', 37, 38, 1200, 160, 90, 55, 'fire', 'water', 'earth', 'titan', 205, 370, '炎のタイタン'),
                ('serpent_flame', 'フレイムサーペント', 'volcano', 33, 34, 550, 140, 30, 110, 'fire', 'water', 'ice', 'reptile', 172, 305, '炎の大蛇'),
                ('raven_fire', 'ファイアレイヴン', 'volcano', 29, 30, 300, 110, 20, 140, 'fire', 'water', 'wind', 'bird', 142, 245, '炎を纏ったカラス'),
                ('bat_inferno', 'インフェルノバット', 'volcano', 31, 32, 280, 130, 25, 135, 'fire', 'water', 'holy', 'beast', 158, 275, '地獄の炎をまとうコウモリ'),
                ('scorpion_lava', 'ラバスコーピオン', 'volcano', 34, 35, 450, 145, 55, 90, 'fire', 'water', 'ice', 'beast', 178, 315, '溶岩のサソリ'),
                ('ancient_fire', 'エンシェントファイア', 'volcano', 38, 38, 800, 180, 60, 85, 'fire', 'water', 'holy', 'elemental', 225, 410, '古代の炎の精霊'),
                
                # === 深淵エリア (Level 38-50) === 10体
                ('shadow_lord', 'シャドウロード', 'abyss', 40, 42, 1200, 200, 70, 120, 'dark', 'holy', 'light', 'demon', 280, 500, '闇の領主'),
                ('void_dragon', 'ヴォイドドラゴン', 'abyss', 45, 47, 1500, 220, 80, 100, 'void', 'holy', 'light', 'dragon', 350, 650, '虚無のドラゴン'),
                ('demon_arch', 'アーチデーモン', 'abyss', 42, 44, 1300, 210, 75, 110, 'dark', 'holy', 'fire', 'demon', 320, 580, '上級悪魔'),
                ('lich_ancient', 'エンシェントリッチ', 'abyss', 44, 46, 1000, 240, 60, 80, 'undead', 'holy', 'fire', 'undead', 340, 620, '古代のリッチ'),
                ('titan_void', 'ヴォイドタイタン', 'abyss', 46, 48, 1800, 190, 100, 60, 'void', 'holy', 'light', 'titan', 380, 700, '虚無のタイタン'),
                ('seraph_fallen', '堕天熾天使', 'abyss', 48, 50, 1100, 260, 50, 130, 'dark', 'holy', 'light', 'angel', 420, 800, '堕ちた最高位の天使'),
                ('hydra_chaos', 'カオスヒドラ', 'abyss', 43, 45, 1400, 180, 85, 90, 'chaos', 'holy', 'order', 'dragon', 360, 660, '混沌の多頭竜'),
                ('kraken_abyss', 'アビスクラーケン', 'abyss', 41, 43, 1600, 170, 90, 70, 'water', 'lightning', 'fire', 'beast', 300, 540, '深淵の大タコ'),
                ('phoenix_void', 'ヴォイドフェニックス', 'abyss', 47, 49, 900, 250, 40, 140, 'void', 'holy', 'life', 'mythical', 400, 750, '虚無の不死鳥'),
                ('god_false', '偽りの神', 'abyss', 50, 50, 2000, 300, 120, 80, 'divine', 'void', 'chaos', 'god', 500, 1000, '神を騙る存在')
            ]
            
            created_count = 0
            skipped_count = 0
            
            # 既存のモンスターをチェック
            existing_monsters = set()
            result = conn.execute(text("SELECT id FROM monster_masters"))
            for row in result:
                existing_monsters.add(row[0])
            
            for monster_data in monsters_data:
                (monster_id, name, area_id, level_min, level_max, hp, attack, defense, speed, 
                 element, weakness, resistance, monster_type, base_gold_reward, experience_reward, description) = monster_data
                
                if monster_id in existing_monsters:
                    skipped_count += 1
                    continue
                
                # モンスターを投入
                monster_sql = """
                INSERT INTO monster_masters 
                (id, name, area_id, level_min, level_max, hp, attack, defense, speed, 
                 element, weakness, resistance, monster_type, base_gold_reward, experience_reward, 
                 description, level, is_active) 
                VALUES (:id, :name, :area_id, :level_min, :level_max, :hp, :attack, :defense, :speed,
                         :element, :weakness, :resistance, :monster_type, :base_gold_reward, :experience_reward,
                         :description, :level, true)
                """
                
                conn.execute(text(monster_sql), {
                    "id": monster_id,
                    "name": name,
                    "area_id": area_id,
                    "level_min": level_min,
                    "level_max": level_max,
                    "hp": hp,
                    "attack": attack,
                    "defense": defense,
                    "speed": speed,
                    "element": element,
                    "weakness": weakness,
                    "resistance": resistance,
                    "monster_type": monster_type,
                    "base_gold_reward": base_gold_reward,
                    "experience_reward": experience_reward,
                    "description": description,
                    "level": level_min  # レベルフィールド用
                })
                
                created_count += 1
                
                if created_count % 20 == 0:
                    print(f'進行状況: {created_count} モンスター作成完了')
            
            # 結果確認
            result = conn.execute(text("SELECT COUNT(*) FROM monster_masters"))
            total_monsters = result.scalar()
            
            # エリア別分布
            result = conn.execute(text("""
            SELECT area_id, COUNT(*) as count 
            FROM monster_masters 
            GROUP BY area_id 
            ORDER BY area_id
            """))
            
            print(f'\n=== 包括的モンスター投入完了 ===')
            print(f'新規作成モンスター: {created_count} 体')
            print(f'スキップ済み: {skipped_count} 体')
            print(f'総モンスター数: {total_monsters} 体')
            
            print(f'\nエリア別分布:')
            for row in result:
                print(f'  {row[0]}: {row[1]}体')
                
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    main()