import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'adventurer_character.g.dart';

// Trust tier enumeration
enum TrustTier {
  @JsonValue('stranger')
  stranger,
  @JsonValue('acquaintance')
  acquaintance,
  @JsonValue('friend')
  friend,
  @JsonValue('trusted')
  trusted,
  @JsonValue('partner')
  partner
}

// Visit purpose enumeration
enum VisitPurpose {
  @JsonValue('trade')
  trade,
  @JsonValue('quest_prep')
  questPrep,
  @JsonValue('dragon_raid')
  dragonRaid,
  @JsonValue('social')
  social
}

// Visit status enumeration
enum VisitStatus {
  @JsonValue('browsing')
  browsing,
  @JsonValue('negotiating')
  negotiating,
  @JsonValue('completed')
  completed,
  @JsonValue('left')
  left
}

// Transaction type enumeration
enum TransactionType {
  @JsonValue('purchase')
  purchase,
  @JsonValue('sale')
  sale,
  @JsonValue('trade')
  trade,
  @JsonValue('negotiation_failed')
  negotiationFailed
}

// Permanent Adventurer Character
@JsonSerializable()
class AdventurerCharacter {
  final int id;
  final String name;
  final String profession;
  final int level;
  final String personality;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? description;
  final String? backstory;
  @JsonKey(name: 'base_attack')
  final int baseAttack;
  @JsonKey(name: 'base_defense')
  final int baseDefense;
  @JsonKey(name: 'base_hp')
  final int baseHp;
  @JsonKey(name: 'special_abilities')
  final List<String>? specialAbilities;
  @JsonKey(name: 'preferred_weapon_types')
  final List<String> preferredWeaponTypes;
  @JsonKey(name: 'budget_base')
  final int budgetBase;
  @JsonKey(name: 'budget_variance')
  final double budgetVariance;
  @JsonKey(name: 'negotiation_skill')
  final double negotiationSkill;
  @JsonKey(name: 'visit_frequency_hours')
  final int visitFrequencyHours;
  @JsonKey(name: 'stay_duration_minutes')
  final int stayDurationMinutes;
  @JsonKey(name: 'urgency_tendency')
  final int urgencyTendency;
  @JsonKey(name: 'experience_points')
  final int experiencePoints;
  @JsonKey(name: 'total_trades_completed')
  final int totalTradesCompleted;
  @JsonKey(name: 'total_gold_spent')
  final int totalGoldSpent;
  @JsonKey(name: 'dragon_raids_participated')
  final int dragonRaidsParticipated;
  @JsonKey(name: 'min_player_level')
  final int minPlayerLevel;
  @JsonKey(name: 'unlock_condition')
  final Map<String, dynamic>? unlockCondition;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AdventurerCharacter({
    required this.id,
    required this.name,
    required this.profession,
    required this.level,
    required this.personality,
    this.avatarUrl,
    this.description,
    this.backstory,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseHp,
    this.specialAbilities,
    required this.preferredWeaponTypes,
    required this.budgetBase,
    required this.budgetVariance,
    required this.negotiationSkill,
    required this.visitFrequencyHours,
    required this.stayDurationMinutes,
    required this.urgencyTendency,
    required this.experiencePoints,
    required this.totalTradesCompleted,
    required this.totalGoldSpent,
    required this.dragonRaidsParticipated,
    required this.minPlayerLevel,
    this.unlockCondition,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // factory AdventurerCharacter.fromJson(Map<String, dynamic> json) =>
  //     _$AdventurerCharacterFromJson(json);
  // Map<String, dynamic> toJson() => _$AdventurerCharacterToJson(this);

  // Get profession icon
  String get professionIcon {
    switch (profession.toLowerCase()) {
      case 'warrior':
        return '⚔️';
      case 'archer':
        return '🏹';
      case 'mage':
        return '🔮';
      case 'rogue':
      case 'thief':
        return '🗡️';
      case 'paladin':
        return '🛡️';
      default:
        return '👤';
    }
  }

  // Get personality display name
  String get personalityName {
    switch (personality.toLowerCase()) {
      case 'generous':
        return '気前が良い';
      case 'wealthy':
        return '裕福';
      case 'normal':
        return '普通';
      case 'stingy':
        return 'けち';
      case 'poor':
        return '貧乏';
      default:
        return '普通';
    }
  }

  // Get current budget with trust level
  int getCurrentBudget(int trustLevel) {
    final trustBonus = (trustLevel / 100.0) * 0.5;
    final personalityMultiplier = _getPersonalityMultiplier();
    return (budgetBase * (1 + trustBonus) * personalityMultiplier).round();
  }

  double _getPersonalityMultiplier() {
    switch (personality.toLowerCase()) {
      case 'generous':
        return 1.2;
      case 'wealthy':
        return 1.5;
      case 'normal':
        return 1.0;
      case 'stingy':
        return 0.8;
      case 'poor':
        return 0.6;
      default:
        return 1.0;
    }
  }

  // Get visit duration with trust bonus
  int getVisitDuration(int trustLevel) {
    final trustMultiplier = 1.0 + (trustLevel / 100.0);
    return (stayDurationMinutes * trustMultiplier).round();
  }
}

// Player-Adventurer Relationship
@JsonSerializable()
class PlayerAdventurerRelation {
  final int id;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'adventurer_id')
  final int adventurerId;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'relationship_status')
  final String relationshipStatus;
  @JsonKey(name: 'total_interactions')
  final int totalInteractions;
  @JsonKey(name: 'successful_trades')
  final int successfulTrades;
  @JsonKey(name: 'failed_negotiations')
  final int failedNegotiations;
  @JsonKey(name: 'total_gold_traded')
  final int totalGoldTraded;
  @JsonKey(name: 'total_items_sold')
  final int totalItemsSold;
  @JsonKey(name: 'total_items_bought')
  final int totalItemsBought;
  @JsonKey(name: 'quests_completed_together')
  final int questsCompletedTogether;
  @JsonKey(name: 'dragon_raids_together')
  final int dragonRaidsTogether;
  @JsonKey(name: 'unlocked_features')
  final List<String>? unlockedFeatures;
  @JsonKey(name: 'special_discounts')
  final Map<String, double>? specialDiscounts;
  @JsonKey(name: 'exclusive_access')
  final List<String>? exclusiveAccess;
  @JsonKey(name: 'first_met_at')
  final DateTime firstMetAt;
  @JsonKey(name: 'last_interaction_at')
  final DateTime? lastInteractionAt;
  @JsonKey(name: 'last_visit_at')
  final DateTime? lastVisitAt;
  @JsonKey(name: 'next_expected_visit')
  final DateTime? nextExpectedVisit;
  @JsonKey(name: 'learned_preferences')
  final Map<String, dynamic>? learnedPreferences;
  @JsonKey(name: 'price_sensitivity')
  final double priceSensitivity;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final AdventurerCharacter? adventurer;

