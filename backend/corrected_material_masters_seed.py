#!/usr/bin/env python3
"""
Corrected Material Masters Seed Data
Includes all required fields: category, emoji, color_code with proper rarity references
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== CORRECTED MATERIAL MASTERS SEED ===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            # Clear existing material data
            print('1. Clearing existing material data...')
            conn.execute(text("DELETE FROM material_masters"))
            
            print('2. Inserting corrected material masters data...')
            
            # Material masters with all required fields
            materials_sql = """
            INSERT INTO material_masters (id, name, category, rarity_id, description, base_price, price_volatility, stack_size, emoji, color_code, is_active, created_at, updated_at) VALUES
            
            -- === COMMON MATERIALS ===
            -- Basic Metals
            ('iron_ore', '鉄鉱石', 'metal', 'common', '武器作成の基本素材。最も一般的な鉱石', 50, 0.1, 999, '⛏️', '#8B4513', true, NOW(), NOW()),
            ('copper_ore', '銅鉱石', 'metal', 'common', '初級武器の材料。加工しやすい鉱石', 30, 0.1, 999, '🟫', '#B87333', true, NOW(), NOW()),
            ('tin_ore', '錫鉱石', 'metal', 'common', '青銅作成に必要な錫。銅と混ぜて合金を作る', 25, 0.1, 999, '⚪', '#C0C0C0', true, NOW(), NOW()),
            ('coal', '石炭', 'fuel', 'common', '鍛冶の燃料として使用する石炭', 20, 0.1, 999, '⚫', '#2F2F2F', true, NOW(), NOW()),
            
            -- Natural Materials
            ('wood', '木材', 'organic', 'common', '弓や杖の材料。軽量で加工しやすい', 15, 0.1, 999, '🪵', '#8B4513', true, NOW(), NOW()),
            ('stone', '石材', 'mineral', 'common', '基礎的な建材。研磨や加重に使用', 10, 0.1, 999, '🪨', '#808080', true, NOW(), NOW()),
            ('leather', '革', 'organic', 'common', '防具や武器の柄巻きに使用する革', 35, 0.1, 500, '🟤', '#8B4513', true, NOW(), NOW()),
            ('cotton', '綿花', 'fiber', 'common', '布地の原料。柔らかい繊維素材', 12, 0.1, 300, '🤍', '#FFFFFF', true, NOW(), NOW()),
            ('hemp', '麻', 'fiber', 'common', '丈夫な繊維。紐や布の材料', 18, 0.1, 400, '🟫', '#8B7355', true, NOW(), NOW()),
            ('bone', '骨', 'organic', 'common', '装飾や小さな部品に使用する動物の骨', 22, 0.1, 200, '🦴', '#F5F5DC', true, NOW(), NOW()),
            
            -- Crafting Components
            ('clay', '粘土', 'earth', 'common', '陶器や鋳型作りに使える良質な粘土', 8, 0.1, 999, '🟤', '#8B4513', true, NOW(), NOW()),
            ('sand', '砂', 'earth', 'common', '研磨や鋳造に使える細かい砂', 5, 0.1, 999, '🟨', '#F4A460', true, NOW(), NOW()),
            ('salt', '塩', 'mineral', 'common', '保存と精製に使用する天然塩', 15, 0.1, 500, '⚪', '#FFFFFF', true, NOW(), NOW()),
            ('resin', '樹脂', 'organic', 'common', '接着剤として使用する天然の樹液', 28, 0.1, 200, '🟡', '#FFD700', true, NOW(), NOW()),
            ('charcoal', '木炭', 'fuel', 'common', '高温燃焼用の燃料。鍛冶に必須', 40, 0.1, 300, '⚫', '#36454F', true, NOW(), NOW()),
            
            -- Enhancement Stones
            ('enhancement_stone', '強化石', 'magic', 'common', 'エンチャントに使用する基本的な魔法石', 100, 0.2, 999, '💎', '#4169E1', true, NOW(), NOW()),
            ('whetstone', '砥石', 'mineral', 'common', '武器を研ぐための石。切れ味を向上させる', 25, 0.1, 500, '🪨', '#696969', true, NOW(), NOW()),
            ('polish_powder', '研磨粉', 'powder', 'common', '武器の光沢を出すための粉末', 30, 0.1, 200, '⚪', '#F0F8FF', true, NOW(), NOW()),
            
            -- Organic Materials
            ('feather', '羽根', 'organic', 'common', '矢羽や装飾に使用する鳥の羽根', 12, 0.1, 300, '🪶', '#F5F5DC', true, NOW(), NOW()),
            ('fur', '毛皮', 'organic', 'common', '防寒具や装飾に使用する動物の毛皮', 45, 0.1, 100, '🟤', '#8B4513', true, NOW(), NOW()),
            
            -- === RARE MATERIALS ===
            -- Rare Metals
            ('silver_ore', '銀鉱石', 'metal', 'rare', '中級武器の材料。魔法抵抗に優れる', 200, 0.15, 999, '⚪', '#C0C0C0', true, NOW(), NOW()),
            ('steel_ingot', '鋼鉄塊', 'metal', 'rare', '高品質な鋼鉄の塊。強度が非常に高い', 300, 0.15, 200, '⚫', '#4F4F4F', true, NOW(), NOW()),
            ('bronze_alloy', '青銅合金', 'metal', 'rare', '銅と錫の合金。耐久性に優れる', 250, 0.15, 300, '🟫', '#CD7F32', true, NOW(), NOW()),
            
            -- Magic Materials  
            ('magic_crystal', '魔法石', 'magic', 'rare', '魔法武器の核となる石。魔力を蓄積できる', 500, 0.2, 999, '🔮', '#9370DB', true, NOW(), NOW()),
            ('mana_essence', 'マナエッセンス', 'magic', 'rare', '純粋な魔力の結晶。エンチャントに使用', 600, 0.25, 100, '💙', '#00BFFF', true, NOW(), NOW()),
            ('spirit_gem', '精霊石', 'magic', 'rare', '精霊の力を宿した宝石。属性付与に使用', 700, 0.2, 50, '💎', '#FF69B4', true, NOW(), NOW()),
            
            -- Rare Organics
            ('ancient_wood', '古代の木材', 'organic', 'rare', '何百年も経た硬い木材。魔法伝導性が高い', 400, 0.15, 100, '🌳', '#228B22', true, NOW(), NOW()),
            ('dragon_scale', '竜の鱗', 'organic', 'rare', '強固な防御力を持つ竜の鱗。非常に希少', 800, 0.25, 50, '🐉', '#8B0000', true, NOW(), NOW()),
            ('phoenix_feather', '不死鳥の羽', 'organic', 'rare', '再生能力を持つ不死鳥の美しい羽', 900, 0.3, 20, '🔥', '#FF4500', true, NOW(), NOW()),
            
            -- Special Stones
            ('fire_stone', '炎の石', 'elemental', 'rare', '火属性の魔力を秘めた赤い石', 350, 0.2, 200, '🔥', '#FF0000', true, NOW(), NOW()),
            ('ice_crystal', '氷の結晶', 'elemental', 'rare', '永久に溶けない氷の結晶', 380, 0.2, 200, '🧊', '#B0E0E6', true, NOW(), NOW()),
            ('lightning_shard', '雷の欠片', 'elemental', 'rare', '雷の力を封じ込めた結晶片', 420, 0.2, 150, '⚡', '#FFD700', true, NOW(), NOW()),
            ('earth_core', '地核石', 'elemental', 'rare', '大地の力を宿した重厚な石', 300, 0.2, 250, '🌍', '#8B4513', true, NOW(), NOW()),
            
            -- Processed Materials
            ('demon_horn', '悪魔の角', 'special', 'rare', '強大な魔力を秘めた悪魔の角', 750, 0.25, 30, '😈', '#8B0000', true, NOW(), NOW()),
            ('angel_feather', '天使の羽', 'special', 'rare', '聖なる力を宿した天使の羽', 820, 0.25, 25, '👼', '#F0F8FF', true, NOW(), NOW()),
            ('beast_fang', '魔獣の牙', 'organic', 'rare', '強力な魔獣の鋭い牙', 450, 0.2, 80, '🦷', '#FFFACD', true, NOW(), NOW()),
            
            -- === EPIC MATERIALS ===
            -- Legendary Metals
            ('gold_ore', '金鉱石', 'metal', 'epic', '最高級武器の材料。純度が極めて高い', 1500, 0.3, 999, '🟨', '#FFD700', true, NOW(), NOW()),
            ('adamantite_ore', 'アダマンタイト鉱石', 'metal', 'epic', '伝説的な硬度を持つ希少鉱石', 2000, 0.3, 100, '💎', '#4169E1', true, NOW(), NOW()),
            ('mithril_ingot', 'ミスリル塊', 'metal', 'epic', '軽量かつ強固な幻の金属', 2500, 0.35, 50, '✨', '#E6E6FA', true, NOW(), NOW()),
            
            -- Ancient Materials
            ('ancient_stone', '古代石', 'special', 'epic', '古代の力を宿した神秘的な石', 3000, 0.4, 999, '🗿', '#8A2BE2', true, NOW(), NOW()),
            ('void_fragment', '虚空の破片', 'void', 'epic', '次元の裂け目から得られる謎の物質', 3500, 0.4, 30, '🌌', '#191970', true, NOW(), NOW()),
            ('time_shard', '時の砂', 'temporal', 'epic', '時間の流れを操る神秘の砂', 4000, 0.45, 20, '⏳', '#DDA0DD', true, NOW(), NOW()),
            
            -- Divine Materials
            ('life_essence', '生命の樹液', 'divine', 'epic', '世界樹から採取された神聖な樹液', 2800, 0.35, 25, '🌱', '#00FF00', true, NOW(), NOW()),
            ('star_fragment', '星の欠片', 'cosmic', 'epic', '天から降ってきた隕石の破片', 3200, 0.4, 15, '⭐', '#FFD700', true, NOW(), NOW()),
            ('soul_crystal', '魂の結晶', 'spirit', 'epic', '純粋な魂の力を封じ込めた結晶', 2600, 0.3, 40, '👻', '#9370DB', true, NOW(), NOW()),
            
            -- Elemental Cores
            ('elemental_core_fire', '火の核', 'elemental', 'epic', '火の精霊の核となる結晶', 2200, 0.3, 60, '🔥', '#FF4500', true, NOW(), NOW()),
            ('elemental_core_water', '水の核', 'elemental', 'epic', '水の精霊の核となる結晶', 2200, 0.3, 60, '💧', '#0000FF', true, NOW(), NOW()),
            ('elemental_core_earth', '地の核', 'elemental', 'epic', '地の精霊の核となる結晶', 2200, 0.3, 60, '⛰️', '#8B4513', true, NOW(), NOW()),
            ('elemental_core_air', '風の核', 'elemental', 'epic', '風の精霊の核となる結晶', 2200, 0.3, 60, '💨', '#87CEEB', true, NOW(), NOW()),
            
            -- === LEGENDARY MATERIALS ===
            -- Creation Materials
            ('genesis_fragment', '創世の欠片', 'primordial', 'legendary', '世界創造時に残された原初の物質', 10000, 0.5, 5, '🌟', '#FFD700', true, NOW(), NOW()),
            ('divine_blood', '神の血', 'divine', 'legendary', '神々の血液から精製された聖なる液体', 15000, 0.6, 3, '🩸', '#8B0000', true, NOW(), NOW()),
            ('world_tree_heart', '世界樹の心臓', 'divine', 'legendary', '世界樹の中心部から取れる究極の素材', 20000, 0.7, 1, '💚', '#00FF00', true, NOW(), NOW()),
            
            -- Ultimate Materials
            ('chaos_crystal', '混沌の結晶', 'chaos', 'legendary', '秩序と混沌が混ざり合った究極の結晶', 12000, 0.5, 8, '🌀', '#4B0082', true, NOW(), NOW()),
            ('infinity_metal', '無限金属', 'cosmic', 'legendary', '無限の可能性を秘めた幻の金属', 18000, 0.6, 2, '♾️', '#C0C0C0', true, NOW(), NOW()),
            ('eternal_flame', '永遠の炎', 'divine', 'legendary', '決して消えることのない神の炎', 16000, 0.55, 4, '🔥', '#FF69B4', true, NOW(), NOW()),
            
            -- Concept Materials
            ('truth_crystal', '真理の結晶', 'abstract', 'legendary', '全ての真理を映し出す完璧な結晶', 25000, 0.8, 1, '💎', '#FFFFFF', true, NOW(), NOW()),
            ('destiny_thread', '運命の糸', 'fate', 'legendary', '運命を紡ぐ神秘的な糸', 14000, 0.5, 6, '🧵', '#9370DB', true, NOW(), NOW()),
            ('void_heart', '虚無の心臓', 'void', 'legendary', '虚無そのものの核となる物質', 22000, 0.7, 2, '🖤', '#000000', true, NOW(), NOW())
            """
            
            conn.execute(text(materials_sql))
            
            print('3. Verifying material masters data...')
            
            # Count by rarity
            result = conn.execute(text("""
                SELECT r.name, COUNT(*) as count 
                FROM material_masters m 
                JOIN rarity_levels r ON m.rarity_id = r.id 
                GROUP BY r.name, r.level 
                ORDER BY r.level
            """))
            
            print('\nMaterial count by rarity:')
            total_materials = 0
            for row in result:
                print(f'  {row[0]}: {row[1]} materials')
                total_materials += row[1]
            
            print(f'\nTotal materials created: {total_materials}')
            
            # Count by category
            result = conn.execute(text("""
                SELECT category, COUNT(*) as count 
                FROM material_masters 
                GROUP BY category 
                ORDER BY category
            """))
            
            print('\nMaterial count by category:')
            for row in result:
                print(f'  {row[0]}: {row[1]} materials')
            
            print('\n✅ MATERIAL MASTERS SEED COMPLETED SUCCESSFULLY!')
            
        except Exception as e:
            print(f'❌ Error: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()