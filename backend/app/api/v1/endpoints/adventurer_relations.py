"""
Adventurer Relationship Management API

This module provides endpoints for managing permanent adventurer relationships,
trust levels, and visit tracking in the new adventurer system.
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import and_, desc, func
from typing import List, Optional
from datetime import datetime, timedelta

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models.player import Player
from app.models.adventurer_character import (
    AdventurerCharacter, PlayerAdventurerRelation, AdventurerVisit,
    AdventurerTransaction, TrustLevel
)
from app.models.adventurer_master import AdventurerMaster
from app.schemas.adventurer_character import (
    AdventurerCharacterResponse, PlayerAdventurerRelationResponse,
    AdventurerVisitResponse, TrustLevelBenefits, AdventurerRelationSummary,
    CreateVisitRequest, CompleteTransactionRequest, AdventurerTransactionResponse
)
from app.core.trust_system import TrustCalculator, TrustEventProcessor, TrustEvent

router = APIRouter()


@router.get("/characters", response_model=List[AdventurerCharacterResponse])
def get_available_adventurers(
    player_level: Optional[int] = None,
    profession: Optional[str] = None,
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Get list of available adventurer characters"""
    query = db.query(AdventurerCharacter).filter(AdventurerCharacter.is_active == True)
    
    # Filter by player level requirements
    if player_level:
        query = query.filter(AdventurerCharacter.min_player_level <= player_level)
    else:
        query = query.filter(AdventurerCharacter.min_player_level <= current_player.level)
    
    # Filter by profession
    if profession:
        query = query.filter(AdventurerCharacter.profession == profession)
    
    adventurers = query.limit(limit).all()
    return adventurers


