#!/usr/bin/env python3
"""
Test monster model queries
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, func
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.models.adventurer_master import MonsterMaster

# Fix database URL for local development
DATABASE_URL = "postgresql+psycopg2://bukiya_user:bukiya_password@localhost:5432/bukiya_game"

def main():
    print('=== Monster Model Query Test ===')
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    db = SessionLocal()
    try:
        print('\n1. Direct count test...')
        total = db.query(func.count(MonsterMaster.id)).scalar()
        print(f'   Total monsters: {total}')
        
        print('\n2. Filter by active test...')
        active_total = db.query(func.count(MonsterMaster.id)).filter(MonsterMaster.is_active == True).scalar()
        print(f'   Active monsters: {active_total}')
        
        print('\n3. Simple query test...')
        monsters = db.query(MonsterMaster).limit(3).all()
        for monster in monsters:
            print(f'   ID: {monster.id}, Name: {monster.name}, Type: {monster.monster_type}')
        
        print('\n4. Filtered query test...')
        active_monsters = db.query(MonsterMaster).filter(MonsterMaster.is_active == True).limit(3).all()
        for monster in active_monsters:
            print(f'   ID: {monster.id}, Name: {monster.name}, Active: {monster.is_active}')
        
        print('\n✅ All tests passed!')
        
    except Exception as e:
        print(f'❌ Error: {e}')
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == '__main__':
    main()