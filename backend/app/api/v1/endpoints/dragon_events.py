"""
Dragon Event API Endpoints

Handles all dragon raid event operations including:
- Event listing and details
- Player participation
- Real-time battle updates
- Reward distribution
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import and_, desc, func
from typing import List, Optional
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.dependencies import get_current_player as get_current_user
from app.models.player import Player
from app.models.dragon_event import (
    DragonEvent, DragonParticipant, DragonBattleLog, DragonEventStatus
)
from app.models.adventurer_instance import AdventurerInstance
from app.schemas.dragon_event import (
    DragonEvent as DragonEventSchema,
    DragonEventSummary,
    DragonBattleState,
    DragonParticipationRequest,
    DragonRewardsResponse,
    DragonEventStatsResponse,
    DragonBattleLog as DragonBattleLogSchema
)
from app.core.dragon_battle_engine import DragonBattleEngine

router = APIRouter()
battle_engine = DragonBattleEngine()


@router.get("/events", response_model=List[DragonEventSummary])
def get_dragon_events(
    status: Optional[str] = None,
    limit: int = 10,
    db: Session = Depends(get_db)
):
    """Get list of dragon events"""
    query = db.query(DragonEvent)
    
    if status:
        query = query.filter(DragonEvent.status == status)
    
    events = query.order_by(desc(DragonEvent.start_time)).limit(limit).all()
    
    # Get participant counts for each event
    event_summaries = []
    for event in events:
        participant_count = db.query(func.count(DragonParticipant.id)).filter(
            DragonParticipant.event_id == event.id
        ).scalar() or 0
        
        summary = DragonEventSummary(
            id=event.id,
            name=event.name,
            dragon_max_hp=event.dragon_max_hp,
            dragon_current_hp=event.dragon_current_hp,
            status=event.status,
            start_time=event.start_time,
            end_time=event.end_time,
            participant_count=participant_count,
            is_victory=(event.dragon_current_hp <= 0)
        )
        event_summaries.append(summary)
    
    return event_summaries


@router.get("/events/current", response_model=Optional[DragonEventSchema])
def get_current_dragon_event(db: Session = Depends(get_db)):
    """Get currently active dragon event"""
    event = db.query(DragonEvent).filter(
        DragonEvent.status == DragonEventStatus.ACTIVE
    ).options(
        selectinload(DragonEvent.participants)
    ).first()
    
    return event


@router.get("/events/{event_id}", response_model=DragonEventSchema)
def get_dragon_event(
    event_id: int,
    db: Session = Depends(get_db)
):
    """Get specific dragon event details"""
    event = db.query(DragonEvent).filter(DragonEvent.id == event_id).options(
        selectinload(DragonEvent.participants)
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Dragon event not found")
    
    return event


@router.post("/events/{event_id}/join")
def join_dragon_event(
    event_id: int,
    participation_request: DragonParticipationRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Join a dragon event with an adventurer"""
    
    # Check if event exists and is active
    event = db.query(DragonEvent).filter(DragonEvent.id == event_id).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Dragon event not found")
    
    if event.status != DragonEventStatus.ACTIVE:
        raise HTTPException(status_code=400, detail="Event is not active")
    
    # Check if event has ended
    if datetime.utcnow() > event.end_time:
        raise HTTPException(status_code=400, detail="Event has ended")
    
    # Verify adventurer belongs to player
    adventurer = db.query(AdventurerInstance).filter(
        and_(
            AdventurerInstance.id == participation_request.adventurer_instance_id,
            AdventurerInstance.player_id == current_user.id
        )
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="Adventurer not found or not owned by player")
    
    # Check if already participating
    existing = db.query(DragonParticipant).filter(
        and_(
            DragonParticipant.event_id == event_id,
            DragonParticipant.player_id == current_user.id
        )
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Already participating in this event")
    
    # Create participation record
    participant = DragonParticipant(
        event_id=event_id,
        player_id=current_user.id,
        adventurer_instance_id=adventurer.id,
        participation_reward=event.participation_reward_gold
    )
    
    db.add(participant)
    db.commit()
    db.refresh(participant)
    
    return {"message": "Successfully joined dragon event", "participant_id": participant.id}


@router.get("/events/{event_id}/battle-state", response_model=DragonBattleState)
def get_battle_state(
    event_id: int,
    db: Session = Depends(get_db)
):
    """Get real-time battle state"""
    
    # Get event
    event = db.query(DragonEvent).filter(DragonEvent.id == event_id).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Dragon event not found")
    
    # Get participant count
    participant_count = db.query(func.count(DragonParticipant.id)).filter(
        DragonParticipant.event_id == event_id
    ).scalar() or 0
    
    # Calculate time remaining
    now = datetime.utcnow()
    time_remaining = max(0, int((event.end_time - now).total_seconds()))
    
    # Get recent battle logs (last 10)
    recent_logs = db.query(DragonBattleLog).filter(
        DragonBattleLog.event_id == event_id
    ).order_by(desc(DragonBattleLog.timestamp)).limit(10).all()
    
    # Calculate total damage dealt
    total_damage = event.dragon_max_hp - event.dragon_current_hp
    
    battle_state = DragonBattleState(
        event_id=event.id,
        dragon_current_hp=event.dragon_current_hp,
        dragon_max_hp=event.dragon_max_hp,
        hp_percentage=(event.dragon_current_hp / event.dragon_max_hp) * 100,
        time_remaining_seconds=time_remaining,
        participant_count=participant_count,
        total_damage_dealt=total_damage,
        is_active=(event.status == DragonEventStatus.ACTIVE and time_remaining > 0),
        recent_logs=[DragonBattleLogSchema.model_validate(log) for log in recent_logs]
    )
    
    return battle_state


@router.get("/events/{event_id}/logs", response_model=List[DragonBattleLogSchema])
def get_battle_logs(
    event_id: int,
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get battle logs for an event"""
    
    logs = db.query(DragonBattleLog).filter(
        DragonBattleLog.event_id == event_id
    ).order_by(desc(DragonBattleLog.timestamp)).offset(offset).limit(limit).all()
    
    return [DragonBattleLogSchema.model_validate(log) for log in logs]


@router.post("/events/{event_id}/claim-rewards", response_model=DragonRewardsResponse)
def claim_event_rewards(
    event_id: int,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Claim rewards from a completed dragon event"""
    
    # Get participant record
    participant = db.query(DragonParticipant).filter(
        and_(
            DragonParticipant.event_id == event_id,
            DragonParticipant.player_id == current_user.id
        )
    ).options(selectinload(DragonParticipant.event)).first()
    
    if not participant:
        raise HTTPException(status_code=404, detail="Not participating in this event")
    
    if participant.rewards_claimed:
        raise HTTPException(status_code=400, detail="Rewards already claimed")
    
    event = participant.event
    if event.status not in [DragonEventStatus.COMPLETED]:
        raise HTTPException(status_code=400, detail="Event not completed yet")
    
    # Calculate rewards
    total_reward = participant.participation_reward
    victory_bonus = 0
    mvp_bonus = 0
    is_mvp = False
    rank = 0
    
    # Check if event was won
    if event.dragon_current_hp <= 0:
        victory_bonus = event.victory_bonus_gold
        total_reward += victory_bonus
        
        # Check if player is MVP (highest damage)
        mvp_participant = db.query(DragonParticipant).filter(
            DragonParticipant.event_id == event_id
        ).order_by(desc(DragonParticipant.total_damage_dealt)).first()
        
        if mvp_participant and mvp_participant.id == participant.id:
            is_mvp = True
            mvp_bonus = event.mvp_bonus_gold
            total_reward += mvp_bonus
    
    # Get participant rank
    rank = db.query(func.count(DragonParticipant.id)).filter(
        and_(
            DragonParticipant.event_id == event_id,
            DragonParticipant.total_damage_dealt > participant.total_damage_dealt
        )
    ).scalar() or 0
    rank += 1
    
    # Update participant rewards
    participant.victory_bonus = victory_bonus
    participant.mvp_bonus = mvp_bonus
    participant.rewards_claimed = True
    
    # Give gold to player
    current_user.gold += total_reward
    
    db.commit()
    
    return DragonRewardsResponse(
        participation_reward=participant.participation_reward,
        victory_bonus=victory_bonus,
        mvp_bonus=mvp_bonus,
        total_reward=total_reward,
        is_mvp=is_mvp,
        rank=rank,
        total_damage=participant.total_damage_dealt
    )


@router.get("/events/{event_id}/stats", response_model=DragonEventStatsResponse)
def get_event_stats(
    event_id: int,
    db: Session = Depends(get_db)
):
    """Get event statistics and leaderboard"""
    
    # Get event
    event = db.query(DragonEvent).filter(DragonEvent.id == event_id).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Dragon event not found")
    
    # Get participant statistics
    participants = db.query(DragonParticipant).filter(
        DragonParticipant.event_id == event_id
    ).options(
        selectinload(DragonParticipant.player)
    ).order_by(desc(DragonParticipant.total_damage_dealt)).all()
    
    # Build leaderboard
    top_participants = []
    mvp_player_name = None
    total_damage_dealt = 0
    
    for i, participant in enumerate(participants[:10]):  # Top 10
        player_name = participant.player.name if participant.player else "Unknown"
        
        top_participants.append({
            "player_name": player_name,
            "damage": participant.total_damage_dealt,
            "rank": i + 1
        })
        
        total_damage_dealt += participant.total_damage_dealt
        
        if i == 0 and participant.total_damage_dealt > 0:
            mvp_player_name = player_name
    
    return DragonEventStatsResponse(
        event=DragonEventSchema.model_validate(event),
        total_participants=len(participants),
        total_damage_dealt=total_damage_dealt,
        top_participants=top_participants,
        is_victory=(event.dragon_current_hp <= 0),
        mvp_player_name=mvp_player_name
    )