#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def map_rarity_id(old_id):
    """古いrarity_id(数値)を新しいrarity_id(文字列)にマッピング"""
    if old_id in [1, '1']:
        return '1'
    elif old_id in [2, '2']:
        return '2'
    elif old_id in [3, '3']:
        return '3'
    elif old_id in [4, '4', 5, '5']:
        return '4'
    else:
        return '1'

def main():
    print('100個の武器データを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 既存武器データクリア
            conn.execute(text("DELETE FROM weapon_masters"))
            conn.commit()
            print('既存武器データクリア完了')
            
            # 100個の武器データを投入
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, description, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, required_shop_level, is_active, created_at, updated_at) VALUES
            -- 剣系武器 (20個)
            ('bronze_sword_new', 'ブロンズソード', '初心者向けの青銅製の剣', 'sword', '1', 8, 12, 40, 60, 1, true, NOW(), NOW()),
            ('iron_sword_new', 'アイアンソード', '鉄製の丈夫な剣', 'sword', '1', 15, 20, 80, 120, 2, true, NOW(), NOW()),
            ('steel_blade', 'スチールブレード', '鋼鉄製の切れ味鋭い剣', 'sword', '2', 22, 28, 180, 220, 3, true, NOW(), NOW()),
            ('silver_sword_new', 'シルバーソード', '銀の力を宿した美しい剣', 'sword', '3', 30, 40, 450, 550, 5, true, NOW(), NOW()),
            ('flame_blade', 'フレイムブレード', '炎の力を宿った魔法の剣', 'sword', '3', 45, 55, 1000, 1400, 8, true, NOW(), NOW()),
            ('excalibur', 'エクスカリバー', '伝説の聖剣', 'sword', '4', 70, 90, 4500, 5500, 20, true, NOW(), NOW()),
            ('long_sword', 'ロングソード', '長めの刃を持つ剣', 'sword', '1', 12, 18, 70, 90, 1, true, NOW(), NOW()),
            ('bastard_sword', 'バスタードソード', '両手持ちの大剣', 'sword', '2', 25, 35, 200, 300, 6, true, NOW(), NOW()),
            ('crystal_sword', 'クリスタルソード', '水晶でできた透明な剣', 'sword', '3', 35, 45, 500, 700, 10, true, NOW(), NOW()),
            ('dragon_slayer', 'ドラゴンスレイヤー', 'ドラゴンを討伐するための専用剣', 'sword', '4', 55, 75, 1800, 2200, 18, true, NOW(), NOW()),
            ('katana', 'カタナ', '東方の技術で作られた湾曲した刃', 'sword', '3', 32, 44, 480, 620, 9, true, NOW(), NOW()),
            ('scimitar', 'シミター', '湾曲した刃を持つ軽量剣', 'sword', '2', 18, 26, 150, 210, 4, true, NOW(), NOW()),
            ('damascus_blade', 'ダマスカスブレード', 'ダマスカス鋼で作られた名剣', 'sword', '3', 48, 62, 1300, 1700, 15, true, NOW(), NOW()),
            ('ice_blade', 'アイスブレード', '氷の力を宿った冷たい剣', 'sword', '3', 36, 48, 580, 720, 11, true, NOW(), NOW()),
            ('thunder_sword', 'サンダーソード', '雷の力を宿った電撃剣', 'sword', '3', 42, 54, 950, 1250, 13, true, NOW(), NOW()),
            ('mithril_sword', 'ミスリルソード', '幻の金属ミスリル製の剣', 'sword', '4', 65, 85, 3500, 4500, 19, true, NOW(), NOW()),
            ('holy_blade', 'ホーリーブレード', '聖なる力を宿した神聖剣', 'sword', '3', 60, 80, 3000, 4000, 17, true, NOW(), NOW()),
            ('demon_slayer', 'デモンスレイヤー', '悪魔を滅する聖剣', 'sword', '3', 52, 68, 1600, 2000, 16, true, NOW(), NOW()),
            ('void_blade', 'ヴォイドブレード', '虚無の力を纏った漆黒の剣', 'sword', '3', 75, 95, 5500, 6500, 22, true, NOW(), NOW()),
            ('gladius', 'グラディウス', '古代の戦士が使った短剣', 'sword', '2', 16, 24, 120, 180, 3, true, NOW(), NOW()),
            
            -- 弓系武器 (20個)
            ('wood_bow', 'ウッドボウ', '木製の基本的な弓', 'bow', '1', 6, 10, 30, 50, 1, true, NOW(), NOW()),
            ('short_bow', 'ショートボウ', '軽量で扱いやすい短弓', 'bow', '1', 10, 14, 50, 70, 1, true, NOW(), NOW()),
            ('long_bow', 'ロングボウ', '射程の長い戦闘用の弓', 'bow', '2', 18, 22, 130, 170, 4, true, NOW(), NOW()),
            ('composite_bow', 'コンポジットボウ', '複数素材で作られた高性能弓', 'bow', '2', 22, 28, 180, 220, 5, true, NOW(), NOW()),
            ('elven_bow', 'エルヴンボウ', 'エルフの技術で作られた美しい弓', 'bow', '3', 28, 36, 400, 500, 7, true, NOW(), NOW()),
            ('wind_bow', 'ウィンドボウ', '風の力を纏った弓', 'bow', '3', 30, 40, 450, 550, 8, true, NOW(), NOW()),
            ('flame_bow', 'フレイムボウ', '炎の矢を放つ魔法の弓', 'bow', '3', 40, 50, 900, 1100, 11, true, NOW(), NOW()),
            ('ice_bow', 'アイスボウ', '氷の矢を放つ氷結の弓', 'bow', '3', 36, 48, 850, 1050, 10, true, NOW(), NOW()),
            ('thunder_bow', 'サンダーボウ', '雷の矢を放つ電撃の弓', 'bow', '3', 42, 54, 1000, 1200, 12, true, NOW(), NOW()),
            ('dragon_bow', 'ドラゴンボウ', 'ドラゴンの力を宿した伝説の弓', 'bow', '3', 60, 80, 3000, 4000, 18, true, NOW(), NOW()),
            ('crossbow', 'クロスボウ', '機械式の弩', 'bow', '2', 24, 32, 200, 240, 6, true, NOW(), NOW()),
            ('recurve_bow', 'リカーブボウ', '反り返った形状の高性能弓', 'bow', '3', 32, 44, 500, 600, 9, true, NOW(), NOW()),
            ('hunter_bow', 'ハンターボウ', '狩猟専用に作られた弓', 'bow', '2', 19, 25, 150, 190, 4, true, NOW(), NOW()),
            ('shadow_bow', 'シャドウボウ', '影の力を宿した暗黒の弓', 'bow', '3', 46, 58, 1200, 1400, 14, true, NOW(), NOW()),
            ('light_bow', 'ライトボウ', '光の力を放つ聖なる弓', 'bow', '3', 44, 56, 1100, 1300, 13, true, NOW(), NOW()),
            ('mithril_bow', 'ミスリルボウ', '幻の金属で作られた軽量弓', 'bow', '3', 55, 75, 2700, 3300, 16, true, NOW(), NOW()),
            ('phoenix_bow', 'フェニックスボウ', '不死鳥の羽で作られた神話の弓', 'bow', '3', 65, 85, 3600, 4400, 19, true, NOW(), NOW()),
            ('void_bow', 'ヴォイドボウ', '虚無の力を放つ究極の弓', 'bow', '3', 70, 90, 4500, 5500, 21, true, NOW(), NOW()),
            ('war_bow', 'ウォーボウ', '戦争用の重装弓', 'bow', '3', 35, 45, 540, 660, 10, true, NOW(), NOW()),
            ('artemis_bow', 'アルテミスボウ', '狩猟の女神の加護を受けた弓', 'bow', '3', 62, 82, 3400, 4200, 18, true, NOW(), NOW()),
            
            -- 杖系武器 (20個)
            ('wood_staff', 'ウッドスタッフ', '木製の基本的な杖', 'staff', '1', 5, 7, 28, 42, 1, true, NOW(), NOW()),
            ('magic_wand', 'マジックワンド', '魔法を扱うための短い杖', 'staff', '1', 8, 12, 40, 60, 1, true, NOW(), NOW()),
            ('iron_rod', 'アイアンロッド', '鉄芯入りの頑丈な杖', 'staff', '2', 15, 21, 108, 132, 3, true, NOW(), NOW()),
            ('fire_staff', 'ファイアスタッフ', '炎の力を増幅する赤い杖', 'staff', '3', 26, 34, 360, 440, 6, true, NOW(), NOW()),
            ('ice_staff', 'アイススタッフ', '氷の力を増幅する青い杖', 'staff', '3', 24, 32, 340, 420, 5, true, NOW(), NOW()),
            ('thunder_staff', 'サンダースタッフ', '雷の力を増幅する黄色い杖', 'staff', '3', 28, 36, 380, 460, 7, true, NOW(), NOW()),
            ('crystal_rod', 'クリスタルロッド', '水晶で作られた透明な杖', 'staff', '3', 35, 45, 720, 880, 9, true, NOW(), NOW()),
            ('archmage_staff', 'アークメイジスタッフ', '大魔法使いの杖', 'staff', '3', 44, 56, 1080, 1320, 12, true, NOW(), NOW()),
            ('dragon_staff', 'ドラゴンスタッフ', 'ドラゴンの骨で作られた杖', 'staff', '3', 55, 75, 2700, 3300, 16, true, NOW(), NOW()),
            ('life_staff', 'ライフスタッフ', '生命力を操る緑の杖', 'staff', '3', 22, 28, 315, 385, 4, true, NOW(), NOW()),
            ('death_staff', 'デススタッフ', '死の力を操る黒い杖', 'staff', '3', 40, 50, 900, 1100, 11, true, NOW(), NOW()),
            ('holy_staff', 'ホーリースタッフ', '聖なる力を宿した白い杖', 'staff', '3', 37, 47, 810, 990, 10, true, NOW(), NOW()),
            ('elder_wand', 'エルダーワンド', '古代魔法使いの遺品', 'staff', '3', 52, 68, 2250, 2750, 14, true, NOW(), NOW()),
            ('staff_of_power', 'スタッフオブパワー', '魔力を極限まで増幅する杖', 'staff', '3', 60, 80, 3150, 3850, 18, true, NOW(), NOW()),
            ('void_staff', 'ヴォイドスタッフ', '虚無の力を操る究極の杖', 'staff', '3', 65, 85, 3600, 4400, 20, true, NOW(), NOW()),
            ('necro_staff', 'ネクロスタッフ', '死霊術師の邪悪な杖', 'staff', '3', 42, 54, 990, 1210, 12, true, NOW(), NOW()),
            ('elemental_staff', 'エレメンタルスタッフ', '全属性を操る万能杖', 'staff', '3', 58, 78, 2880, 3520, 17, true, NOW(), NOW()),
            ('wizard_staff', 'ワイザードスタッフ', '賢者の知恵を宿した杖', 'staff', '3', 30, 40, 432, 528, 8, true, NOW(), NOW()),
            ('mithril_rod', 'ミスリルロッド', '幻の金属で作られた軽量杖', 'staff', '3', 48, 62, 1260, 1540, 14, true, NOW(), NOW()),
            ('phoenix_wand', 'フェニックスワンド', '不死鳥の羽で作られた神話の杖', 'staff', '3', 62, 82, 3420, 4180, 19, true, NOW(), NOW()),
            
            -- 短剣系武器 (20個)
            ('iron_dagger', 'アイアンダガー', '鉄製の基本的な短剣', 'dagger', '1', 6, 10, 24, 36, 1, true, NOW(), NOW()),
            ('steel_dagger', 'スチールダガー', '鋼鉄製の鋭い短剣', 'dagger', '2', 12, 18, 64, 96, 3, true, NOW(), NOW()),
            ('poison_dagger', 'ポイズンダガー', '毒を塗った危険な短剣', 'dagger', '3', 16, 24, 200, 300, 5, true, NOW(), NOW()),
            ('silver_dagger', 'シルバーダガー', '銀製の美しい短剣', 'dagger', '2', 14, 22, 96, 144, 4, true, NOW(), NOW()),
            ('shadow_blade', 'シャドウブレード', '影の力を宿した暗殺者の短剣', 'dagger', '3', 28, 42, 560, 840, 8, true, NOW(), NOW()),
            ('flame_dagger', 'フレイムダガー', '炎の力を宿した灼熱の短剣', 'dagger', '3', 20, 30, 240, 360, 6, true, NOW(), NOW()),
            ('ice_dagger', 'アイスダガー', '氷の力を宿した冷徹な短剣', 'dagger', '3', 18, 28, 224, 336, 5, true, NOW(), NOW()),
            ('thunder_dagger', 'サンダーダガー', '雷の力を宿した電撃の短剣', 'dagger', '3', 22, 32, 256, 384, 7, true, NOW(), NOW()),
            ('dragon_fang', 'ドラゴンファング', 'ドラゴンの牙で作られた短剣', 'dagger', '3', 32, 48, 720, 1080, 10, true, NOW(), NOW()),
            ('assassin_blade', 'アサシンブレード', '暗殺者専用の特殊短剣', 'dagger', '3', 30, 46, 640, 960, 9, true, NOW(), NOW()),
            ('vampire_fang', 'ヴァンパイアファング', '吸血鬼の牙を模した短剣', 'dagger', '3', 34, 50, 760, 1140, 11, true, NOW(), NOW()),
            ('crystal_dagger', 'クリスタルダガー', '水晶で作られた透明な短剣', 'dagger', '3', 24, 36, 304, 456, 7, true, NOW(), NOW()),
            ('mithril_dagger', 'ミスリルダガー', '幻の金属で作られた軽量短剣', 'dagger', '3', 40, 60, 1600, 2400, 13, true, NOW(), NOW()),
            ('void_dagger', 'ヴォイドダガー', '虚無の力を宿した究極の短剣', 'dagger', '3', 44, 66, 2000, 3000, 15, true, NOW(), NOW()),
            ('holy_dagger', 'ホーリーダガー', '聖なる力を宿した神聖短剣', 'dagger', '3', 29, 43, 600, 900, 8, true, NOW(), NOW()),
            ('curse_dagger', 'カースダガー', '呪いの力を宿した邪悪な短剣', 'dagger', '3', 35, 53, 800, 1200, 12, true, NOW(), NOW()),
            ('rune_dagger', 'ルーンダガー', '古代ルーンが刻まれた短剣', 'dagger', '3', 26, 38, 320, 480, 7, true, NOW(), NOW()),
            ('bloody_dagger', 'ブラッディダガー', '血に染まった恐怖の短剣', 'dagger', '3', 22, 34, 280, 420, 6, true, NOW(), NOW()),
            ('paralyze_dagger', 'パラライズダガー', '麻痺効果のある特殊短剣', 'dagger', '3', 21, 31, 264, 396, 6, true, NOW(), NOW()),
            ('speed_dagger', 'スピードダガー', '素早い攻撃に特化した短剣', 'dagger', '2', 18, 26, 144, 216, 4, true, NOW(), NOW()),
            
            -- ハンマー系武器 (20個)
            ('iron_hammer', 'アイアンハンマー', '鉄製の基本的なハンマー', 'hammer', '1', 12, 18, 56, 84, 1, true, NOW(), NOW()),
            ('steel_hammer', 'スチールハンマー', '鋼鉄製の重いハンマー', 'hammer', '2', 20, 30, 120, 180, 4, true, NOW(), NOW()),
            ('war_hammer', 'ウォーハンマー', '戦争用の大型ハンマー', 'hammer', '2', 24, 36, 160, 240, 5, true, NOW(), NOW()),
            ('thunder_hammer', 'サンダーハンマー', '雷の力を宿した電撃ハンマー', 'hammer', '3', 32, 48, 400, 600, 8, true, NOW(), NOW()),
            ('earth_crusher', 'アースクラッシャー', '大地を砕く巨大ハンマー', 'hammer', '3', 36, 54, 480, 720, 10, true, NOW(), NOW()),
            ('flame_hammer', 'フレイムハンマー', '炎の力を宿った灼熱ハンマー', 'hammer', '3', 34, 50, 440, 660, 9, true, NOW(), NOW()),
            ('ice_hammer', 'アイスハンマー', '氷の力を宿った氷結ハンマー', 'hammer', '3', 30, 46, 384, 576, 7, true, NOW(), NOW()),
            ('dragon_hammer', 'ドラゴンハンマー', 'ドラゴンの力を宿った伝説ハンマー', 'hammer', '3', 48, 72, 1200, 1800, 14, true, NOW(), NOW()),
            ('soul_crusher', 'ソウルクラッシャー', '魂を砕く邪悪なハンマー', 'hammer', '3', 44, 66, 1040, 1560, 12, true, NOW(), NOW()),
            ('holy_hammer', 'ホーリーハンマー', '聖なる力を宿った神聖ハンマー', 'hammer', '3', 40, 60, 960, 1440, 11, true, NOW(), NOW()),
            ('mithril_hammer', 'ミスリルハンマー', '幻の金属で作られた軽量ハンマー', 'hammer', '3', 56, 84, 2400, 3600, 16, true, NOW(), NOW()),
            ('void_hammer', 'ヴォイドハンマー', '虚無の力を操る究極ハンマー', 'hammer', '3', 64, 96, 3200, 4800, 18, true, NOW(), NOW()),
            ('crystal_hammer', 'クリスタルハンマー', '水晶で作られた透明なハンマー', 'hammer', '3', 28, 42, 336, 504, 6, true, NOW(), NOW()),
            ('giant_hammer', 'ジャイアントハンマー', '巨人が使う超大型ハンマー', 'hammer', '3', 52, 78, 1440, 2160, 15, true, NOW(), NOW()),
            ('demon_hammer', 'デモンハンマー', '悪魔の力を宿った邪悪ハンマー', 'hammer', '3', 46, 70, 1120, 1680, 13, true, NOW(), NOW()),
            ('phoenix_hammer', 'フェニックスハンマー', '不死鳥の力を宿った神話ハンマー', 'hammer', '3', 60, 90, 2800, 4200, 17, true, NOW(), NOW()),
            ('chaos_hammer', 'カオスハンマー', '混沌の力を操る破滅ハンマー', 'hammer', '3', 68, 102, 4000, 6000, 20, true, NOW(), NOW()),
            ('lightning_mace', 'ライトニングメイス', '雷神の加護を受けた神聖メイス', 'hammer', '3', 42, 62, 1000, 1500, 11, true, NOW(), NOW()),
            ('blood_hammer', 'ブラッドハンマー', '血に飢えた呪われたハンマー', 'hammer', '3', 38, 58, 520, 780, 10, true, NOW(), NOW()),
            ('god_hammer', 'ゴッドハンマー', '神々の力を宿した最強ハンマー', 'hammer', '3', 72, 108, 8000, 12000, 25, true, NOW(), NOW())
            """
            
            conn.execute(text(weapons_sql))
            conn.commit()
            print('100個の武器マスター投入完了！')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters WHERE rarity_id = '1'"))
            common_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters WHERE rarity_id = '2'"))
            rare_count = result.scalar()
            
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters WHERE rarity_id = '3'"))
            epic_count = result.scalar()
            
            print(f'\n🎉 100個の武器データ投入完了！')
            print(f'✅ 武器総数: {weapon_count} 件')
            print(f'✅ Common: {common_count} 件')
            print(f'✅ Rare: {rare_count} 件')
            print(f'✅ Epic: {epic_count} 件')
            print('\n100個の豊富な武器データが復活しました！')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()