class Mission {
  final int id;
  final String playerId;
  final int missionTemplateId;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;
  final double progressPercentage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime? expiresAt;
  final MissionTemplate missionTemplate;
  final bool canClaimReward;
  final bool isReadyToComplete;

  Mission({
    required this.id,
    required this.playerId,
    required this.missionTemplateId,
    required this.currentProgress,
    required this.isCompleted,
    required this.isClaimed,
    required this.progressPercentage,
    required this.createdAt,
    this.completedAt,
    this.claimedAt,
    this.expiresAt,
    required this.missionTemplate,
    required this.canClaimReward,
    required this.isReadyToComplete,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      playerId: json['player_id'],
      missionTemplateId: json['mission_template_id'],
      currentProgress: json['current_progress'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      isClaimed: json['is_claimed'] ?? false,
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      claimedAt: json['claimed_at'] != null 
          ? DateTime.parse(json['claimed_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      missionTemplate: MissionTemplate.fromJson(json['mission_template']),
      canClaimReward: json['can_claim_reward'] ?? false,
      isReadyToComplete: json['is_ready_to_complete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'mission_template_id': missionTemplateId,
      'current_progress': currentProgress,
      'is_completed': isCompleted,
      'is_claimed': isClaimed,
      'progress_percentage': progressPercentage,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'claimed_at': claimedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'mission_template': missionTemplate.toJson(),
      'can_claim_reward': canClaimReward,
      'is_ready_to_complete': isReadyToComplete,
    };
  }

  // 利便性のためのゲッター（mission_templateから取得）
  String get name => missionTemplate.name;
  String get description => missionTemplate.description;
  MissionType get missionType => missionTemplate.missionType;
  String get targetType => missionTemplate.targetType;
  int get targetCount => missionTemplate.targetCount;
  int get rewardGold => missionTemplate.rewardGold;
  int get rewardExp => missionTemplate.rewardExp;

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

class MissionTemplate {
  final int id;
  final String name;
  final String description;
  final MissionType missionType;
  final String targetType;
  final int targetCount;
  final Map<String, dynamic>? targetConditions;
  final int rewardGold;
  final int rewardExp;
  final Map<String, dynamic>? rewardItems;
  final bool isActive;
  final int requiredLevel;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.missionType,
    required this.targetType,
    required this.targetCount,
    this.targetConditions,
    required this.rewardGold,
    required this.rewardExp,
    this.rewardItems,
    required this.isActive,
    required this.requiredLevel,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionTemplate.fromJson(Map<String, dynamic> json) {
    return MissionTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      missionType: MissionType.fromString(json['mission_type']),
      targetType: json['target_type'],
      targetCount: json['target_count'],
      targetConditions: json['target_conditions'],
      rewardGold: json['reward_gold'] ?? 0,
      rewardExp: json['reward_exp'] ?? 0,
      rewardItems: json['reward_items'],
      isActive: json['is_active'] ?? true,
      requiredLevel: json['required_level'] ?? 1,
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
      'target_conditions': targetConditions,
      'reward_gold': rewardGold,
      'reward_exp': rewardExp,
      'reward_items': rewardItems,
      'is_active': isActive,
      'required_level': requiredLevel,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
