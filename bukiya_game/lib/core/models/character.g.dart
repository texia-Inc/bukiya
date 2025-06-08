// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      title: json['title'] as String?,
      profession: json['profession'] as String,
      rarity: json['rarity'] as String,
      baseLevel: (json['base_level'] as num).toInt(),
      maxLevel: (json['max_level'] as num).toInt(),
      unlockPlayerLevel: (json['unlock_player_level'] as num).toInt(),
      personality: json['personality'] as String,
      backstory: json['backstory'] as String?,
      quote: json['quote'] as String?,
      colorTheme: json['color_theme'] as String,
      dragonBattleEligible: json['dragon_battle_eligible'] as bool,
      baseStats: json['base_stats'] as Map<String, dynamic>,
      growthRates: json['growth_rates'] as Map<String, dynamic>,
      preferredWeaponTypes: (json['preferred_weapon_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      elementalAffinity: json['elemental_affinity'] as String?,
      specialAbilities: (json['special_abilities'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      teamSynergy: json['team_synergy'] as Map<String, dynamic>,
      avatarUrl: json['avatar_url'] as String?,
      voiceType: json['voice_type'] as String?,
      isStoryCharacter: json['is_story_character'] as bool,
      unlockOrder: (json['unlock_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'profession': instance.profession,
      'rarity': instance.rarity,
      'base_level': instance.baseLevel,
      'max_level': instance.maxLevel,
      'unlock_player_level': instance.unlockPlayerLevel,
      'personality': instance.personality,
      'backstory': instance.backstory,
      'quote': instance.quote,
      'color_theme': instance.colorTheme,
      'dragon_battle_eligible': instance.dragonBattleEligible,
      'base_stats': instance.baseStats,
      'growth_rates': instance.growthRates,
      'preferred_weapon_types': instance.preferredWeaponTypes,
      'elemental_affinity': instance.elementalAffinity,
      'special_abilities': instance.specialAbilities,
      'team_synergy': instance.teamSynergy,
      'avatar_url': instance.avatarUrl,
      'voice_type': instance.voiceType,
      'is_story_character': instance.isStoryCharacter,
      'unlock_order': instance.unlockOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };

CharacterBond _$CharacterBondFromJson(Map<String, dynamic> json) =>
    CharacterBond(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      characterId: (json['character_id'] as num).toInt(),
      trustLevel: (json['trust_level'] as num).toInt(),
      friendshipLevel: (json['friendship_level'] as num).toInt(),
      totalInteractions: (json['total_interactions'] as num).toInt(),
      totalWeaponGifts: (json['total_weapon_gifts'] as num).toInt(),
      totalQuestsTogether: (json['total_quests_together'] as num).toInt(),
      totalDragonBattles: (json['total_dragon_battles'] as num).toInt(),
      currentLevel: (json['current_level'] as num).toInt(),
      currentExperience: (json['current_experience'] as num).toInt(),
      isUnlocked: json['is_unlocked'] as bool,
      isFavorited: json['is_favorited'] as bool,
      totalTrustPoints: (json['total_trust_points'] as num).toInt(),
      customNickname: json['custom_nickname'] as String?,
      conversationFlags: json['conversation_flags'] as Map<String, dynamic>,
      storyProgress: json['story_progress'] as Map<String, dynamic>,
      unlockDate: json['unlock_date'] == null
          ? null
          : DateTime.parse(json['unlock_date'] as String),
      lastInteractionAt: json['last_interaction_at'] == null
          ? null
          : DateTime.parse(json['last_interaction_at'] as String),
      lastLevelUpAt: json['last_level_up_at'] == null
          ? null
          : DateTime.parse(json['last_level_up_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CharacterBondToJson(CharacterBond instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'character_id': instance.characterId,
      'trust_level': instance.trustLevel,
      'friendship_level': instance.friendshipLevel,
      'total_interactions': instance.totalInteractions,
      'total_weapon_gifts': instance.totalWeaponGifts,
      'total_quests_together': instance.totalQuestsTogether,
      'total_dragon_battles': instance.totalDragonBattles,
      'current_level': instance.currentLevel,
      'current_experience': instance.currentExperience,
      'is_unlocked': instance.isUnlocked,
      'is_favorited': instance.isFavorited,
      'total_trust_points': instance.totalTrustPoints,
      'custom_nickname': instance.customNickname,
      'conversation_flags': instance.conversationFlags,
      'story_progress': instance.storyProgress,
      'unlock_date': instance.unlockDate?.toIso8601String(),
      'last_interaction_at': instance.lastInteractionAt?.toIso8601String(),
      'last_level_up_at': instance.lastLevelUpAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

CharacterData _$CharacterDataFromJson(Map<String, dynamic> json) =>
    CharacterData(
      character: Character.fromJson(json['character'] as Map<String, dynamic>),
      bond: json['bond'] == null
          ? null
          : CharacterBond.fromJson(json['bond'] as Map<String, dynamic>),
      isUnlocked: json['is_unlocked'] as bool,
      canUnlock: json['can_unlock'] as bool,
      unlockRequirementMet: json['unlock_requirement_met'] as bool,
    );

Map<String, dynamic> _$CharacterDataToJson(CharacterData instance) =>
    <String, dynamic>{
      'character': instance.character,
      'bond': instance.bond,
      'is_unlocked': instance.isUnlocked,
      'can_unlock': instance.canUnlock,
      'unlock_requirement_met': instance.unlockRequirementMet,
    };

CharacterListResponse _$CharacterListResponseFromJson(
        Map<String, dynamic> json) =>
    CharacterListResponse(
      characters: (json['characters'] as List<dynamic>)
          .map((e) => CharacterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      playerLevel: (json['player_level'] as num).toInt(),
      totalAvailable: (json['total_available'] as num).toInt(),
      totalUnlocked: (json['total_unlocked'] as num).toInt(),
    );

Map<String, dynamic> _$CharacterListResponseToJson(
        CharacterListResponse instance) =>
    <String, dynamic>{
      'characters': instance.characters,
      'player_level': instance.playerLevel,
      'total_available': instance.totalAvailable,
      'total_unlocked': instance.totalUnlocked,
    };

CharacterConversation _$CharacterConversationFromJson(
        Map<String, dynamic> json) =>
    CharacterConversation(
      id: json['id'] as String,
      conversationType: json['conversation_type'] as String,
      conversationText: json['conversation_text'] as String?,
      trustGained: (json['trust_gained'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CharacterConversationToJson(
        CharacterConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_type': instance.conversationType,
      'conversation_text': instance.conversationText,
      'trust_gained': instance.trustGained,
      'created_at': instance.createdAt.toIso8601String(),
    };
