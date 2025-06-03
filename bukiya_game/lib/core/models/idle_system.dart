class IdleSystem {
  final int baseIncomePerSecond;
  final int currentLevel;
  final int upgradeCount;
  final double multiplier;
  final DateTime lastCollectedAt;
  final List<IdleUpgrade> availableUpgrades;
  final List<IdleBonus> activeBonuses;

  const IdleSystem({
    required this.baseIncomePerSecond,
    required this.currentLevel,
    required this.upgradeCount,
    required this.multiplier,
    required this.lastCollectedAt,
    required this.availableUpgrades,
    required this.activeBonuses,
  });

  factory IdleSystem.fromJson(Map<String, dynamic> json) {
    return IdleSystem(
      baseIncomePerSecond: json['base_income_per_second'] ?? 1,
      currentLevel: json['current_level'] ?? 1,
      upgradeCount: json['upgrade_count'] ?? 0,
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      lastCollectedAt: DateTime.parse(json['last_collected_at'] ?? DateTime.now().toIso8601String()),
      availableUpgrades: (json['available_upgrades'] as List<dynamic>?)
          ?.map((e) => IdleUpgrade.fromJson(e))
          .toList() ?? [],
      activeBonuses: (json['active_bonuses'] as List<dynamic>?)
          ?.map((e) => IdleBonus.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_income_per_second': baseIncomePerSecond,
      'current_level': currentLevel,
      'upgrade_count': upgradeCount,
      'multiplier': multiplier,
      'last_collected_at': lastCollectedAt.toIso8601String(),
      'available_upgrades': availableUpgrades.map((e) => e.toJson()).toList(),
      'active_bonuses': activeBonuses.map((e) => e.toJson()).toList(),
    };
  }

  // 現在の1秒あたりの収益を計算
  int get currentIncomePerSecond {
    double income = baseIncomePerSecond * multiplier;
    
    // アクティブボーナスを適用
    for (final bonus in activeBonuses) {
      if (bonus.isActive) {
        income *= bonus.multiplier;
      }
    }
    
    return income.round();
  }

  // 指定時間での収益を計算
  int calculateIncome(Duration duration) {
    final seconds = duration.inSeconds;
    return currentIncomePerSecond * seconds;
  }

  // 最後の回収から現在までの収益を計算
  int get pendingIncome {
    final now = DateTime.now();
    final duration = now.difference(lastCollectedAt);
    return calculateIncome(duration);
  }

  // 次のレベルまでの必要経験値
  int get experienceToNextLevel {
    return currentLevel * 100;
  }

  // 効率性の表示用文字列
  String get efficiencyDisplay {
    return '${currentIncomePerSecond}G/秒';
  }

  // レベルアップ可能かチェック
  bool canLevelUp(int currentExperience) {
    return currentExperience >= experienceToNextLevel;
  }

  IdleSystem copyWith({
    int? baseIncomePerSecond,
    int? currentLevel,
    int? upgradeCount,
    double? multiplier,
    DateTime? lastCollectedAt,
    List<IdleUpgrade>? availableUpgrades,
    List<IdleBonus>? activeBonuses,
  }) {
    return IdleSystem(
      baseIncomePerSecond: baseIncomePerSecond ?? this.baseIncomePerSecond,
      currentLevel: currentLevel ?? this.currentLevel,
      upgradeCount: upgradeCount ?? this.upgradeCount,
      multiplier: multiplier ?? this.multiplier,
      lastCollectedAt: lastCollectedAt ?? this.lastCollectedAt,
      availableUpgrades: availableUpgrades ?? this.availableUpgrades,
      activeBonuses: activeBonuses ?? this.activeBonuses,
    );
  }
}

class IdleUpgrade {
  final String id;
  final String name;
  final String description;
  final int cost;
  final double incomeMultiplier;
  final int level;
  final int maxLevel;
  final String iconName;
  final bool isUnlocked;

  const IdleUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.incomeMultiplier,
    required this.level,
    required this.maxLevel,
    required this.iconName,
    required this.isUnlocked,
  });

  factory IdleUpgrade.fromJson(Map<String, dynamic> json) {
    return IdleUpgrade(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cost: json['cost'] ?? 0,
      incomeMultiplier: (json['income_multiplier'] ?? 1.0).toDouble(),
      level: json['level'] ?? 0,
      maxLevel: json['max_level'] ?? 10,
      iconName: json['icon_name'] ?? 'upgrade',
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'income_multiplier': incomeMultiplier,
      'level': level,
      'max_level': maxLevel,
      'icon_name': iconName,
      'is_unlocked': isUnlocked,
    };
  }

  // 次のレベルのコスト
  int get nextLevelCost {
    if (level >= maxLevel) return 0;
    return (cost * (1.5 * (level + 1))).round();
  }

  // アップグレード可能かチェック
  bool canUpgrade(int playerGold) {
    return level < maxLevel && playerGold >= nextLevelCost && isUnlocked;
  }

  // 最大レベルかチェック
  bool get isMaxLevel => level >= maxLevel;

  // 効果の説明文
  String get effectDescription {
    final percentage = ((incomeMultiplier - 1) * 100).round();
    return '収益 +${percentage}%';
  }

  IdleUpgrade copyWith({
    String? id,
    String? name,
    String? description,
    int? cost,
    double? incomeMultiplier,
    int? level,
    int? maxLevel,
    String? iconName,
    bool? isUnlocked,
  }) {
    return IdleUpgrade(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      incomeMultiplier: incomeMultiplier ?? this.incomeMultiplier,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      iconName: iconName ?? this.iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class IdleBonus {
  final String id;
  final String name;
  final String description;
  final double multiplier;
  final DateTime startTime;
  final Duration duration;
  final String iconName;
  final BonusType type;

  const IdleBonus({
    required this.id,
    required this.name,
    required this.description,
    required this.multiplier,
    required this.startTime,
    required this.duration,
    required this.iconName,
    required this.type,
  });

  factory IdleBonus.fromJson(Map<String, dynamic> json) {
    return IdleBonus(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      duration: Duration(seconds: json['duration_seconds'] ?? 0),
      iconName: json['icon_name'] ?? 'bonus',
      type: BonusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BonusType.income,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'multiplier': multiplier,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'icon_name': iconName,
      'type': type.name,
    };
  }

  // ボーナスがアクティブかチェック
  bool get isActive {
    final now = DateTime.now();
    final endTime = startTime.add(duration);
    return now.isBefore(endTime);
  }

  // 残り時間
  Duration get remainingTime {
    if (!isActive) return Duration.zero;
    final now = DateTime.now();
    final endTime = startTime.add(duration);
    return endTime.difference(now);
  }

  // 残り時間の表示用文字列
  String get remainingTimeDisplay {
    final remaining = remainingTime;
    if (remaining.inHours > 0) {
      return '${remaining.inHours}時間${remaining.inMinutes % 60}分';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}分${remaining.inSeconds % 60}秒';
    } else {
      return '${remaining.inSeconds}秒';
    }
  }

  // 効果の説明文
  String get effectDescription {
    final percentage = ((multiplier - 1) * 100).round();
    switch (type) {
      case BonusType.income:
        return '収益 +${percentage}%';
      case BonusType.experience:
        return '経験値 +${percentage}%';
      case BonusType.crafting:
        return '錬成効率 +${percentage}%';
    }
  }
}

enum BonusType {
  income,
  experience,
  crafting,
}

// 放置システムの結果
class IdleCollectionResult {
  final int goldEarned;
  final int experienceGained;
  final Duration offlineTime;
  final List<String> bonusesExpired;
  final bool leveledUp;
  final int newLevel;

  const IdleCollectionResult({
    required this.goldEarned,
    required this.experienceGained,
    required this.offlineTime,
    required this.bonusesExpired,
    required this.leveledUp,
    required this.newLevel,
  });

  factory IdleCollectionResult.fromJson(Map<String, dynamic> json) {
    return IdleCollectionResult(
      goldEarned: json['gold_earned'] ?? 0,
      experienceGained: json['experience_gained'] ?? 0,
      offlineTime: Duration(seconds: json['offline_time_seconds'] ?? 0),
      bonusesExpired: List<String>.from(json['bonuses_expired'] ?? []),
      leveledUp: json['leveled_up'] ?? false,
      newLevel: json['new_level'] ?? 1,
    );
  }

  // オフライン時間の表示用文字列
  String get offlineTimeDisplay {
    if (offlineTime.inDays > 0) {
      return '${offlineTime.inDays}日${offlineTime.inHours % 24}時間';
    } else if (offlineTime.inHours > 0) {
      return '${offlineTime.inHours}時間${offlineTime.inMinutes % 60}分';
    } else if (offlineTime.inMinutes > 0) {
      return '${offlineTime.inMinutes}分${offlineTime.inSeconds % 60}秒';
    } else {
      return '${offlineTime.inSeconds}秒';
    }
  }
}

// アップグレード結果
class UpgradeResult {
  final bool success;
  final String message;
  final IdleUpgrade? upgradedItem;
  final int newGoldAmount;
  final double newMultiplier;

  const UpgradeResult({
    required this.success,
    required this.message,
    this.upgradedItem,
    required this.newGoldAmount,
    required this.newMultiplier,
  });

  factory UpgradeResult.fromJson(Map<String, dynamic> json) {
    return UpgradeResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      upgradedItem: json['upgraded_item'] != null 
          ? IdleUpgrade.fromJson(json['upgraded_item'])
          : null,
      newGoldAmount: json['new_gold_amount'] ?? 0,
      newMultiplier: (json['new_multiplier'] ?? 1.0).toDouble(),
    );
  }
}
