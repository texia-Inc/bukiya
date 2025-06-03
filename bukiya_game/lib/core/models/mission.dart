class Mission {
  final int id;
  final String name;
  final String description;
  final MissionType missionType;
  final String targetType;
  final int targetCount;
  final int currentProgress;
  final Map<String, dynamic>? targetConditions;
  final int rewardGold;
  final int rewardExp;
  final Map<String, dynamic>? rewardItems;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? completedAt;

  Mission({
    required this.id,
    required this.name,
    required this.description,
    required this.missionType,
    required this.targetType,
    required this.targetCount,
    required this.currentProgress,
    this.targetConditions,
    required this.rewardGold,
    required this.rewardExp,
    this.rewardItems,
    required this.isCompleted,
    required this.isClaimed,
    this.expiresAt,
    required this.createdAt,
    this.completedAt,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      missionType: MissionType.fromString(json['mission_type']),
      targetType: json['target_type'],
      targetCount: json['target_count'],
      currentProgress: json['current_progress'] ?? 0,
      targetConditions: json['target_conditions'],
      rewardGold: json['reward_gold'],
      rewardExp: json['reward_exp'],
      rewardItems: json['reward_items'],
      isCompleted: json['is_completed'] ?? false,
      isClaimed: json['is_claimed'] ?? false,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mission_type': missionType.value,
      'target_type': targetType,
      'target_count': targetCount,
      'current_progress': currentProgress,
      'target_conditions': targetConditions,
      'reward_gold': rewardGold,
      'reward_exp': rewardExp,
      'reward_items': rewardItems,
      'is_completed': isCompleted,
      'is_claimed': isClaimed,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Mission copyWith({
    int? id,
    String? name,
    String? description,
    MissionType? missionType,
    String? targetType,
    int? targetCount,
    int? currentProgress,
    Map<String, dynamic>? targetConditions,
    int? rewardGold,
    int? rewardExp,
    Map<String, dynamic>? rewardItems,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Mission(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      missionType: missionType ?? this.missionType,
      targetType: targetType ?? this.targetType,
      targetCount: targetCount ?? this.targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      targetConditions: targetConditions ?? this.targetConditions,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardExp: rewardExp ?? this.rewardExp,
      rewardItems: rewardItems ?? this.rewardItems,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // 進捗率を計算
  double get progressPercentage {
    if (targetCount == 0) return 0.0;
    return (currentProgress / targetCount).clamp(0.0, 1.0);
  }

  // 残り時間を取得（デイリー・ウィークリーミッション用）
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  // 期限切れかどうか
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // 報酬受取可能かどうか
  bool get canClaimReward {
    return isCompleted && !isClaimed && !isExpired;
  }

  // ターゲットタイプの表示名を取得
  String get targetTypeDisplayName {
    switch (targetType) {
      case 'craft_weapon':
        return '武器作成';
      case 'sell_weapon':
        return '武器販売';
      case 'collect_material':
        return '素材収集';
      case 'dispatch_adventurer':
        return '冒険派遣';
      case 'login':
        return 'ログイン';
      case 'earn_gold':
        return 'ゴールド獲得';
      case 'upgrade_shop':
        return 'ショップアップグレード';
      default:
        return targetType;
    }
  }
}

enum MissionType {
  daily('daily', 'デイリー'),
  weekly('weekly', 'ウィークリー'),
  achievement('achievement', 'アチーブメント');

  const MissionType(this.value, this.displayName);

  final String value;
  final String displayName;

  static MissionType fromString(String value) {
    switch (value) {
      case 'daily':
        return MissionType.daily;
      case 'weekly':
        return MissionType.weekly;
      case 'achievement':
        return MissionType.achievement;
      default:
        throw ArgumentError('Unknown mission type: $value');
    }
  }
}

class MissionReward {
  final int gold;
  final int exp;
  final Map<String, dynamic>? items;

  MissionReward({
    required this.gold,
    required this.exp,
    this.items,
  });

  factory MissionReward.fromJson(Map<String, dynamic> json) {
    return MissionReward(
      gold: json['gold'] ?? 0,
      exp: json['exp'] ?? 0,
      items: json['items'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'exp': exp,
      'items': items,
    };
  }

  // 報酬の説明文を生成
  String get description {
    List<String> rewards = [];
    
    if (gold > 0) {
      rewards.add('${gold.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
        (Match m) => '${m[1]},'
      )}G');
    }
    
    if (exp > 0) {
      rewards.add('経験値$exp');
    }
    
    if (items != null && items!.isNotEmpty) {
      items!.forEach((key, value) {
        rewards.add('$key x$value');
      });
    }
    
    return rewards.join(' + ');
  }
}
