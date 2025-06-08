"""
Dragon Event Background Service

This service handles:
- Automatic dragon event creation and scheduling
- Real-time battle simulation
- Event lifecycle management
- Reward distribution
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, and_, func
from sqlalchemy.orm import selectinload

from app.core.database import AsyncSessionLocal
from app.models.dragon_event import (
    DragonEvent, DragonParticipant, DragonBattleLog, 
    DragonEventStatus, DragonEventSchedule
)
from app.models.player_weapon import PlayerWeapon
from app.core.dragon_battle_engine import DragonBattleEngine

logger = logging.getLogger(__name__)


class DragonEventService:
    """
    Background service for managing dragon events
    """
    
    def __init__(self):
        self.battle_engine = DragonBattleEngine()
        self.is_running = False
        self.update_interval = 30  # Battle updates every 30 seconds
    
    async def start_service(self):
        """Start the background service"""
        self.is_running = True
        logger.info("Dragon Event Service started")
        
        # Run event management tasks
        await asyncio.gather(
            self.event_scheduler_loop(),
            self.battle_simulation_loop(),
            self.event_cleanup_loop()
        )
    
    async def stop_service(self):
        """Stop the background service"""
        self.is_running = False
        logger.info("Dragon Event Service stopped")
    
    async def event_scheduler_loop(self):
        """Check for and create scheduled events"""
        while self.is_running:
            try:
                await self.check_and_create_scheduled_events()
                await asyncio.sleep(300)  # Check every 5 minutes
            except Exception as e:
                logger.error(f"Error in event scheduler: {e}")
                await asyncio.sleep(60)  # Wait 1 minute on error
    
    async def battle_simulation_loop(self):
        """Run battle simulation for active events"""
        while self.is_running:
            try:
                await self.simulate_active_battles()
                await asyncio.sleep(self.update_interval)
            except Exception as e:
                logger.error(f"Error in battle simulation: {e}")
                await asyncio.sleep(30)  # Wait 30 seconds on error
    
    async def event_cleanup_loop(self):
        """Clean up completed events and handle timeouts"""
        while self.is_running:
            try:
                await self.cleanup_completed_events()
                await asyncio.sleep(60)  # Check every minute
            except Exception as e:
                logger.error(f"Error in event cleanup: {e}")
                await asyncio.sleep(60)
    
    async def check_and_create_scheduled_events(self):
        """Check schedules and create new events"""
        async with AsyncSessionLocal() as db:
            # Get active schedules
            schedules_query = select(DragonEventSchedule).where(
                DragonEventSchedule.is_active == True
            )
            result = await db.execute(schedules_query)
            schedules = result.scalars().all()
            
            now = datetime.utcnow()
            
            for schedule in schedules:
                # Check if it's time to create a new event
                if self.should_trigger_schedule(schedule, now):
                    await self.create_scheduled_event(db, schedule, now)
    
    def should_trigger_schedule(self, schedule: DragonEventSchedule, now: datetime) -> bool:
        """Check if a schedule should trigger"""
        if schedule.next_trigger and now >= schedule.next_trigger:
            return True
        
        # If no next_trigger set, check if it's the right day/time
        if (now.weekday() == schedule.day_of_week and 
            now.hour == schedule.hour and 
            now.minute >= schedule.minute):
            
            # Make sure we haven't already triggered today
            if (not schedule.last_triggered or 
                schedule.last_triggered.date() < now.date()):
                return True
        
        return False
    
    async def create_scheduled_event(
        self, 
        db: AsyncSession, 
        schedule: DragonEventSchedule, 
        now: datetime
    ):
        """Create a new dragon event from schedule"""
        
        # Calculate event times
        start_time = now.replace(second=0, microsecond=0)
        end_time = start_time + timedelta(minutes=schedule.battle_duration_minutes)
        
        # Create event
        event = DragonEvent(
            name=f"{schedule.name} - {start_time.strftime('%B %d')}",
            description=f"Weekly dragon raid event: {schedule.name}",
            dragon_max_hp=schedule.dragon_base_hp,
            dragon_current_hp=schedule.dragon_base_hp,
            dragon_level=schedule.dragon_level,
            start_time=start_time,
            end_time=end_time,
            status=DragonEventStatus.ACTIVE,
            battle_duration_minutes=schedule.battle_duration_minutes,
            participation_reward_gold=schedule.participation_reward,
            victory_bonus_gold=schedule.victory_bonus,
            mvp_bonus_gold=schedule.mvp_bonus
        )
        
        db.add(event)
        
        # Update schedule
        schedule.last_triggered = now
        schedule.next_trigger = self.calculate_next_trigger(schedule, now)
        
        await db.commit()
        
        logger.info(f"Created scheduled dragon event: {event.name}")
    
    def calculate_next_trigger(
        self, 
        schedule: DragonEventSchedule, 
        current_time: datetime
    ) -> datetime:
        """Calculate next trigger time for a schedule"""
        # Calculate next week's trigger time
        days_ahead = schedule.day_of_week - current_time.weekday()
        if days_ahead <= 0:  # Target day already happened this week
            days_ahead += 7
        
        next_trigger = current_time + timedelta(days=days_ahead)
        next_trigger = next_trigger.replace(
            hour=schedule.hour, 
            minute=schedule.minute, 
            second=0, 
            microsecond=0
        )
        
        return next_trigger
    
    async def simulate_active_battles(self):
        """Simulate battles for all active events"""
        async with AsyncSessionLocal() as db:
            # Get active events
            events_query = select(DragonEvent).where(
                DragonEvent.status == DragonEventStatus.ACTIVE
            ).options(
                selectinload(DragonEvent.participants).selectinload(DragonParticipant.adventurer),
                selectinload(DragonEvent.participants).selectinload(DragonParticipant.player)
            )
            
            result = await db.execute(events_query)
            active_events = result.scalars().all()
            
            for event in active_events:
                await self.simulate_event_battle(db, event)
    
    async def simulate_event_battle(self, db: AsyncSession, event: DragonEvent):
        """Simulate battle for a single event"""
        if event.dragon_current_hp <= 0:
            return  # Dragon already defeated
        
        now = datetime.utcnow()
        if now > event.end_time:
            # Event timed out
            await self.complete_event(db, event)
            return
        
        # Calculate current battle second
        elapsed = (now - event.start_time).total_seconds()
        battle_second = int(elapsed)
        
        # Get participants with adventurers
        participants = [p for p in event.participants if p.adventurer]
        
        if not participants:
            return  # No participants
        
        # Simulate battle round
        battle_actions = self.battle_engine.simulate_battle_round(
            participants, event, battle_second
        )
        
        total_damage = 0
        battle_logs = []
        
        # Process battle actions
        for action in battle_actions:
            if action.damage > 0:
                total_damage += action.damage
                
                # Update participant damage
                for participant in participants:
                    if participant.id == action.participant_id:
                        participant.total_damage_dealt += action.damage
                        break
            
            # Create battle log
            if action.participant_id > 0:  # Player action
                participant_id = action.participant_id
            else:  # Dragon action
                participant_id = None
            
            battle_log = DragonBattleLog(
                event_id=event.id,
                participant_id=participant_id,
                action_type=action.action_type,
                damage_dealt=action.damage,
                message=action.message,
                dragon_hp_after=max(0, event.dragon_current_hp - total_damage),
                battle_second=battle_second,
                timestamp=action.timestamp
            )
            
            battle_logs.append(battle_log)
        
        # Update dragon HP
        event.dragon_current_hp = max(0, event.dragon_current_hp - total_damage)
        
        # Add battle logs to database
        for log in battle_logs:
            db.add(log)
        
        # Check if dragon is defeated
        if event.dragon_current_hp <= 0:
            await self.complete_event(db, event, victory=True)
        
        await db.commit()
    
    async def complete_event(self, db: AsyncSession, event: DragonEvent, victory: bool = False):
        """Complete a dragon event"""
        event.status = DragonEventStatus.COMPLETED
        
        # Add completion message
        if victory:
            message = self.battle_engine.generate_victory_message(True, len(event.participants))
        else:
            message = self.battle_engine.generate_victory_message(False, len(event.participants))
        
        completion_log = DragonBattleLog(
            event_id=event.id,
            participant_id=None,
            action_type="event_complete",
            damage_dealt=0,
            message=message,
            dragon_hp_after=event.dragon_current_hp,
            battle_second=int((datetime.utcnow() - event.start_time).total_seconds()),
            timestamp=datetime.utcnow()
        )
        
        db.add(completion_log)
        
        logger.info(f"Dragon event {event.id} completed. Victory: {victory}")
    
    async def cleanup_completed_events(self):
        """Clean up old completed events"""
        async with AsyncSessionLocal() as db:
            # Check for events that should be completed due to timeout
            timeout_query = select(DragonEvent).where(
                and_(
                    DragonEvent.status == DragonEventStatus.ACTIVE,
                    DragonEvent.end_time < datetime.utcnow()
                )
            )
            
            result = await db.execute(timeout_query)
            timeout_events = result.scalars().all()
            
            for event in timeout_events:
                await self.complete_event(db, event, victory=False)
            
            if timeout_events:
                await db.commit()
    
    async def create_test_event(self) -> int:
        """Create a test dragon event for immediate testing"""
        async with AsyncSessionLocal() as db:
            now = datetime.utcnow()
            
            event = DragonEvent(
                name="Test Dragon Raid",
                description="A test dragon event for immediate participation",
                dragon_max_hp=5000,  # Smaller HP for testing
                dragon_current_hp=5000,
                dragon_level=1,
                start_time=now,
                end_time=now + timedelta(minutes=15),  # 15 minute test event
                status=DragonEventStatus.ACTIVE,
                battle_duration_minutes=15,
                participation_reward_gold=500,
                victory_bonus_gold=2000,
                mvp_bonus_gold=5000
            )
            
            db.add(event)
            await db.commit()
            await db.refresh(event)
            
            logger.info(f"Created test dragon event with ID: {event.id}")
            return event.id
    
    async def setup_weekly_schedule(self):
        """Set up the default weekly dragon event schedule"""
        async with AsyncSessionLocal() as db:
            # Check if schedule already exists
            existing_query = select(DragonEventSchedule).where(
                DragonEventSchedule.name == "Weekly Dragon Raid"
            )
            result = await db.execute(existing_query)
            existing = result.scalar_one_or_none()
            
            if existing:
                logger.info("Weekly schedule already exists")
                return
            
            # Create weekly schedule (Sunday evening)
            schedule = DragonEventSchedule(
                name="Weekly Dragon Raid",
                day_of_week=6,  # Sunday
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
            schedule.next_trigger = self.calculate_next_trigger(schedule, now)
            
            db.add(schedule)
            await db.commit()
            
            logger.info("Created weekly dragon event schedule")


# Global service instance
dragon_service = DragonEventService()