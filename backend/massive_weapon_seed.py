#!/usr/bin/env python3
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('大量武器データを投入中...')
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        try:
            # 大量武器データ挿入（50個の武器）
            weapons_sql = """
            INSERT INTO weapon_masters (id, name, description, weapon_type_id, rarity_id, base_attack_min, base_attack_max, base_price_min, base_price_max, required_shop_level, is_active, created_at, updated_at) VALUES
            -- 剣系武器 (20個)
            ('bronze_sword_mk2', 'ブロンズソード改', '改良された青銅製の剣', 'sword', 1, 9, 13, 45, 65, 1, true, NOW(), NOW()),
            ('iron_sword_mk2', 'アイアンソード改', '改良された鉄製の剣', 'sword', 1, 16, 21, 85, 125, 2, true, NOW(), NOW()),
            ('steel_sword', 'スチールソード', '丈夫な鋼鉄製の剣', 'sword', 2, 23, 29, 190, 230, 3, true, NOW(), NOW()),
            ('silver_blade', 'シルバーブレード', '銀の輝きを放つ剣', 'sword', 3, 31, 41, 460, 560, 5, true, NOW(), NOW()),
            ('flame_sword', 'フレイムソード', '炎を纏う魔法の剣', 'sword', 4, 46, 56, 1050, 1450, 8, true, NOW(), NOW()),
            ('ice_blade', 'アイスブレード', '氷の力を宿した剣', 'sword', 3, 29, 39, 440, 540, 4, true, NOW(), NOW()),
            ('thunder_sword', 'サンダーソード', '雷の力を持つ剣', 'sword', 4, 44, 54, 1000, 1400, 7, true, NOW(), NOW()),
            ('cursed_blade', 'カースドブレード', '呪いを宿した暗黒の剣', 'sword', 4, 48, 58, 1100, 1500, 9, true, NOW(), NOW()),
            ('holy_sword', 'ホーリーソード', '聖なる力を宿した剣', 'sword', 4, 47, 57, 1080, 1480, 8, true, NOW(), NOW()),
            ('dragon_slayer', 'ドラゴンスレイヤー', 'ドラゴンを討つ伝説の剣', 'sword', 5, 60, 80, 2000, 3000, 15, true, NOW(), NOW()),
            ('mithril_sword', 'ミスリルソード', '幻の金属製の軽量剣', 'sword', 5, 58, 78, 1900, 2900, 14, true, NOW(), NOW()),
            ('excalibur', 'エクスカリバー', '選ばれし者の聖剣', 'sword', 5, 65, 85, 2200, 3200, 20, true, NOW(), NOW()),
            ('katana', 'カタナ', '東方の技術で作られた曲刀', 'sword', 3, 33, 43, 480, 580, 6, true, NOW(), NOW()),
            ('scimitar', 'シミター', '湾曲した刃を持つ軽剣', 'sword', 2, 21, 27, 170, 210, 3, true, NOW(), NOW()),
            ('bastard_sword', 'バスタードソード', '両手持ちの大剣', 'sword', 3, 35, 45, 500, 600, 7, true, NOW(), NOW()),
            ('rapier', 'レイピア', '突きに特化した細剣', 'sword', 2, 19, 25, 160, 200, 3, true, NOW(), NOW()),
            ('claymore', 'クレイモア', '巨大な両手剣', 'sword', 4, 50, 60, 1200, 1600, 10, true, NOW(), NOW()),
            ('void_blade', 'ヴォイドブレード', '虚無の力を纏った剣', 'sword', 5, 62, 82, 2100, 3100, 18, true, NOW(), NOW()),
            ('crystal_sword', 'クリスタルソード', '水晶で作られた透明な剣', 'sword', 4, 45, 55, 1020, 1420, 8, true, NOW(), NOW()),
            ('demon_blade', 'デモンブレード', '悪魔の力を宿した剣', 'sword', 5, 59, 79, 1950, 2950, 16, true, NOW(), NOW()),
            
            -- 弓系武器 (15個)
            ('wooden_bow_mk2', 'ウッドボウ改', '改良された木製の弓', 'bow', 1, 7, 11, 35, 55, 1, true, NOW(), NOW()),
            ('short_bow', 'ショートボウ', '軽量で扱いやすい短弓', 'bow', 1, 10, 14, 50, 70, 1, true, NOW(), NOW()),
            ('long_bow_mk2', 'ロングボウ改', '改良された長弓', 'bow', 2, 19, 26, 150, 190, 4, true, NOW(), NOW()),
            ('composite_bow', 'コンポジットボウ', '複合素材の高性能弓', 'bow', 2, 22, 28, 180, 220, 4, true, NOW(), NOW()),
            ('elven_bow', 'エルヴンボウ', 'エルフの技術で作られた弓', 'bow', 3, 28, 38, 420, 520, 6, true, NOW(), NOW()),
            ('fire_bow', 'ファイアボウ', '炎の矢を放つ弓', 'bow', 4, 42, 52, 980, 1380, 8, true, NOW(), NOW()),
            ('ice_bow', 'アイスボウ', '氷の矢を放つ弓', 'bow', 4, 40, 50, 950, 1350, 7, true, NOW(), NOW()),
            ('wind_bow', 'ウィンドボウ', '風の力を纏った弓', 'bow', 3, 30, 40, 450, 550, 6, true, NOW(), NOW()),
            ('shadow_bow', 'シャドウボウ', '影の力を宿した弓', 'bow', 4, 44, 54, 1020, 1420, 9, true, NOW(), NOW()),
            ('crossbow', 'クロスボウ', '機械式の弩', 'bow', 2, 24, 30, 200, 240, 5, true, NOW(), NOW()),
            ('hunter_bow', 'ハンターボウ', '狩猟専用の弓', 'bow', 2, 20, 26, 160, 200, 3, true, NOW(), NOW()),
            ('sniper_bow', 'スナイパーボウ', '精密射撃用の弓', 'bow', 3, 32, 42, 480, 580, 7, true, NOW(), NOW()),
            ('dragon_bow', 'ドラゴンボウ', 'ドラゴンの力を宿した弓', 'bow', 5, 55, 75, 1800, 2800, 14, true, NOW(), NOW()),
            ('phoenix_bow', 'フェニックスボウ', '不死鳥の羽で作られた弓', 'bow', 5, 57, 77, 1850, 2850, 15, true, NOW(), NOW()),
            ('void_bow', 'ヴォイドボウ', '虚無の力を放つ弓', 'bow', 5, 60, 80, 2000, 3000, 17, true, NOW(), NOW()),
            
            -- 杖系武器 (15個)
            ('magic_wand', 'マジックワンド', '基本的な魔法の杖', 'staff', 1, 8, 12, 40, 60, 1, true, NOW(), NOW()),
            ('iron_staff', 'アイアンスタッフ', '鉄芯入りの頑丈な杖', 'staff', 2, 14, 20, 110, 150, 3, true, NOW(), NOW()),
            ('fire_staff_mk2', 'ファイアスタッフ改', '改良された炎の杖', 'staff', 3, 26, 36, 360, 460, 6, true, NOW(), NOW()),
            ('ice_staff', 'アイススタッフ', '氷の力を増幅する杖', 'staff', 3, 24, 34, 340, 440, 5, true, NOW(), NOW()),
            ('thunder_staff', 'サンダースタッフ', '雷の力を操る杖', 'staff', 3, 28, 38, 380, 480, 7, true, NOW(), NOW()),
            ('crystal_rod', 'クリスタルロッド', '水晶で作られた杖', 'staff', 4, 38, 48, 900, 1300, 9, true, NOW(), NOW()),
            ('archmage_staff', 'アークメイジスタッフ', '大魔法使いの杖', 'staff', 4, 45, 55, 1050, 1450, 11, true, NOW(), NOW()),
            ('life_staff', 'ライフスタッフ', '生命力を操る緑の杖', 'staff', 3, 22, 32, 320, 420, 4, true, NOW(), NOW()),
            ('death_staff', 'デススタッフ', '死の力を操る黒い杖', 'staff', 4, 43, 53, 1000, 1400, 10, true, NOW(), NOW()),
            ('holy_staff', 'ホーリースタッフ', '聖なる力を宿した杖', 'staff', 4, 41, 51, 980, 1380, 9, true, NOW(), NOW()),
            ('elder_wand', 'エルダーワンド', '古代魔法使いの遺品', 'staff', 5, 52, 72, 1700, 2700, 13, true, NOW(), NOW()),
            ('staff_of_power', 'スタッフオブパワー', '魔力を極限まで増幅する杖', 'staff', 5, 58, 78, 1900, 2900, 16, true, NOW(), NOW()),
            ('void_staff', 'ヴォイドスタッフ', '虚無の力を操る杖', 'staff', 5, 55, 75, 1800, 2800, 15, true, NOW(), NOW()),
            ('elemental_staff', 'エレメンタルスタッフ', '全属性を操る万能杖', 'staff', 5, 60, 80, 2000, 3000, 18, true, NOW(), NOW()),
            ('necro_staff', 'ネクロスタッフ', '死霊術師の邪悪な杖', 'staff', 4, 46, 56, 1080, 1480, 11, true, NOW(), NOW())
            ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            base_attack_min = EXCLUDED.base_attack_min,
            base_attack_max = EXCLUDED.base_attack_max,
            base_price_min = EXCLUDED.base_price_min,
            base_price_max = EXCLUDED.base_price_max,
            updated_at = NOW()
            """
            
            conn.execute(text(weapons_sql))
            conn.commit()
            print('大量武器マスター 50 件作成/更新')
            
            # 確認
            result = conn.execute(text("SELECT COUNT(*) FROM weapon_masters"))
            weapon_count = result.scalar()
            
            print(f'\n=== データ投入結果 ===')
            print(f'武器マスター総数: {weapon_count} 件')
            print('\n大量武器データ投入完了！')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()
            conn.rollback()

if __name__ == '__main__':
    main()