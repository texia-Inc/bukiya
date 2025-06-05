#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('武器データを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 既存武器データのみクリア（武器に関連するもののみ）
            # 武器に関連するデータのみクリアして、新しい100個の武器を追加
            conn.execute(text("DELETE FROM player_weapons"))
            conn.execute(text("DELETE FROM crafting_recipes"))
            conn.execute(text("DELETE FROM weapon_masters"))
            conn.commit()
            print('既存武器データクリア完了')
            
            # 武器タイプ挿入（ON CONFLICT を使用して既存データは更新）
            weapon_types_sql = """
            INSERT INTO weapon_types (id, name, description, is_active, created_at, updated_at) VALUES
            ('sword', '剣', '近接戦闘用の刃物武器', true, NOW(), NOW()),
            ('bow', '弓', '遠距離攻撃用の射撃武器', true, NOW(), NOW()),
            ('staff', '杖', '魔法を扱うための武器', true, NOW(), NOW()),
            ('dagger', '短剣', '素早い攻撃が可能な小型武器', true, NOW(), NOW()),
            ('hammer', 'ハンマー', '重厚な攻撃力を持つ鈍器', true, NOW(), NOW())
            ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            updated_at = NOW()
            """
            conn.execute(text(weapon_types_sql))
            print('武器タイプ 5 件作成/更新')
            
            # レアリティ挿入（ON CONFLICT を使用して既存データは更新）
            rarity_sql = """
            INSERT INTO rarity_levels (id, name, description, color_code, multiplier, drop_rate, is_active, created_at, updated_at) VALUES
            (1, 'コモン', '一般的な品質', '#808080', 1.0, 60.0, true, NOW(), NOW()),
            (2, 'アンコモン', '少し珍しい品質', '#008000', 1.2, 25.0, true, NOW(), NOW()),
            (3, 'レア', '希少な品質', '#0080ff', 1.5, 10.0, true, NOW(), NOW()),
            (4, 'エピック', '非常に希少な品質', '#8000ff', 2.0, 4.0, true, NOW(), NOW()),
            (5, 'レジェンダリー', '伝説級の品質', '#ff8000', 3.0, 1.0, true, NOW(), NOW())
            ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            color_code = EXCLUDED.color_code,
            multiplier = EXCLUDED.multiplier,
            drop_rate = EXCLUDED.drop_rate,
            updated_at = NOW()
            """
            conn.execute(text(rarity_sql))
            print('レアリティ 5 件作成/更新')
            
            # 武器データ挿入（100個の武器）
            weapons_sql = """
            INSERT INTO weapon_masters (name, description, weapon_type_id, rarity_id, base_attack, base_price, required_level, is_craftable, is_active, created_at, updated_at) VALUES
            -- 剣系武器 (20個)
            ('ブロンズソード', '初心者向けの青銅製の剣', 'sword', 1, 10, 50, 1, true, true, NOW(), NOW()),
            ('アイアンソード', '鉄製の丈夫な剣', 'sword', 1, 18, 100, 3, true, true, NOW(), NOW()),
            ('スチールブレード', '鋼鉄製の切れ味鋭い剣', 'sword', 2, 25, 200, 5, true, true, NOW(), NOW()),
            ('シルバーソード', '銀の力を宿した美しい剣', 'sword', 3, 35, 500, 8, true, true, NOW(), NOW()),
            ('フレイムブレード', '炎の力を宿した魔法の剣', 'sword', 4, 50, 1200, 12, true, true, NOW(), NOW()),
            ('エクスカリバー', '伝説の聖剣', 'sword', 5, 80, 5000, 20, false, true, NOW(), NOW()),
            ('ロングソード', '長めの刃を持つ剣', 'sword', 1, 15, 80, 1, true, true, NOW(), NOW()),
            ('バスタードソード', '両手持ちの大剣', 'sword', 2, 30, 250, 6, true, true, NOW(), NOW()),
            ('クリスタルソード', '水晶でできた透明な剣', 'sword', 3, 40, 600, 10, true, true, NOW(), NOW()),
            ('ドラゴンスレイヤー', 'ドラゴンを討伐するための専用剣', 'sword', 4, 65, 2000, 18, true, true, NOW(), NOW()),
            ('カタナ', '東方の技術で作られた湾曲した刃', 'sword', 3, 38, 550, 9, true, true, NOW(), NOW()),
            ('シミター', '湾曲した刃を持つ軽量剣', 'sword', 2, 22, 180, 4, true, true, NOW(), NOW()),
            ('ダマスカスブレード', 'ダマスカス鋼で作られた名剣', 'sword', 4, 55, 1500, 15, true, true, NOW(), NOW()),
            ('アイスブレード', '氷の力を宿した冷たい剣', 'sword', 3, 42, 650, 11, true, true, NOW(), NOW()),
            ('サンダーソード', '雷の力を宿した電撃剣', 'sword', 4, 48, 1100, 13, true, true, NOW(), NOW()),
            ('ミスリルソード', '幻の金属ミスリル製の剣', 'sword', 5, 75, 4000, 19, true, true, NOW(), NOW()),
            ('ホーリーブレード', '聖なる力を宿した神聖剣', 'sword', 5, 70, 3500, 17, false, true, NOW(), NOW()),
            ('デモンスレイヤー', '悪魔を滅する聖剣', 'sword', 4, 60, 1800, 16, true, true, NOW(), NOW()),
            ('ヴォイドブレード', '虚無の力を纏った漆黒の剣', 'sword', 5, 85, 6000, 22, false, true, NOW(), NOW()),
            ('グラディウス', '古代の戦士が使った短剣', 'sword', 2, 20, 150, 3, true, true, NOW(), NOW()),
            
            -- 弓系武器 (20個)
            ('ウッドボウ', '木製の基本的な弓', 'bow', 1, 8, 40, 1, true, true, NOW(), NOW()),
            ('ショートボウ', '軽量で扱いやすい短弓', 'bow', 1, 12, 60, 1, true, true, NOW(), NOW()),
            ('ロングボウ', '射程の長い戦闘用の弓', 'bow', 2, 20, 150, 4, true, true, NOW(), NOW()),
            ('コンポジットボウ', '複数素材で作られた高性能弓', 'bow', 2, 25, 200, 5, true, true, NOW(), NOW()),
            ('エルヴンボウ', 'エルフの技術で作られた美しい弓', 'bow', 3, 32, 450, 7, true, true, NOW(), NOW()),
            ('ウィンドボウ', '風の力を纏った弓', 'bow', 3, 35, 500, 8, true, true, NOW(), NOW()),
            ('フレイムボウ', '炎の矢を放つ魔法の弓', 'bow', 4, 45, 1000, 11, true, true, NOW(), NOW()),
            ('アイスボウ', '氷の矢を放つ氷結の弓', 'bow', 4, 42, 950, 10, true, true, NOW(), NOW()),
            ('サンダーボウ', '雷の矢を放つ電撃の弓', 'bow', 4, 48, 1100, 12, true, true, NOW(), NOW()),
            ('ドラゴンボウ', 'ドラゴンの力を宿した伝説の弓', 'bow', 5, 70, 3500, 18, false, true, NOW(), NOW()),
            ('クロスボウ', '機械式の弩', 'bow', 2, 28, 220, 6, true, true, NOW(), NOW()),
            ('リカーブボウ', '反り返った形状の高性能弓', 'bow', 3, 38, 550, 9, true, true, NOW(), NOW()),
            ('ハンターボウ', '狩猟専用に作られた弓', 'bow', 2, 22, 170, 4, true, true, NOW(), NOW()),
            ('シャドウボウ', '影の力を宿した暗黒の弓', 'bow', 4, 52, 1300, 14, true, true, NOW(), NOW()),
            ('ライトボウ', '光の力を放つ聖なる弓', 'bow', 4, 50, 1200, 13, true, true, NOW(), NOW()),
            ('ミスリルボウ', '幻の金属で作られた軽量弓', 'bow', 5, 65, 3000, 16, true, true, NOW(), NOW()),
            ('フェニックスボウ', '不死鳥の羽で作られた神話の弓', 'bow', 5, 75, 4000, 19, false, true, NOW(), NOW()),
            ('ヴォイドボウ', '虚無の力を放つ究極の弓', 'bow', 5, 80, 5000, 21, false, true, NOW(), NOW()),
            ('ウォーボウ', '戦争用の重装弓', 'bow', 3, 40, 600, 10, true, true, NOW(), NOW()),
            ('アルテミスボウ', '狩猟の女神の加護を受けた弓', 'bow', 5, 72, 3800, 18, false, true, NOW(), NOW()),
            
            -- 杖系武器 (20個)
            ('ウッドスタッフ', '木製の基本的な杖', 'staff', 1, 6, 35, 1, true, true, NOW(), NOW()),
            ('マジックワンド', '魔法を扱うための短い杖', 'staff', 1, 10, 50, 1, true, true, NOW(), NOW()),
            ('アイアンロッド', '鉄芯入りの頑丈な杖', 'staff', 2, 18, 120, 3, true, true, NOW(), NOW()),
            ('ファイアスタッフ', '炎の力を増幅する赤い杖', 'staff', 3, 30, 400, 6, true, true, NOW(), NOW()),
            ('アイススタッフ', '氷の力を増幅する青い杖', 'staff', 3, 28, 380, 5, true, true, NOW(), NOW()),
            ('サンダースタッフ', '雷の力を増幅する黄色い杖', 'staff', 3, 32, 420, 7, true, true, NOW(), NOW()),
            ('クリスタルロッド', '水晶で作られた透明な杖', 'staff', 4, 40, 800, 9, true, true, NOW(), NOW()),
            ('アークメイジスタッフ', '大魔法使いの杖', 'staff', 4, 50, 1200, 12, true, true, NOW(), NOW()),
            ('ドラゴンスタッフ', 'ドラゴンの骨で作られた杖', 'staff', 5, 65, 3000, 16, false, true, NOW(), NOW()),
            ('ライフスタッフ', '生命力を操る緑の杖', 'staff', 3, 25, 350, 4, true, true, NOW(), NOW()),
            ('デススタッフ', '死の力を操る黒い杖', 'staff', 4, 45, 1000, 11, true, true, NOW(), NOW()),
            ('ホーリースタッフ', '聖なる力を宿した白い杖', 'staff', 4, 42, 900, 10, true, true, NOW(), NOW()),
            ('エルダーワンド', '古代魔法使いの遺品', 'staff', 5, 60, 2500, 14, false, true, NOW(), NOW()),
            ('スタッフ・オブ・パワー', '魔力を極限まで増幅する杖', 'staff', 5, 70, 3500, 18, false, true, NOW(), NOW()),
            ('ヴォイドスタッフ', '虚無の力を操る究極の杖', 'staff', 5, 75, 4000, 20, false, true, NOW(), NOW()),
            ('ネクロスタッフ', '死霊術師の邪悪な杖', 'staff', 4, 48, 1100, 12, true, true, NOW(), NOW()),
            ('エレメンタルスタッフ', '全属性を操る万能杖', 'staff', 5, 68, 3200, 17, true, true, NOW(), NOW()),
            ('ワイザードスタッフ', '賢者の知恵を宿した杖', 'staff', 3, 35, 480, 8, true, true, NOW(), NOW()),
            ('ミスリルロッド', '幻の金属で作られた軽量杖', 'staff', 4, 55, 1400, 14, true, true, NOW(), NOW()),
            ('フェニックスワンド', '不死鳥の羽で作られた神話の杖', 'staff', 5, 72, 3800, 19, false, true, NOW(), NOW()),
            
            -- 短剣系武器 (20個)
            ('アイアンダガー', '鉄製の基本的な短剣', 'dagger', 1, 8, 30, 1, true, true, NOW(), NOW()),
            ('スチールダガー', '鋼鉄製の鋭い短剣', 'dagger', 2, 15, 80, 3, true, true, NOW(), NOW()),
            ('ポイズンダガー', '毒を塗った危険な短剣', 'dagger', 3, 20, 250, 5, true, true, NOW(), NOW()),
            ('シルバーダガー', '銀製の美しい短剣', 'dagger', 2, 18, 120, 4, true, true, NOW(), NOW()),
            ('シャドウブレード', '影の力を宿した暗殺者の短剣', 'dagger', 4, 35, 700, 8, true, true, NOW(), NOW()),
            ('フレイムダガー', '炎の力を宿した灼熱の短剣', 'dagger', 3, 25, 300, 6, true, true, NOW(), NOW()),
            ('アイスダガー', '氷の力を宿した冷徹な短剣', 'dagger', 3, 23, 280, 5, true, true, NOW(), NOW()),
            ('サンダーダガー', '雷の力を宿した電撃の短剣', 'dagger', 3, 27, 320, 7, true, true, NOW(), NOW()),
            ('ドラゴンファング', 'ドラゴンの牙で作られた短剣', 'dagger', 4, 40, 900, 10, false, true, NOW(), NOW()),
            ('アサシンブレード', '暗殺者専用の特殊短剣', 'dagger', 4, 38, 800, 9, true, true, NOW(), NOW()),
            ('ヴァンパイアファング', '吸血鬼の牙を模した短剣', 'dagger', 4, 42, 950, 11, true, true, NOW(), NOW()),
            ('クリスタルダガー', '水晶で作られた透明な短剣', 'dagger', 3, 30, 380, 7, true, true, NOW(), NOW()),
            ('ミスリルダガー', '幻の金属で作られた軽量短剣', 'dagger', 5, 50, 2000, 13, true, true, NOW(), NOW()),
            ('ヴォイドダガー', '虚無の力を宿した究極の短剣', 'dagger', 5, 55, 2500, 15, false, true, NOW(), NOW()),
            ('ホーリーダガー', '聖なる力を宿した神聖短剣', 'dagger', 4, 36, 750, 8, true, true, NOW(), NOW()),
            ('カース・ダガー', '呪いの力を宿した邪悪な短剣', 'dagger', 4, 44, 1000, 12, true, true, NOW(), NOW()),
            ('ルーンダガー', '古代ルーンが刻まれた短剣', 'dagger', 3, 32, 400, 7, true, true, NOW(), NOW()),
            ('ブラッディダガー', '血に染まった恐怖の短剣', 'dagger', 3, 28, 350, 6, true, true, NOW(), NOW()),
            ('パラライズダガー', '麻痺効果のある特殊短剣', 'dagger', 3, 26, 330, 6, true, true, NOW(), NOW()),
            ('スピードダガー', '素早い攻撃に特化した短剣', 'dagger', 2, 22, 180, 4, true, true, NOW(), NOW()),
            
            -- ハンマー系武器 (20個)
            ('アイアンハンマー', '鉄製の基本的なハンマー', 'hammer', 1, 15, 70, 1, true, true, NOW(), NOW()),
            ('スチールハンマー', '鋼鉄製の重いハンマー', 'hammer', 2, 25, 150, 4, true, true, NOW(), NOW()),
            ('ウォーハンマー', '戦争用の大型ハンマー', 'hammer', 2, 30, 200, 5, true, true, NOW(), NOW()),
            ('サンダーハンマー', '雷の力を宿した電撃ハンマー', 'hammer', 3, 40, 500, 8, true, true, NOW(), NOW()),
            ('アースクラッシャー', '大地を砕く巨大ハンマー', 'hammer', 3, 45, 600, 10, true, true, NOW(), NOW()),
            ('フレイムハンマー', '炎の力を宿した灼熱ハンマー', 'hammer', 3, 42, 550, 9, true, true, NOW(), NOW()),
            ('アイスハンマー', '氷の力を宿した氷結ハンマー', 'hammer', 3, 38, 480, 7, true, true, NOW(), NOW()),
            ('ドラゴンハンマー', 'ドラゴンの力を宿した伝説ハンマー', 'hammer', 4, 60, 1500, 14, false, true, NOW(), NOW()),
            ('ソウルクラッシャー', '魂を砕く邪悪なハンマー', 'hammer', 4, 55, 1300, 12, true, true, NOW(), NOW()),
            ('ホーリーハンマー', '聖なる力を宿した神聖ハンマー', 'hammer', 4, 50, 1200, 11, true, true, NOW(), NOW()),
            ('ミスリルハンマー', '幻の金属で作られた軽量ハンマー', 'hammer', 5, 70, 3000, 16, true, true, NOW(), NOW()),
            ('ヴォイドハンマー', '虚無の力を操る究極ハンマー', 'hammer', 5, 80, 4000, 18, false, true, NOW(), NOW()),
            ('クリスタルハンマー', '水晶で作られた透明なハンマー', 'hammer', 3, 35, 420, 6, true, true, NOW(), NOW()),
            ('ジャイアントハンマー', '巨人が使う超大型ハンマー', 'hammer', 4, 65, 1800, 15, true, true, NOW(), NOW()),
            ('デモンハンマー', '悪魔の力を宿した邪悪ハンマー', 'hammer', 4, 58, 1400, 13, true, true, NOW(), NOW()),
            ('フェニックスハンマー', '不死鳥の力を宿した神話ハンマー', 'hammer', 5, 75, 3500, 17, false, true, NOW(), NOW()),
            ('カオスハンマー', '混沌の力を操る破滅ハンマー', 'hammer', 5, 85, 5000, 20, false, true, NOW(), NOW()),
            ('ライトニングメイス', '雷神の加護を受けた神聖メイス', 'hammer', 4, 52, 1250, 11, true, true, NOW(), NOW()),
            ('ブラッドハンマー', '血に飢えた呪われたハンマー', 'hammer', 3, 48, 650, 10, true, true, NOW(), NOW()),
            ('ゴッドハンマー', '神々の力を宿した最強ハンマー', 'hammer', 5, 90, 10000, 25, false, true, NOW(), NOW())
            """
            
            conn.execute(text(weapons_sql))
            conn.commit()
            print('武器マスター 100 件作成')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_types"))
            weapon_type_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM rarity_levels"))
            rarity_count = result.scalar()
            
            print(f'\n=== データ投入結果 ===')
            print(f'武器タイプ: {weapon_type_count} 件')
            print(f'レアリティ: {rarity_count} 件')
            print(f'武器マスター: {weapon_count} 件')
            print('\n武器データ投入完了！')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()