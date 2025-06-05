#!/usr/bin/env python3
from app.core.database import SessionLocal
from app.models import WeaponType, RarityLevel, WeaponMaster, MaterialMaster

def main():
    print('包括的なシードデータを投入中...')
    db = SessionLocal()

    try:
        # 既存データを削除
        db.query(WeaponMaster).delete()
        db.query(MaterialMaster).delete()
        db.query(WeaponType).delete()
        db.query(RarityLevel).delete()
        db.commit()
        print('既存データ削除完了')
        
        # 武器タイプ
        weapon_types_data = [
            {"id": "sword", "name": "剣", "description": "近接戦闘用の刃物武器", "is_active": True},
            {"id": "bow", "name": "弓", "description": "遠距離攻撃用の射撃武器", "is_active": True},
            {"id": "staff", "name": "杖", "description": "魔法を扱うための武器", "is_active": True},
            {"id": "dagger", "name": "短剣", "description": "素早い攻撃が可能な小型武器", "is_active": True},
            {"id": "hammer", "name": "ハンマー", "description": "重厚な攻撃力を持つ鈍器", "is_active": True}
        ]
        
        weapon_types = [WeaponType(**data) for data in weapon_types_data]
        db.add_all(weapon_types)
        db.commit()
        print(f'武器タイプ {len(weapon_types)} 件作成')
        
        # レアリティ
        rarity_levels_data = [
            {"id": 1, "name": "コモン", "description": "一般的な品質", "color_code": "#808080", "multiplier": 1.0, "drop_rate": 60.0, "is_active": True},
            {"id": 2, "name": "アンコモン", "description": "少し珍しい品質", "color_code": "#008000", "multiplier": 1.2, "drop_rate": 25.0, "is_active": True},
            {"id": 3, "name": "レア", "description": "希少な品質", "color_code": "#0080ff", "multiplier": 1.5, "drop_rate": 10.0, "is_active": True},
            {"id": 4, "name": "エピック", "description": "非常に希少な品質", "color_code": "#8000ff", "multiplier": 2.0, "drop_rate": 4.0, "is_active": True},
            {"id": 5, "name": "レジェンダリー", "description": "伝説級の品質", "color_code": "#ff8000", "multiplier": 3.0, "drop_rate": 1.0, "is_active": True}
        ]
        
        rarities = [RarityLevel(**data) for data in rarity_levels_data]
        db.add_all(rarities)
        db.commit()
        print(f'レアリティ {len(rarities)} 件作成')
        
        # 100個の武器データ
        weapons_data = [
            # 剣系武器 (20個)
            {"name": "ブロンズソード", "description": "初心者向けの青銅製の剣", "weapon_type_id": "sword", "rarity_id": 1, "base_attack": 10, "base_price": 50, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "アイアンソード", "description": "鉄製の丈夫な剣", "weapon_type_id": "sword", "rarity_id": 1, "base_attack": 18, "base_price": 100, "required_level": 3, "is_craftable": True, "is_active": True},
            {"name": "スチールブレード", "description": "鋼鉄製の切れ味鋭い剣", "weapon_type_id": "sword", "rarity_id": 2, "base_attack": 25, "base_price": 200, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "シルバーソード", "description": "銀の力を宿した美しい剣", "weapon_type_id": "sword", "rarity_id": 3, "base_attack": 35, "base_price": 500, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "フレイムブレード", "description": "炎の力を宿した魔法の剣", "weapon_type_id": "sword", "rarity_id": 4, "base_attack": 50, "base_price": 1200, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "エクスカリバー", "description": "伝説の聖剣", "weapon_type_id": "sword", "rarity_id": 5, "base_attack": 80, "base_price": 5000, "required_level": 20, "is_craftable": False, "is_active": True},
            {"name": "ロングソード", "description": "長めの刃を持つ剣", "weapon_type_id": "sword", "rarity_id": 1, "base_attack": 15, "base_price": 80, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "バスタードソード", "description": "両手持ちの大剣", "weapon_type_id": "sword", "rarity_id": 2, "base_attack": 30, "base_price": 250, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "クリスタルソード", "description": "水晶でできた透明な剣", "weapon_type_id": "sword", "rarity_id": 3, "base_attack": 40, "base_price": 600, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "ドラゴンスレイヤー", "description": "ドラゴンを討伐するための専用剣", "weapon_type_id": "sword", "rarity_id": 4, "base_attack": 65, "base_price": 2000, "required_level": 18, "is_craftable": True, "is_active": True},
            {"name": "カタナ", "description": "東方の技術で作られた湾曲した刃", "weapon_type_id": "sword", "rarity_id": 3, "base_attack": 38, "base_price": 550, "required_level": 9, "is_craftable": True, "is_active": True},
            {"name": "シミター", "description": "湾曲した刃を持つ軽量剣", "weapon_type_id": "sword", "rarity_id": 2, "base_attack": 22, "base_price": 180, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "ダマスカスブレード", "description": "ダマスカス鋼で作られた名剣", "weapon_type_id": "sword", "rarity_id": 4, "base_attack": 55, "base_price": 1500, "required_level": 15, "is_craftable": True, "is_active": True},
            {"name": "アイスブレード", "description": "氷の力を宿した冷たい剣", "weapon_type_id": "sword", "rarity_id": 3, "base_attack": 42, "base_price": 650, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "サンダーソード", "description": "雷の力を宿した電撃剣", "weapon_type_id": "sword", "rarity_id": 4, "base_attack": 48, "base_price": 1100, "required_level": 13, "is_craftable": True, "is_active": True},
            {"name": "ミスリルソード", "description": "幻の金属ミスリル製の剣", "weapon_type_id": "sword", "rarity_id": 5, "base_attack": 75, "base_price": 4000, "required_level": 19, "is_craftable": True, "is_active": True},
            {"name": "ホーリーブレード", "description": "聖なる力を宿した神聖剣", "weapon_type_id": "sword", "rarity_id": 5, "base_attack": 70, "base_price": 3500, "required_level": 17, "is_craftable": False, "is_active": True},
            {"name": "デモンスレイヤー", "description": "悪魔を滅する聖剣", "weapon_type_id": "sword", "rarity_id": 4, "base_attack": 60, "base_price": 1800, "required_level": 16, "is_craftable": True, "is_active": True},
            {"name": "ヴォイドブレード", "description": "虚無の力を纏った漆黒の剣", "weapon_type_id": "sword", "rarity_id": 5, "base_attack": 85, "base_price": 6000, "required_level": 22, "is_craftable": False, "is_active": True},
            {"name": "グラディウス", "description": "古代の戦士が使った短剣", "weapon_type_id": "sword", "rarity_id": 2, "base_attack": 20, "base_price": 150, "required_level": 3, "is_craftable": True, "is_active": True},

            # 弓系武器 (20個)
            {"name": "ウッドボウ", "description": "木製の基本的な弓", "weapon_type_id": "bow", "rarity_id": 1, "base_attack": 8, "base_price": 40, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "ショートボウ", "description": "軽量で扱いやすい短弓", "weapon_type_id": "bow", "rarity_id": 1, "base_attack": 12, "base_price": 60, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "ロングボウ", "description": "射程の長い戦闘用の弓", "weapon_type_id": "bow", "rarity_id": 2, "base_attack": 20, "base_price": 150, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "コンポジットボウ", "description": "複数素材で作られた高性能弓", "weapon_type_id": "bow", "rarity_id": 2, "base_attack": 25, "base_price": 200, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "エルヴンボウ", "description": "エルフの技術で作られた美しい弓", "weapon_type_id": "bow", "rarity_id": 3, "base_attack": 32, "base_price": 450, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "ウィンドボウ", "description": "風の力を纏った弓", "weapon_type_id": "bow", "rarity_id": 3, "base_attack": 35, "base_price": 500, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "フレイムボウ", "description": "炎の矢を放つ魔法の弓", "weapon_type_id": "bow", "rarity_id": 4, "base_attack": 45, "base_price": 1000, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "アイスボウ", "description": "氷の矢を放つ氷結の弓", "weapon_type_id": "bow", "rarity_id": 4, "base_attack": 42, "base_price": 950, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "サンダーボウ", "description": "雷の矢を放つ電撃の弓", "weapon_type_id": "bow", "rarity_id": 4, "base_attack": 48, "base_price": 1100, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "ドラゴンボウ", "description": "ドラゴンの力を宿した伝説の弓", "weapon_type_id": "bow", "rarity_id": 5, "base_attack": 70, "base_price": 3500, "required_level": 18, "is_craftable": False, "is_active": True},
            {"name": "クロスボウ", "description": "機械式の弩", "weapon_type_id": "bow", "rarity_id": 2, "base_attack": 28, "base_price": 220, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "リカーブボウ", "description": "反り返った形状の高性能弓", "weapon_type_id": "bow", "rarity_id": 3, "base_attack": 38, "base_price": 550, "required_level": 9, "is_craftable": True, "is_active": True},
            {"name": "ハンターボウ", "description": "狩猟専用に作られた弓", "weapon_type_id": "bow", "rarity_id": 2, "base_attack": 22, "base_price": 170, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "シャドウボウ", "description": "影の力を宿した暗黒の弓", "weapon_type_id": "bow", "rarity_id": 4, "base_attack": 52, "base_price": 1300, "required_level": 14, "is_craftable": True, "is_active": True},
            {"name": "ライトボウ", "description": "光の力を放つ聖なる弓", "weapon_type_id": "bow", "rarity_id": 4, "base_attack": 50, "base_price": 1200, "required_level": 13, "is_craftable": True, "is_active": True},
            {"name": "ミスリルボウ", "description": "幻の金属で作られた軽量弓", "weapon_type_id": "bow", "rarity_id": 5, "base_attack": 65, "base_price": 3000, "required_level": 16, "is_craftable": True, "is_active": True},
            {"name": "フェニックスボウ", "description": "不死鳥の羽で作られた神話の弓", "weapon_type_id": "bow", "rarity_id": 5, "base_attack": 75, "base_price": 4000, "required_level": 19, "is_craftable": False, "is_active": True},
            {"name": "ヴォイドボウ", "description": "虚無の力を放つ究極の弓", "weapon_type_id": "bow", "rarity_id": 5, "base_attack": 80, "base_price": 5000, "required_level": 21, "is_craftable": False, "is_active": True},
            {"name": "ウォーボウ", "description": "戦争用の重装弓", "weapon_type_id": "bow", "rarity_id": 3, "base_attack": 40, "base_price": 600, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "アルテミスボウ", "description": "狩猟の女神の加護を受けた弓", "weapon_type_id": "bow", "rarity_id": 5, "base_attack": 72, "base_price": 3800, "required_level": 18, "is_craftable": False, "is_active": True},

            # 杖系武器 (20個)
            {"name": "ウッドスタッフ", "description": "木製の基本的な杖", "weapon_type_id": "staff", "rarity_id": 1, "base_attack": 6, "base_price": 35, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "マジックワンド", "description": "魔法を扱うための短い杖", "weapon_type_id": "staff", "rarity_id": 1, "base_attack": 10, "base_price": 50, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "アイアンロッド", "description": "鉄芯入りの頑丈な杖", "weapon_type_id": "staff", "rarity_id": 2, "base_attack": 18, "base_price": 120, "required_level": 3, "is_craftable": True, "is_active": True},
            {"name": "ファイアスタッフ", "description": "炎の力を増幅する赤い杖", "weapon_type_id": "staff", "rarity_id": 3, "base_attack": 30, "base_price": 400, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "アイススタッフ", "description": "氷の力を増幅する青い杖", "weapon_type_id": "staff", "rarity_id": 3, "base_attack": 28, "base_price": 380, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "サンダースタッフ", "description": "雷の力を増幅する黄色い杖", "weapon_type_id": "staff", "rarity_id": 3, "base_attack": 32, "base_price": 420, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "クリスタルロッド", "description": "水晶で作られた透明な杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 40, "base_price": 800, "required_level": 9, "is_craftable": True, "is_active": True},
            {"name": "アークメイジスタッフ", "description": "大魔法使いの杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 50, "base_price": 1200, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "ドラゴンスタッフ", "description": "ドラゴンの骨で作られた杖", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 65, "base_price": 3000, "required_level": 16, "is_craftable": False, "is_active": True},
            {"name": "ライフスタッフ", "description": "生命力を操る緑の杖", "weapon_type_id": "staff", "rarity_id": 3, "base_attack": 25, "base_price": 350, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "デススタッフ", "description": "死の力を操る黒い杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 45, "base_price": 1000, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "ホーリースタッフ", "description": "聖なる力を宿した白い杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 42, "base_price": 900, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "エルダーワンド", "description": "古代魔法使いの遺品", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 60, "base_price": 2500, "required_level": 14, "is_craftable": False, "is_active": True},
            {"name": "スタッフ・オブ・パワー", "description": "魔力を極限まで増幅する杖", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 70, "base_price": 3500, "required_level": 18, "is_craftable": False, "is_active": True},
            {"name": "ヴォイドスタッフ", "description": "虚無の力を操る究極の杖", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 75, "base_price": 4000, "required_level": 20, "is_craftable": False, "is_active": True},
            {"name": "ネクロスタッフ", "description": "死霊術師の邪悪な杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 48, "base_price": 1100, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "エレメンタルスタッフ", "description": "全属性を操る万能杖", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 68, "base_price": 3200, "required_level": 17, "is_craftable": True, "is_active": True},
            {"name": "ワイザードスタッフ", "description": "賢者の知恵を宿した杖", "weapon_type_id": "staff", "rarity_id": 3, "base_attack": 35, "base_price": 480, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "ミスリルロッド", "description": "幻の金属で作られた軽量杖", "weapon_type_id": "staff", "rarity_id": 4, "base_attack": 55, "base_price": 1400, "required_level": 14, "is_craftable": True, "is_active": True},
            {"name": "フェニックスワンド", "description": "不死鳥の羽で作られた神話の杖", "weapon_type_id": "staff", "rarity_id": 5, "base_attack": 72, "base_price": 3800, "required_level": 19, "is_craftable": False, "is_active": True},

            # 短剣系武器 (20個)
            {"name": "アイアンダガー", "description": "鉄製の基本的な短剣", "weapon_type_id": "dagger", "rarity_id": 1, "base_attack": 8, "base_price": 30, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "スチールダガー", "description": "鋼鉄製の鋭い短剣", "weapon_type_id": "dagger", "rarity_id": 2, "base_attack": 15, "base_price": 80, "required_level": 3, "is_craftable": True, "is_active": True},
            {"name": "ポイズンダガー", "description": "毒を塗った危険な短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 20, "base_price": 250, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "シルバーダガー", "description": "銀製の美しい短剣", "weapon_type_id": "dagger", "rarity_id": 2, "base_attack": 18, "base_price": 120, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "シャドウブレード", "description": "影の力を宿した暗殺者の短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 35, "base_price": 700, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "フレイムダガー", "description": "炎の力を宿した灼熱の短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 25, "base_price": 300, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "アイスダガー", "description": "氷の力を宿した冷徹な短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 23, "base_price": 280, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "サンダーダガー", "description": "雷の力を宿した電撃の短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 27, "base_price": 320, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "ドラゴンファング", "description": "ドラゴンの牙で作られた短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 40, "base_price": 900, "required_level": 10, "is_craftable": False, "is_active": True},
            {"name": "アサシンブレード", "description": "暗殺者専用の特殊短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 38, "base_price": 800, "required_level": 9, "is_craftable": True, "is_active": True},
            {"name": "ヴァンパイアファング", "description": "吸血鬼の牙を模した短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 42, "base_price": 950, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "クリスタルダガー", "description": "水晶で作られた透明な短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 30, "base_price": 380, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "ミスリルダガー", "description": "幻の金属で作られた軽量短剣", "weapon_type_id": "dagger", "rarity_id": 5, "base_attack": 50, "base_price": 2000, "required_level": 13, "is_craftable": True, "is_active": True},
            {"name": "ヴォイドダガー", "description": "虚無の力を宿した究極の短剣", "weapon_type_id": "dagger", "rarity_id": 5, "base_attack": 55, "base_price": 2500, "required_level": 15, "is_craftable": False, "is_active": True},
            {"name": "ホーリーダガー", "description": "聖なる力を宿した神聖短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 36, "base_price": 750, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "カース・ダガー", "description": "呪いの力を宿した邪悪な短剣", "weapon_type_id": "dagger", "rarity_id": 4, "base_attack": 44, "base_price": 1000, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "ルーンダガー", "description": "古代ルーンが刻まれた短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 32, "base_price": 400, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "ブラッディダガー", "description": "血に染まった恐怖の短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 28, "base_price": 350, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "パラライズダガー", "description": "麻痺効果のある特殊短剣", "weapon_type_id": "dagger", "rarity_id": 3, "base_attack": 26, "base_price": 330, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "スピードダガー", "description": "素早い攻撃に特化した短剣", "weapon_type_id": "dagger", "rarity_id": 2, "base_attack": 22, "base_price": 180, "required_level": 4, "is_craftable": True, "is_active": True},

            # ハンマー系武器 (20個)
            {"name": "アイアンハンマー", "description": "鉄製の基本的なハンマー", "weapon_type_id": "hammer", "rarity_id": 1, "base_attack": 15, "base_price": 70, "required_level": 1, "is_craftable": True, "is_active": True},
            {"name": "スチールハンマー", "description": "鋼鉄製の重いハンマー", "weapon_type_id": "hammer", "rarity_id": 2, "base_attack": 25, "base_price": 150, "required_level": 4, "is_craftable": True, "is_active": True},
            {"name": "ウォーハンマー", "description": "戦争用の大型ハンマー", "weapon_type_id": "hammer", "rarity_id": 2, "base_attack": 30, "base_price": 200, "required_level": 5, "is_craftable": True, "is_active": True},
            {"name": "サンダーハンマー", "description": "雷の力を宿した電撃ハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 40, "base_price": 500, "required_level": 8, "is_craftable": True, "is_active": True},
            {"name": "アースクラッシャー", "description": "大地を砕く巨大ハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 45, "base_price": 600, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "フレイムハンマー", "description": "炎の力を宿した灼熱ハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 42, "base_price": 550, "required_level": 9, "is_craftable": True, "is_active": True},
            {"name": "アイスハンマー", "description": "氷の力を宿した氷結ハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 38, "base_price": 480, "required_level": 7, "is_craftable": True, "is_active": True},
            {"name": "ドラゴンハンマー", "description": "ドラゴンの力を宿した伝説ハンマー", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 60, "base_price": 1500, "required_level": 14, "is_craftable": False, "is_active": True},
            {"name": "ソウルクラッシャー", "description": "魂を砕く邪悪なハンマー", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 55, "base_price": 1300, "required_level": 12, "is_craftable": True, "is_active": True},
            {"name": "ホーリーハンマー", "description": "聖なる力を宿した神聖ハンマー", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 50, "base_price": 1200, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "ミスリルハンマー", "description": "幻の金属で作られた軽量ハンマー", "weapon_type_id": "hammer", "rarity_id": 5, "base_attack": 70, "base_price": 3000, "required_level": 16, "is_craftable": True, "is_active": True},
            {"name": "ヴォイドハンマー", "description": "虚無の力を操る究極ハンマー", "weapon_type_id": "hammer", "rarity_id": 5, "base_attack": 80, "base_price": 4000, "required_level": 18, "is_craftable": False, "is_active": True},
            {"name": "クリスタルハンマー", "description": "水晶で作られた透明なハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 35, "base_price": 420, "required_level": 6, "is_craftable": True, "is_active": True},
            {"name": "ジャイアントハンマー", "description": "巨人が使う超大型ハンマー", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 65, "base_price": 1800, "required_level": 15, "is_craftable": True, "is_active": True},
            {"name": "デモンハンマー", "description": "悪魔の力を宿した邪悪ハンマー", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 58, "base_price": 1400, "required_level": 13, "is_craftable": True, "is_active": True},
            {"name": "フェニックスハンマー", "description": "不死鳥の力を宿した神話ハンマー", "weapon_type_id": "hammer", "rarity_id": 5, "base_attack": 75, "base_price": 3500, "required_level": 17, "is_craftable": False, "is_active": True},
            {"name": "カオスハンマー", "description": "混沌の力を操る破滅ハンマー", "weapon_type_id": "hammer", "rarity_id": 5, "base_attack": 85, "base_price": 5000, "required_level": 20, "is_craftable": False, "is_active": True},
            {"name": "ライトニングメイス", "description": "雷神の加護を受けた神聖メイス", "weapon_type_id": "hammer", "rarity_id": 4, "base_attack": 52, "base_price": 1250, "required_level": 11, "is_craftable": True, "is_active": True},
            {"name": "ブラッドハンマー", "description": "血に飢えた呪われたハンマー", "weapon_type_id": "hammer", "rarity_id": 3, "base_attack": 48, "base_price": 650, "required_level": 10, "is_craftable": True, "is_active": True},
            {"name": "ゴッドハンマー", "description": "神々の力を宿した最強ハンマー", "weapon_type_id": "hammer", "rarity_id": 5, "base_attack": 90, "base_price": 10000, "required_level": 25, "is_craftable": False, "is_active": True}
        ]
        
        weapons = [WeaponMaster(**data) for data in weapons_data]
        db.add_all(weapons)
        db.commit()
        print(f'武器マスター {len(weapons)} 件作成')
        
        # 素材マスター（既存データ）
        materials = [
            MaterialMaster(name='鉄鉱石', rarity_id=1, base_price=10),
            MaterialMaster(name='魔法の水晶', rarity_id=2, base_price=50),
            MaterialMaster(name='古代の木材', rarity_id=1, base_price=20),
            MaterialMaster(name='希少な宝石', rarity_id=3, base_price=100),
            MaterialMaster(name='ドラゴンの鱗', rarity_id=3, base_price=200),
            MaterialMaster(name='ミスリル鉱石', rarity_id=4, base_price=500),
            MaterialMaster(name='毒草', rarity_id=1, base_price=5),
            MaterialMaster(name='聖なる水', rarity_id=2, base_price=80)
        ]
        db.add_all(materials)
        db.commit()
        print(f'素材マスター {len(materials)} 件作成')
        
        # 確認
        weapon_count = db.query(WeaponMaster).count()
        material_count = db.query(MaterialMaster).count()
        weapon_type_count = db.query(WeaponType).count()
        rarity_count = db.query(RarityLevel).count()
        
        print(f'\n=== 包括的データ投入結果 ===')
        print(f'武器タイプ: {weapon_type_count} 件')
        print(f'レアリティ: {rarity_count} 件')
        print(f'武器マスター: {weapon_count} 件')
        print(f'素材マスター: {material_count} 件')
        print('\n包括的シードデータ投入完了！')
        
    except Exception as e:
        print(f'エラー: {e}')
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == '__main__':
    main()