// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      gold: (json['gold'] as num).toInt(),
      gems: (json['gems'] as num).toInt(),
      shopLevel: (json['shop_level'] as num).toInt(),
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      reputation: (json['reputation'] as num).toInt(),
      isActive: json['is_active'] as bool,
      lastLogin: _dateTimeFromJsonNullable(json['last_login'] as String?),
      createdAt: _dateTimeFromJson(json['created_at'] as String?),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at'] as String?),
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'gold': instance.gold,
      'gems': instance.gems,
      'shop_level': instance.shopLevel,
      'experience': instance.experience,
      'reputation': instance.reputation,
      'is_active': instance.isActive,
      'last_login': _dateTimeToJson(instance.lastLogin),
      'created_at': _dateTimeToJson(instance.createdAt),
      'updated_at': _dateTimeToJson(instance.updatedAt),
    };

PlayerStatistics _$PlayerStatisticsFromJson(Map<String, dynamic> json) =>
    PlayerStatistics(
      playerId: json['player_id'] as String?,
      totalPlayTimeSeconds: (json['total_play_time_seconds'] as num).toInt(),
      sessionCount: (json['session_count'] as num).toInt(),
      lastSessionDuration:
          (json['last_session_duration'] as num?)?.toInt() ?? 0,
      averageSessionDuration: (json['average_session_duration'] as num).toInt(),
      totalGoldEarned: (json['total_gold_earned'] as num).toInt(),
      totalGoldSpent: (json['total_gold_spent'] as num).toInt(),
      totalGemsPurchased: (json['total_gems_purchased'] as num?)?.toInt() ?? 0,
      totalGemsSpent: (json['total_gems_spent'] as num?)?.toInt() ?? 0,
      weaponsCrafted: (json['weapons_crafted'] as num).toInt(),
      enchantsAttempted: (json['enchants_attempted'] as num).toInt(),
      enchantsSucceeded: (json['enchants_succeeded'] as num).toInt(),
      tradesCompleted: (json['trades_completed'] as num?)?.toInt() ?? 0,
      expeditionsSent: (json['expeditions_sent'] as num?)?.toInt() ?? 0,
      highestWeaponAttack: (json['highest_weapon_attack'] as num).toInt(),
      highestEnchantLevel:
          (json['highest_enchant_level'] as num?)?.toInt() ?? 0,
      maxDailyGold: (json['max_daily_gold'] as num?)?.toInt() ?? 0,
      enchantSuccessRate: (json['enchant_success_rate'] as num).toDouble(),
      updatedAt: _dateTimeFromJsonNullable(json['updated_at'] as String?),
    );

Map<String, dynamic> _$PlayerStatisticsToJson(PlayerStatistics instance) =>
    <String, dynamic>{
      'player_id': instance.playerId,
      'total_play_time_seconds': instance.totalPlayTimeSeconds,
      'session_count': instance.sessionCount,
      'last_session_duration': instance.lastSessionDuration,
      'average_session_duration': instance.averageSessionDuration,
      'total_gold_earned': instance.totalGoldEarned,
      'total_gold_spent': instance.totalGoldSpent,
      'total_gems_purchased': instance.totalGemsPurchased,
      'total_gems_spent': instance.totalGemsSpent,
      'weapons_crafted': instance.weaponsCrafted,
      'enchants_attempted': instance.enchantsAttempted,
      'enchants_succeeded': instance.enchantsSucceeded,
      'trades_completed': instance.tradesCompleted,
      'expeditions_sent': instance.expeditionsSent,
      'highest_weapon_attack': instance.highestWeaponAttack,
      'highest_enchant_level': instance.highestEnchantLevel,
      'max_daily_gold': instance.maxDailyGold,
      'enchant_success_rate': instance.enchantSuccessRate,
      'updated_at': _dateTimeToJson(instance.updatedAt),
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      playerId: json['player_id'] as String,
      username: json['username'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'player_id': instance.playerId,
      'username': instance.username,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
    };
