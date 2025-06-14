// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weapon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weapon _$WeaponFromJson(Map<String, dynamic> json) => Weapon(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      attack: (json['attack'] as num).toInt(),
      weaponType: json['weapon_type'] as String,
      rarity: json['rarity'] as String,
      price: (json['price'] as num).toInt(),
      requiredLevel: (json['required_level'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$WeaponToJson(Weapon instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'attack': instance.attack,
      'weapon_type': instance.weaponType,
      'rarity': instance.rarity,
      'price': instance.price,
      'required_level': instance.requiredLevel,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

PlayerWeapon _$PlayerWeaponFromJson(Map<String, dynamic> json) => PlayerWeapon(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      weaponId: (json['weapon_id'] as num).toInt(),
      weaponName: json['weapon_name'] as String,
      attack: (json['attack'] as num).toInt(),
      enchantLevel: (json['enchant_level'] as num).toInt(),
      isEquipped: json['is_equipped'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PlayerWeaponToJson(PlayerWeapon instance) =>
    <String, dynamic>{
      'id': instance.id,
      'player_id': instance.playerId,
      'weapon_id': instance.weaponId,
      'weapon_name': instance.weaponName,
      'attack': instance.attack,
      'enchant_level': instance.enchantLevel,
      'is_equipped': instance.isEquipped,
      'created_at': instance.createdAt.toIso8601String(),
    };

WeaponType _$WeaponTypeFromJson(Map<String, dynamic> json) => WeaponType(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      attackMultiplier: (json['attack_multiplier'] as num).toDouble(),
    );

Map<String, dynamic> _$WeaponTypeToJson(WeaponType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'attack_multiplier': instance.attackMultiplier,
    };
