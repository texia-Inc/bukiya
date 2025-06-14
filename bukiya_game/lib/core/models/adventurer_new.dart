import 'package:json_annotation/json_annotation.dart';

part 'adventurer_new.g.dart';

// 冒険者マスター
@JsonSerializable()
class AdventurerMaster {
  @JsonKey()
  final String? id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String profession;
  @JsonKey(defaultValue: 1)
  final int level;
  @JsonKey(defaultValue: '')
  final String personality;
  @JsonKey(name: 'trust_level', defaultValue: 50)
  final int trustLevel;
  @JsonKey(name: 'budget_min', defaultValue: 500)
  final int budgetMin;
  @JsonKey(name: 'budget_max', defaultValue: 2000)
  final int budgetMax;
  @JsonKey(name: 'preferred_weapon_type', defaultValue: '')
  final String preferredWeaponType;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? description;
  @JsonKey(name: 'min_attack_requirement', defaultValue: 100)
  final int minAttackRequirement;
  @JsonKey(name: 'max_budget_multiplier', defaultValue: 1.0)
  final double maxBudgetMultiplier;
  @JsonKey(name: 'urgency_tendency', defaultValue: 3)
  final int urgencyTendency;
  @JsonKey(name: 'spawn_weight', defaultValue: 100)
  final int spawnWeight;
  @JsonKey(name: 'min_player_level', defaultValue: 1)
  final int minPlayerLevel;
  @JsonKey(name: 'max_player_level')
  final int? maxPlayerLevel;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const AdventurerMaster({
    this.id,
    required this.name,
    required this.profession,
    required this.level,
    required this.personality,
    required this.trustLevel,
    required this.budgetMin,
    required this.budgetMax,
    required this.preferredWeaponType,
    this.avatarUrl,
    this.description,
    required this.minAttackRequirement,
    required this.maxBudgetMultiplier,
    required this.urgencyTendency,
    required this.spawnWeight,
    required this.minPlayerLevel,
    this.maxPlayerLevel,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AdventurerMaster.fromJson(Map<String, dynamic> json) {
    // idがintの場合はStringに変換
    if (json['id'] != null && json['id'] is int) {
      json['id'] = json['id'].toString();
    }
    return _$AdventurerMasterFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AdventurerMasterToJson(this);
}

// 冒険者リクエスト
@JsonSerializable()
class AdventurerRequest {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(name: 'adventurer_instance_id', defaultValue: '')
  final String adventurerInstanceId;
  @JsonKey(name: 'weapon_type', defaultValue: '')
  final String weaponType;
  @JsonKey(name: 'min_attack', defaultValue: 100)
  final int minAttack;
  @JsonKey(name: 'max_budget', defaultValue: 1000)
  final int maxBudget;
  @JsonKey(name: 'preferred_rarity')
  final String? preferredRarity;
  @JsonKey(defaultValue: 3)
  final int urgency;
  final String? description;
  final DateTime deadline;
  @JsonKey(defaultValue: 'pending')
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AdventurerRequest({
    required this.id,
    required this.adventurerInstanceId,
    required this.weaponType,
    required this.minAttack,
    required this.maxBudget,
    this.preferredRarity,
    required this.urgency,
    this.description,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdventurerRequest.fromJson(Map<String, dynamic> json) => _$AdventurerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AdventurerRequestToJson(this);

  // 緊急度の表示名
  String get urgencyName {
    switch (urgency) {
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

  // 残り時間（分）
  int get remainingMinutes {
    final now = DateTime.now();
    if (now.isAfter(deadline)) return 0;
    return deadline.difference(now).inMinutes;
  }
}

// 冒険者インスタンス
@JsonSerializable()
class Adventurer {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(name: 'adventurer_master_id')
  final String? adventurerMasterId;
  @JsonKey(name: 'player_id')
  final String? playerId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 1)
  final int level;
  @JsonKey(name: 'trust_level', defaultValue: 50)
  final int trustLevel;
  @JsonKey(defaultValue: 'visiting')
  final String status;
  @JsonKey(name: 'current_quest_id')
  final String? currentQuestId;
  @JsonKey(name: 'visit_start_time')
  final DateTime? visitStartTime;
  @JsonKey(name: 'visit_end_time')
  final DateTime? visitEndTime;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'adventurer_master')
  final AdventurerMaster? adventurerMaster;
  final List<AdventurerRequest> requests;
  @JsonKey(name: 'current_quest')
  final QuestProgress? currentQuest;
  
  // 固有キャラクターシステム
  @JsonKey(name: 'is_named_character', defaultValue: false)
  final bool isNamedCharacter;
  @JsonKey(name: 'character_id')
  final int? characterId;
  @JsonKey(name: 'generic_name')
  final String? genericName;

  const Adventurer({
    required this.id,
    this.adventurerMasterId,
    this.playerId,
    required this.name,
    required this.level,
    required this.trustLevel,
    required this.status,
    this.currentQuestId,
    this.visitStartTime,
    this.visitEndTime,
    this.createdAt,
    this.updatedAt,
    this.adventurerMaster,
    this.requests = const [],
    this.currentQuest,
    required this.isNamedCharacter,
    this.characterId,
    this.genericName,
  });

  factory Adventurer.fromJson(Map<String, dynamic> json) {
    // adventurer_master_idを安全に変換
    if (json['adventurer_master_id'] != null && json['adventurer_master_id'] is int) {
      json['adventurer_master_id'] = json['adventurer_master_id'].toString();
    }
    return _$AdventurerFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AdventurerToJson(this);

  // 残り滞在時間（分）
  int get remainingVisitMinutes {
    if (visitEndTime == null) {
      // 新しく訪問した冒険者の場合、デフォルトで60分間の滞在時間を想定
      return 0; // UIでは「出発準備中」と表示される
    }
    
    // UTC時間として扱う
    final now = DateTime.now().toUtc();
    final endTime = visitEndTime!.toUtc();
    
    if (now.isAfter(endTime)) {
      return 0; // UIでは「出発準備中」と表示される
    }
    
    final remaining = endTime.difference(now).inMinutes;
    
    // 1分未満の場合は1分として表示
    return remaining > 0 ? remaining : 1;
  }

  // 信頼レベルの表示名
  String get trustLevelName {
    if (trustLevel >= 80) return '親友';
    if (trustLevel >= 60) return '信頼';
    if (trustLevel >= 40) return '普通';
    if (trustLevel >= 20) return '警戒';
    return '不信';
  }

  // 職業アイコン
  String get professionIcon {
    if (adventurerMaster == null) return '👤';
    switch (adventurerMaster!.profession.toLowerCase()) {
      case 'warrior':
        return '⚔️';
      case 'archer':
        return '🏹';
      case 'mage':
        return '🔮';
      case 'thief':
      case 'rogue':
        return '🗡️';
      case 'paladin':
        return '🛡️';
      default:
        return '👤';
    }
  }

  // 性格による価格交渉倍率
  double get negotiationMultiplier {
    if (adventurerMaster == null) return 1.0;
    switch (adventurerMaster!.personality.toLowerCase()) {
      case 'generous':
        return 1.2; // 気前が良い
      case 'normal':
        return 1.0; // 普通
      case 'stingy':
        return 0.8; // けち
      case 'wealthy':
        return 1.5; // 裕福
      case 'poor':
        return 0.6; // 貧乏
      default:
        return 1.0;
    }
  }

  // 予算
  int get budget => adventurerMaster?.budgetMax ?? 1000;

  // 好きな武器タイプ
  String get preferredWeaponType => adventurerMaster?.preferredWeaponType ?? '';

  // 職業
  String get profession => adventurerMaster?.profession ?? '';

  // 性格
  String get personality => adventurerMaster?.personality ?? '';

  // 現在のリクエスト
  AdventurerRequest? get currentRequest => 
      requests.where((r) => r.status == 'pending').isNotEmpty 
          ? requests.where((r) => r.status == 'pending').first 
          : null;

  // AdventurerStatusに変換
  AdventurerStatus get adventurerStatus {
    switch (status) {
      case 'visiting':
        return AdventurerStatus.visiting;
      case 'on_quest':
        return AdventurerStatus.onQuest;
      case 'returning':
        return AdventurerStatus.returning;
      case 'completed':
        return AdventurerStatus.completed;
      case 'left':
        return AdventurerStatus.left;
      default:
        return AdventurerStatus.visiting;
    }
  }
}

enum AdventurerStatus {
  @JsonValue('visiting')
  visiting, // 店舗訪問中

  @JsonValue('on_quest')
  onQuest, // 冒険中

  @JsonValue('returning')
  returning, // 帰還中（買取案件あり）

  @JsonValue('completed')
  completed, // 取引完了

  @JsonValue('left')
  left, // 立ち去った
}

// クエストエリア
@JsonSerializable()
class QuestArea {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'area_type', defaultValue: '')
  final String areaType;
  @JsonKey(defaultValue: 1)
  final int difficulty;
  @JsonKey(name: 'required_level', defaultValue: 1)
  final int? requiredLevel;
  @JsonKey(name: 'duration_minutes', defaultValue: 60)
  final int durationMinutes;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'background_color', defaultValue: '#4CAF50')
  final String backgroundColor;
  final String? description;
  @JsonKey(name: 'unlock_condition')
  final String? unlockCondition;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool? isActive;
  @JsonKey(name: 'display_order', defaultValue: 1)
  final int? displayOrder;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const QuestArea({
    required this.id,
    required this.name,
    required this.areaType,
    required this.difficulty,
    this.requiredLevel,
    required this.durationMinutes,
    this.imageUrl,
    required this.backgroundColor,
    this.description,
    this.unlockCondition,
    this.isActive,
    this.displayOrder,
    this.createdAt,
    this.updatedAt,
  });

  factory QuestArea.fromJson(Map<String, dynamic> json) => _$QuestAreaFromJson(json);
  Map<String, dynamic> toJson() => _$QuestAreaToJson(this);

  // 難易度の表示名
  String get difficultyName {
    switch (difficulty) {
      case 1:
        return '初級';
      case 2:
        return '中級';
      case 3:
        return '上級';
      case 4:
        return '特級';
      case 5:
        return '神話級';
      default:
        return '不明';
    }
  }

  // 継続時間（分）
  int get duration => durationMinutes;

  // 画像URL（互換性のため）
  String get imageUrlCompat => imageUrl ?? '';
}

// クエスト進捗詳細情報
@JsonSerializable()
class QuestProgress {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: 'in_progress')
  final String status;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @JsonKey(name: 'progress_percentage', defaultValue: 0.0)
  final double progressPercentage;
  @JsonKey(name: 'remaining_time')
  final RemainingTime remainingTime;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'quest_area')
  final QuestArea questArea;
  @JsonKey(name: 'weapon_used')
  final WeaponUsed weaponUsed;
  @JsonKey(name: 'monster_fighting')
  final MonsterFighting? monsterFighting;

  const QuestProgress({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.progressPercentage,
    required this.remainingTime,
    required this.isCompleted,
    required this.questArea,
    required this.weaponUsed,
    this.monsterFighting,
  });

  factory QuestProgress.fromJson(Map<String, dynamic> json) => _$QuestProgressFromJson(json);
  Map<String, dynamic> toJson() => _$QuestProgressToJson(this);

  // 進捗状況の表示テキスト
  String get progressText {
    if (isCompleted) return '完了';
    return '${progressPercentage.toStringAsFixed(1)}%';
  }

  // 残り時間の表示テキスト
  String get remainingTimeText {
    if (isCompleted) return '完了';
    if (remainingTime.hours > 0) {
      return '${remainingTime.hours}時間${remainingTime.minutes}分';
    } else {
      return '${remainingTime.minutes}分';
    }
  }
}

// 残り時間情報
@JsonSerializable()
class RemainingTime {
  @JsonKey(defaultValue: 0)
  final int hours;
  @JsonKey(defaultValue: 0)
  final int minutes;
  @JsonKey(name: 'total_minutes', defaultValue: 0)
  final int totalMinutes;

  const RemainingTime({
    required this.hours,
    required this.minutes,
    required this.totalMinutes,
  });

  factory RemainingTime.fromJson(Map<String, dynamic> json) => _$RemainingTimeFromJson(json);
  Map<String, dynamic> toJson() => _$RemainingTimeToJson(this);
}

// 戦闘中モンスター情報
@JsonSerializable()
class MonsterFighting {
  @JsonKey(defaultValue: 0)
  final int? id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 1)
  final int level;
  @JsonKey(name: 'monster_type', defaultValue: '')
  final String monsterType;
  @JsonKey(defaultValue: 100)
  final int hp;
  @JsonKey(defaultValue: 20)
  final int attack;
  @JsonKey(defaultValue: 10)
  final int defense;
  @JsonKey(defaultValue: '')
  final String? element;
  @JsonKey(defaultValue: '')
  final String description;

  const MonsterFighting({
    this.id,
    required this.name,
    required this.level,
    required this.monsterType,
    required this.hp,
    required this.attack,
    required this.defense,
    this.element,
    required this.description,
  });

  factory MonsterFighting.fromJson(Map<String, dynamic> json) {
    // idがintの場合は変換する必要はない（idは既にint?として定義されている）
    return _$MonsterFightingFromJson(json);
  }
  Map<String, dynamic> toJson() => _$MonsterFightingToJson(this);

  // モンスタータイプの表示名
  String get typeDisplayName {
    switch (monsterType.toLowerCase()) {
      case 'beast':
        return '野獣';
      case 'humanoid':
        return '人型';
      case 'undead':
        return 'アンデッド';
      case 'elemental':
        return '精霊';
      case 'dragon':
        return 'ドラゴン';
      case 'machine':
        return '機械';
      case 'flying':
        return '飛行';
      default:
        return 'モンスター';
    }
  }

  // 属性の表示名
  String get elementDisplayName {
    if (element == null || element!.isEmpty) return '';
    switch (element!.toLowerCase()) {
      case 'fire':
        return '火';
      case 'water':
        return '水';
      case 'earth':
        return '土';
      case 'wind':
        return '風';
      case 'lightning':
        return '雷';
      case 'ice':
        return '氷';
      case 'light':
        return '光';
      case 'dark':
        return '闇';
      case 'poison':
        return '毒';
      default:
        return element!;
    }
  }
}

// 使用武器情報
@JsonSerializable()
class WeaponUsed {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 100)
  final int attack;
  @JsonKey(name: 'enchant_level', defaultValue: 0)
  final int enchantLevel;
  @JsonKey(name: 'weapon_type', defaultValue: '')
  final String weaponType;
  @JsonKey(name: 'display_name', defaultValue: '')
  final String displayName;

