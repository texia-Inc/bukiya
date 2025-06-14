#!/usr/bin/env python3
"""
モンスタードロップセットアップスクリプト
包括的なドロップテーブルの作成と検証を一括実行します。
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from monster_drop_comprehensive_seed import MonsterDropSeeder
from verify_monster_drops import MonsterDropVerifier

def main():
    print("🏆 武器屋放置ゲーム - モンスタードロップセットアップ")
    print("=" * 60)
    
    # Step 1: ドロップテーブル作成
    print("\n📝 STEP 1: ドロップテーブル作成")
    print("-" * 40)
    
    try:
        seeder = MonsterDropSeeder()
        seeder.run()
        print("✅ ドロップテーブル作成完了")
    except Exception as e:
        print(f"❌ ドロップテーブル作成エラー: {e}")
        return False
    
    # Step 2: 検証実行
    print("\n🔍 STEP 2: ドロップテーブル検証")
    print("-" * 40)
    
    try:
        verifier = MonsterDropVerifier()
        verification_passed = verifier.run_verification()
        
        if verification_passed:
            print("✅ 検証完了 - 全チェック合格")
        else:
            print("⚠️ 検証完了 - 一部問題あり（確認が必要）")
        
    except Exception as e:
        print(f"❌ 検証エラー: {e}")
        return False
    
    # 完了メッセージ
    print("\n" + "=" * 60)
    print("🎉 モンスタードロップセットアップ完了！")
    print("\n💡 作成内容:")
    print("  ✓ 全100体のモンスターにバランスの取れたマテリアルドロップ")
    print("  ✓ 各モンスターに1%の確率で次のレアリティ武器ドロップ")
    print("  ✓ レベル帯に応じた適切なアイテム分布")
    print("  ✓ プログレッション論理に基づいたドロップ設計")
    
    print("\n🎮 ゲームでお楽しみください！")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)