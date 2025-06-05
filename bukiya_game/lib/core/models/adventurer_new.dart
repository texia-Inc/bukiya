import 'package:json_annotation/json_annotation.dart';

part 'adventurer_new.g.dart';

// 冒険者マスター
@JsonSerializable()
class AdventurerMaster {
  final int id;
  final String name;
  final String profession;
  final int level;
  final String personality;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  @JsonKey(name: 'budget_min')
  final int budgetMin;
  @JsonKey(name: 'budget_max')
  final int budgetMax;
  @JsonKey(name: 'preferred_weapon_type')
  final String preferredWeaponType;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? description;
  @JsonKey(name: 'min_attack_requirement')
  final int minAttackRequirement;
  @JsonKey(name: 'max_budget_multiplier')
  final double maxBudgetMultiplier;
  @JsonKey(name: 'urgency_tendency')
  final int urgencyTendency;
  @JsonKey(name: 'spawn_weight')
  final int spawnWeight;
  @JsonKey(name: 'min_player_level')
  final int minPlayerLevel;
  @JsonKey(name: 'max_player_level')
  final int? maxPlayerLevel;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const AdventurerMaster({
    required this.id,
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
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdventurerMaster.fromJson(Map<String, dynamic> json) =>
      _$AdventurerMasterFromJson(json);
  Map<String, dynamic> toJson() => _$AdventurerMasterToJson(this);
}

// 冒険者リクエスト
@JsonSerializable()
class AdventurerRequest {
  final String id;
  @JsonKey(name: 'adventurer_instance_id')
  final String adventurerInstanceId;
  @JsonKey(name: 'weapon_type')
  final String weaponType;
  @JsonKey(name: 'min_attack')
  final int minAttack;
  @JsonKey(name: 'max_budget')
  final int maxBudget;
  @JsonKey(name: 'preferred_rarity')
  final String? preferredRarity;
  final int urgency;
  final String? description;
  final DateTime deadline;
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

  factory AdventurerRequest.fromJson(Map<String, dynamic> json) =>
      _$AdventurerRequestFromJson(json);
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
  final String id;
  @JsonKey(name: 'adventurer_master_id')
  final int adventurerMasterId;
  @JsonKey(name: 'player_id')
  final String? playerId;
  final String name;
  final int level;
  @JsonKey(name: 'trust_level')
  final int trustLevel;
  final String status;
  @JsonKey(name: 'current_quest_id')
  final String? currentQuestId;
  @JsonKey(name: 'visit_start_time')
  final DateTime? visitStartTime;
  @JsonKey(name: 'visit_end_time')
  final DateTime? visitEndTime;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'adventurer_master')
  final AdventurerMaster? adventurerMaster;
  final List<AdventurerRequest> requests;

  const Adventurer({
    required this.id,
    required this.adventurerMasterId,
    this.playerId,
    required this.name,
    required this.level,
    required this.trustLevel,
    required this.status,
    this.currentQuestId,
    this.visitStartTime,
    this.visitEndTime,
    required this.createdAt,
    required this.updatedAt,
    this.adventurerMaster,
    this.requests = const [],
  });

  factory Adventurer.fromJson(Map<String, dynamic> json) =>
      _$AdventurerFromJson(json);
  Map<String, dynamic> toJson() => _$AdventurerToJson(this);

  // 残り滞在時間（分）
  int get remainingVisitMinutes {
    if (visitEndTime == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(visitEndTime!)) return 0;
    return visitEndTime!.difference(now).inMinutes;
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
  final int id;
  final String name;
  @JsonKey(name: 'area_type')
  final String areaType;
  final int difficulty;
  @JsonKey(name: 'required_level')
  final int requiredLevel;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'background_color')
  final String backgroundColor;
  final String? description;
  @JsonKey(name: 'unlock_condition')
  final String? unlockCondition;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const QuestArea({
    required this.id,
    required this.name,
    required this.areaType,
    required this.difficulty,
    required this.requiredLevel,
    required this.durationMinutes,
    this.imageUrl,
    required this.backgroundColor,
    this.description,
    this.unlockCondition,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestArea.fromJson(Map<String, dynamic> json) =>
      _$QuestAreaFromJson(json);
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

// クエスト報酬
@JsonSerializable()
class QuestReward {
  final String id;
  @JsonKey(name: 'adventurer_quest_id')
  final String adventurerQuestId;
  @JsonKey(name: 'item_type')
  final String itemType;
  @JsonKey(name: 'item_id')
  final String itemId;
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
    required this.quantity,
    this.buybackPrice,
    this.buybackDeadline,
    required this.isBought,
    required this.createdAt,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) =>
      _$QuestRewardFromJson(json);
  Map<String, dynamic> toJson() => _$QuestRewardToJson(this);
}

// クエスト結果
@JsonSerializable()
class QuestResult {
  final String id;
  @JsonKey(name: 'adventurer_instance_id')
  final String adventurerInstanceId;
  @JsonKey(name: 'quest_area_id')
  final int questAreaId;
  @JsonKey(name: 'player_weapon_id')
  final String? playerWeaponId;
  final String status;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final bool? success;
  @JsonKey(name: 'gold_earned')
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
  final String id;
  final String itemType;
  final String itemId;
  final String name;
  final String rarity;
  final int quantity;
  final int buybackPrice;
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