  const WeaponUsed({
    required this.id,
    required this.name,
    required this.attack,
    required this.enchantLevel,
    required this.weaponType,
    required this.displayName,
  });

  factory WeaponUsed.fromJson(Map<String, dynamic> json) => _$WeaponUsedFromJson(json);
  Map<String, dynamic> toJson() => _$WeaponUsedToJson(this);

  // エンチャントレベル表示
  String get enchantText {
    if (enchantLevel > 0) {
      return '+$enchantLevel';
    }
    return '';
  }

  // 完全な武器名
  String get fullDisplayName {
    String result = displayName;
    if (enchantLevel > 0) {
      result += ' +$enchantLevel';
    }
    return result;
  }
}

// クエスト報酬
@JsonSerializable()
class QuestReward {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(name: 'adventurer_quest_id', defaultValue: '')
  final String adventurerQuestId;
  @JsonKey(name: 'item_type', defaultValue: '')
  final String itemType;
  @JsonKey(name: 'item_id', defaultValue: '')
  final String itemId;
  @JsonKey(name: 'item_name', defaultValue: '')
  final String itemName;
  @JsonKey(defaultValue: 1)
  final int quantity;
  @JsonKey(name: 'buyback_price')
  final int? buybackPrice;
  @JsonKey(name: 'buyback_deadline')
  final DateTime? buybackDeadline;
  @JsonKey(name: 'is_bought')
  final bool isBought;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const QuestReward({
    required this.id,
    required this.adventurerQuestId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    this.buybackPrice,
    this.buybackDeadline,
    required this.isBought,
    required this.createdAt,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) {
    // item_idがintの場合はStringに変換、nullの場合は空文字に
    if (json['item_id'] != null && json['item_id'] is int) {
      json['item_id'] = json['item_id'].toString();
    } else if (json['item_id'] == null) {
      json['item_id'] = '';
    }
    return _$QuestRewardFromJson(json);
  }
  Map<String, dynamic> toJson() => _$QuestRewardToJson(this);
}

// クエスト結果
@JsonSerializable()
class QuestResult {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(name: 'adventurer_instance_id', defaultValue: '')
  final String adventurerInstanceId;
  @JsonKey(name: 'quest_area_id', defaultValue: 0)
  final int questAreaId;
  @JsonKey(name: 'player_weapon_id')
  final String? playerWeaponId;
  @JsonKey(defaultValue: 'pending')
  final String status;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final bool? success;
  @JsonKey(name: 'gold_earned', defaultValue: 0)
  final int goldEarned;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'quest_area')
  final QuestArea? questArea;
  final List<QuestReward> rewards;

