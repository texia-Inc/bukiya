// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventurer_new.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdventurerMaster _$AdventurerMasterFromJson(Map<String, dynamic> json) =>
    AdventurerMaster(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profession: json['profession'] as String,
      level: (json['level'] as num).toInt(),
      personality: json['personality'] as String,
      trustLevel: (json['trust_level'] as num).toInt(),
      budgetMin: (json['budget_min'] as num).toInt(),
      budgetMax: (json['budget_max'] as num).toInt(),
      preferredWeaponType: json['preferred_weapon_type'] as String,
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      minAttackRequirement: (json['min_attack_requirement'] as num).toInt(),
      maxBudgetMultiplier: (json['max_budget_multiplier'] as num).toDouble(),
      urgencyTendency: (json['urgency_tendency'] as num).toInt(),
      spawnWeight: (json['spawn_weight'] as num).toInt(),
      minPlayerLevel: (json['min_player_level'] as num).toInt(),
      maxPlayerLevel: (json['max_player_level'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdventurerMasterToJson(AdventurerMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profession': instance.profession,
      'level': instance.level,
      'personality': instance.personality,
      'trust_level': instance.trustLevel,
      'budget_min': instance.budgetMin,
      'budget_max': instance.budgetMax,
      'preferred_weapon_type': instance.preferredWeaponType,
      'avatar_url': instance.avatarUrl,
      'description': instance.description,
      'min_attack_requirement': instance.minAttackRequirement,
      'max_budget_multiplier': instance.maxBudgetMultiplier,
      'urgency_tendency': instance.urgencyTendency,
      'spawn_weight': instance.spawnWeight,
      'min_player_level': instance.minPlayerLevel,
      'max_player_level': instance.maxPlayerLevel,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

AdventurerRequest _$AdventurerRequestFromJson(Map<String, dynamic> json) =>
    AdventurerRequest(
      id: json['id'] as String,
      adventurerInstanceId: json['adventurer_instance_id'] as String,
      weaponType: json['weapon_type'] as String,
      minAttack: (json['min_attack'] as num).toInt(),
      maxBudget: (json['max_budget'] as num).toInt(),
      preferredRarity: json['preferred_rarity'] as String?,
      urgency: (json['urgency'] as num).toInt(),
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AdventurerRequestToJson(AdventurerRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurer_instance_id': instance.adventurerInstanceId,
      'weapon_type': instance.weaponType,
      'min_attack': instance.minAttack,
      'max_budget': instance.maxBudget,
      'preferred_rarity': instance.preferredRarity,
      'urgency': instance.urgency,
      'description': instance.description,
      'deadline': instance.deadline.toIso8601String(),
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

Adventurer _$AdventurerFromJson(Map<String, dynamic> json) => Adventurer(
      id: json['id'] as String,
      adventurerMasterId: (json['adventurer_master_id'] as num).toInt(),
      playerId: json['player_id'] as String?,
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      trustLevel: (json['trust_level'] as num).toInt(),
      status: json['status'] as String,
      currentQuestId: json['current_quest_id'] as String?,
      visitStartTime: json['visit_start_time'] == null
          ? null
          : DateTime.parse(json['visit_start_time'] as String),
      visitEndTime: json['visit_end_time'] == null
          ? null
          : DateTime.parse(json['visit_end_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      adventurerMaster: json['adventurer_master'] == null
          ? null
          : AdventurerMaster.fromJson(
              json['adventurer_master'] as Map<String, dynamic>),
      requests: (json['requests'] as List<dynamic>?)
              ?.map(
                  (e) => AdventurerRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AdventurerToJson(Adventurer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurer_master_id': instance.adventurerMasterId,
      'player_id': instance.playerId,
      'name': instance.name,
      'level': instance.level,
      'trust_level': instance.trustLevel,
      'status': instance.status,
      'current_quest_id': instance.currentQuestId,
      'visit_start_time': instance.visitStartTime?.toIso8601String(),
      'visit_end_time': instance.visitEndTime?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'adventurer_master': instance.adventurerMaster,
      'requests': instance.requests,
    };

QuestArea _$QuestAreaFromJson(Map<String, dynamic> json) => QuestArea(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      areaType: json['area_type'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      requiredLevel: (json['required_level'] as num).toInt(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      imageUrl: json['image_url'] as String?,
      backgroundColor: json['background_color'] as String,
      description: json['description'] as String?,
      unlockCondition: json['unlock_condition'] as String?,
      isActive: json['is_active'] as bool,
      displayOrder: (json['display_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$QuestAreaToJson(QuestArea instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'area_type': instance.areaType,
      'difficulty': instance.difficulty,
      'required_level': instance.requiredLevel,
      'duration_minutes': instance.durationMinutes,
      'image_url': instance.imageUrl,
      'background_color': instance.backgroundColor,
      'description': instance.description,
      'unlock_condition': instance.unlockCondition,
      'is_active': instance.isActive,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

QuestReward _$QuestRewardFromJson(Map<String, dynamic> json) => QuestReward(
      id: json['id'] as String,
      adventurerQuestId: json['adventurer_quest_id'] as String,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      buybackPrice: (json['buyback_price'] as num?)?.toInt(),
      buybackDeadline: json['buyback_deadline'] == null
          ? null
          : DateTime.parse(json['buyback_deadline'] as String),
      isBought: json['is_bought'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QuestRewardToJson(QuestReward instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurer_quest_id': instance.adventurerQuestId,
      'item_type': instance.itemType,
      'item_id': instance.itemId,
      'quantity': instance.quantity,
      'buyback_price': instance.buybackPrice,
      'buyback_deadline': instance.buybackDeadline?.toIso8601String(),
      'is_bought': instance.isBought,
      'created_at': instance.createdAt.toIso8601String(),
    };

QuestResult _$QuestResultFromJson(Map<String, dynamic> json) => QuestResult(
      id: json['id'] as String,
      adventurerInstanceId: json['adventurer_instance_id'] as String,
      questAreaId: (json['quest_area_id'] as num).toInt(),
      playerWeaponId: json['player_weapon_id'] as String?,
      status: json['status'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      success: json['success'] as bool?,
      goldEarned: (json['gold_earned'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      questArea: json['quest_area'] == null
          ? null
          : QuestArea.fromJson(json['quest_area'] as Map<String, dynamic>),
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => QuestReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QuestResultToJson(QuestResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurer_instance_id': instance.adventurerInstanceId,
      'quest_area_id': instance.questAreaId,
      'player_weapon_id': instance.playerWeaponId,
      'status': instance.status,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'success': instance.success,
      'gold_earned': instance.goldEarned,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'quest_area': instance.questArea,
      'rewards': instance.rewards,
    };

QuestDrop _$QuestDropFromJson(Map<String, dynamic> json) => QuestDrop(
      id: json['id'] as String,
      itemType: json['itemType'] as String,
      itemId: json['itemId'] as String,
      name: json['name'] as String,
      rarity: json['rarity'] as String,
      quantity: (json['quantity'] as num).toInt(),
      buybackPrice: (json['buybackPrice'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$QuestDropToJson(QuestDrop instance) => <String, dynamic>{
      'id': instance.id,
      'itemType': instance.itemType,
      'itemId': instance.itemId,
      'name': instance.name,
      'rarity': instance.rarity,
      'quantity': instance.quantity,
      'buybackPrice': instance.buybackPrice,
      'description': instance.description,
    };