  const PlayerAdventurerRelation({
    required this.id,
    required this.playerId,
    required this.adventurerId,
    required this.trustLevel,
    required this.relationshipStatus,
    required this.totalInteractions,
    required this.successfulTrades,
    required this.failedNegotiations,
    required this.totalGoldTraded,
    required this.totalItemsSold,
    required this.totalItemsBought,
    required this.questsCompletedTogether,
    required this.dragonRaidsTogether,
    this.unlockedFeatures,
    this.specialDiscounts,
    this.exclusiveAccess,
    required this.firstMetAt,
    this.lastInteractionAt,
    this.lastVisitAt,
    this.nextExpectedVisit,
    this.learnedPreferences,
    required this.priceSensitivity,
    required this.createdAt,
    required this.updatedAt,
    this.adventurer,
  });

  // factory PlayerAdventurerRelation.fromJson(Map<String, dynamic> json) =>
  //     _$PlayerAdventurerRelationFromJson(json);
  // Map<String, dynamic> toJson() => _$PlayerAdventurerRelationToJson(this);

  // Get trust tier
  TrustTier get trustTier {
    if (trustLevel >= 80) return TrustTier.partner;
    if (trustLevel >= 60) return TrustTier.trusted;
    if (trustLevel >= 40) return TrustTier.friend;
    if (trustLevel >= 20) return TrustTier.acquaintance;
    return TrustTier.stranger;
  }

