#!/usr/bin/env python3
"""
Create Dragon Event Tables

This script creates the necessary database tables for the dragon event system.
Run this after the main database is set up.
"""

import sys
import os

# Add the backend directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import engine, SessionLocal
from app.models.dragon_event import DragonEvent, DragonParticipant, DragonBattleLog, DragonEventSchedule
from app.core.database import Base


def create_dragon_tables():
    """Create dragon event tables"""
    print("Creating dragon event tables...")
    
    try:
        # Create all tables
        Base.metadata.create_all(bind=engine)
        
        print("✅ Dragon event tables created successfully!")
        
        # Create initial weekly schedule
        create_initial_schedule()
        
    except Exception as e:
        print(f"❌ Error creating dragon event tables: {e}")
        raise


def create_initial_schedule():
    """Create the initial weekly dragon event schedule"""
    print("Creating initial dragon event schedule...")
    
    try:
        db = SessionLocal()
        try:
            from datetime import datetime, timedelta
            from app.models.dragon_event import DragonEventSchedule
            
            # Check if schedule already exists
            existing = db.query(DragonEventSchedule).filter(
                DragonEventSchedule.name == "Weekly Dragon Raid"
            ).first()
            
            if existing:
                print("Weekly schedule already exists")
                return
            
            # Create weekly schedule (Sunday evening)
            schedule = DragonEventSchedule(
                name="Weekly Dragon Raid",
                day_of_week=6,  # Sunday (0=Monday, 6=Sunday)
                hour=19,  # 7 PM
                minute=0,
                dragon_base_hp=10000,
                dragon_level=1,
                battle_duration_minutes=30,
                participation_reward=1000,
                victory_bonus=5000,
                mvp_bonus=10000,
                is_active=True
            )
            
            # Calculate next trigger
            now = datetime.utcnow()
            days_ahead = schedule.day_of_week - now.weekday()
            if days_ahead <= 0:  # Target day already happened this week
                days_ahead += 7
            
            next_trigger = now + timedelta(days=days_ahead)
            next_trigger = next_trigger.replace(
                hour=schedule.hour, 
                minute=schedule.minute, 
                second=0, 
                microsecond=0
            )
            
            schedule.next_trigger = next_trigger
            
            db.add(schedule)
            db.commit()
            
            print(f"✅ Weekly dragon event schedule created! Next event: {next_trigger}")
            
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Error creating schedule: {e}")
        raise


def create_test_event():
    """Create a test dragon event for immediate testing"""
    print("Creating test dragon event...")
    
    try:
        db = SessionLocal()
        try:
            from datetime import datetime, timedelta
            from app.models.dragon_event import DragonEvent, DragonEventStatus
            
            now = datetime.utcnow()
            
            test_event = DragonEvent(
                name="Test Dragon Raid",
                description="A test dragon event for immediate participation and testing",
                dragon_max_hp=3000,  # Smaller HP for testing
                dragon_current_hp=3000,
                dragon_level=1,
                start_time=now,
                end_time=now + timedelta(minutes=10),  # 10 minute test event
                status=DragonEventStatus.ACTIVE,
                battle_duration_minutes=10,
                participation_reward_gold=500,
                victory_bonus_gold=2000,
                mvp_bonus_gold=5000
            )
            
            db.add(test_event)
            db.commit()
            db.refresh(test_event)
            
            print(f"✅ Test dragon event created with ID: {test_event.id}")
            print(f"   Event runs until: {test_event.end_time}")
            print(f"   Players can now join at: /api/v1/dragon-events/events/{test_event.id}/join")
            
            return test_event.id
            
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Error creating test event: {e}")
        raise


def main():
    """Main function"""
    print("🐉 Dragon Event System Setup")
    print("=" * 40)
    
    try:
        # Create tables
        create_dragon_tables()
        
        # Ask if user wants to create a test event
        create_test = input("\nCreate a test dragon event for immediate testing? (y/n): ").lower().strip()
        if create_test in ['y', 'yes']:
            create_test_event()
        
        print("\n🎉 Dragon event system setup complete!")
        print("\nNext steps:")
        print("1. Start the backend server")
        print("2. Check /api/v1/dragon-events/events for active events")
        print("3. Players can join events using their adventurers")
        print("4. Watch the real-time battle simulation!")
        
    except Exception as e:
        print(f"\n💥 Setup failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()