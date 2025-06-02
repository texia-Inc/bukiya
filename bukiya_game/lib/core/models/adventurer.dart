import 'package:json_annotation/json_annotation.dart';

part 'adventurer.g.dart';

@JsonSerializable()
class Adventurer {
  final String id;
  final String name;
  final String profession;
  final int level;
  final String personality;
  final int trustLevel;
  final int budget;
  final String preferredWeaponType;
  final String avatarUrl;
  final DateTime visitStartTime;
  final DateTime visitEndTime;
  final AdventurerStatus status;
  final AdventurerRequest? currentRequest;

  const Adventurer({
    required this.id,
    required this.name,
    required this.profession,
    required this.level,
    required this.personality,
    required this.trustLevel,
    required this.budget,
    required this.preferredWeaponType,
    required this.avatarUrl,
    required this.visitStartTime,
    required this.visitEndTime,
    required this.status,
    this.currentRequest,
  });

  factory Adventurer.fromJson(Map<String, dynamic> json) =>
      _$AdventurerFromJson(json);

  Map<String, dynamic> toJson() => _$AdventurerToJson(this);

  // 残り滞在時間（分）
  int get remainingVisitMinutes {
    final now = DateTime.now();
    if (now.isAfter(visitEndTime)) return 0;
    return visitEndTime.difference(now).inMinutes;
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
    switch (profession.toLowerCase()) {
      case 'warrior':
        return '⚔️';
      case 'archer':
        return '🏹';
      case 'mage':
        return '🔮';
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
    switch (personality.toLowerCase()) {
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
}

@JsonSerializable()
class AdventurerRequest {
  final String id;
  final String adventurerId;
  final String weaponType;
  final int minAttack;
  final int maxBudget;
  final String? preferredRarity;
  final int urgency; // 1-5 (5が最も緊急)
  final String description;
  final DateTime deadline;

  const AdventurerRequest({
    required this.id,
    required this.adventurerId,
    required this.weaponType,
    required this.minAttack,
    required this.maxBudget,
    this.preferredRarity,
    required this.urgency,
    required this.description,
    required this.deadline,
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

  // 緊急度の色
  String get urgencyColor {
    switch (urgency) {
      case 5:
        return '#FF0000'; // 赤
      case 4:
        return '#FF6600'; // オレンジ
      case 3:
        return '#FFCC00'; // 黄色
      case 2:
        return '#00CC00'; // 緑
      case 1:
        return '#0066CC'; // 青
      default:
        return '#FFCC00';
    }
  }

  // 残り時間（分）
  int get remainingMinutes {
    final now = DateTime.now();
    if (now.isAfter(deadline)) return 0;
    return deadline.difference(now).inMinutes;
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

@JsonSerializable()
class QuestResult {
  final String id;
  final String adventurerId;
  final String questArea;
  final bool success;
  final int goldEarned;
  final List<QuestDrop> drops;
  final DateTime completedAt;
  final DateTime buybackDeadline;

  const QuestResult({
    required this.id,
    required this.adventurerId,
    required this.questArea,
    required this.success,
    required this.goldEarned,
    required this.drops,
    required this.completedAt,
    required this.buybackDeadline,
  });

  factory QuestResult.fromJson(Map<String, dynamic> json) =>
      _$QuestResultFromJson(json);

  Map<String, dynamic> toJson() => _$QuestResultToJson(this);

  // 買取期限までの残り時間（分）
  int get remainingBuybackMinutes {
    final now = DateTime.now();
    if (now.isAfter(buybackDeadline)) return 0;
    return buybackDeadline.difference(now).inMinutes;
  }

  // 総買取価格
  int get totalBuybackPrice {
    return drops.fold(0, (sum, drop) => sum + drop.buybackPrice);
  }
}

@JsonSerializable()
class QuestDrop {
  final String id;
  final String itemType; // 'weapon' or 'material'
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

@JsonSerializable()
class QuestArea {
  final String id;
  final String name;
  final String description;
  final int requiredLevel;
  final int duration; // 分
  final int difficulty; // 1-5
  final String imageUrl;

  const QuestArea({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.duration,
    required this.difficulty,
    required this.imageUrl,
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

  // 難易度の色
  String get difficultyColor {
    switch (difficulty) {
      case 1:
        return '#00CC00'; // 緑
      case 2:
        return '#FFCC00'; // 黄色
      case 3:
        return '#FF6600'; // オレンジ
      case 4:
        return '#FF0000'; // 赤
      case 5:
        return '#9900CC'; // 紫
      default:
        return '#CCCCCC';
    }
  }
}
