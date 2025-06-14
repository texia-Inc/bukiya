#!/usr/bin/env python3

import asyncio
import requests
from app.core.database import SessionLocal
from app.models import CraftingRecipe, RecipeMaterial, WeaponMaster, MaterialMaster
from sqlalchemy.orm import joinedload

def test_simple_query():
    print("Testing simple recipe query...")
    db = SessionLocal()
    try:
        # Simple query without joins
        recipes = db.query(CraftingRecipe).filter(CraftingRecipe.is_active == True).limit(5).all()
        print(f"Found {len(recipes)} recipes")
        
        for recipe in recipes:
            print(f"- {recipe.name} (ID: {recipe.id})")
            
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False
    finally:
        db.close()

def test_api_endpoint():
    print("Testing API endpoint...")
    try:
        response = requests.get("http://localhost:8000/api/v1/recipes/1", timeout=5)
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Recipe name: {data['data']['name']}")
            print(f"Materials count: {len(data['data']['materials'])}")
            return True
        else:
            print(f"Error response: {response.text}")
            return False
    except Exception as e:
        print(f"API Error: {e}")
        return False

if __name__ == "__main__":
    print("=== Recipe System Test ===")
    
    # Test 1: Simple database query
    if test_simple_query():
        print("✅ Database query works")
    else:
        print("❌ Database query failed")
    
    # Test 2: Single recipe API
    if test_api_endpoint():
        print("✅ Single recipe API works")
    else:
        print("❌ Single recipe API failed")
        
    print("=== Test Complete ===")