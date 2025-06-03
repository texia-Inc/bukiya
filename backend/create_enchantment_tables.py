"""
エンチャントシステムのテーブル作成スクリプト
"""

from sqlalchemy import create_engine
from app.core.database import Base, engine
from app.models.enchantment import (
    EnchantmentType, WeaponEnchantment, EnchantmentLog,
    EnchantmentMaterial, PlayerEnchantmentMaterial
)

def create_enchantment_tables():
    """エンチャントシステムのテーブルを作成"""
    try:
        
        # エンチャント関連のテーブルを作成
        print("エンチャントテーブルを作成中...")
        
        # 特定のテーブルのみ作成
        EnchantmentType.__table__.create(engine, checkfirst=True)
        print("✅ enchantment_types テーブル作成完了")
        
        WeaponEnchantment.__table__.create(engine, checkfirst=True)
        print("✅ weapon_enchantments テーブル作成完了")
        
        EnchantmentLog.__table__.create(engine, checkfirst=True)
        print("✅ enchantment_logs テーブル作成完了")
        
        EnchantmentMaterial.__table__.create(engine, checkfirst=True)
        print("✅ enchantment_materials テーブル作成完了")
        
        PlayerEnchantmentMaterial.__table__.create(engine, checkfirst=True)
        print("✅ player_enchantment_materials テーブル作成完了")
        
        print("🎉 エンチャントテーブル作成完了！")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")

if __name__ == "__main__":
    create_enchantment_tables()
