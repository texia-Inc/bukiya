"""
Trust Level Progression System

This module handles trust level calculations, progression mechanics,
and the practical benefits that come with higher trust levels.
"""

import math
from typing import Dict, List, Tuple, Optional
from datetime import datetime, timedelta
from enum import Enum

from app.models.adventurer_character import (
    PlayerAdventurerRelation, 
    AdventurerTransaction, 
    AdventurerVisit,
    TrustLevel
)


class TrustEvent(Enum):
    """Different events that can affect trust"""
    # Positive Events
    SUCCESSFUL_TRADE = "successful_trade"
    QUICK_NEGOTIATION = "quick_negotiation" 
    FAIR_PRICE = "fair_price"
    REQUESTED_ITEM_SOLD = "requested_item_sold"
    PREMIUM_ITEM_SOLD = "premium_item_sold"
    REPEAT_CUSTOMER = "repeat_customer"
    DRAGON_RAID_INVITE = "dragon_raid_invite"
    
    # Negative Events
    OVERPRICED_ITEM = "overpriced_item"
    NEGOTIATION_FAILED = "negotiation_failed"
    POOR_QUALITY_ITEM = "poor_quality_item"
    BROKEN_PROMISE = "broken_promise"
    LONG_WAIT_TIME = "long_wait_time"
    
    # Neutral Events
    NORMAL_TRADE = "normal_trade"
    BROWSING_ONLY = "browsing_only"


