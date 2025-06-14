#!/usr/bin/env python3
"""
100種類の包括的な素材シードデータ
現在のテーブル構造に完全対応
"""

from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('100種類の包括的素材データを投入中...')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # 現在の素材数を確認
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            current_count = result.scalar()
            print(f"現在の素材数: {current_count}")
            
            # 100種類の素材データ
            materials_data = [
                # === Common素材 (40個) ===
                ('copper_ore', '銅鉱石', 'metal', '1', '基本的な銅の鉱石', 15, 999, '🟫'),
                ('tin_ore', '錫鉱石', 'metal', '1', '青銅作成に必要な錫', 12, 999, '⚪'),
                ('coal', '石炭', 'fuel', '1', '燃料として使用する石炭', 8, 999, '⚫'),
                ('clay', '粘土', 'earth', '1', '陶器作成に使用する粘土', 5, 999, '🟤'),
                ('sand', '砂', 'earth', '1', '精製に使用する砂', 3, 999, '🟨'),
                ('salt', '塩', 'mineral', '1', '保存と精製に使用', 6, 500, '⚪'),
                ('moss', '苔', 'plant', '1', '薬草の材料となる苔', 4, 200, '🟢'),
                ('mushroom', 'きのこ', 'plant', '1', '料理や薬の材料', 8, 100, '🍄'),
                ('fur', '獣の毛皮', 'leather', '1', '防具作成の基本素材', 20, 200, '🟤'),
                ('feather', '鳥の羽', 'organic', '1', '矢や装飾に使用', 10, 300, '🪶'),
                ('bone', '骨', 'organic', '1', '武器の柄や道具に使用', 15, 500, '🦴'),
                ('resin', '樹脂', 'organic', '1', '接着剤として使用', 12, 200, '🟡'),
                ('iron_sand', '砂鉄', 'metal', '1', '鉄の原料となる砂鉄', 18, 999, '⚫'),
                ('bamboo', '竹', 'plant', '1', '軽量で丈夫な素材', 14, 500, '🎋'),
                ('cotton', '綿花', 'fiber', '1', '布地の原料', 12, 300, '🤍'),
                ('leather_strip', '革紐', 'leather', '1', '武器の柄巻きに使用', 16, 200, '🟤'),
                ('hemp_rope', '麻紐', 'fiber', '1', '丈夫な紐状素材', 8, 300, '🟫'),
                ('wood_chip', '木屑', 'wood', '1', '燃料や詰め物に使用', 3, 999, '🟫'),
                ('small_stone', '小石', 'stone', '1', '研磨剤として使用', 2, 999, '🪨'),
                ('sap', '樹液', 'organic', '1', '接着剤として使用', 18, 200, '🟡'),
                ('wool', '羊毛', 'fiber', '1', '防具の裏地に使用', 22, 200, '🤍'),
                ('charcoal', '木炭', 'fuel', '1', '鍛冶の燃料', 25, 500, '⚫'),
                ('flint', '火打ち石', 'stone', '1', '火起こしに使用', 10, 200, '🪨'),
                ('beeswax', '蜜蝋', 'organic', '1', '防水や光沢出しに使用', 30, 100, '🟡'),
                ('sinew', '腱', 'organic', '1', '弓の弦や縫合に使用', 25, 150, '🤍'),
                ('shell', '貝殻', 'organic', '1', '装飾や道具に使用', 8, 300, '🐚'),
                ('kelp', '昆布', 'plant', '1', '海藻の一種、食用にも', 6, 200, '🟢'),
                ('coral', '珊瑚', 'mineral', '1', '装飾用の美しい珊瑚', 35, 50, '🪸'),
                ('amber', '琥珀', 'organic', '1', '樹脂の化石、装飾用', 45, 30, '🟠'),
                ('obsidian', '黒曜石', 'stone', '1', '鋭い刃を作れる火山ガラス', 40, 100, '⚫'),
                ('quartz', '水晶', 'crystal', '1', '透明な結晶、装飾用', 28, 200, '💎'),
                ('granite', '花崗岩', 'stone', '1', '硬い岩石、建材用', 12, 999, '🪨'),
                ('marble', '大理石', 'stone', '1', '美しい模様の石材', 55, 200, '⚪'),
                ('slate', '粘板岩', 'stone', '1', '薄く割れる岩石', 18, 500, '🪨'),
                ('limestone', '石灰岩', 'stone', '1', '建材や精錬に使用', 8, 999, '🤍'),
                ('copper_ingot', '銅のインゴット', 'metal', '1', '精錬された銅の塊', 50, 200, '🟫'),
                ('bronze_ingot', '青銅のインゴット', 'metal', '1', '銅と錫の合金', 75, 150, '🟫'),
                ('steel_wool', 'スチールウール', 'metal', '1', '細かい鋼鉄の繊維', 35, 300, '⚪'),
                ('lead_ore', '鉛鉱石', 'metal', '1', '重い金属の鉱石', 22, 500, '🔘'),
                ('zinc_ore', '亜鉛鉱石', 'metal', '1', '防錆に使われる金属', 28, 400, '⚪'),
                
                # === Uncommon素材 (30個) ===
                ('bronze_alloy', '青銅合金', 'metal', '2', '銅と錫から作られた合金', 120, 200, '🟫'),
                ('hardwood', '硬質木材', 'wood', '2', '特別に硬化処理された木材', 85, 300, '🟫'),
                ('magic_powder', '魔法の粉末', 'magic', '2', '魔法効果を持つ不思議な粉', 150, 100, '✨'),
                ('elf_thread', 'エルフの糸', 'magic', '2', 'エルフが紡いだ特殊な糸', 180, 50, '🧵'),
                ('beast_fang', '獣王の牙', 'organic', '2', '強力な獣の牙', 200, 20, '🦷'),
                ('ancient_stone', '古代の石', 'stone', '2', '古代文明の遺物', 160, 50, '🗿'),
                ('sea_pearl', '深海の真珠', 'organic', '2', '深海から採取された真珠', 220, 30, '🦪'),
                ('wind_crystal', '風霊石', 'crystal', '2', '風の精霊が宿る石', 190, 40, '💎'),
                ('silver_thread', '銀糸', 'metal', '2', '美しい銀の糸', 140, 100, '⚪'),
                ('enchanted_wood', '魔法の木材', 'magic', '2', '魔力を帯びた特殊な木材', 130, 150, '🌳'),
                ('crystal_dust', '水晶の粉', 'crystal', '2', '砕いた水晶の粉末', 100, 200, '✨'),
                ('demon_horn', '悪魔の角', 'magic', '2', '下級悪魔の角', 250, 15, '😈'),
                ('phoenix_down', 'フェニックスの羽毛', 'magic', '2', '不死鳥の小さな羽毛', 300, 10, '🔥'),
                ('mithril_dust', 'ミスリルの粉', 'metal', '2', 'ミスリルを砕いた粉', 280, 50, '✨'),
                ('unicorn_hair', 'ユニコーンの毛', 'magic', '2', 'ユニコーンの尻尾の毛', 350, 8, '🦄'),
                ('dragon_tooth', 'ドラゴンの牙', 'dragon', '2', '若いドラゴンの牙', 400, 12, '🐲'),
                ('elemental_core', '精霊の核', 'magic', '2', '精霊の力の源', 220, 25, '💎'),
                ('blessed_water', '聖水', 'magic', '2', '神官が祝福した水', 120, 100, '💧'),
                ('cursed_bone', '呪いの骨', 'magic', '2', '邪悪な力を帯びた骨', 180, 30, '💀'),
                ('starfall_metal', '星降りの金属', 'metal', '2', '隕石から採取した金属', 320, 20, '⭐'),
                ('ice_crystal', '氷の結晶', 'crystal', '2', '永久に溶けない氷', 160, 80, '❄️'),
                ('fire_opal', '炎のオパール', 'gem', '2', '炎の力を秘めた宝石', 240, 25, '🔥'),
                ('moon_dust', '月の粉', 'magic', '2', '月から降り注ぐ神秘の粉', 200, 40, '🌙'),
                ('shadow_silk', '影の絹', 'magic', '2', '闇の力を纏った絹', 190, 60, '🖤'),
                ('storm_glass', '嵐のガラス', 'crystal', '2', '嵐の力を封じたガラス', 210, 35, '⚡'),
                ('earth_essence', '大地の精髄', 'magic', '2', '大地の力が凝縮された物質', 170, 70, '🌍'),
                ('void_shard', '虚無の欠片', 'magic', '2', '虚無から生まれた謎の欠片', 260, 15, '⚫'),
                ('light_prism', '光のプリズム', 'crystal', '2', '光を分解する特殊な結晶', 180, 45, '🌈'),
                ('gravity_stone', '重力石', 'stone', '2', '重力を操る不思議な石', 230, 30, '🪨'),
                ('time_fragment', '時の欠片', 'magic', '2', '時間の流れを感じる欠片', 300, 20, '⏰'),
                
                # === Rare素材 (20個) ===
                ('dragon_blood', 'ドラゴンの血', 'dragon', '3', 'ドラゴンから採取した貴重な血', 800, 10, '🐲'),
                ('star_fragment', '星の欠片', 'cosmic', '3', '天から降ってきた隕石の破片', 1200, 5, '⭐'),
                ('time_sand', '時の砂', 'magic', '3', '時間を操る不思議な砂', 1000, 20, '⏳'),
                ('spirit_tear', '精霊の涙', 'magic', '3', '精霊が流した涙の結晶', 720, 15, '💧'),
                ('moonstone', '月光石', 'gem', '3', '月の光を蓄えた神秘的な石', 880, 12, '🌙'),
                ('adamantine_ore', 'アダマンタイト鉱石', 'metal', '3', '最硬の金属鉱石', 1500, 8, '💎'),
                ('philosopher_stone', '賢者の石', 'magic', '3', '錬金術の究極の石', 2000, 3, '🔮'),
                ('world_tree_bark', '世界樹の樹皮', 'magic', '3', '世界を支える大樹の樹皮', 900, 10, '🌳'),
                ('cosmic_dust', '宇宙塵', 'cosmic', '3', '宇宙空間から飛来した塵', 1100, 15, '✨'),
                ('divine_feather', '神の羽根', 'divine', '3', '神々の使いの羽根', 1600, 6, '🪶'),
                ('demon_heart', '悪魔の心臓', 'demon', '3', '強力な悪魔の心臓', 1400, 5, '❤️'),
                ('ancient_rune', '古代ルーン石', 'magic', '3', '古代文字が刻まれた石', 800, 18, '🗿'),
                ('crystal_of_souls', '魂の結晶', 'magic', '3', '多くの魂が込められた結晶', 1300, 8, '💎'),
                ('eternal_flame', '永遠の炎', 'magic', '3', '決して消えない聖なる炎', 1200, 10, '🔥'),
                ('void_essence', '虚無の精髄', 'void', '3', '虚無の力そのもの', 1800, 4, '⚫'),
                ('primordial_water', '原始の水', 'magic', '3', '世界創造時の水', 950, 12, '💧'),
                ('celestial_silk', '天界の絹', 'divine', '3', '天界で織られた絹', 1100, 8, '☁️'),
                ('chaos_orb', '混沌の珠', 'chaos', '3', '混沌の力を秘めた珠', 1700, 6, '🔮'),
                ('life_essence', '生命の精髄', 'magic', '3', '純粋な生命力の結晶', 1000, 15, '💚'),
                ('death_essence', '死の精髄', 'magic', '3', '死の力を凝縮した物質', 1050, 12, '💀'),
                
                # === Epic素材 (8個) ===
                ('phoenix_heart', 'フェニックスの心臓', 'phoenix', '4', '不死鳥の心臓', 5000, 3, '🔥'),
                ('void_crystal', '虚無の結晶', 'void', '4', '虚無の力を封じ込めた結晶', 6000, 2, '⚫'),
                ('dragon_soul', 'ドラゴンソウル', 'dragon', '4', '古代ドラゴンの魂', 8000, 2, '🐲'),
                ('god_tear', '神の涙', 'divine', '4', '神々が流した涙の結晶', 7000, 3, '💧'),
                ('world_core', '世界の核', 'cosmic', '4', '世界の中心にある核', 10000, 1, '🌍'),
                ('time_crystal', '時空の結晶', 'cosmic', '4', '時間と空間を操る結晶', 9000, 2, '⏰'),
                ('creation_dust', '創造の塵', 'divine', '4', '世界創造時の塵', 7500, 3, '✨'),
                ('infinity_shard', '無限の欠片', 'cosmic', '4', '無限の力を秘めた欠片', 12000, 1, '♾️'),
                
                # === Legendary素材 (2個) ===
                ('origin_crystal', '始原の結晶', 'origin', '4', '全ての始まりの結晶', 25000, 1, '💎'),
                ('omnipotent_essence', '全能の精髄', 'omnipotent', '4', '全ての力を内包する精髄', 50000, 1, '🌟')
            ]
            
            # 既存の素材をチェックして重複回避
            existing_materials = set()
            result = conn.execute(text("SELECT id FROM material_masters"))
            for row in result:
                existing_materials.add(row[0])
            
            created_count = 0
            skipped_count = 0
            
            for material_data in materials_data:
                material_id, name, category, rarity_id, description, base_price, stack_size, emoji = material_data
                
                if material_id in existing_materials:
                    skipped_count += 1
                    continue
                
                # 素材を投入
                material_sql = """
                INSERT INTO material_masters 
                (id, name, category, rarity_id, description, base_price, stack_size, emoji, is_active) 
                VALUES (:id, :name, :category, :rarity_id, :description, :base_price, :stack_size, :emoji, true)
                """
                
                conn.execute(text(material_sql), {
                    "id": material_id,
                    "name": name,
                    "category": category,
                    "rarity_id": rarity_id,
                    "description": description,
                    "base_price": base_price,
                    "stack_size": stack_size,
                    "emoji": emoji
                })
                
                created_count += 1
                
                if created_count % 20 == 0:
                    print(f'進行状況: {created_count} 素材作成完了')
            
            # 結果確認
            result = conn.execute(text("SELECT COUNT(*) FROM material_masters"))
            total_materials = result.scalar()
            
            # レアリティ別分布
            result = conn.execute(text("""
            SELECT r.name, COUNT(*) as count 
            FROM material_masters m 
            JOIN rarity_levels r ON m.rarity_id = r.id 
            GROUP BY r.id, r.name 
            ORDER BY r.level
            """))
            
            print(f'\n=== 包括的素材投入完了 ===')
            print(f'新規作成素材: {created_count} 件')
            print(f'スキップ済み素材: {skipped_count} 件')
            print(f'総素材数: {total_materials} 件')
            
            print(f'\nレアリティ別分布:')
            for row in result:
                print(f'  {row[0]}: {row[1]}個')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    main()