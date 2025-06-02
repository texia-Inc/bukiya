// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adventurer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Adventurer _$AdventurerFromJson(Map<String, dynamic> json) => Adventurer(
      id: json['id'] as String,
      name: json['name'] as String,
      profession: json['profession'] as String,
      level: (json['level'] as num).toInt(),
      personality: json['personality'] as String,
      trustLevel: (json['trustLevel'] as num).toInt(),
      budget: (json['budget'] as num).toInt(),
      preferredWeaponType: json['preferredWeaponType'] as String,
      avatarUrl: json['avatarUrl'] as String,
      visitStartTime: DateTime.parse(json['visitStartTime'] as String),
      visitEndTime: DateTime.parse(json['visitEndTime'] as String),
      status: $enumDecode(_$AdventurerStatusEnumMap, json['status']),
      currentRequest: json['currentRequest'] == null
          ? null
          : AdventurerRequest.fromJson(
              json['currentRequest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdventurerToJson(Adventurer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profession': instance.profession,
      'level': instance.level,
      'personality': instance.personality,
      'trustLevel': instance.trustLevel,
      'budget': instance.budget,
      'preferredWeaponType': instance.preferredWeaponType,
      'avatarUrl': instance.avatarUrl,
      'visitStartTime': instance.visitStartTime.toIso8601String(),
      'visitEndTime': instance.visitEndTime.toIso8601String(),
      'status': _$AdventurerStatusEnumMap[instance.status]!,
      'currentRequest': instance.currentRequest,
    };

const _$AdventurerStatusEnumMap = {
  AdventurerStatus.visiting: 'visiting',
  AdventurerStatus.onQuest: 'on_quest',
  AdventurerStatus.returning: 'returning',
  AdventurerStatus.completed: 'completed',
  AdventurerStatus.left: 'left',
};

AdventurerRequest _$AdventurerRequestFromJson(Map<String, dynamic> json) =>
    AdventurerRequest(
      id: json['id'] as String,
      adventurerId: json['adventurerId'] as String,
      weaponType: json['weaponType'] as String,
      minAttack: (json['minAttack'] as num).toInt(),
      maxBudget: (json['maxBudget'] as num).toInt(),
      preferredRarity: json['preferredRarity'] as String?,
      urgency: (json['urgency'] as num).toInt(),
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
    );

Map<String, dynamic> _$AdventurerRequestToJson(AdventurerRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurerId': instance.adventurerId,
      'weaponType': instance.weaponType,
      'minAttack': instance.minAttack,
      'maxBudget': instance.maxBudget,
      'preferredRarity': instance.preferredRarity,
      'urgency': instance.urgency,
      'description': instance.description,
      'deadline': instance.deadline.toIso8601String(),
    };

QuestResult _$QuestResultFromJson(Map<String, dynamic> json) => QuestResult(
      id: json['id'] as String,
      adventurerId: json['adventurerId'] as String,
      questArea: json['questArea'] as String,
      success: json['success'] as bool,
      goldEarned: (json['goldEarned'] as num).toInt(),
      drops: (json['drops'] as List<dynamic>)
          .map((e) => QuestDrop.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      buybackDeadline: DateTime.parse(json['buybackDeadline'] as String),
    );

Map<String, dynamic> _$QuestResultToJson(QuestResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adventurerId': instance.adventurerId,
      'questArea': instance.questArea,
      'success': instance.success,
      'goldEarned': instance.goldEarned,
      'drops': instance.drops,
      'completedAt': instance.completedAt.toIso8601String(),
      'buybackDeadline': instance.buybackDeadline.toIso8601String(),
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

QuestArea _$QuestAreaFromJson(Map<String, dynamic> json) => QuestArea(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredLevel: (json['requiredLevel'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      difficulty: (json['difficulty'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$QuestAreaToJson(QuestArea instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'requiredLevel': instance.requiredLevel,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
      'imageUrl': instance.imageUrl,
    };
