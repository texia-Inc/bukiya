"""
Test the adventurer API endpoint directly
"""
import requests
import json

# First, let's login to get a token
login_data = {
    "email": "test@example.com",
    "password": "password"
}

base_url = "http://localhost:8000"

try:
    # Login
    login_response = requests.post(f"{base_url}/api/v1/auth/login", json=login_data)
    if login_response.status_code == 200:
        response_data = login_response.json()
        print(f"Login response: {response_data}")
        
        # Check different possible response structures
        if "access_token" in response_data:
            access_token = response_data["access_token"]
        elif "data" in response_data and "access_token" in response_data["data"]:
            access_token = response_data["data"]["access_token"]
        else:
            print(f"❌ Unexpected response structure: {response_data}")
            exit(1)
            
        print("✅ Login successful")
        
        # Get visiting adventurers
        headers = {"Authorization": f"Bearer {access_token}"}
        response = requests.get(f"{base_url}/api/v1/adventurers/visiting", headers=headers)
        
        print(f"\n📋 Visiting Adventurers Response:")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Total adventurers: {data.get('total', 0)}")
            
            if data.get('adventurers'):
                for adv in data['adventurers']:
                    print(f"\nAdventurer:")
                    print(f"  ID: {adv.get('id')} (type in JSON: {type(adv.get('id'))})")
                    print(f"  Name: {adv.get('name')}")
                    print(f"  adventurer_master_id: {adv.get('adventurer_master_id')} (type: {type(adv.get('adventurer_master_id'))})")
                    if adv.get('adventurer_master'):
                        print(f"  Master ID: {adv['adventurer_master'].get('id')} (type: {type(adv['adventurer_master'].get('id'))})")
            else:
                print("No adventurers currently visiting")
                
            # Pretty print the full response for debugging
            print("\n🔍 Full Response JSON:")
            print(json.dumps(data, indent=2, default=str))
        else:
            print(f"Error response: {response.text}")
    else:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")
        
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()