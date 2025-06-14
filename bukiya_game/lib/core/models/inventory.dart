import 'package:flutter/material.dart';
import 'weapon.dart';
import 'crafting.dart' as crafting;

class PlayerWeapon {
  final String id;
  final String playerId;
  final int weaponMasterId;
  final int attack;
  final int enchantLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Weapon weaponMaster;

  PlayerWeapon({
    required this.id,
    required this.playerId,
    required this.weaponMasterId,
    required this.attack,
    required this.enchantLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.weaponMaster,
  });

  factory PlayerWeapon.fromJson(Map<String, dynamic> json) {
    return PlayerWeapon(
      id: json['id'],
      playerId: json['player_id'],
      weaponMasterId: json['weapon_master_id'] as int,
      attack: json['attack'] ?? json['base_attack'] ?? 0,
      enchantLevel: json['enchant_level'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      weaponMaster: Weapon.fromJson(json['weapon_master']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'weapon_master_id': weaponMasterId,
      'attack': attack,
      'enchant_level': enchantLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'weapon_master': weaponMaster.toJson(),
    };
  }

  // 総攻撃力（基本攻撃力 + エンチャントボーナス）
  int get totalAttack => attack + (enchantLevel * 10);

  // エンチャント可能かどうか
  bool get canEnchant => enchantLevel < 15;

  // エンチャント成功率
  double get enchantSuccessRate {
    if (enchantLevel >= 15) return 0.0;
    return 1.0 - (enchantLevel * 0.05); // レベルが上がるほど成功率低下
  }

  // 売却価格
  int get sellPrice {
    final basePrice = weaponMaster.price;
    final enchantBonus = enchantLevel * 100;
    return (basePrice * 0.5).round() + enchantBonus;
  }

  // エンチャントコスト
  int get enchantCost => (enchantLevel + 1) * 1000;

  // エンチャントレベル表示
  String get enchantLevelDisplay {
    return enchantLevel > 0 ? '+$enchantLevel' : '';
  }

  // 武器名（エンチャントレベル付き）
  String get displayName {
    final enchantDisplay = enchantLevelDisplay;
    return enchantDisplay.isNotEmpty 
        ? '${weaponMaster.name} $enchantDisplay'
        : weaponMaster.name;
  }

  // レアリティ色
  Color get rarityColor => _getRarityColor(weaponMaster.rarity);

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9E9E9E);
      case 'uncommon':
        return const Color(0xFF4CAF50);
      case 'rare':
        return const Color(0xFF2196F3);
      case 'epic':
        return const Color(0xFF9C27B0);
      case 'legendary':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  PlayerWeapon copyWith({
    String? id,
    String? playerId,
    int? weaponMasterId,
    int? attack,
    int? enchantLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Weapon? weaponMaster,
  }) {
    return PlayerWeapon(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      weaponMasterId: weaponMasterId ?? this.weaponMasterId,
      attack: attack ?? this.attack,
      enchantLevel: enchantLevel ?? this.enchantLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weaponMaster: weaponMaster ?? this.weaponMaster,
    );
  }
}

class InventoryPlayerMaterial {
  final int materialId;
  final int quantity;
  final crafting.Material material;

  InventoryPlayerMaterial({
    required this.materialId,
    required this.quantity,
    required this.material,
  });

