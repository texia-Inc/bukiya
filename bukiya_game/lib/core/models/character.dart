import 'package:json_annotation/json_annotation.dart';

part 'character.g.dart';

@JsonSerializable()
class Character {
  final int id;
  final String name;
  final String? title;
  final String profession;
  final String rarity;
  @JsonKey(name: 'base_level')
  final int baseLevel;
  @JsonKey(name: 'max_level')
  final int maxLevel;
  @JsonKey(name: 'unlock_player_level')
  final int unlockPlayerLevel;
  final String personality;
  final String? backstory;
  final String? quote;
  @JsonKey(name: 'color_theme')
  final String colorTheme;
  @JsonKey(name: 'dragon_battle_eligible')
  final bool dragonBattleEligible;
  @JsonKey(name: 'base_stats')
  final Map<String, dynamic> baseStats;
  @JsonKey(name: 'growth_rates')
  final Map<String, dynamic> growthRates;
  @JsonKey(name: 'preferred_weapon_types')
  final List<String> preferredWeaponTypes;
  @JsonKey(name: 'elemental_affinity')
  final String? elementalAffinity;
  @JsonKey(name: 'special_abilities')
  final List<Map<String, dynamic>> specialAbilities;
  @JsonKey(name: 'team_synergy')
  final Map<String, dynamic> teamSynergy;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'voice_type')
  final String? voiceType;
  @JsonKey(name: 'is_story_character')
  final bool isStoryCharacter;
  @JsonKey(name: 'unlock_order')
  final int unlockOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Character({
    required this.id,
    required this.name,
    this.title,
    required this.profession,
    required this.rarity,
    required this.baseLevel,
    required this.maxLevel,
    required this.unlockPlayerLevel,
    required this.personality,
    this.backstory,
    this.quote,
    required this.colorTheme,
    required this.dragonBattleEligible,
    required this.baseStats,
    required this.growthRates,
    required this.preferredWeaponTypes,
    this.elementalAffinity,
    required this.specialAbilities,
    required this.teamSynergy,
    this.avatarUrl,
    this.voiceType,
    required this.isStoryCharacter,
    required this.unlockOrder,
    required this.createdAt,
  });

  factory Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterToJson(this);

  // 表示用の名前
  String get displayName => title != null ? '$title $name' : name;

  // レア度の色を取得
  String get rarityColor {
    switch (rarity) {
      case 'common':
        return '#9E9E9E';
      case 'uncommon':
        return '#4CAF50';
      case 'rare':
        return '#2196F3';
      case 'epic':
        return '#9C27B0';
      case 'legendary':
        return '#FF9800';
      default:
        return '#9E9E9E';
    }
  }

  // 職業の日本語名
  String get professionName {
    switch (profession) {
      case 'warrior':
        return '戦士';
      case 'archer':
        return '弓使い';
      case 'mage':
        return '魔法使い';
      case 'rogue':
        return '盗賊';
      case 'priest':
        return '僧侶';
      default:
        return profession;
    }
  }

  // レア度の日本語名
  String get rarityName {
    switch (rarity) {
      case 'common':
        return 'コモン';
      case 'uncommon':
        return 'アンコモン';
      case 'rare':
        return 'レア';
      case 'epic':
        return 'エピック';
      case 'legendary':
        return 'レジェンダリー';
      default:
        return rarity;
    }
  }
}

