#!/usr/bin/env python3
"""
包括的データベース状況確認スクリプト
全テーブルの存在とデータ件数を確認
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text, inspect
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== 包括的データベース状況確認 ===')
    engine = create_engine(DATABASE_URL)
    
    try:
        with engine.connect() as conn:
            inspector = inspect(engine)
            
            print('\n1. 全テーブル一覧:')
            tables = inspector.get_table_names()
            print(f'   総テーブル数: {len(tables)}')
            
            # 重要なテーブルの存在確認とデータ件数
            critical_tables = [
                'rarity_levels', 'weapon_types', 'weapon_masters', 'material_masters',
                'crafting_recipes', 'recipe_materials', 'monster_masters', 'area_masters',
                'players', 'player_weapons', 'player_materials', 'adventurer_characters',
                'adventurer_instances', 'enchantment_types', 'enchantment_materials',
                'mission_templates', 'idle_upgrade_masters', 'monster_drop_tables'
            ]
            
            print('\n2. 重要テーブルの状況:')
            existing_tables = {}
            missing_tables = []
            
            for table in critical_tables:
                if table in tables:
                    try:
                        result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
                        count = result.scalar()
                        existing_tables[table] = count
                        status = "✅" if count > 0 else "⚠️ "
                        print(f'   {status} {table}: {count} レコード')
                    except Exception as e:
                        print(f'   ❌ {table}: エラー - {e}')
                else:
                    missing_tables.append(table)
                    print(f'   ❌ {table}: テーブルが存在しません')
            
            print('\n3. ゲーム機能別データ状況:')
            
            # 武器システム
            print('\n   【武器システム】')
            if 'weapon_masters' in existing_tables:
                result = conn.execute(text("""
                    SELECT r.name, COUNT(*) as count 
                    FROM weapon_masters w 
                    JOIN rarity_levels r ON w.rarity_id = r.id 
                    GROUP BY r.name, r.level 
                    ORDER BY r.level
                """))
                for row in result:
                    print(f'     {row[0]}武器: {row[1]}種類')
            
            # 素材システム
            print('\n   【素材システム】')
            if 'material_masters' in existing_tables:
                result = conn.execute(text("""
                    SELECT r.name, COUNT(*) as count 
                    FROM material_masters m 
                    JOIN rarity_levels r ON m.rarity_id = r.id 
                    GROUP BY r.name, r.level 
                    ORDER BY r.level
                """))
                for row in result:
                    print(f'     {row[0]}素材: {row[1]}種類')
            
            # レシピシステム
            print('\n   【レシピシステム】')
            if 'crafting_recipes' in existing_tables:
                result = conn.execute(text("""
                    SELECT r.name, COUNT(*) as count 
                    FROM crafting_recipes cr
                    JOIN weapon_masters w ON cr.weapon_id = w.id
                    JOIN rarity_levels r ON w.rarity_id = r.id
                    GROUP BY r.name, r.level 
                    ORDER BY r.level
                """))
                for row in result:
                    print(f'     {row[0]}武器レシピ: {row[1]}件')
                
                if 'recipe_materials' in existing_tables:
                    result = conn.execute(text("SELECT COUNT(*) FROM recipe_materials"))
                    count = result.scalar()
                    print(f'     レシピ素材要件: {count}件')
            
            # モンスターシステム
            print('\n   【モンスターシステム】')
            if 'monster_masters' in existing_tables:
                result = conn.execute(text("""
                    SELECT 
                        CASE 
                            WHEN level <= 20 THEN 'Tier 1 (1-20)'
                            WHEN level <= 50 THEN 'Tier 2 (21-50)'
                            WHEN level <= 80 THEN 'Tier 3 (51-80)'
                            ELSE 'Tier 4 (81-100)'
                        END as tier,
                        COUNT(*) as count
                    FROM monster_masters 
                    GROUP BY 
                        CASE 
                            WHEN level <= 20 THEN 'Tier 1 (1-20)'
                            WHEN level <= 50 THEN 'Tier 2 (21-50)'
                            WHEN level <= 80 THEN 'Tier 3 (51-80)'
                            ELSE 'Tier 4 (81-100)'
                        END
                    ORDER BY tier
                """))
                for row in result:
                    print(f'     {row[0]}: {row[1]}体')
                
                if 'area_masters' in existing_tables:
                    result = conn.execute(text("SELECT COUNT(*) FROM area_masters"))
                    area_count = result.scalar()
                    print(f'     エリア数: {area_count}箇所')
            
            # 冒険者システム
            print('\n   【冒険者システム】')
            if 'adventurer_characters' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM adventurer_characters"))
                char_count = result.scalar()
                print(f'     冒険者キャラクター: {char_count}体')
            
            if 'adventurer_instances' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM adventurer_instances"))
                instance_count = result.scalar()
                print(f'     冒険者インスタンス: {instance_count}体')
            
            # エンチャントシステム
            print('\n   【エンチャントシステム】')
            if 'enchantment_types' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM enchantment_types"))
                ench_types = result.scalar()
                print(f'     エンチャント種類: {ench_types}種類')
            
            if 'enchantment_materials' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM enchantment_materials"))
                ench_materials = result.scalar()
                print(f'     エンチャント素材: {ench_materials}種類')
            
            # ミッションシステム
            print('\n   【ミッションシステム】')
            if 'mission_templates' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM mission_templates"))
                mission_count = result.scalar()
                print(f'     ミッションテンプレート: {mission_count}件')
            
            # 放置システム
            print('\n   【放置システム】')
            if 'idle_upgrade_masters' in existing_tables:
                result = conn.execute(text("SELECT COUNT(*) FROM idle_upgrade_masters"))
                idle_count = result.scalar()
                print(f'     放置アップグレード: {idle_count}種類')
            
            print('\n4. 不足している重要テーブル:')
            if missing_tables:
                for table in missing_tables:
                    print(f'   ❌ {table}')
                    
                print('\n   必要な作成スクリプト:')
                script_mapping = {
                    'adventurer_characters': 'create_adventurer_tables.py',
                    'adventurer_instances': 'create_adventurer_tables.py', 
                    'enchantment_types': 'create_enchantment_tables.py',
                    'enchantment_materials': 'create_enchantment_tables.py',
                    'mission_templates': 'create_mission_templates.py',
                    'idle_upgrade_masters': 'create_idle_tables.py',
                    'monster_drop_tables': 'setup_monster_drops.py'
                }
                
                for table in missing_tables:
                    if table in script_mapping:
                        print(f'     {table} → {script_mapping[table]}')
            else:
                print('   ✅ 全ての重要テーブルが存在します')
            
            print('\n5. データ復旧完了度評価:')
            
            # 各システムの完成度チェック
            completion = {}
            
            # 基本マスターデータ (必須)
            master_tables = ['rarity_levels', 'weapon_types', 'weapon_masters', 'material_masters']
            master_complete = all(table in existing_tables and existing_tables[table] > 0 for table in master_tables)
            completion['基本マスターデータ'] = master_complete
            
            # レシピシステム (重要)
            recipe_complete = ('crafting_recipes' in existing_tables and existing_tables['crafting_recipes'] > 0 and
                             'recipe_materials' in existing_tables and existing_tables['recipe_materials'] > 0)
            completion['レシピシステム'] = recipe_complete
            
            # モンスターシステム (重要)
            monster_complete = ('monster_masters' in existing_tables and existing_tables['monster_masters'] > 0 and
                              'area_masters' in existing_tables and existing_tables['area_masters'] > 0)
            completion['モンスターシステム'] = monster_complete
            
            # 冒険者システム (オプション)
            adventurer_complete = ('adventurer_characters' in existing_tables and existing_tables['adventurer_characters'] > 0)
            completion['冒険者システム'] = adventurer_complete
            
            # エンチャントシステム (オプション)
            enchant_complete = ('enchantment_types' in existing_tables and existing_tables['enchantment_types'] > 0)
            completion['エンチャントシステム'] = enchant_complete
            
            for system, complete in completion.items():
                status = "✅ 完了" if complete else "❌ 未完了"
                print(f'   {system}: {status}')
            
            # 総合評価
            essential_systems = ['基本マスターデータ', 'レシピシステム', 'モンスターシステム']
            essential_complete = all(completion[sys] for sys in essential_systems)
            
            print(f'\n6. 総合評価:')
            if essential_complete:
                print('   🎉 ゲーム運用に必要な基本データは全て復旧済みです！')
                
                optional_complete = sum(completion[sys] for sys in completion if sys not in essential_systems)
                total_optional = len(completion) - len(essential_systems)
                print(f'   📊 オプション機能: {optional_complete}/{total_optional} 完了')
            else:
                print('   ⚠️  まだ復旧が必要なシステムがあります')
                for sys in essential_systems:
                    if not completion[sys]:
                        print(f'     - {sys}が未完了')
                        
        print('\n✅ データベース状況確認完了')
            
    except Exception as e:
        print(f'❌ データベース接続エラー: {e}')
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()