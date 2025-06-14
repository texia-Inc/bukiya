#!/usr/bin/env python3
"""
武器仕入れシステムのテスト
"""

import requests
import json

# テスト設定
BASE_URL = "http://localhost:8000/api/v1"
TEST_EMAIL = "shoptest@example.com"
TEST_PASSWORD = "shoptest123"

def get_auth_token():
    """認証トークンを取得"""
    login_data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }
    
    response = requests.post(f"{BASE_URL}/auth/login", json=login_data)
    if response.status_code == 200:
        return response.json()["data"]["access_token"]
    else:
        print(f"Login failed: {response.text}")
        return None

def get_headers(token):
    """認証ヘッダーを作成"""
    return {"Authorization": f"Bearer {token}"}

def test_procurement_system():
    """武器仕入れシステムをテスト"""
    print("=== 武器仕入れシステムテスト ===")
    
    # 認証
    token = get_auth_token()
    if not token:
        print("❌ 認証に失敗しました")
        return
    
    headers = get_headers(token)
    
    # 現在のプレイヤー情報を取得
    response = requests.get(f"{BASE_URL}/players/me", headers=headers)
    if response.status_code != 200:
        print(f"❌ プレイヤー情報取得に失敗: {response.text}")
        return
    
    player_data = response.json()["data"]["player"]
    initial_gold = player_data["gold"]
    initial_level = player_data["shop_level"]
    
    print(f"🎯 初期状態: ゴールド{initial_gold}G, ショップレベル{initial_level}")
    
    # 武器仕入れテスト
    weapon_id = "110"  # ブロンズソード（販売価格50G → 仕入れ価格35G）
    
    print(f"\n--- 武器仕入れテスト ---")
    print(f"仕入れ対象: 武器ID {weapon_id}")
    
    # 新しい仕入れエンドポイントをテスト
    procurement_data = {"weapon_id": weapon_id}
    response = requests.post(f"{BASE_URL}/shop/procure", json=procurement_data, headers=headers)
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ 仕入れ成功!")
        print(f"   武器名: {result['data']['weapon_name']}")
        print(f"   仕入れ費用: {result['data']['procurement_cost']}G")
        print(f"   残りゴールド: {result['data']['remaining_gold']}G")
        print(f"   メッセージ: {result['message']}")
        
        # ショップ進行情報の確認
        shop_progression = result['data'].get('shop_progression', {})
        if shop_progression:
            print(f"   経験値獲得: +{shop_progression.get('exp_gained', 0)}")
            
        # レベルアップの確認
        level_up = result['data'].get('shop_level_up')
        if level_up:
            print(f"🎉 {level_up['message']}")
            
    else:
        print(f"❌ 仕入れ失敗: {response.text}")
        return
    
    # 価格差の確認
    expected_cost = 50 * 0.7  # 35G（販売価格50Gの70%）
    actual_cost = result['data']['procurement_cost']
    print(f"\n💰 価格設定確認:")
    print(f"   期待仕入れ価格: {expected_cost}G（販売価格の70%）")
    print(f"   実際仕入れ価格: {actual_cost}G")
    print(f"   ✅ 価格計算正常" if actual_cost == expected_cost else f"❌ 価格計算異常")
    
    # 旧エンドポイント（後方互換性）もテスト
    print(f"\n--- 後方互換性テスト（旧purchaseエンドポイント） ---")
    response = requests.post(f"{BASE_URL}/shop/purchase", json=procurement_data, headers=headers)
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ 旧エンドポイント動作確認")
        print(f"   メッセージ: {result['message']}")
        print(f"   ✅ 「仕入れ」用語に変更済み" if "仕入れ" in result['message'] else "❌ まだ「購入」表記")
    else:
        print(f"❌ 旧エンドポイント失敗: {response.text}")
    
    # 最終状態確認
    response = requests.get(f"{BASE_URL}/players/me", headers=headers)
    if response.status_code == 200:
        final_data = response.json()["data"]["player"]
        final_gold = final_data["gold"]
        final_level = final_data["shop_level"]
        
        print(f"\n🏁 最終状態: ゴールド{final_gold}G, ショップレベル{final_level}")
        print(f"📊 ゴールド変化: {initial_gold}G → {final_gold}G ({final_gold - initial_gold}G)")
        print(f"📈 レベル変化: {initial_level} → {final_level}")
    
    print("\n=== 仕入れシステムテスト完了 ===")

if __name__ == "__main__":
    test_procurement_system()