"""
Test script to verify adventurer instance schema
"""
from app.schemas.adventurer_instance import AdventurerInstance, AdventurerInstanceCreate
from datetime import datetime
from uuid import uuid4

# Test creating an adventurer instance with string adventurer_master_id
test_data = {
    "id": str(uuid4()),
    "adventurer_master_id": "adv_001",  # This should be a string now
    "player_id": str(uuid4()),
    "name": "Test Adventurer",
    "level": 5,
    "trust_level": 50,
    "status": "visiting",
    "current_quest_id": None,
    "visit_start_time": datetime.now(),
    "visit_end_time": datetime.now(),
    "created_at": datetime.now(),
    "updated_at": datetime.now(),
    "adventurer_master": None,
    "requests": [],
    "is_named_character": False,
    "character_id": None,
    "generic_name": None
}

try:
    # Create adventurer instance from dict
    adventurer = AdventurerInstance(**test_data)
    print("✅ Successfully created AdventurerInstance with string adventurer_master_id")
    print(f"   adventurer_master_id type: {type(adventurer.adventurer_master_id)}")
    print(f"   adventurer_master_id value: {adventurer.adventurer_master_id}")
    
    # Test serialization
    json_data = adventurer.dict()
    print("✅ Successfully serialized to dict")
    print(f"   adventurer_master_id in dict: {json_data['adventurer_master_id']}")
    
except Exception as e:
    print(f"❌ Error: {e}")

# Test with integer adventurer_master_id (should fail or be converted)
test_data_int = test_data.copy()
test_data_int["adventurer_master_id"] = 123  # Integer instead of string

try:
    adventurer_int = AdventurerInstance(**test_data_int)
    print(f"⚠️  Integer adventurer_master_id was accepted: {adventurer_int.adventurer_master_id}")
    print(f"   Type: {type(adventurer_int.adventurer_master_id)}")
except Exception as e:
    print(f"✅ Integer adventurer_master_id correctly rejected: {e}")