  factory InventoryPlayerMaterial.fromJson(Map<String, dynamic> json) {
    return InventoryPlayerMaterial(
      materialId: json['material_id'] as int,
      quantity: json['quantity'],
      material: crafting.Material.fromJson(json['material']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'quantity': quantity,
      'material': material.toJson(),
    };
  }

  // 総価値
  int get totalValue => material.sellPrice * quantity;

  // 売却価格（80%）
  int get sellPrice => (material.sellPrice * 0.8).round();

  // 総売却価格
  int get totalSellPrice => sellPrice * quantity;

  // スタック上限チェック
  bool get isMaxStack => quantity >= 999; // デフォルトのスタック上限

  // 数量表示
  String get quantityDisplay {
    if (quantity >= 1000000) {
      return '${(quantity / 1000000).toStringAsFixed(1)}M';
    } else if (quantity >= 1000) {
      return '${(quantity / 1000).toStringAsFixed(1)}K';
    }
    return quantity.toString();
  }

  InventoryPlayerMaterial copyWith({
    int? materialId,
    int? quantity,
    crafting.Material? material,
  }) {
    return InventoryPlayerMaterial(
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      material: material ?? this.material,
    );
  }
}

class InventoryStats {
  final int totalWeapons;
  final int totalMaterials;
  final int totalWeaponValue;
  final int totalMaterialValue;
  final int totalValue;
  final Map<String, int> weaponsByRarity;
  final Map<String, int> materialsByRarity;

  InventoryStats({
    required this.totalWeapons,
    required this.totalMaterials,
    required this.totalWeaponValue,
    required this.totalMaterialValue,
    required this.totalValue,
    required this.weaponsByRarity,
    required this.materialsByRarity,
  });

  factory InventoryStats.fromInventory({
    required List<PlayerWeapon> weapons,
    required List<InventoryPlayerMaterial> materials,
  }) {
    // 武器統計
    int totalWeaponValue = 0;
    Map<String, int> weaponsByRarity = {};
    
    for (final weapon in weapons) {
      totalWeaponValue += weapon.sellPrice;
      final rarity = weapon.weaponMaster.rarity;
      weaponsByRarity[rarity] = (weaponsByRarity[rarity] ?? 0) + 1;
    }

    // 素材統計
    int totalMaterialValue = 0;
    Map<String, int> materialsByRarity = {};
    
    for (final material in materials) {
      totalMaterialValue += material.totalSellPrice;
      final rarity = material.material.rarity;
      materialsByRarity[rarity] = (materialsByRarity[rarity] ?? 0) + material.quantity;
    }

    return InventoryStats(
      totalWeapons: weapons.length,
      totalMaterials: materials.fold(0, (sum, m) => sum + m.quantity),
      totalWeaponValue: totalWeaponValue,
      totalMaterialValue: totalMaterialValue,
      totalValue: totalWeaponValue + totalMaterialValue,
      weaponsByRarity: weaponsByRarity,
      materialsByRarity: materialsByRarity,
    );
  }

  // 総価値の表示用文字列
  String get totalValueFormatted {
    return totalValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 武器価値の表示用文字列
  String get weaponValueFormatted {
    return totalWeaponValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 素材価値の表示用文字列
  String get materialValueFormatted {
    return totalMaterialValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

class EnchantRequest {
  final String weaponId;

  EnchantRequest({
    required this.weaponId,
  });

  Map<String, dynamic> toJson() {
    return {
      'weapon_id': weaponId,
    };
  }
}

class EnchantResult {
  final bool success;
  final int newLevel;
  final int newAttack;
  final int goldSpent;
  final String message;

  EnchantResult({
    required this.success,
    required this.newLevel,
    required this.newAttack,
    required this.goldSpent,
    required this.message,
  });

  factory EnchantResult.fromJson(Map<String, dynamic> json) {
    return EnchantResult(
      success: json['success'],
      newLevel: json['new_level'],
      newAttack: json['new_attack'],
      goldSpent: json['gold_spent'],
      message: json['message'],
    );
  }
}

class MaterialSellRequest {
  final int materialId;
  final int quantity;

  MaterialSellRequest({
    required this.materialId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'quantity': quantity,
    };
  }
}

class MaterialSellResult {
  final int goldEarned;
  final int newQuantity;
  final String message;

  MaterialSellResult({
    required this.goldEarned,
    required this.newQuantity,
    required this.message,
  });

  factory MaterialSellResult.fromJson(Map<String, dynamic> json) {
    return MaterialSellResult(
      goldEarned: json['gold_earned'],
      newQuantity: json['new_quantity'],
      message: json['message'],
    );
  }
}
