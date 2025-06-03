"""
放置システム用のテーブルを作成するスクリプト
"""

from sqlalchemy import create_engine
from app.core.database import Base
from app.models.idle_system import PlayerIdleSystem, IdleUpgradeMaster, PlayerIdleUpgrade, IdleBonusMaster, PlayerIdleBonus
from app.core.config import settings

def create_tables():
    """放置システムのテーブルを作成"""
    engine = create_engine(settings.DATABASE_URL)
    
    # 放置システム関連のテーブルのみ作成
    tables_to_create = [
        PlayerIdleSystem.__table__,
        IdleUpgradeMaster.__table__,
        PlayerIdleUpgrade.__table__,
        IdleBonusMaster.__table__,
        PlayerIdleBonus.__table__
    ]
    
    for table in tables_to_create:
        try:
            table.create(engine, checkfirst=True)
            print(f"テーブル {table.name} を作成しました")
        except Exception as e:
            print(f"テーブル {table.name} の作成でエラー: {e}")
    
    print("放置システムのテーブル作成完了！")

if __name__ == "__main__":
    create_tables()
