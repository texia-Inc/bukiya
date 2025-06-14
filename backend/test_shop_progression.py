#!/usr/bin/env python3
"""
ショップレベル進行システムのテスト
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

def test_shop_progression():
    """ショップレベル進行をテスト"""
    print("=== ショップレベル進行テスト ===")
    
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
    initial_level = player_data["shop_level"]
    initial_exp = player_data.get("shop_exp", 0)
    
    print(f"🎯 初期ショップレベル: {initial_level}, 経験値: {initial_exp}")
    
    # 武器購入を10回実行してレベルアップをテスト
    weapon_id = "110"  # ブロンズソード
    
    for i in range(10):
        print(f"\n--- 武器購入テスト {i+1}/10 ---")
        
        # 武器購入
        purchase_data = {"weapon_id": weapon_id}
        response = requests.post(f"{BASE_URL}/shop/purchase", json=purchase_data, headers=headers)
        
        if response.status_code == 200:
            result = response.json()
            shop_progression = result["data"].get("shop_progression", {})
            level_up = result["data"].get("shop_level_up")
            
            print(f"✅ 購入成功: 経験値+{shop_progression.get('exp_gained', 0)}")
            print(f"   現在レベル: {shop_progression.get('current_level', 'unknown')}")
            print(f"   進捗: {shop_progression.get('progress_percentage', 0)*100:.1f}%")
            
            if level_up:
                print(f"🎉 レベルアップ！ {level_up['message']}")
                
        elif response.status_code == 400:
            result = response.json()
            if "ゴールドが不足" in result["detail"]:
                print("💰 ゴールド不足のため武器売却に切り替え")
                
                # プレイヤーの武器を取得
                weapons_response = requests.get(f"{BASE_URL}/weapons/my", headers=headers)
                if weapons_response.status_code == 200:
                    weapons = weapons_response.json()["data"]
                    if weapons:
                        # 最初の武器を売却
                        sell_data = {"player_weapon_id": weapons[0]["id"]}
                        sell_response = requests.post(f"{BASE_URL}/shop/sell", json=sell_data, headers=headers)
                        
                        if sell_response.status_code == 200:
                            sell_result = sell_response.json()
                            shop_progression = sell_result["data"].get("shop_progression", {})
                            level_up = sell_result["data"].get("shop_level_up")
                            
                            print(f"✅ 売却成功: 経験値+{shop_progression.get('exp_gained', 0)}")
                            print(f"   現在レベル: {shop_progression.get('current_level', 'unknown')}")
                            
                            if level_up:
                                print(f"🎉 レベルアップ！ {level_up['message']}")
            else:
                print(f"❌ 購入エラー: {result['detail']}")
                break
        else:
            print(f"❌ 購入失敗: {response.text}")
            break
    
    # 最終的なプレイヤー情報を取得
    response = requests.get(f"{BASE_URL}/players/me", headers=headers)
    if response.status_code == 200:
        final_data = response.json()["data"]["player"]
        final_level = final_data["shop_level"]
        final_exp = final_data.get("shop_exp", 0)
        
        print(f"\n🏁 最終ショップレベル: {final_level}, 経験値: {final_exp}")
        print(f"📈 レベル変化: {initial_level} → {final_level} ({final_level - initial_level}レベルアップ)")
        print(f"📊 経験値変化: {initial_exp} → {final_exp} (+{final_exp - initial_exp})")
    
    print("\n=== テスト完了 ===")

if __name__ == "__main__":
    test_shop_progression()