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
      experience: (json['experience'] as num).toInt(),
      reputation: (json['reputation'] as num).toInt(),
      isActive: json['is_active'] as bool,
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'last_login': instance.lastLogin?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

PlayerStatistics _$PlayerStatisticsFromJson(Map<String, dynamic> json) =>
    PlayerStatistics(
      totalPlayTimeSeconds: (json['total_play_time_seconds'] as num).toInt(),
      sessionCount: (json['session_count'] as num).toInt(),
      averageSessionDuration: (json['average_session_duration'] as num).toInt(),
      totalGoldEarned: (json['total_gold_earned'] as num).toInt(),
      totalGoldSpent: (json['total_gold_spent'] as num).toInt(),
      weaponsCrafted: (json['weapons_crafted'] as num).toInt(),
      enchantsAttempted: (json['enchants_attempted'] as num).toInt(),
      enchantsSucceeded: (json['enchants_succeeded'] as num).toInt(),
      highestWeaponAttack: (json['highest_weapon_attack'] as num).toInt(),
      enchantSuccessRate: (json['enchant_success_rate'] as num).toDouble(),
    );

Map<String, dynamic> _$PlayerStatisticsToJson(PlayerStatistics instance) =>
    <String, dynamic>{
      'total_play_time_seconds': instance.totalPlayTimeSeconds,
      'session_count': instance.sessionCount,
      'average_session_duration': instance.averageSessionDuration,
      'total_gold_earned': instance.totalGoldEarned,
      'total_gold_spent': instance.totalGoldSpent,
      'weapons_crafted': instance.weaponsCrafted,
      'enchants_attempted': instance.enchantsAttempted,
      'enchants_succeeded': instance.enchantsSucceeded,
      'highest_weapon_attack': instance.highestWeaponAttack,
      'enchant_success_rate': instance.enchantSuccessRate,
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
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      user: Player.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'user': instance.user,
    };
