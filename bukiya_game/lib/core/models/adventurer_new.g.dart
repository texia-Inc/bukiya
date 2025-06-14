// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventurer_new.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdventurerMaster _$AdventurerMasterFromJson(Map<String, dynamic> json) =>
    AdventurerMaster(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      profession: json['profession'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      personality: json['personality'] as String? ?? '',
      trustLevel: (json['trust_level'] as num?)?.toInt() ?? 50,
      budgetMin: (json['budget_min'] as num?)?.toInt() ?? 500,
      budgetMax: (json['budget_max'] as num?)?.toInt() ?? 2000,
      preferredWeaponType: json['preferred_weapon_type'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      minAttackRequirement:
          (json['min_attack_requirement'] as num?)?.toInt() ?? 100,
      maxBudgetMultiplier:
          (json['max_budget_multiplier'] as num?)?.toDouble() ?? 1.0,
      urgencyTendency: (json['urgency_tendency'] as num?)?.toInt() ?? 3,
      spawnWeight: (json['spawn_weight'] as num?)?.toInt() ?? 100,
      minPlayerLevel: (json['min_player_level'] as num?)?.toInt() ?? 1,
      maxPlayerLevel: (json['max_player_level'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
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
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

AdventurerRequest _$AdventurerRequestFromJson(Map<String, dynamic> json) =>
    AdventurerRequest(
      id: json['id'] as String? ?? '',
      adventurerInstanceId: json['adventurer_instance_id'] as String? ?? '',
      weaponType: json['weapon_type'] as String? ?? '',
      minAttack: (json['min_attack'] as num?)?.toInt() ?? 100,
      maxBudget: (json['max_budget'] as num?)?.toInt() ?? 1000,
      preferredRarity: json['preferred_rarity'] as String?,
      urgency: (json['urgency'] as num?)?.toInt() ?? 3,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String? ?? 'pending',
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
      id: json['id'] as String? ?? '',
      adventurerMasterId: json['adventurer_master_id'] as String?,
      playerId: json['player_id'] as String?,
      name: json['name'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      trustLevel: (json['trust_level'] as num?)?.toInt() ?? 50,
      status: json['status'] as String? ?? 'visiting',
      currentQuestId: json['current_quest_id'] as String?,
      visitStartTime: json['visit_start_time'] == null
          ? null
          : DateTime.parse(json['visit_start_time'] as String),
      visitEndTime: json['visit_end_time'] == null
          ? null
          : DateTime.parse(json['visit_end_time'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      adventurerMaster: json['adventurer_master'] == null
          ? null
          : AdventurerMaster.fromJson(
              json['adventurer_master'] as Map<String, dynamic>),
      requests: (json['requests'] as List<dynamic>?)
              ?.map(
                  (e) => AdventurerRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentQuest: json['current_quest'] == null
          ? null
          : QuestProgress.fromJson(
              json['current_quest'] as Map<String, dynamic>),
      isNamedCharacter: json['is_named_character'] as bool? ?? false,
      characterId: (json['character_id'] as num?)?.toInt(),
      genericName: json['generic_name'] as String?,
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
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'adventurer_master': instance.adventurerMaster,
      'requests': instance.requests,
      'current_quest': instance.currentQuest,
      'is_named_character': instance.isNamedCharacter,
      'character_id': instance.characterId,
      'generic_name': instance.genericName,
    };

QuestArea _$QuestAreaFromJson(Map<String, dynamic> json) => QuestArea(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      areaType: json['area_type'] as String? ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      requiredLevel: (json['required_level'] as num?)?.toInt() ?? 1,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      imageUrl: json['image_url'] as String?,
      backgroundColor: json['background_color'] as String? ?? '#4CAF50',
      description: json['description'] as String?,
      unlockCondition: json['unlock_condition'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
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
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

QuestProgress _$QuestProgressFromJson(Map<String, dynamic> json) =>
    QuestProgress(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      remainingTime: RemainingTime.fromJson(
          json['remaining_time'] as Map<String, dynamic>),
      isCompleted: json['is_completed'] as bool,
      questArea: QuestArea.fromJson(json['quest_area'] as Map<String, dynamic>),
      weaponUsed:
          WeaponUsed.fromJson(json['weapon_used'] as Map<String, dynamic>),
      monsterFighting: json['monster_fighting'] == null
          ? null
          : MonsterFighting.fromJson(
              json['monster_fighting'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuestProgressToJson(QuestProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'progress_percentage': instance.progressPercentage,
      'remaining_time': instance.remainingTime,
      'is_completed': instance.isCompleted,
      'quest_area': instance.questArea,
      'weapon_used': instance.weaponUsed,
      'monster_fighting': instance.monsterFighting,
    };

RemainingTime _$RemainingTimeFromJson(Map<String, dynamic> json) =>
    RemainingTime(
      hours: (json['hours'] as num?)?.toInt() ?? 0,
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      totalMinutes: (json['total_minutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RemainingTimeToJson(RemainingTime instance) =>
    <String, dynamic>{
      'hours': instance.hours,
      'minutes': instance.minutes,
      'total_minutes': instance.totalMinutes,
    };

MonsterFighting _$MonsterFightingFromJson(Map<String, dynamic> json) =>
    MonsterFighting(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      monsterType: json['monster_type'] as String? ?? '',
      hp: (json['hp'] as num?)?.toInt() ?? 100,
      attack: (json['attack'] as num?)?.toInt() ?? 20,
      defense: (json['defense'] as num?)?.toInt() ?? 10,
      element: json['element'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$MonsterFightingToJson(MonsterFighting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'level': instance.level,
      'monster_type': instance.monsterType,
      'hp': instance.hp,
      'attack': instance.attack,
      'defense': instance.defense,
      'element': instance.element,
      'description': instance.description,
    };

WeaponUsed _$WeaponUsedFromJson(Map<String, dynamic> json) => WeaponUsed(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      attack: (json['attack'] as num?)?.toInt() ?? 100,
      enchantLevel: (json['enchant_level'] as num?)?.toInt() ?? 0,
      weaponType: json['weapon_type'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
    );

Map<String, dynamic> _$WeaponUsedToJson(WeaponUsed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'attack': instance.attack,
      'enchant_level': instance.enchantLevel,
      'weapon_type': instance.weaponType,
      'display_name': instance.displayName,
    };

QuestReward _$QuestRewardFromJson(Map<String, dynamic> json) => QuestReward(
      id: json['id'] as String? ?? '',
      adventurerQuestId: json['adventurer_quest_id'] as String? ?? '',
      itemType: json['item_type'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
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
      'item_name': instance.itemName,
      'quantity': instance.quantity,
      'buyback_price': instance.buybackPrice,
      'buyback_deadline': instance.buybackDeadline?.toIso8601String(),
      'is_bought': instance.isBought,
      'created_at': instance.createdAt.toIso8601String(),
    };

QuestResult _$QuestResultFromJson(Map<String, dynamic> json) => QuestResult(
      id: json['id'] as String? ?? '',
      adventurerInstanceId: json['adventurer_instance_id'] as String? ?? '',
      questAreaId: (json['quest_area_id'] as num?)?.toInt() ?? 0,
      playerWeaponId: json['player_weapon_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      success: json['success'] as bool?,
      goldEarned: (json['gold_earned'] as num?)?.toInt() ?? 0,
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
      id: json['id'] as String? ?? '',
      itemType: json['itemType'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rarity: json['rarity'] as String? ?? 'common',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      buybackPrice: (json['buybackPrice'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
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