@router.get("/relations", response_model=List[AdventurerRelationSummary])
def get_player_adventurer_relations(
    trust_level_min: Optional[int] = None,
    include_inactive: bool = False,
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Get player's adventurer relationships"""
    query = db.query(PlayerAdventurerRelation).filter(
        PlayerAdventurerRelation.player_id == current_player.id
    ).options(
        selectinload(PlayerAdventurerRelation.adventurer)
    )
    
    # Filter by trust level
    if trust_level_min is not None:
        query = query.filter(PlayerAdventurerRelation.trust_level >= trust_level_min)
    
    # Order by trust level descending, then by last interaction
    query = query.order_by(
        desc(PlayerAdventurerRelation.trust_level),
        desc(PlayerAdventurerRelation.last_interaction_at)
    )
    
    relations = query.limit(limit).all()
    
    # Build summary responses
    summaries = []
    for relation in relations:
        benefits = TrustCalculator.get_trust_tier_benefits(relation.trust_level)
        
        summary = AdventurerRelationSummary(
            relation_id=relation.id,
            adventurer_id=relation.adventurer_id,
            adventurer_name=relation.adventurer.name,
            adventurer_profession=relation.adventurer.profession,
            trust_level=relation.trust_level,
            trust_tier=relation.trust_tier.name,
            price_discount=benefits["price_discount"],
            can_dragon_raids=benefits["dragon_raids"],
            total_interactions=relation.total_interactions,
            successful_trades=relation.successful_trades,
            last_interaction_at=relation.last_interaction_at,
            next_expected_visit=relation.next_expected_visit
        )
        summaries.append(summary)
    
    return summaries


@router.get("/relations/{relation_id}", response_model=PlayerAdventurerRelationResponse)
def get_adventurer_relation_details(
    relation_id: int,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Get detailed information about a specific adventurer relationship"""
    relation = db.query(PlayerAdventurerRelation).filter(
        and_(
            PlayerAdventurerRelation.id == relation_id,
            PlayerAdventurerRelation.player_id == current_player.id
        )
    ).options(
        selectinload(PlayerAdventurerRelation.adventurer),
        selectinload(PlayerAdventurerRelation.visits)
    ).first()
    
    if not relation:
        raise HTTPException(status_code=404, detail="Adventurer relationship not found")
    
    return relation


@router.get("/visits/active", response_model=List[AdventurerVisitResponse])
def get_active_visits(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Get currently active adventurer visits"""
    visits = db.query(AdventurerVisit).filter(
        and_(
            AdventurerVisit.player_id == current_player.id,
            AdventurerVisit.visit_end_time.is_(None),
            AdventurerVisit.current_status.in_(["browsing", "negotiating"])
        )
    ).options(
        selectinload(AdventurerVisit.adventurer),
        selectinload(AdventurerVisit.relation)
    ).all()
    
    return visits


@router.post("/visits", response_model=AdventurerVisitResponse)
def create_adventurer_visit(
    visit_request: CreateVisitRequest,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Create a new adventurer visit"""
    
    # Get or create the adventurer relationship
    relation = db.query(PlayerAdventurerRelation).filter(
        and_(
            PlayerAdventurerRelation.player_id == current_player.id,
            PlayerAdventurerRelation.adventurer_id == visit_request.adventurer_id
        )
    ).first()
    
    if not relation:
        # Create new relationship for first-time visitor
        adventurer = db.query(AdventurerCharacter).filter(
            AdventurerCharacter.id == visit_request.adventurer_id
        ).first()
        
        if not adventurer:
            raise HTTPException(status_code=404, detail="Adventurer not found")
        
        relation = PlayerAdventurerRelation(
            player_id=current_player.id,
            adventurer_id=visit_request.adventurer_id
        )
        db.add(relation)
        db.flush()  # Get the ID
    
    # Calculate visit duration with trust bonuses
    base_duration = visit_request.planned_duration_minutes or relation.adventurer.stay_duration_minutes
    actual_duration = TrustCalculator.calculate_visit_duration(base_duration, relation)
    
    # Calculate budget with trust bonuses
    budget = relation.adventurer.get_current_budget(relation.trust_level)
    
    # Create the visit
    visit = AdventurerVisit(
        player_id=current_player.id,
        adventurer_id=visit_request.adventurer_id,
        relation_id=relation.id,
        planned_duration_minutes=actual_duration,
        visit_purpose=visit_request.visit_purpose or "trade",
        budget_for_visit=budget,
        urgency_level=visit_request.urgency_level or 3
    )
    
    # Set weapon request if provided
    if visit_request.weapon_request:
        visit.weapon_request = visit_request.weapon_request
    
    db.add(visit)
    db.commit()
    db.refresh(visit)
    
    return visit


@router.put("/visits/{visit_id}/complete")
def complete_visit(
    visit_id: int,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Mark a visit as complete and process trust changes"""
    
    visit = db.query(AdventurerVisit).filter(
        and_(
            AdventurerVisit.id == visit_id,
            AdventurerVisit.player_id == current_player.id
        )
    ).options(
        selectinload(AdventurerVisit.relation)
    ).first()
    
    if not visit:
        raise HTTPException(status_code=404, detail="Visit not found")
    
    if not visit.is_active:
        raise HTTPException(status_code=400, detail="Visit is already completed")
    
    # Complete the visit
    visit.complete_visit()
    
    # Process trust changes for visit completion
    trust_change, events = TrustEventProcessor.process_visit_completion(
        visit, visit.relation
    )
    
    # Update visit with trust changes
    visit.trust_gained = max(0, trust_change)
    visit.trust_lost = max(0, -trust_change)
    
    db.commit()
    
    return {
        "message": "Visit completed successfully",
        "trust_change": trust_change,
        "events_processed": events,
        "new_trust_level": visit.relation.trust_level
    }


@router.post("/transactions", response_model=AdventurerTransactionResponse)
def create_transaction(
    transaction_request: CompleteTransactionRequest,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Record a transaction and process trust changes"""
    
    # Verify the visit exists and belongs to the player
    visit = db.query(AdventurerVisit).filter(
        and_(
            AdventurerVisit.id == transaction_request.visit_id,
            AdventurerVisit.player_id == current_player.id
        )
    ).options(
        selectinload(AdventurerVisit.relation)
    ).first()
    
    if not visit:
        raise HTTPException(status_code=404, detail="Visit not found")
    
    # Create the transaction record
    transaction = AdventurerTransaction(
        visit_id=visit.id,
        player_id=current_player.id,
        adventurer_id=visit.adventurer_id,
        transaction_type=transaction_request.transaction_type,
        item_type=transaction_request.item_type,
        item_id=transaction_request.item_id,
        item_name=transaction_request.item_name,
        base_price=transaction_request.base_price,
        negotiated_price=transaction_request.negotiated_price,
        was_requested_item=transaction_request.was_requested_item,
        negotiation_rounds=transaction_request.negotiation_rounds
    )
    
    # Calculate price modifier and trust discount
    transaction.price_modifier = transaction.negotiated_price / max(1, transaction.base_price)
    transaction.trust_discount = TrustCalculator.calculate_price_modifier(visit.relation)
    
    db.add(transaction)
    db.flush()  # Get the ID
    
    # Process trust changes
    trust_change, events = TrustEventProcessor.process_transaction_completion(
        transaction, visit.relation
    )
    
    # Update transaction with trust change
    transaction.trust_change = trust_change
    transaction.satisfaction_level = min(5, max(1, 3 + (trust_change // 2)))  # 1-5 based on trust change
    
    # Update visit totals
    if transaction.transaction_type == "purchase":
        visit.total_gold_spent += transaction.negotiated_price
        if visit.items_purchased:
            visit.items_purchased.append({
                "item_id": transaction.item_id,
                "item_name": transaction.item_name,
                "price": transaction.negotiated_price
            })
        else:
            visit.items_purchased = [{
                "item_id": transaction.item_id,
                "item_name": transaction.item_name,
                "price": transaction.negotiated_price
            }]
    
    db.commit()
    db.refresh(transaction)
    
    return transaction


@router.get("/trust-benefits/{trust_level}", response_model=TrustLevelBenefits)
def get_trust_level_benefits(trust_level: int):
    """Get benefits for a specific trust level"""
    if not 0 <= trust_level <= 100:
        raise HTTPException(status_code=400, detail="Trust level must be between 0 and 100")
    
    benefits = TrustCalculator.get_trust_tier_benefits(trust_level)
    
    # Determine tier name
    if trust_level >= 80:
        tier_name = "Partner"
    elif trust_level >= 60:
        tier_name = "Trusted"
    elif trust_level >= 40:
        tier_name = "Friend"
    elif trust_level >= 20:
        tier_name = "Acquaintance"
    else:
        tier_name = "Stranger"
    
    return TrustLevelBenefits(
        trust_level=trust_level,
        tier_name=tier_name,
        price_discount_percent=benefits["price_discount"] * 100,
        visit_duration_bonus_percent=benefits["visit_duration_bonus"] * 100,
        can_make_special_requests=benefits["special_requests"],
        can_access_exclusive_items=benefits["exclusive_items"],
        can_participate_dragon_raids=benefits["dragon_raids"],
        negotiation_attempts=benefits["negotiation_attempts"],
        description=benefits["description"]
    )


@router.get("/stats/summary")
def get_adventurer_relationship_stats(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """Get summary statistics for player's adventurer relationships"""
    
    # Get basic counts
    total_relations = db.query(func.count(PlayerAdventurerRelation.id)).filter(
        PlayerAdventurerRelation.player_id == current_player.id
    ).scalar() or 0
    
    # Get trust level distribution
    trust_stats = db.query(
        func.count().label("count"),
        func.avg(PlayerAdventurerRelation.trust_level).label("avg_trust")
    ).filter(
        PlayerAdventurerRelation.player_id == current_player.id
    ).first()
    
    # Count by trust tiers
    partner_count = db.query(func.count(PlayerAdventurerRelation.id)).filter(
        and_(
            PlayerAdventurerRelation.player_id == current_player.id,
            PlayerAdventurerRelation.trust_level >= 80
        )
    ).scalar() or 0
    
    trusted_count = db.query(func.count(PlayerAdventurerRelation.id)).filter(
        and_(
            PlayerAdventurerRelation.player_id == current_player.id,
            PlayerAdventurerRelation.trust_level >= 60,
            PlayerAdventurerRelation.trust_level < 80
        )
    ).scalar() or 0
    
    # Get trading stats
    trade_stats = db.query(
        func.sum(PlayerAdventurerRelation.total_gold_traded).label("total_gold"),
        func.sum(PlayerAdventurerRelation.total_items_sold).label("total_items"),
        func.sum(PlayerAdventurerRelation.successful_trades).label("successful_trades")
    ).filter(
        PlayerAdventurerRelation.player_id == current_player.id
    ).first()
    
    return {
        "total_relationships": total_relations,
        "average_trust_level": round(trust_stats.avg_trust or 0, 1),
        "partner_tier_count": partner_count,
        "trusted_tier_count": trusted_count,
        "dragon_raid_eligible": partner_count,
        "total_gold_traded": trade_stats.total_gold or 0,
        "total_items_sold": trade_stats.total_items or 0,
        "total_successful_trades": trade_stats.successful_trades or 0
    }