class TrustCalculator:
    """
    Handles trust level calculations and progression mechanics
    """
    
    # Trust gain/loss values for different events
    TRUST_VALUES = {
        # Positive events (1-10 trust gain)
        TrustEvent.SUCCESSFUL_TRADE: 2,
        TrustEvent.QUICK_NEGOTIATION: 1,
        TrustEvent.FAIR_PRICE: 3,
        TrustEvent.REQUESTED_ITEM_SOLD: 5,
        TrustEvent.PREMIUM_ITEM_SOLD: 4,
        TrustEvent.REPEAT_CUSTOMER: 1,
        TrustEvent.DRAGON_RAID_INVITE: 10,
        
        # Negative events (-1 to -5 trust loss)
        TrustEvent.OVERPRICED_ITEM: -3,
        TrustEvent.NEGOTIATION_FAILED: -1,
        TrustEvent.POOR_QUALITY_ITEM: -4,
        TrustEvent.BROKEN_PROMISE: -5,
        TrustEvent.LONG_WAIT_TIME: -2,
        
        # Neutral events
        TrustEvent.NORMAL_TRADE: 1,
        TrustEvent.BROWSING_ONLY: 0,
    }
    
    # Trust tier thresholds and benefits
    TRUST_BENEFITS = {
        TrustLevel.STRANGER: {
            "price_discount": 0.0,
            "visit_duration_bonus": 0.0,
            "special_requests": False,
            "dragon_raids": False,
            "exclusive_items": False,
            "negotiation_attempts": 1,
            "description": "Basic trading only"
        },
        TrustLevel.ACQUAINTANCE: {
            "price_discount": 0.02,  # 2% discount
            "visit_duration_bonus": 0.1,  # 10% longer visits
            "special_requests": False,
            "dragon_raids": False,
            "exclusive_items": False,
            "negotiation_attempts": 2,
            "description": "Slight price improvements"
        },
        TrustLevel.FRIEND: {
            "price_discount": 0.05,  # 5% discount
            "visit_duration_bonus": 0.25,  # 25% longer visits
            "special_requests": True,
            "dragon_raids": False,
            "exclusive_items": False,
            "negotiation_attempts": 3,
            "description": "Better deals, special requests"
        },
        TrustLevel.TRUSTED: {
            "price_discount": 0.10,  # 10% discount
            "visit_duration_bonus": 0.5,  # 50% longer visits
            "special_requests": True,
            "dragon_raids": False,
            "exclusive_items": True,
            "negotiation_attempts": 4,
            "description": "Premium requests, exclusive items"
        },
        TrustLevel.PARTNER: {
            "price_discount": 0.20,  # 20% discount
            "visit_duration_bonus": 1.0,  # 100% longer visits
            "special_requests": True,
            "dragon_raids": True,
            "exclusive_items": True,
            "negotiation_attempts": 5,
            "description": "Dragon raids, maximum benefits"
        }
    }
    
    @classmethod
    def calculate_trust_change(
        cls,
        event: TrustEvent,
        relation: PlayerAdventurerRelation,
        context: Optional[Dict] = None
    ) -> int:
        """
        Calculate trust change for a specific event
        
        Args:
            event: The trust event that occurred
            relation: Current player-adventurer relationship
            context: Additional context for the calculation
            
        Returns:
            Trust points to add/subtract
        """
        base_change = cls.TRUST_VALUES.get(event, 0)
        
        if base_change == 0:
            return 0
        
        # Apply modifiers based on context
        multiplier = 1.0
        
        # Higher trust levels have diminishing returns for positive events
        if base_change > 0:
            trust_factor = 1.0 - (relation.trust_level / 200.0)  # Reduce gains as trust increases
            multiplier *= max(0.3, trust_factor)  # Minimum 30% of base gain
        
        # Negative events hurt more at higher trust levels
        elif base_change < 0:
            trust_factor = 1.0 + (relation.trust_level / 100.0)  # More painful at higher trust
            multiplier *= trust_factor
        
        # Apply context-specific modifiers
        if context:
            multiplier *= cls._get_context_modifier(event, context, relation)
        
        final_change = int(base_change * multiplier)
        return final_change
    
    @classmethod
    def _get_context_modifier(
        cls,
        event: TrustEvent,
        context: Dict,
        relation: PlayerAdventurerRelation
    ) -> float:
        """Get context-specific multipliers for trust changes"""
        modifier = 1.0
        
        # Price-related modifiers
        if "price_ratio" in context:
            price_ratio = context["price_ratio"]  # negotiated_price / fair_price
            
            if event in [TrustEvent.FAIR_PRICE, TrustEvent.SUCCESSFUL_TRADE]:
                if price_ratio <= 0.8:  # Great deal for adventurer
                    modifier *= 1.5
                elif price_ratio <= 0.9:  # Good deal
                    modifier *= 1.2
                elif price_ratio >= 1.3:  # Overpriced
                    modifier *= 0.5
                elif price_ratio >= 1.2:  # Expensive
                    modifier *= 0.8
        
        # Item quality modifiers
        if "item_quality" in context:
            quality = context["item_quality"]  # enchantment level, rarity, etc.
            if quality > 3:  # High quality item
                modifier *= 1.3
            elif quality < 2:  # Low quality item
                modifier *= 0.7
        
        # Timing modifiers
        if "wait_time_minutes" in context:
            wait_time = context["wait_time_minutes"]
            if wait_time > 5:  # Long wait
                if event == TrustEvent.LONG_WAIT_TIME:
                    modifier *= min(2.0, wait_time / 5.0)  # Worse with longer waits
            else:  # Quick service
                if event == TrustEvent.QUICK_NEGOTIATION:
                    modifier *= 1.5
        
        # Repeat customer bonus
        if "days_since_last_visit" in context:
            days = context["days_since_last_visit"]
            if days <= 3 and event == TrustEvent.REPEAT_CUSTOMER:
                modifier *= 2.0  # Frequent visitor bonus
        
        return modifier
    
    @classmethod
    def get_trust_tier_benefits(cls, trust_level: int) -> Dict:
        """Get benefits for a specific trust level"""
        if trust_level >= 80:
            return cls.TRUST_BENEFITS[TrustLevel.PARTNER]
        elif trust_level >= 60:
            return cls.TRUST_BENEFITS[TrustLevel.TRUSTED]
        elif trust_level >= 40:
            return cls.TRUST_BENEFITS[TrustLevel.FRIEND]
        elif trust_level >= 20:
            return cls.TRUST_BENEFITS[TrustLevel.ACQUAINTANCE]
        else:
            return cls.TRUST_BENEFITS[TrustLevel.STRANGER]
    
    @classmethod
    def calculate_price_modifier(cls, relation: PlayerAdventurerRelation) -> float:
        """Calculate price modification based on trust level"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        return 1.0 - benefits["price_discount"]
    
    @classmethod
    def calculate_visit_duration(
        cls, 
        base_duration: int, 
        relation: PlayerAdventurerRelation
    ) -> int:
        """Calculate extended visit duration based on trust"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        bonus_multiplier = 1.0 + benefits["visit_duration_bonus"]
        return int(base_duration * bonus_multiplier)
    
    @classmethod
    def can_make_special_requests(cls, relation: PlayerAdventurerRelation) -> bool:
        """Check if adventurer can make special item requests"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        return benefits["special_requests"]
    
    @classmethod
    def can_access_exclusive_items(cls, relation: PlayerAdventurerRelation) -> bool:
        """Check if adventurer can see exclusive items"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        return benefits["exclusive_items"]
    
    @classmethod
    def can_participate_dragon_raids(cls, relation: PlayerAdventurerRelation) -> bool:
        """Check if adventurer can participate in dragon raids"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        return benefits["dragon_raids"]
    
    @classmethod
    def get_negotiation_attempts(cls, relation: PlayerAdventurerRelation) -> int:
        """Get number of negotiation attempts allowed"""
        benefits = cls.get_trust_tier_benefits(relation.trust_level)
        return benefits["negotiation_attempts"]


class TrustEventProcessor:
    """
    Processes trust events and updates relationships
    """
    
    @classmethod
    def process_transaction_completion(
        cls,
        transaction: AdventurerTransaction,
        relation: PlayerAdventurerRelation
    ) -> Tuple[int, List[str]]:
        """
        Process trust changes when a transaction completes
        
        Returns:
            Tuple of (total_trust_change, list_of_events_processed)
        """
        trust_changes = []
        events_processed = []
        
        # Basic successful trade
        if transaction.transaction_type == "purchase":
            trust_change = TrustCalculator.calculate_trust_change(
                TrustEvent.SUCCESSFUL_TRADE,
                relation,
                {
                    "price_ratio": transaction.negotiated_price / max(1, transaction.base_price),
                    "item_quality": cls._assess_item_quality(transaction),
                }
            )
            trust_changes.append(trust_change)
            events_processed.append("Successful trade")
            
            # Check if it was a requested item
            if transaction.was_requested_item:
                request_bonus = TrustCalculator.calculate_trust_change(
                    TrustEvent.REQUESTED_ITEM_SOLD,
                    relation
                )
                trust_changes.append(request_bonus)
                events_processed.append("Sold requested item")
            
            # Check for fair pricing
            price_ratio = transaction.negotiated_price / max(1, transaction.base_price)
            if 0.8 <= price_ratio <= 1.1:  # Fair price range
                fair_price_bonus = TrustCalculator.calculate_trust_change(
                    TrustEvent.FAIR_PRICE,
                    relation,
                    {"price_ratio": price_ratio}
                )
                trust_changes.append(fair_price_bonus)
                events_processed.append("Fair pricing")
            elif price_ratio > 1.2:  # Overpriced
                overpriced_penalty = TrustCalculator.calculate_trust_change(
                    TrustEvent.OVERPRICED_ITEM,
                    relation,
                    {"price_ratio": price_ratio}
                )
                trust_changes.append(overpriced_penalty)
                events_processed.append("Overpriced item")
        
        elif transaction.transaction_type == "negotiation_failed":
            negotiation_penalty = TrustCalculator.calculate_trust_change(
                TrustEvent.NEGOTIATION_FAILED,
                relation
            )
            trust_changes.append(negotiation_penalty)
            events_processed.append("Negotiation failed")
        
        # Apply trust changes
        total_change = sum(trust_changes)
        if total_change > 0:
            relation.increase_trust(total_change)
        elif total_change < 0:
            relation.decrease_trust(abs(total_change))
        
        # Update interaction stats
        relation.total_interactions += 1
        if transaction.transaction_type == "purchase":
            relation.successful_trades += 1
            relation.total_gold_traded += transaction.negotiated_price
            relation.total_items_sold += 1
        else:
            relation.failed_negotiations += 1
        
        relation.last_interaction_at = datetime.utcnow()
        
        return total_change, events_processed
    
    @classmethod
    def process_visit_completion(
        cls,
        visit: AdventurerVisit,
        relation: PlayerAdventurerRelation
    ) -> Tuple[int, List[str]]:
        """
        Process trust changes when a visit completes
        
        Returns:
            Tuple of (total_trust_change, list_of_events_processed)
        """
        trust_changes = []
        events_processed = []
        
        # Check if this was a repeat visit (within 7 days)
        if relation.last_visit_at:
            days_since_last = (visit.visit_start_time - relation.last_visit_at).days
            if days_since_last <= 7:
                repeat_bonus = TrustCalculator.calculate_trust_change(
                    TrustEvent.REPEAT_CUSTOMER,
                    relation,
                    {"days_since_last_visit": days_since_last}
                )
                trust_changes.append(repeat_bonus)
                events_processed.append("Repeat customer")
        
        # Process any wait time issues
        if visit.actual_duration_minutes and visit.actual_duration_minutes > visit.planned_duration_minutes * 1.5:
            wait_penalty = TrustCalculator.calculate_trust_change(
                TrustEvent.LONG_WAIT_TIME,
                relation,
                {"wait_time_minutes": visit.actual_duration_minutes - visit.planned_duration_minutes}
            )
            trust_changes.append(wait_penalty)
            events_processed.append("Long wait time")
        
        # Apply trust changes
        total_change = sum(trust_changes)
        if total_change > 0:
            relation.increase_trust(total_change)
        elif total_change < 0:
            relation.decrease_trust(abs(total_change))
        
        # Update visit tracking
        relation.last_visit_at = visit.visit_start_time
        
        return total_change, events_processed
    
    @classmethod
    def _assess_item_quality(cls, transaction: AdventurerTransaction) -> int:
        """Assess item quality for trust calculations (1-5 scale)"""
        # This would assess enchantment levels, rarity, etc.
        # For now, return a default quality
        return 3  # Average quality
    
    @classmethod
    def process_dragon_raid_invitation(
        cls,
        relation: PlayerAdventurerRelation
    ) -> Tuple[int, List[str]]:
        """Process trust gain from dragon raid invitation"""
        if relation.trust_level >= TrustLevel.PARTNER.value:
            trust_change = TrustCalculator.calculate_trust_change(
                TrustEvent.DRAGON_RAID_INVITE,
                relation
            )
            relation.increase_trust(trust_change)
            return trust_change, ["Dragon raid invitation"]
        return 0, []