  // Get trust tier name in Japanese
  String get trustTierName {
    switch (trustTier) {
      case TrustTier.partner:
        return 'パートナー';
      case TrustTier.trusted:
        return '信頼関係';
      case TrustTier.friend:
        return '友達';
      case TrustTier.acquaintance:
        return '知り合い';
      case TrustTier.stranger:
        return '他人';
    }
  }

  // Check if can access dragon raids
  bool get canAccessDragonRaids => trustLevel >= 80;

  // Get price discount percentage
  double get priceDiscountPercent {
    switch (trustTier) {
      case TrustTier.partner:
        return 20.0;
      case TrustTier.trusted:
        return 10.0;
      case TrustTier.friend:
        return 5.0;
      case TrustTier.acquaintance:
        return 2.0;
      case TrustTier.stranger:
        return 0.0;
    }
  }

  // Get visit duration bonus percentage
  double get visitDurationBonusPercent {
    switch (trustTier) {
      case TrustTier.partner:
        return 100.0;
      case TrustTier.trusted:
        return 50.0;
      case TrustTier.friend:
        return 25.0;
      case TrustTier.acquaintance:
        return 10.0;
      case TrustTier.stranger:
        return 0.0;
    }
  }

  // Get negotiation attempts allowed
  int get negotiationAttempts {
    switch (trustTier) {
      case TrustTier.partner:
        return 5;
      case TrustTier.trusted:
        return 4;
      case TrustTier.friend:
        return 3;
      case TrustTier.acquaintance:
        return 2;
      case TrustTier.stranger:
        return 1;
    }
  }

  // Check if can make special requests
  bool get canMakeSpecialRequests => trustLevel >= 40;

  // Check if can access exclusive items
  bool get canAccessExclusiveItems => trustLevel >= 60;
}

// Adventurer Relationship Summary
@JsonSerializable()
class AdventurerRelationSummary {
  @JsonKey(name: 'relation_id')
  final int relationId;
  @JsonKey(name: 'adventurer_id')
  final int adventurerId;
  @JsonKey(name: 'adventurer_name')
  final String adventurerName;
  @JsonKey(name: 'adventurer_profession')
  final String adventurerProfession;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'trust_tier')
  final String trustTier;
  @JsonKey(name: 'price_discount')
  final double priceDiscount;
  @JsonKey(name: 'can_dragon_raids')
  final bool canDragonRaids;
  @JsonKey(name: 'total_interactions')
  final int totalInteractions;
  @JsonKey(name: 'successful_trades')
  final int successfulTrades;
  @JsonKey(name: 'last_interaction_at')
  final DateTime? lastInteractionAt;
  @JsonKey(name: 'next_expected_visit')
  final DateTime? nextExpectedVisit;

  const AdventurerRelationSummary({
    required this.relationId,
    required this.adventurerId,
    required this.adventurerName,
    required this.adventurerProfession,
    required this.trustLevel,
    required this.trustTier,
    required this.priceDiscount,
    required this.canDragonRaids,
    required this.totalInteractions,
    required this.successfulTrades,
    this.lastInteractionAt,
    this.nextExpectedVisit,
  });

  // factory AdventurerRelationSummary.fromJson(Map<String, dynamic> json) =>
  //     _$AdventurerRelationSummaryFromJson(json);
  // Map<String, dynamic> toJson() => _$AdventurerRelationSummaryToJson(this);

  // Get profession icon
  String get professionIcon {
    switch (adventurerProfession.toLowerCase()) {
      case 'warrior':
        return '⚔️';
      case 'archer':
        return '🏹';
      case 'mage':
        return '🔮';
      case 'rogue':
      case 'thief':
        return '🗡️';
      case 'paladin':
        return '🛡️';
      default:
        return '👤';
    }
  }

  // Get trust tier color
  Color get trustTierColor {
    switch (trustTier) {
      case 'partner':
        return const Color(0xFFFFD700); // Gold
      case 'trusted':
        return const Color(0xFF9C27B0); // Purple
      case 'friend':
        return const Color(0xFF4CAF50); // Green
      case 'acquaintance':
        return const Color(0xFF2196F3); // Blue
      case 'stranger':
      default:
        return const Color(0xFF757575); // Gray
    }
  }

  // Get time until next expected visit
  String get timeUntilNextVisit {
    if (nextExpectedVisit == null) return '未定';
    
    final now = DateTime.now();
    final difference = nextExpectedVisit!.difference(now);
    
    if (difference.isNegative) return 'いつでも';
    
    if (difference.inDays > 0) {
      return '${difference.inDays}日後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間後';
    } else {
      return '${difference.inMinutes}分後';
    }
  }
}

