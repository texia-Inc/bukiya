#!/usr/bin/env python3
"""
API Endpoint Test Script
Test all critical endpoints to verify they're working
"""
import requests
import json
import time

BASE_URL = "http://localhost:8000"

def test_endpoint(method, endpoint, data=None, headers=None, expected_status=None):
    """Test a single API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    print(f"\n🔍 Testing {method} {endpoint}")
    
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=5)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=5)
        
        print(f"   Status: {response.status_code}")
        
        if expected_status and response.status_code != expected_status:
            print(f"   ❌ Expected {expected_status}, got {response.status_code}")
        else:
            print(f"   ✅ Response received")
            
        if response.headers.get('content-type', '').startswith('application/json'):
            try:
                json_data = response.json()
                print(f"   Data: {json.dumps(json_data, indent=2)[:200]}...")
            except:
                print(f"   Raw: {response.text[:200]}...")
        else:
            print(f"   Raw: {response.text[:200]}...")
            
        return response.status_code == (expected_status or 200)
        
    except requests.exceptions.ConnectionError:
        print(f"   ❌ Connection refused - is the server running?")
        return False
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False

def main():
    print("=== API Endpoint Test Suite ===")
    
    # 1. Health check
    test_endpoint("GET", "/health", expected_status=200)
    
    # 2. API documentation (should exist in development)
    test_endpoint("GET", "/docs", expected_status=200)
    
    # 3. Auth endpoints (expect various status codes)
    test_endpoint("POST", "/api/v1/auth/login", 
                 data={"email": "test@test.com", "password": "test"}, 
                 expected_status=401)  # Should fail with invalid credentials
    
    test_endpoint("POST", "/api/v1/auth/guest-login", expected_status=200)
    
    # 4. Player endpoint (should require auth)
    test_endpoint("GET", "/api/v1/players/me", expected_status=401)
    
    # 5. Other critical endpoints
    test_endpoint("GET", "/api/v1/weapons", expected_status=401)  # Should require auth
    test_endpoint("GET", "/api/v1/materials", expected_status=401)  # Should require auth
    
    print("\n=== Test Summary ===")
    print("If most endpoints return 401 (Unauthorized), that's GOOD!")
    print("It means the API is running and auth is working.")
    print("404 errors indicate missing endpoints - that's BAD.")
    print("\nNext: Try the Flutter app login flow.")

if __name__ == "__main__":
    main()