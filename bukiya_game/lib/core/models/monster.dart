import 'package:flutter/material.dart';

/// モンスターモデル
class Monster {
  final int id;
  final String name;
  final String description;
  final String monsterType;
  final String rarity;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int level;
  final int expReward;
  final int goldReward;
  final String? imageUrl;
  final List<String> skills;
  final Map<String, int>? dropItems; // itemId -> dropRate(%)
  final String habitat; // 生息地
  final bool isBoss;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Monster({
    required this.id,
    required this.name,
    required this.description,
    required this.monsterType,
    required this.rarity,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.level,
    required this.expReward,
    required this.goldReward,
    this.imageUrl,
    required this.skills,
    this.dropItems,
    required this.habitat,
    required this.isBoss,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      id: json['id'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      monsterType: json['monster_type'] ?? 'normal',
      rarity: json['rarity'] ?? 'common',
      hp: json['hp'] ?? 0,
      attack: json['attack'] ?? 0,
      defense: json['defense'] ?? 0,
      speed: json['speed'] ?? 0,
      level: json['level'] ?? 1,
      expReward: json['exp_reward'] ?? 0,
      goldReward: json['gold_reward'] ?? 0,
      imageUrl: json['image_url'],
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'])
          : [],
      dropItems: json['drop_items'] != null
          ? Map<String, int>.from(json['drop_items'])
          : null,
      habitat: json['habitat'] ?? 'unknown',
      isBoss: json['is_boss'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monster_type': monsterType,
      'rarity': rarity,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'level': level,
      'exp_reward': expReward,
      'gold_reward': goldReward,
      'image_url': imageUrl,
      'skills': skills,
      'drop_items': dropItems,
      'habitat': habitat,
      'is_boss': isBoss,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Monster copyWith({
    int? id,
    String? name,
    String? description,
    String? monsterType,
    String? rarity,
    int? hp,
    int? attack,
    int? defense,
    int? speed,
    int? level,
    int? expReward,
    int? goldReward,
    String? imageUrl,
    List<String>? skills,
    Map<String, int>? dropItems,
    String? habitat,
    bool? isBoss,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Monster(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      monsterType: monsterType ?? this.monsterType,
      rarity: rarity ?? this.rarity,
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      level: level ?? this.level,
      expReward: expReward ?? this.expReward,
      goldReward: goldReward ?? this.goldReward,
      imageUrl: imageUrl ?? this.imageUrl,
      skills: skills ?? this.skills,
      dropItems: dropItems ?? this.dropItems,
      habitat: habitat ?? this.habitat,
      isBoss: isBoss ?? this.isBoss,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // レアリティに基づく色を取得
  Color get rarityColor {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 総合戦闘力を計算
  int get combatPower {
    return attack + defense + (speed ~/ 2) + (hp ~/ 10);
  }

  @override
  String toString() {
    return 'Monster(id: $id, name: $name, level: $level, rarity: $rarity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Monster && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// モンスタータイプの列挙
class MonsterType {
  static const String normal = 'normal';
  static const String flying = 'flying';
  static const String aquatic = 'aquatic';
  static const String undead = 'undead';
  static const String demon = 'demon';
  static const String dragon = 'dragon';
  static const String elemental = 'elemental';
  static const String beast = 'beast';
  static const String humanoid = 'humanoid';
  static const String machine = 'machine';

  static String getDisplayName(String type) {
    switch (type) {
      case normal:
        return '通常';
      case flying:
        return '飛行';
      case aquatic:
        return '水棲';
      case undead:
        return 'アンデッド';
      case demon:
        return '悪魔';
      case dragon:
        return 'ドラゴン';
      case elemental:
        return '精霊';
      case beast:
        return '獣';
      case humanoid:
        return '人型';
      case machine:
        return '機械';
      default:
        return type;
    }
  }

  static List<String> get allTypes => [
    normal,
    flying,
    aquatic,
    undead,
    demon,
    dragon,
    elemental,
    beast,
    humanoid,
    machine,
  ];
}

/// 生息地の列挙
class MonsterHabitat {
  static const String forest = 'forest';
  static const String mountain = 'mountain';
  static const String cave = 'cave';
  static const String desert = 'desert';
  static const String ocean = 'ocean';
  static const String volcano = 'volcano';
  static const String sky = 'sky';
  static const String dungeon = 'dungeon';
  static const String castle = 'castle';
  static const String abyss = 'abyss';

  static String getDisplayName(String habitat) {
    switch (habitat) {
      case forest:
        return '森';
      case mountain:
        return '山';
      case cave:
        return '洞窟';
      case desert:
        return '砂漠';
      case ocean:
        return '海';
      case volcano:
        return '火山';
      case sky:
        return '空';
      case dungeon:
        return 'ダンジョン';
      case castle:
        return '城';
      case abyss:
        return '深淵';
      default:
        return habitat;
    }
  }

  static List<String> get allHabitats => [
    forest,
    mountain,
    cave,
    desert,
    ocean,
    volcano,
    sky,
    dungeon,
    castle,
    abyss,
  ];
}