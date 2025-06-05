import 'package:json_annotation/json_annotation.dart';

part 'weapon.g.dart';

@JsonSerializable()
class Weapon {
  final String id;
  final String name;
  final String description;
  final int attack;
  @JsonKey(name: 'weapon_type')
  final String weaponType;
  final String rarity;
  final int price;
  @JsonKey(name: 'required_level')
  final int requiredLevel;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Weapon({
    required this.id,
    required this.name,
    required this.description,
    required this.attack,
    required this.weaponType,
    required this.rarity,
    required this.price,
    required this.requiredLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    attack: (json['calculated_attack'] ?? json['base_attack'] ?? 0) is num ? (json['calculated_attack'] ?? json['base_attack'] ?? 0).toInt() : int.tryParse((json['calculated_attack'] ?? json['base_attack']).toString()) ?? 0,
    weaponType: json['weapon_type_id']?.toString() ?? json['weapon_type']?.toString() ?? '',
    rarity: json['rarity']?['name']?.toString() ?? json['rarity_id']?.toString() ?? '',
    price: (json['calculated_price'] ?? json['base_price'] ?? 0) is num ? (json['calculated_price'] ?? json['base_price'] ?? 0).toInt() : int.tryParse((json['calculated_price'] ?? json['base_price']).toString()) ?? 0,
    requiredLevel: (json['required_level'] ?? 1) is num ? (json['required_level'] ?? 1).toInt() : int.tryParse(json['required_level'].toString()) ?? 1,
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );
  Map<String, dynamic> toJson() => _$WeaponToJson(this);

  Weapon copyWith({
    String? id,
    String? name,
    String? description,
    int? attack,
    String? weaponType,
    String? rarity,
    int? price,
    int? requiredLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Weapon(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      attack: attack ?? this.attack,
      weaponType: weaponType ?? this.weaponType,
      rarity: rarity ?? this.rarity,
      price: price ?? this.price,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Weapon(id: $id, name: $name, attack: $attack, rarity: $rarity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Weapon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class PlayerWeapon {
  final String id;
  @JsonKey(name: 'player_id')
  final String playerId;
  @JsonKey(name: 'weapon_id')
  final String weaponId;
  @JsonKey(name: 'weapon_name')
  final String weaponName;
  final int attack;
  @JsonKey(name: 'enchant_level')
  final int enchantLevel;
  @JsonKey(name: 'is_equipped')
  final bool isEquipped;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const PlayerWeapon({
    required this.id,
    required this.playerId,
    required this.weaponId,
    required this.weaponName,
    required this.attack,
    required this.enchantLevel,
    required this.isEquipped,
    required this.createdAt,
  });

  factory PlayerWeapon.fromJson(Map<String, dynamic> json) => PlayerWeapon(
    id: json['id'].toString(),
    playerId: json['player_id'].toString(),
    weaponId: json['weapon_id'].toString(),
    weaponName: json['weapon_name']?.toString() ?? '',
    attack: (json['attack'] ?? 0) is num ? (json['attack'] ?? 0).toInt() : int.tryParse(json['attack'].toString()) ?? 0,
    enchantLevel: (json['enchant_level'] ?? 0) is num ? (json['enchant_level'] ?? 0).toInt() : int.tryParse(json['enchant_level'].toString()) ?? 0,
    isEquipped: json['is_equipped'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );
  Map<String, dynamic> toJson() => _$PlayerWeaponToJson(this);

  PlayerWeapon copyWith({
    String? id,
    String? playerId,
    String? weaponId,
    String? weaponName,
    int? attack,
    int? enchantLevel,
    bool? isEquipped,
    DateTime? createdAt,
  }) {
    return PlayerWeapon(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      weaponId: weaponId ?? this.weaponId,
      weaponName: weaponName ?? this.weaponName,
      attack: attack ?? this.attack,
      enchantLevel: enchantLevel ?? this.enchantLevel,
      isEquipped: isEquipped ?? this.isEquipped,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // エンチャント後の攻撃力
  int get totalAttack => attack + (enchantLevel * 10);

  @override
  String toString() {
    return 'PlayerWeapon(id: $id, name: $weaponName, attack: $totalAttack, enchant: +$enchantLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerWeapon && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class WeaponType {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'attack_multiplier')
  final double attackMultiplier;

  const WeaponType({
    required this.id,
    required this.name,
    required this.description,
    required this.attackMultiplier,
  });

  factory WeaponType.fromJson(Map<String, dynamic> json) => WeaponType(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    attackMultiplier: (json['attack_multiplier'] ?? 1.0) is num ? (json['attack_multiplier'] ?? 1.0).toDouble() : double.tryParse(json['attack_multiplier'].toString()) ?? 1.0,
  );
  Map<String, dynamic> toJson() => _$WeaponTypeToJson(this);

  @override
  String toString() {
    return 'WeaponType(id: $id, name: $name, multiplier: $attackMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeaponType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
