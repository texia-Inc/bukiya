#!/usr/bin/env python3
"""
包括的なアドベンチャラーキャラクターシードデータ
固有キャラクターの詳細なデータを復旧・拡張する
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text

def main():
    print('🌟 包括的なアドベンチャラーキャラクターデータを投入中...')
    
    # Use postgres service name for Docker execution
    db_url = "postgresql://bukiya_user:bukiya_password@postgres:5432/bukiya_game"
    engine = create_engine(db_url)
    
    with engine.begin() as conn:
        try:
            # 既存のデータをクリア
            conn.execute(text("DELETE FROM player_character_bonds"))
            conn.execute(text("DELETE FROM adventurer_characters"))
            print("📦 既存の固有キャラクターデータをクリア")
            
            # 包括的なアドベンチャラーキャラクターデータ
            characters_sql = """
            INSERT INTO adventurer_characters (
                name, title, profession, rarity, base_level, max_level, max_trust_level,
                unlock_player_level, base_stats, growth_rates, preferred_weapon_types,
                elemental_affinity, personality, backstory, quote, color_theme,
                special_abilities, passive_skills, dragon_battle_eligible,
                leadership_bonus, team_synergy, is_story_character, unlock_order,
                is_limited_time, is_active
            ) VALUES
            
            -- ★ メインストーリーキャラクター (5人)
            ('アリス', '見習い冒険者', 'warrior', 'common', 1, 50, 100, 1,
             '{"attack": 12, "defense": 8, "speed": 6, "magic": 2}',
             '{"attack": 1.3, "defense": 1.2, "speed": 1.0, "magic": 0.8}',
             ARRAY['sword', 'dagger'], NULL, 'friendly',
             '小さな村出身の少女。剣を握って間もないが、努力家で仲間想い。',
             'みんなで一緒に頑張りましょう！', '#FF6B8A',
             '[{"name": "初心者の幸運", "description": "最初の武器強化が50%成功率アップ"}]',
             '[{"name": "チームワーク", "description": "パーティ全体のモラル+10%"}]',
             false, 5, '{"リオン": 1.2, "エリー": 1.1}', true, 1, false, true),
            
            ('リオン', '若き射手', 'archer', 'common', 2, 55, 100, 3,
             '{"attack": 14, "defense": 6, "speed": 12, "magic": 4}',
             '{"attack": 1.2, "defense": 1.0, "speed": 1.4, "magic": 1.1}',
             ARRAY['bow'], 'wind', 'normal',
             '森で育った青年。動物との対話ができ、風の魔法も少し扱える。',
             '風よ、俺の矢を導け！', '#4CAF50',
             '[{"name": "精密射撃", "description": "クリティカル率+15%"}]',
             '[{"name": "森の知識", "description": "素材収集時ボーナス+20%"}]',
             false, 8, '{"アリス": 1.2, "ガルド": 1.1}', true, 2, false, true),
            
            ('エリー', '魔法学徒', 'mage', 'rare', 3, 60, 120, 5,
             '{"attack": 6, "defense": 4, "speed": 8, "magic": 18}',
             '{"attack": 0.8, "defense": 0.9, "speed": 1.1, "magic": 1.5}',
             ARRAY['staff'], 'arcane', 'stingy',
             '魔法学院の特待生。プライドが高いが、実力は確か。節約家。',
             '魔法の真理を解き明かしてみせる！', '#9C27B0',
             '[{"name": "魔法増幅", "description": "魔法武器の威力+25%"}]',
             '[{"name": "魔力節約", "description": "魔法使用時のマナ消費-20%"}]',
             true, 12, '{"セレナ": 1.3, "アリス": 1.1}', true, 3, false, true),
            
            ('ガルド', '歴戦の戦士', 'warrior', 'rare', 15, 70, 150, 10,
             '{"attack": 22, "defense": 18, "speed": 8, "magic": 3}',
             '{"attack": 1.4, "defense": 1.3, "speed": 0.9, "magic": 0.7}',
             ARRAY['sword', 'hammer'], 'earth', 'generous',
             '数々の戦場を生き抜いた歴戦の戦士。若い冒険者たちの良き師。',
             '俺の背中を見て学べ！', '#795548',
             '[{"name": "戦場経験", "description": "HPが50%以下で攻撃力+30%"}]',
             '[{"name": "指導者", "description": "パーティの経験値獲得+15%"}]',
             true, 15, '{"アリス": 1.3, "リオン": 1.2}', true, 4, false, true),
            
            ('セレナ', '賢者', 'mage', 'epic', 25, 80, 200, 15,
             '{"attack": 8, "defense": 10, "speed": 12, "magic": 28}',
             '{"attack": 0.9, "defense": 1.1, "speed": 1.2, "magic": 1.6}',
             ARRAY['staff'], 'light', 'wealthy',
             '古代魔法の研究者。豊富な知識と財力を持つ神秘的な女性。',
             '知識こそが真の力よ', '#FFD700',
             '[{"name": "古代魔法", "description": "全属性魔法威力+40%"}]',
             '[{"name": "賢者の知恵", "description": "アイテム鑑定成功率+50%"}]',
             true, 20, '{"エリー": 1.4, "全員": 1.1}', true, 5, false, true),
            
            -- ★ サブキャラクター群 (10人)
            ('ルナ', '月の踊り子', 'rogue', 'rare', 8, 60, 120, 8,
             '{"attack": 16, "defense": 8, "speed": 18, "magic": 6}',
             '{"attack": 1.3, "defense": 1.0, "speed": 1.5, "magic": 1.2}',
             ARRAY['dagger'], 'dark', 'mysterious',
             '月明かりの下で舞うように戦う謎多き盗賊。',
             '月影に踊り、敵を翻弄する', '#6A1B9A',
             '[{"name": "影分身", "description": "回避率+25%"}]',
             '[{"name": "夜行性", "description": "夜間戦闘で全能力+20%"}]',
             false, 10, '{"アリス": 1.1}', false, 6, false, true),
            
            ('ブレイク', '鋼鉄の盾', 'paladin', 'rare', 12, 65, 130, 12,
             '{"attack": 14, "defense": 24, "speed": 4, "magic": 8}',
             '{"attack": 1.1, "defense": 1.5, "speed": 0.8, "magic": 1.2}',
             ARRAY['sword', 'hammer'], 'light', 'loyal',
             '正義を愛する聖騎士。仲間を守ることに命をかける。',
             'この盾がある限り、誰も傷つけさせない', '#03A9F4',
             '[{"name": "聖なる守護", "description": "パーティのダメージ軽減+20%"}]',
             '[{"name": "不屈の意志", "description": "状態異常耐性+50%"}]',
             true, 18, '{"ガルド": 1.2, "全員": 1.05}', false, 7, false, true),
            
            ('フィア', '炎の精霊使い', 'mage', 'epic', 18, 75, 160, 18,
             '{"attack": 10, "defense": 8, "speed": 14, "magic": 26}',
             '{"attack": 1.0, "defense": 1.0, "speed": 1.3, "magic": 1.5}',
             ARRAY['staff'], 'fire', 'passionate',
             '炎の精霊と契約した情熱的な魔法使い。',
             '我が炎で全てを焼き尽くす！', '#FF5722',
             '[{"name": "炎の化身", "description": "火属性魔法威力+60%"}]',
             '[{"name": "熱血", "description": "クリティカル時に追加炎ダメージ"}]',
             true, 22, '{"セレナ": 1.2, "エリー": 1.1}', false, 8, false, true),
            
            ('アイス', '氷雪の射手', 'archer', 'epic', 20, 75, 150, 20,
             '{"attack": 20, "defense": 10, "speed": 16, "magic": 12}',
             '{"attack": 1.4, "defense": 1.1, "speed": 1.3, "magic": 1.2}',
             ARRAY['bow'], 'ice', 'cool',
             '極北から来た冷静沈着な弓使い。氷の魔法も操る。',
             '氷点下の精密さで仕留める', '#00BCD4',
             '[{"name": "氷結射撃", "description": "攻撃時30%で敵を凍結"}]',
             '[{"name": "冷静沈着", "description": "常に冷静、混乱耐性100%"}]',
             true, 25, '{"リオン": 1.3, "フィア": 0.8}', false, 9, false, true),
            
            ('ドラン', '竜の血を引く者', 'warrior', 'legendary', 30, 90, 250, 25,
             '{"attack": 32, "defense": 22, "speed": 12, "magic": 16}',
             '{"attack": 1.5, "defense": 1.3, "speed": 1.1, "magic": 1.3}',
             ARRAY['sword'], 'dragon', 'noble',
             '古き竜族の血を引く高貴な戦士。真の力はまだ目覚めていない。',
             '竜の誇りにかけて！', '#D32F2F',
             '[{"name": "竜の怒り", "description": "HP低下で攻撃力倍増"}]',
             '[{"name": "竜鱗", "description": "物理ダメージ軽減30%"}]',
             true, 50, '{"ガルド": 1.4, "全員": 1.2}', false, 10, false, true),
            
            ('ミスティ', '時の魔女', 'mage', 'legendary', 35, 95, 300, 30,
             '{"attack": 12, "defense": 16, "speed": 20, "magic": 40}',
             '{"attack": 1.0, "defense": 1.2, "speed": 1.4, "magic": 1.8}',
             ARRAY['staff'], 'time', 'enigmatic',
             '時間を操る禁断の魔法を研究する謎の魔女。',
             '時よ、私の意のままに', '#9E9E9E',
             '[{"name": "時間操作", "description": "ターン順操作可能"}]',
             '[{"name": "予知", "description": "敵の攻撃を50%で回避"}]',
             true, 80, '{"セレナ": 1.5, "エリー": 1.3}', false, 11, false, true),
            
            ('サンダー', '雷神の使い', 'archer', 'legendary', 32, 90, 280, 28,
             '{"attack": 28, "defense": 14, "speed": 24, "magic": 18}',
             '{"attack": 1.5, "defense": 1.1, "speed": 1.5, "magic": 1.4}',
             ARRAY['bow'], 'thunder', 'wild',
             '雷神に選ばれし者。雷の矢で敵を貫く。',
             '雷鳴よ、我が矢と共に！', '#FFEB3B',
             '[{"name": "雷神の矢", "description": "攻撃時全敵にダメージ"}]',
             '[{"name": "電撃耐性", "description": "雷属性ダメージ無効"}]',
             true, 70, '{"リオン": 1.4, "アイス": 1.2}', false, 12, false, true),
            
            ('シャドウ', '影の暗殺者', 'rogue', 'legendary', 28, 85, 200, 25,
             '{"attack": 30, "defense": 8, "speed": 32, "magic": 10}',
             '{"attack": 1.6, "defense": 0.9, "speed": 1.7, "magic": 1.2}',
             ARRAY['dagger'], 'shadow', 'silent',
             '完璧な暗殺技術を持つ影の一族の末裔。',
             '...', '#424242',
             '[{"name": "一撃必殺", "description": "低確率で即死攻撃"}]',
             '[{"name": "透明化", "description": "戦闘開始時しばらく無敵"}]',
             true, 60, '{"ルナ": 1.5}', false, 13, false, true),
            
            ('オーロラ', '光の聖女', 'paladin', 'legendary', 26, 85, 350, 22,
             '{"attack": 16, "defense": 20, "speed": 14, "magic": 30}',
             '{"attack": 1.2, "defense": 1.4, "speed": 1.2, "magic": 1.6}',
             ARRAY['staff', 'sword'], 'holy', 'compassionate',
             '女神の加護を受けた聖女。全ての生命を愛する。',
             '光よ、迷える魂を導きたまえ', '#FFFFFF',
             '[{"name": "神聖治癒", "description": "戦闘後パーティ全回復"}]',
             '[{"name": "聖なる加護", "description": "パーティの全耐性+25%"}]',
             true, 100, '{"全員": 1.3}', false, 14, false, true),
            
            ('ヴォイド', '虚無の王', 'warrior', 'legendary', 40, 100, 500, 35,
             '{"attack": 45, "defense": 30, "speed": 18, "magic": 25}',
             '{"attack": 1.8, "defense": 1.5, "speed": 1.3, "magic": 1.5}',
             ARRAY['sword'], 'void', 'transcendent',
             '全てを無に帰す力を持つ超越者。真の最終ボス級の存在。',
             '虚無こそが真理...', '#000000',
             '[{"name": "虚無の剣", "description": "防御無視攻撃"}]',
             '[{"name": "超越", "description": "全状態異常無効"}]',
             true, 200, '{}', false, 15, false, true)
            """
            
            conn.execute(text(characters_sql))
            print("✨ 15人の包括的なアドベンチャラーキャラクターを作成")
            
            # 統計情報を表示
            result = conn.execute(text("SELECT COUNT(*) FROM adventurer_characters"))
            total_count = result.scalar()
            
            result = conn.execute(text("""
                SELECT rarity, COUNT(*) as count 
                FROM adventurer_characters 
                GROUP BY rarity 
                ORDER BY 
                    CASE rarity 
                        WHEN 'common' THEN 1 
                        WHEN 'rare' THEN 2 
                        WHEN 'epic' THEN 3 
                        WHEN 'legendary' THEN 4 
                        ELSE 5 
                    END
            """))
            
            print(f"\n📊 キャラクター統計:")
            print(f"   総キャラクター数: {total_count}")
            for rarity, count in result:
                print(f"   {rarity}: {count}人")
            
            result = conn.execute(text("""
                SELECT profession, COUNT(*) as count 
                FROM adventurer_characters 
                GROUP BY profession 
                ORDER BY count DESC
            """))
            
            print(f"\n⚔️ 職業分布:")
            for profession, count in result:
                print(f"   {profession}: {count}人")
            
            print("\n🎉 包括的なアドベンチャラーキャラクターデータ投入完了！")
            
        except Exception as e:
            print(f"❌ エラー: {e}")
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()