// Adventurer Visit
@JsonSerializable()
class AdventurerVisit {
  final int id;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'adventurer_id')
  final int adventurerId;
  @JsonKey(name: 'relation_id')
  final int relationId;
  @JsonKey(name: 'visit_start_time')
  final DateTime visitStartTime;
  @JsonKey(name: 'visit_end_time')
  final DateTime? visitEndTime;
  @JsonKey(name: 'planned_duration_minutes')
  final int plannedDurationMinutes;
  @JsonKey(name: 'actual_duration_minutes')
  final int? actualDurationMinutes;
  @JsonKey(name: 'visit_purpose')
  final String visitPurpose;
  @JsonKey(name: 'current_status')
  final String currentStatus;
  @JsonKey(name: 'weapon_request')
  final Map<String, dynamic>? weaponRequest;
  @JsonKey(name: 'budget_for_visit')
  final int budgetForVisit;
  @JsonKey(name: 'urgency_level')
  final int urgencyLevel;
  @JsonKey(name: 'items_purchased')
  final List<Map<String, dynamic>>? itemsPurchased;
  @JsonKey(name: 'items_sold_to_player')
  final List<Map<String, dynamic>>? itemsSoldToPlayer;
  @JsonKey(name: 'total_gold_spent')
  final int totalGoldSpent;
  @JsonKey(name: 'total_gold_earned')
  final int totalGoldEarned;
  @JsonKey(name: 'trust_gained')
  final int trustGained;
  @JsonKey(name: 'trust_lost')
  final int trustLost;
  @JsonKey(name: 'relationship_notes')
  final String? relationshipNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final AdventurerCharacter? adventurer;
  final PlayerAdventurerRelation? relation;

  const AdventurerVisit({
    required this.id,
    required this.playerId,
    required this.adventurerId,
    required this.relationId,
    required this.visitStartTime,
    this.visitEndTime,
    required this.plannedDurationMinutes,
    this.actualDurationMinutes,
    required this.visitPurpose,
    required this.currentStatus,
    this.weaponRequest,
    required this.budgetForVisit,
    required this.urgencyLevel,
    this.itemsPurchased,
    this.itemsSoldToPlayer,
    required this.totalGoldSpent,
    required this.totalGoldEarned,
    required this.trustGained,
    required this.trustLost,
    this.relationshipNotes,
    required this.createdAt,
    required this.updatedAt,
    this.adventurer,
    this.relation,
  });

  // factory AdventurerVisit.fromJson(Map<String, dynamic> json) =>
  //     _$AdventurerVisitFromJson(json);
  // Map<String, dynamic> toJson() => _$AdventurerVisitToJson(this);

  // Check if visit is currently active
  bool get isActive => visitEndTime == null && !['completed', 'left'].contains(currentStatus);

  // Get remaining time in minutes
  int get remainingTimeMinutes {
    if (!isActive) return 0;
    
    final elapsed = DateTime.now().difference(visitStartTime).inMinutes;
    return (plannedDurationMinutes - elapsed).clamp(0, plannedDurationMinutes);
  }

  // Get visit status in Japanese
  String get statusName {
    switch (currentStatus) {
      case 'browsing':
        return '商品を見ている';
      case 'negotiating':
        return '交渉中';
      case 'completed':
        return '取引完了';
      case 'left':
        return '立ち去った';
      default:
        return currentStatus;
    }
  }

  // Get urgency level name
  String get urgencyName {
    switch (urgencyLevel) {
      case 5:
        return '超緊急';
      case 4:
        return '緊急';
      case 3:
        return '普通';
      case 2:
        return '余裕';
      case 1:
        return 'のんびり';
      default:
        return '普通';
    }
  }

  // Get urgency color
  Color get urgencyColor {
    switch (urgencyLevel) {
      case 5:
        return const Color(0xFFFF1744); // Red
      case 4:
        return const Color(0xFFFF9800); // Orange
      case 3:
        return const Color(0xFF2196F3); // Blue
      case 2:
        return const Color(0xFF4CAF50); // Green
      case 1:
        return const Color(0xFF9E9E9E); // Gray
      default:
        return const Color(0xFF2196F3);
    }
  }
}