  const QuestResult({
    required this.id,
    required this.adventurerInstanceId,
    required this.questAreaId,
    this.playerWeaponId,
    required this.status,
    required this.startTime,
    this.endTime,
    this.success,
    required this.goldEarned,
    required this.createdAt,
    required this.updatedAt,
    this.questArea,
    this.rewards = const [],
  });

  factory QuestResult.fromJson(Map<String, dynamic> json) =>
      _$QuestResultFromJson(json);
  Map<String, dynamic> toJson() => _$QuestResultToJson(this);

  // 買取期限までの残り時間（分）
  int get remainingBuybackMinutes {
    final validRewards = rewards.where((r) => !r.isBought && r.buybackDeadline != null);
    if (validRewards.isEmpty) return 0;
    
    final earliestDeadline = validRewards
        .map((r) => r.buybackDeadline!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    
    final now = DateTime.now();
    if (now.isAfter(earliestDeadline)) return 0;
    return earliestDeadline.difference(now).inMinutes;
  }

  // 総買取価格
  int get totalBuybackPrice {
    return rewards
        .where((r) => !r.isBought && r.buybackPrice != null)
        .fold(0, (sum, r) => sum + r.buybackPrice!);
  }

  // 冒険エリア名
  String get questAreaName => questArea?.name ?? '';

  // 互換性のため（旧モデル）
  String get adventurerId => adventurerInstanceId;
  String get questAreaCompat => questAreaName;
  DateTime get completedAt => endTime ?? updatedAt;
  DateTime? get buybackDeadline => 
      rewards.where((r) => !r.isBought && r.buybackDeadline != null).isNotEmpty
          ? rewards.where((r) => !r.isBought && r.buybackDeadline != null).first.buybackDeadline
          : null;
  
  List<QuestDrop> get drops => rewards.map((r) => QuestDrop(
    id: r.id,
    itemType: r.itemType,
    itemId: r.itemId,
    name: r.itemId, // 仮で itemId を使用
    rarity: 'common', // 仮の値
    quantity: r.quantity,
    buybackPrice: r.buybackPrice ?? 0,
    description: '',
  )).toList();
}

// 互換性のための QuestDrop
@JsonSerializable()
class QuestDrop {
  @JsonKey(defaultValue: '')
  final String id;
  @JsonKey(defaultValue: '')
  final String itemType;
  @JsonKey(defaultValue: '')
  final String itemId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 'common')
  final String rarity;
  @JsonKey(defaultValue: 1)
  final int quantity;
  @JsonKey(defaultValue: 0)
  final int buybackPrice;
  @JsonKey(defaultValue: '')
  final String description;

  const QuestDrop({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.name,
    required this.rarity,
    required this.quantity,
    required this.buybackPrice,
    required this.description,
  });

  factory QuestDrop.fromJson(Map<String, dynamic> json) =>
      _$QuestDropFromJson(json);
  Map<String, dynamic> toJson() => _$QuestDropToJson(this);
}