@JsonSerializable()
class CharacterBond {
  final String id;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'character_id')
  final int characterId;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'friendship_level')
  final int friendshipLevel;
  @JsonKey(name: 'total_interactions')
  final int totalInteractions;
  @JsonKey(name: 'total_weapon_gifts')
  final int totalWeaponGifts;
  @JsonKey(name: 'total_quests_together')
  final int totalQuestsTogether;
  @JsonKey(name: 'total_dragon_battles')
  final int totalDragonBattles;
  @JsonKey(name: 'current_level')
  final int currentLevel;
  @JsonKey(name: 'current_experience')
  final int currentExperience;
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @JsonKey(name: 'is_favorited')
  final bool isFavorited;
  @JsonKey(name: 'total_trust_points')
  final int totalTrustPoints;
  @JsonKey(name: 'custom_nickname')
  final String? customNickname;
  @JsonKey(name: 'conversation_flags')
  final Map<String, dynamic> conversationFlags;
  @JsonKey(name: 'story_progress')
  final Map<String, dynamic> storyProgress;
  @JsonKey(name: 'unlock_date')
  final DateTime? unlockDate;
  @JsonKey(name: 'last_interaction_at')
  final DateTime? lastInteractionAt;
  @JsonKey(name: 'last_level_up_at')
  final DateTime? lastLevelUpAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  CharacterBond({
    required this.id,
    required this.playerId,
    required this.characterId,
    required this.trustLevel,
    required this.friendshipLevel,
    required this.totalInteractions,
    required this.totalWeaponGifts,
    required this.totalQuestsTogether,
    required this.totalDragonBattles,
    required this.currentLevel,
    required this.currentExperience,
    required this.isUnlocked,
    required this.isFavorited,
    required this.totalTrustPoints,
    this.customNickname,
    required this.conversationFlags,
    required this.storyProgress,
    this.unlockDate,
    this.lastInteractionAt,
    this.lastLevelUpAt,
    required this.createdAt,
  });

  factory CharacterBond.fromJson(Map<String, dynamic> json) => _$CharacterBondFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterBondToJson(this);

  // 信頼度レベルの名前
  String get trustLevelName {
    if (trustLevel >= 80) return 'パートナー';
    if (trustLevel >= 60) return '信頼';
    if (trustLevel >= 40) return '友人';
    if (trustLevel >= 20) return '知人';
    return '初対面';
  }

  // 龍戦に参加可能か
  bool get canParticipateInDragonBattle => trustLevel >= 80;
}

@JsonSerializable()
class CharacterData {
  final Character character;
  final CharacterBond? bond;
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @JsonKey(name: 'can_unlock')
  final bool canUnlock;
  @JsonKey(name: 'unlock_requirement_met')
  final bool unlockRequirementMet;

  CharacterData({
    required this.character,
    this.bond,
    required this.isUnlocked,
    required this.canUnlock,
    required this.unlockRequirementMet,
  });

  factory CharacterData.fromJson(Map<String, dynamic> json) => _$CharacterDataFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterDataToJson(this);
}

@JsonSerializable()
class CharacterListResponse {
  final List<CharacterData> characters;
  @JsonKey(name: 'player_level')
  final int playerLevel;
  @JsonKey(name: 'total_available')
  final int totalAvailable;
  @JsonKey(name: 'total_unlocked')
  final int totalUnlocked;

  CharacterListResponse({
    required this.characters,
    required this.playerLevel,
    required this.totalAvailable,
    required this.totalUnlocked,
  });

  factory CharacterListResponse.fromJson(Map<String, dynamic> json) => _$CharacterListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterListResponseToJson(this);
}

// 交流履歴
@JsonSerializable()
class CharacterConversation {
  final String id;
  @JsonKey(name: 'conversation_type')
  final String conversationType;
  @JsonKey(name: 'conversation_text')
  final String? conversationText;
  @JsonKey(name: 'trust_gained')
  final int trustGained;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  CharacterConversation({
    required this.id,
    required this.conversationType,
    this.conversationText,
    required this.trustGained,
    required this.createdAt,
  });

  factory CharacterConversation.fromJson(Map<String, dynamic> json) => _$CharacterConversationFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterConversationToJson(this);

  // 交流タイプの日本語名
  String get interactionTypeName {
    switch (conversationType) {
      case 'greeting':
        return '挨拶';
      case 'weapon_gift':
        return '武器プレゼント';
      case 'conversation':
        return '会話';
      case 'quest_together':
        return '共同クエスト';
      case 'dragon_battle':
        return '龍戦';
      default:
        return conversationType;
    }
  }
}