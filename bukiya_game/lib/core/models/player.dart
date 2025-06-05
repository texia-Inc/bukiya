import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

DateTime _dateTimeFromJson(String? dateString) {
  if (dateString == null) return DateTime.now();
  
  // バックエンドの不正な日付フォーマット (+00:00Z) を修正
  String cleanDateString = dateString;
  if (dateString.endsWith('+00:00Z')) {
    cleanDateString = dateString.replaceAll('+00:00Z', 'Z');
  }
  
  try {
    return DateTime.parse(cleanDateString);
  } catch (e) {
    // パースに失敗した場合は現在時刻を返す
    print('Date parse error for: $dateString, using current time');
    return DateTime.now();
  }
}

DateTime? _dateTimeFromJsonNullable(String? dateString) {
  if (dateString == null) return null;
  return _dateTimeFromJson(dateString);
}

String? _dateTimeToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}

@JsonSerializable()
class Player {
  final String id;
  final String username;
  final String email;
  final int gold;
  final int gems;
  @JsonKey(name: 'shop_level')
  final int shopLevel;
  @JsonKey(defaultValue: 0)
  final int experience;
  final int reputation;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'last_login', fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJson)
  final DateTime? lastLogin;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJson)
  final DateTime? updatedAt;

  const Player({
    required this.id,
    required this.username,
    required this.email,
    required this.gold,
    required this.gems,
    required this.shopLevel,
    required this.experience,
    required this.reputation,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player copyWith({
    String? id,
    String? username,
    String? email,
    int? gold,
    int? gems,
    int? shopLevel,
    int? experience,
    int? reputation,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      shopLevel: shopLevel ?? this.shopLevel,
      experience: experience ?? this.experience,
      reputation: reputation ?? this.reputation,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt,
    );
  }

  // レベル計算
  int get level {
    // 経験値からレベルを計算
    return (experience / 1000).floor() + 1;
  }

  // 次のレベルまでの経験値
  int get expToNextLevel {
    final nextLevelExp = level * 1000;
    return nextLevelExp - experience;
  }

  // 現在レベルでの進捗率
  double get levelProgress {
    final currentLevelExp = (level - 1) * 1000;
    final nextLevelExp = level * 1000;
    final currentProgress = experience - currentLevelExp;
    return currentProgress / (nextLevelExp - currentLevelExp);
  }

  @override
  String toString() {
    return 'Player(id: $id, username: $username, level: $level, gold: $gold, gems: $gems)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class PlayerStatistics {
  @JsonKey(name: 'player_id')
  final String? playerId;
  @JsonKey(name: 'total_play_time_seconds')
  final int totalPlayTimeSeconds;
  @JsonKey(name: 'session_count')
  final int sessionCount;
  @JsonKey(name: 'last_session_duration', defaultValue: 0)
  final int lastSessionDuration;
  @JsonKey(name: 'average_session_duration')
  final int averageSessionDuration;
  @JsonKey(name: 'total_gold_earned')
  final int totalGoldEarned;
  @JsonKey(name: 'total_gold_spent')
  final int totalGoldSpent;
  @JsonKey(name: 'total_gems_purchased', defaultValue: 0)
  final int totalGemsPurchased;
  @JsonKey(name: 'total_gems_spent', defaultValue: 0)
  final int totalGemsSpent;
  @JsonKey(name: 'weapons_crafted')
  final int weaponsCrafted;
  @JsonKey(name: 'enchants_attempted')
  final int enchantsAttempted;
  @JsonKey(name: 'enchants_succeeded')
  final int enchantsSucceeded;
  @JsonKey(name: 'trades_completed', defaultValue: 0)
  final int tradesCompleted;
  @JsonKey(name: 'expeditions_sent', defaultValue: 0)
  final int expeditionsSent;
  @JsonKey(name: 'highest_weapon_attack')
  final int highestWeaponAttack;
  @JsonKey(name: 'highest_enchant_level', defaultValue: 0)
  final int highestEnchantLevel;
  @JsonKey(name: 'max_daily_gold', defaultValue: 0)
  final int maxDailyGold;
  @JsonKey(name: 'enchant_success_rate')
  final double enchantSuccessRate;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJson)
  final DateTime? updatedAt;

  const PlayerStatistics({
    this.playerId,
    required this.totalPlayTimeSeconds,
    required this.sessionCount,
    required this.lastSessionDuration,
    required this.averageSessionDuration,
    required this.totalGoldEarned,
    required this.totalGoldSpent,
    required this.totalGemsPurchased,
    required this.totalGemsSpent,
    required this.weaponsCrafted,
    required this.enchantsAttempted,
    required this.enchantsSucceeded,
    required this.tradesCompleted,
    required this.expeditionsSent,
    required this.highestWeaponAttack,
    required this.highestEnchantLevel,
    required this.maxDailyGold,
    required this.enchantSuccessRate,
    this.updatedAt,
  });

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerStatisticsToJson(this);

  // 総プレイ時間（時間単位）
  double get totalPlayTimeHours => totalPlayTimeSeconds / 3600;

  // 平均セッション時間（分単位）
  double get averageSessionMinutes => averageSessionDuration / 60;

  @override
  String toString() {
    return 'PlayerStatistics(totalPlayTime: ${totalPlayTimeHours.toStringAsFixed(1)}h, weaponsCrafted: $weaponsCrafted)';
  }
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'player_id')
  final String playerId;
  final String username;
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  const AuthResponse({
    required this.playerId,
    required this.username,
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
