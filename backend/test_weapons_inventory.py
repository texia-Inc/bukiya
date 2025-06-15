#!/usr/bin/env python3
"""
Test script for weapons inventory endpoint
Tests the /api/v1/weapons/player/inventory endpoint that was failing with 500 error
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
    print(f"Headers: {dict(response.headers)}")
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
    
    print_response(response, "User Registration")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            return data["data"]["access_token"], test_username, test_email
        else:
            print(f"Registration failed: {data.get('message', 'Unknown error')}")
    
    return None, test_username, test_email

def test_guest_login():
    """Try guest login as alternative"""
    device_id = str(uuid.uuid4())
    
    guest_data = {
        "device_id": device_id,
        "device_info": {
            "name": "Test Device",
            "platform": "test",
            "model": "test_model",
            "version": "1.0"
        }
    }
    
    print(f"Trying guest login with device_id: {device_id}")
    
    response = requests.post(
        f"{BASE_URL}/api/v1/auth/guest-login",
        json=guest_data,
        timeout=10
    )
    
    print_response(response, "Guest Login")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            return data["data"]["access_token"], data["data"]["username"], data["data"]["player_id"]
    
    return None, None, None

def test_weapons_inventory(access_token):
    """Test the weapons inventory endpoint that was failing"""
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    print("Testing weapons inventory endpoint...")
    
    response = requests.get(
        f"{BASE_URL}/api/v1/weapons/player/inventory",
        headers=headers,
        timeout=10
    )
    
    print_response(response, "Weapons Inventory")
    
    return response.status_code == 200

def test_other_endpoints(access_token):
    """Test other related endpoints for comparison"""
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    endpoints_to_test = [
        ("/api/v1/players/me", "Player Profile"),
        ("/api/v1/weapons", "Weapons List"),
        ("/api/v1/materials", "Materials List"),
    ]
    
    for endpoint, name in endpoints_to_test:
        print(f"\nTesting {name} ({endpoint})...")
        try:
            response = requests.get(
                f"{BASE_URL}{endpoint}",
                headers=headers,
                timeout=10
            )
            print(f"Status: {response.status_code}")
            if response.status_code == 200:
                try:
                    data = response.json()
                    print(f"Success: {data.get('success', 'N/A')}")
                    print(f"Message: {data.get('message', 'N/A')}")
                except:
                    print("Response received but not JSON")
            elif response.status_code == 401:
                print("Unauthorized (expected if auth is working)")
            else:
                print(f"Unexpected status: {response.text[:200]}")
        except Exception as e:
            print(f"Error: {e}")

def check_server_health():
    """Check if the server is running"""
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"Server health check: {response.status_code}")
        return response.status_code == 200
    except:
        print("❌ Server is not running or not accessible")
        return False

def main():
    """Main test function"""
    print("=== Weapons Inventory Test Suite ===")
    print(f"Testing against: {BASE_URL}")
    print(f"Timestamp: {datetime.now()}")
    
    # 1. Check server health
    if not check_server_health():
        print("Please start the backend server first:")
        print("  docker-compose up -d")
        print("  OR")
        print("  cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
        return
    
    # 2. Try to create a test user
    access_token, username, identifier = create_test_user()
    
    # 3. If registration fails, try guest login
    if not access_token:
        print("\nUser registration failed, trying guest login...")
        access_token, username, identifier = test_guest_login()
    
    if not access_token:
        print("❌ Could not obtain access token from either registration or guest login")
        return
    
    print(f"✅ Successfully obtained access token for user: {username}")
    print(f"Token (first 20 chars): {access_token[:20]}...")
    
    # 4. Test the main endpoint that was failing
    success = test_weapons_inventory(access_token)
    
    if success:
        print("✅ Weapons inventory endpoint is working correctly!")
    else:
        print("❌ Weapons inventory endpoint is still failing")
    
    # 5. Test other endpoints for comparison
    test_other_endpoints(access_token)
    
    print("\n=== Test Summary ===")
    print(f"User: {username} ({identifier})")
    print(f"Inventory endpoint: {'✅ SUCCESS' if success else '❌ FAILED'}")
    print("\nIf the inventory endpoint is working now, the Pydantic validation fix was successful!")

if __name__ == "__main__":
    main()