// Trust Level Benefits
@JsonSerializable()
class TrustLevelBenefits {
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'tier_name')
  final String tierName;
  @JsonKey(name: 'price_discount_percent')
  final double priceDiscountPercent;
  @JsonKey(name: 'visit_duration_bonus_percent')
  final double visitDurationBonusPercent;
  @JsonKey(name: 'can_make_special_requests')
  final bool canMakeSpecialRequests;
  @JsonKey(name: 'can_access_exclusive_items')
  final bool canAccessExclusiveItems;
  @JsonKey(name: 'can_participate_dragon_raids')
  final bool canParticipateDragonRaids;
  @JsonKey(name: 'negotiation_attempts')
  final int negotiationAttempts;
  final String description;

  const TrustLevelBenefits({
    required this.trustLevel,
    required this.tierName,
    required this.priceDiscountPercent,
    required this.visitDurationBonusPercent,
    required this.canMakeSpecialRequests,
    required this.canAccessExclusiveItems,
    required this.canParticipateDragonRaids,
    required this.negotiationAttempts,
    required this.description,
  });

  // factory TrustLevelBenefits.fromJson(Map<String, dynamic> json) =>
  //     _$TrustLevelBenefitsFromJson(json);
  // Map<String, dynamic> toJson() => _$TrustLevelBenefitsToJson(this);
}

// Adventurer Transaction
@JsonSerializable()
class AdventurerTransaction {
  final int id;
  @JsonKey(name: 'visit_id')
  final int visitId;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'adventurer_id')
  final int adventurerId;
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @JsonKey(name: 'item_type')
  final String itemType;
  @JsonKey(name: 'item_id')
  final String itemId;
  @JsonKey(name: 'item_name')
  final String itemName;
  @JsonKey(name: 'base_price')
  final int basePrice;
  @JsonKey(name: 'negotiated_price')
  final int negotiatedPrice;
  @JsonKey(name: 'price_modifier')
  final double priceModifier;
  @JsonKey(name: 'trust_discount')
  final double trustDiscount;
  @JsonKey(name: 'trust_change')
  final int trustChange;
  @JsonKey(name: 'satisfaction_level')
  final int satisfactionLevel;
  @JsonKey(name: 'was_requested_item')
  final bool wasRequestedItem;
  @JsonKey(name: 'negotiation_rounds')
  final int negotiationRounds;
  @JsonKey(name: 'transaction_notes')
  final String? transactionNotes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const AdventurerTransaction({
    required this.id,
    required this.visitId,
    required this.playerId,
    required this.adventurerId,
    required this.transactionType,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.basePrice,
    required this.negotiatedPrice,
    required this.priceModifier,
    required this.trustDiscount,
    required this.trustChange,
    required this.satisfactionLevel,
    required this.wasRequestedItem,
    required this.negotiationRounds,
    this.transactionNotes,
    required this.createdAt,
  });

  // factory AdventurerTransaction.fromJson(Map<String, dynamic> json) =>
  //     _$AdventurerTransactionFromJson(json);
  // Map<String, dynamic> toJson() => _$AdventurerTransactionToJson(this);

  // Get transaction type name in Japanese
  String get transactionTypeName {
    switch (transactionType) {
      case 'purchase':
        return '購入';
      case 'sale':
        return '売却';
      case 'trade':
        return '交換';
      case 'negotiation_failed':
        return '交渉失敗';
      default:
        return transactionType;
    }
  }

  // Get satisfaction level name
  String get satisfactionLevelName {
    switch (satisfactionLevel) {
      case 5:
        return '大満足';
      case 4:
        return '満足';
      case 3:
        return '普通';
      case 2:
        return '不満';
      case 1:
        return '大不満';
      default:
        return '普通';
    }
  }

  // Check if transaction was successful
  bool get wasSuccessful => transactionType != 'negotiation_failed';

  // Get price difference percentage
  double get priceDiscountPercent {
    if (basePrice == 0) return 0.0;
    return ((basePrice - negotiatedPrice) / basePrice * 100);
  }
}