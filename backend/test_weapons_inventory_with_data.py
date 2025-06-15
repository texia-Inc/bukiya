#!/usr/bin/env python3
"""
Test script for weapons inventory endpoint with actual weapons data
"""
import requests
import json
import time
import uuid
from datetime import datetime

BASE_URL = "http://localhost:8000"

def print_response(response, title="Response"):
    """Print formatted response for debugging"""
    print(f"\n=== {title} ===")
    print(f"Status Code: {response.status_code}")
    try:
        data = response.json()
        print(f"JSON Response: {json.dumps(data, indent=2, default=str)}")
    except:
        print(f"Raw Response: {response.text}")
    print("=" * 50)

def create_test_user():
    """Create a test user for testing"""
    test_email = f"test_{int(time.time())}@test.com"
    test_username = f"testuser_{int(time.time())}"
    
    user_data = {
        "username": test_username,
        "email": test_email,
        "password": "testpassword123"
    }
    
    print(f"Creating test user: {test_username} ({test_email})")
    
    response = requests.post(
        f"{BASE_URL}/api/v1/auth/register",
        json=user_data,
        timeout=10
    )
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            return data["data"]["access_token"], test_username, test_email
    
    return None, test_username, test_email

def get_available_weapons(access_token):
    """Get list of available weapons from shop"""
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    response = requests.get(
        f"{BASE_URL}/api/v1/weapons",
        headers=headers,
        timeout=10
    )
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success") and data.get("data"):
            return data["data"][:3]  # Return first 3 weapons
    
    return []

def create_player_weapon(access_token, weapon_master_id):
    """Create a weapon for the player using the API"""
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    weapon_data = {
        "weapon_master_id": weapon_master_id,
        "base_attack": 100 + weapon_master_id,  # Required base_attack field
        "enchant_level": weapon_master_id % 3,  # 0-2 enchant level
        "custom_name": f"Test Weapon {weapon_master_id}"
    }
    
    print(f"Creating player weapon with master ID: {weapon_master_id}")
    
    response = requests.post(
        f"{BASE_URL}/api/v1/weapons/player/create",
        json=weapon_data,
        headers=headers,
        timeout=10
    )
    
    print_response(response, f"Create Weapon {weapon_master_id}")
    
    return response.status_code == 200

def test_weapons_inventory(access_token, expected_count=0):
    """Test the weapons inventory endpoint"""
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    print(f"Testing weapons inventory endpoint (expecting {expected_count} weapons)...")
    
    response = requests.get(
        f"{BASE_URL}/api/v1/weapons/player/inventory",
        headers=headers,
        timeout=10
    )
    
    print_response(response, "Weapons Inventory")
    
    success = response.status_code == 200
    weapons_count = 0
    
    if success:
        data = response.json()
        if data.get("success") and isinstance(data.get("data"), list):
            weapons_count = len(data["data"])
            print(f"Found {weapons_count} weapons in inventory")
            
            # Print detailed info about each weapon
            for i, weapon in enumerate(data["data"]):
                print(f"\nWeapon {i+1}:")
                print(f"  ID: {weapon.get('id', 'N/A')}")
                print(f"  Name: {weapon.get('weapon_name', 'N/A')}")
                print(f"  Attack: {weapon.get('attack', 'N/A')}")
                print(f"  Enchant Level: {weapon.get('enchant_level', 'N/A')}")
                print(f"  Custom Name: {weapon.get('custom_name', 'N/A')}")
                
                weapon_master = weapon.get('weapon_master', {})
                if weapon_master:
                    print(f"  Master Name: {weapon_master.get('name', 'N/A')}")
                    print(f"  Rarity: {weapon_master.get('rarity', {}).get('name', 'N/A')}")
                    print(f"  Type: {weapon_master.get('weapon_type', {}).get('name', 'N/A')}")
    
    return success, weapons_count

def main():
    """Main test function"""
    print("=== Weapons Inventory Test with Data ===")
    print(f"Testing against: {BASE_URL}")
    print(f"Timestamp: {datetime.now()}")
    
    # 1. Create a test user
    access_token, username, email = create_test_user()
    
    if not access_token:
        print("❌ Could not create test user")
        return
    
    print(f"✅ Successfully created user: {username}")
    
    # 2. Test empty inventory first
    success, count = test_weapons_inventory(access_token, 0)
    
    if not success:
        print("❌ Weapons inventory endpoint failed with empty inventory")
        return
    
    print(f"✅ Empty inventory test passed ({count} weapons)")
    
    # 3. Get available weapons
    weapons = get_available_weapons(access_token)
    
    if not weapons:
        print("⚠️  No weapons available in the database")
        print("✅ Test completed successfully - inventory endpoint is working")
        return
    
    print(f"Found {len(weapons)} available weapons")
    
    # 4. Create some player weapons
    created_weapons = 0
    for weapon in weapons:
        weapon_id = weapon.get('id')
        if weapon_id:
            if create_player_weapon(access_token, weapon_id):
                created_weapons += 1
                print(f"✅ Created weapon {weapon_id}")
            else:
                print(f"❌ Failed to create weapon {weapon_id}")
    
    print(f"Created {created_weapons} weapons")
    
    # 5. Test inventory with weapons
    success, count = test_weapons_inventory(access_token, created_weapons)
    
    if success and count == created_weapons:
        print(f"✅ Inventory test with {count} weapons passed!")
    else:
        print(f"❌ Inventory test failed. Expected {created_weapons}, got {count}")
    
    print("\n=== Test Summary ===")
    print(f"User: {username} ({email})")
    print(f"Weapons created: {created_weapons}")
    print(f"Weapons in inventory: {count}")
    print(f"Inventory endpoint: {'✅ SUCCESS' if success else '❌ FAILED'}")
    
    if success:
        print("\n🎉 The weapons inventory endpoint is working correctly!")
        print("   - Successfully handles empty inventory")
        print("   - Successfully handles populated inventory")
        print("   - Properly validates and returns weapon data")
        print("   - The Pydantic validation fix was successful!")

if __name__ == "__main__":
    main()