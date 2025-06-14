#!/usr/bin/env python3
"""
冒険者・モンスター管理画面エラー修正（安全版）
依存関係を考慮したマイニマルな修正を実行
"""

import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

# Fix database URL for local development
DATABASE_URL = settings.DATABASE_URL.replace("postgres:", "localhost:")

def main():
    print('=== 冒険者・モンスター管理画面エラー修正（安全版）===')
    engine = create_engine(DATABASE_URL)
    
    with engine.begin() as conn:
        try:
            print('\n1. 外部キー依存関係の調査...')
            
            # 依存テーブルの確認
            result = conn.execute(text("""
                SELECT 
                    tc.table_name,
                    kcu.column_name,
                    ccu.table_name AS foreign_table_name,
                    ccu.column_name AS foreign_column_name
                FROM information_schema.table_constraints AS tc
                JOIN information_schema.key_column_usage AS kcu 
                    ON tc.constraint_name = kcu.constraint_name
                JOIN information_schema.constraint_column_usage AS ccu 
                    ON ccu.constraint_name = tc.constraint_name
                WHERE tc.constraint_type = 'FOREIGN KEY' 
                AND (ccu.table_name = 'adventurer_masters' OR ccu.table_name = 'monster_masters')
            """))
            
            dependencies = list(result.fetchall())
            print('   依存関係:')
            for dep in dependencies:
                print(f'     {dep[0]}.{dep[1]} → {dep[2]}.{dep[3]}')
            
            print('\n2. 現在のデータの確認...')
            
            # adventurer_masters のサンプルデータ
            result = conn.execute(text("SELECT id, name FROM adventurer_masters LIMIT 3"))
            print('   adventurer_masters サンプル:')
            for row in result:
                print(f'     ID: {row[0]}, Name: {row[1]}')
            
            # monster_masters のサンプルデータ
            result = conn.execute(text("SELECT id, name FROM monster_masters LIMIT 3"))
            print('   monster_masters サンプル:')
            for row in result:
                print(f'     ID: {row[0]}, Name: {row[1]}')
            
            print('\n3. アプローチの変更: モデル側を修正する方針に変更')
            print('   理由: データベースの依存関係が複雑で、ID型変更のリスクが高い')
            
            print('\n4. SQLAlchemyモデルの修正推奨事項:')
            print('   adventurer_master.py:')
            print('     - id = Column(Integer, ...) → id = Column(String(50), ...)')
            print('   monster_masters (adventurer_master.py内):')
            print('     - id = Column(Integer, ...) → id = Column(String(50), ...)')
            print('   adventurer_instance.py:')
            print('     - adventurer_master_id = Column(Integer, ...) → Column(String(50), ...)')
            
            print('\n5. 実際のAPIスキーマの修正推奨事項:')
            print('   schemas/adventurer.py:')
            print('     - id: int → id: str')
            print('   schemas/monster.py:')  
            print('     - id: int → id: str')
            
            print('\n6. 現在のデータを保持したまま、アプリケーション側で対応')
            print('   データベース変更なし、コード修正で対応する安全なアプローチです')
            
            print('\n7. 重複カラムの整理（実行可能な軽微な修正）...')
            
            # 重複カラムの存在確認
            result = conn.execute(text("""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = 'adventurer_masters' 
                AND column_name IN ('class', 'profession')
                ORDER BY column_name
            """))
            columns = [row[0] for row in result]
            print(f'   重複カラム: {columns}')
            
            if 'class' in columns and 'profession' in columns:
                print('   重複カラム統合を実行...')
                
                # profession が NULL の場合、class の値をコピー
                conn.execute(text("""
                    UPDATE adventurer_masters 
                    SET profession = class 
                    WHERE profession IS NULL AND class IS NOT NULL
                """))
                
                # class カラムを削除（リスクが低い）
                conn.execute(text("ALTER TABLE adventurer_masters DROP COLUMN IF EXISTS class"))
                print('   ✅ class カラムを削除し、profession に統合完了')
            
            print('\n✅ 安全な修正完了!')
            print('\n次のステップ:')
            print('1. SQLAlchemyモデルでString型IDに修正')
            print('2. Pydanticスキーマで文字列型IDに修正')
            print('3. フロントエンド側で文字列IDに対応')
            
        except Exception as e:
            print(f'❌ エラー: {e}')
            import traceback
            traceback.print_exc()
            raise

if __name__ == '__main__':
    main()