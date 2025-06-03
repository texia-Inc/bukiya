import 'package:flutter/material.dart';

class EnchantmentType {
  final int id;
  final String name;
  final String description;
  final String effectType;
  final double effectValue;
  final int maxLevel;
  final double baseSuccessRate;
  final int baseCost;
  final Map<String, dynamic>? requiredMaterials;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnchantmentType({
    required this.id,
    required this.name,
    required this.description,
    required this.effectType,
    required this.effectValue,
    required this.maxLevel,
    required this.baseSuccessRate,
    required this.baseCost,
    this.requiredMaterials,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory EnchantmentType.fromJson(Map<String, dynamic> json) {
    return EnchantmentType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      effectType: json['effect_type'],
      effectValue: json['effect_value'].toDouble(),
      maxLevel: json['max_level'],
      baseSuccessRate: json['base_success_rate'].toDouble(),
      baseCost: json['base_cost'],
      requiredMaterials: json['required_materials'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'effect_type': effectType,
      'effect_value': effectValue,
      'max_level': maxLevel,
      'base_success_rate': baseSuccessRate,
      'base_cost': baseCost,
      'required_materials': requiredMaterials,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get effectTypeDisplayName {
    switch (effectType) {
      case 'attack':
        return '攻撃力';
      case 'defense':
        return '防御力';
      case 'speed':
        return '速度';
      case 'critical':
        return 'クリティカル';
      case 'accuracy':
        return '命中';
      case 'durability':
        return '耐久';
      default:
        return effectType;
    }
  }
}

class EnchantmentMaterial {
  final int id;
  final String name;
  final String description;
  final String rarity;
  final String? effectType;
  final String materialType;
  final double successRateBonus;
  final double costMultiplier;
  final int maxStack;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnchantmentMaterial({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    this.effectType,
    required this.materialType,
    required this.successRateBonus,
    required this.costMultiplier,
    required this.maxStack,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory EnchantmentMaterial.fromJson(Map<String, dynamic> json) {
    return EnchantmentMaterial(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rarity: json['rarity'],
      effectType: json['effect_type'],
      materialType: json['material_type'] ?? 'general',
      successRateBonus: json['success_rate_bonus'].toDouble(),
      costMultiplier: json['cost_multiplier'].toDouble(),
      maxStack: json['max_stack'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity,
      'effect_type': effectType,
      'material_type': materialType,
      'success_rate_bonus': successRateBonus,
      'cost_multiplier': costMultiplier,
      'max_stack': maxStack,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get rarityDisplayName {
    switch (rarity) {
      case 'common':
        return 'コモン';
      case 'uncommon':
        return 'アンコモン';
      case 'rare':
        return 'レア';
      case 'epic':
        return 'エピック';
      case 'legendary':
        return 'レジェンダリー';
      default:
        return rarity;
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.blue;
      case 'rare':
        return Colors.purple;
      case 'epic':
        return Colors.orange;
      case 'legendary':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class PlayerEnchantmentMaterial {
  final int id;
  final int playerId;
  final int materialId;
  final int quantity;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final EnchantmentMaterial? material;

  PlayerEnchantmentMaterial({
    required this.id,
    required this.playerId,
    required this.materialId,
    required this.quantity,
    required this.createdAt,
    this.updatedAt,
    this.material,
  });

  factory PlayerEnchantmentMaterial.fromJson(Map<String, dynamic> json) {
    return PlayerEnchantmentMaterial(
      id: json['id'],
      playerId: json['player_id'],
      materialId: json['material_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      material: json['material'] != null ? EnchantmentMaterial.fromJson(json['material']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'material_id': materialId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'material': material?.toJson(),
    };
  }
}

class WeaponEnchantment {
  final int id;
  final int weaponId;
  final int enchantmentTypeId;
  final int level;
  final int successCount;
  final int failureCount;
  final int totalCost;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final EnchantmentType? enchantmentType;

  WeaponEnchantment({
    required this.id,
    required this.weaponId,
    required this.enchantmentTypeId,
    required this.level,
    required this.successCount,
    required this.failureCount,
    required this.totalCost,
    required this.createdAt,
    this.updatedAt,
    this.enchantmentType,
  });

  factory WeaponEnchantment.fromJson(Map<String, dynamic> json) {
    return WeaponEnchantment(
      id: json['id'],
      weaponId: json['weapon_id'],
      enchantmentTypeId: json['enchantment_type_id'],
      level: json['level'],
      successCount: json['success_count'],
      failureCount: json['failure_count'],
      totalCost: json['total_cost'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      enchantmentType: json['enchantment_type'] != null 
          ? EnchantmentType.fromJson(json['enchantment_type']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weapon_id': weaponId,
      'enchantment_type_id': enchantmentTypeId,
      'level': level,
      'success_count': successCount,
      'failure_count': failureCount,
      'total_cost': totalCost,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'enchantment_type': enchantmentType?.toJson(),
    };
  }
}

enum EnchantmentResult {
  success,
  failure,
  destroy,
}

class EnchantmentLog {
  final int id;
  final int playerId;
  final int weaponId;
  final int enchantmentTypeId;
  final int beforeLevel;
  final int afterLevel;
  final EnchantmentResult result;
  final int cost;
  final Map<String, dynamic>? materialsUsed;
  final double successRate;
  final DateTime createdAt;

  EnchantmentLog({
    required this.id,
    required this.playerId,
    required this.weaponId,
    required this.enchantmentTypeId,
    required this.beforeLevel,
    required this.afterLevel,
    required this.result,
    required this.cost,
    this.materialsUsed,
    required this.successRate,
    required this.createdAt,
  });

  factory EnchantmentLog.fromJson(Map<String, dynamic> json) {
    return EnchantmentLog(
      id: json['id'],
      playerId: json['player_id'],
      weaponId: json['weapon_id'],
      enchantmentTypeId: json['enchantment_type_id'],
      beforeLevel: json['before_level'],
      afterLevel: json['after_level'],
      result: _parseEnchantmentResult(json['result']),
      cost: json['cost'],
      materialsUsed: json['materials_used'],
      successRate: json['success_rate'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static EnchantmentResult _parseEnchantmentResult(String result) {
    switch (result) {
      case 'success':
        return EnchantmentResult.success;
      case 'failure':
        return EnchantmentResult.failure;
      case 'destroy':
        return EnchantmentResult.destroy;
      default:
        return EnchantmentResult.failure;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'weapon_id': weaponId,
      'enchantment_type_id': enchantmentTypeId,
      'before_level': beforeLevel,
      'after_level': afterLevel,
      'result': result.toString().split('.').last,
      'cost': cost,
      'materials_used': materialsUsed,
      'success_rate': successRate,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get resultDisplayName {
    switch (result) {
      case EnchantmentResult.success:
        return '成功';
      case EnchantmentResult.failure:
        return '失敗';
      case EnchantmentResult.destroy:
        return '破壊';
    }
  }

  Color get resultColor {
    switch (result) {
      case EnchantmentResult.success:
        return Colors.green;
      case EnchantmentResult.failure:
        return Colors.orange;
      case EnchantmentResult.destroy:
        return Colors.red;
    }
  }
}

class EnchantmentStats {
  final int totalEnchantments;
  final int successCount;
  final int failureCount;
  final int destroyCount;
  final double successRate;
  final int totalCost;
  final double averageLevel;

  EnchantmentStats({
    required this.totalEnchantments,
    required this.successCount,
    required this.failureCount,
    required this.destroyCount,
    required this.successRate,
    required this.totalCost,
    required this.averageLevel,
  });

  factory EnchantmentStats.fromJson(Map<String, dynamic> json) {
    return EnchantmentStats(
      totalEnchantments: json['total_enchantments'],
      successCount: json['success_count'],
      failureCount: json['failure_count'],
      destroyCount: json['destroy_count'],
      successRate: json['success_rate'].toDouble(),
      totalCost: json['total_cost'],
      averageLevel: json['average_level'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_enchantments': totalEnchantments,
      'success_count': successCount,
      'failure_count': failureCount,
      'destroy_count': destroyCount,
      'success_rate': successRate,
      'total_cost': totalCost,
      'average_level': averageLevel,
    };
  }
}

class EnchantmentRequest {
  final String weaponId;
  final int enchantmentTypeId;
  final List<Map<String, dynamic>>? useMaterials;
  final bool useProtection;

  EnchantmentRequest({
    required this.weaponId,
    required this.enchantmentTypeId,
    this.useMaterials,
    this.useProtection = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'weapon_id': weaponId,
      'enchantment_type_id': enchantmentTypeId,
      'use_materials': useMaterials,
      'use_protection': useProtection,
    };
  }
}

class EnchantmentResponse {
  final EnchantmentResult result;
  final int beforeLevel;
  final int afterLevel;
  final int cost;
  final double successRate;
  final Map<String, dynamic>? materialsUsed;
  final String message;

  EnchantmentResponse({
    required this.result,
    required this.beforeLevel,
    required this.afterLevel,
    required this.cost,
    required this.successRate,
    this.materialsUsed,
    required this.message,
  });

  factory EnchantmentResponse.fromJson(Map<String, dynamic> json) {
    return EnchantmentResponse(
      result: _parseEnchantmentResult(json['result']),
      beforeLevel: json['before_level'],
      afterLevel: json['after_level'],
      cost: json['cost'],
      successRate: json['success_rate'].toDouble(),
      materialsUsed: json['materials_used'],
      message: json['message'],
    );
  }

  static EnchantmentResult _parseEnchantmentResult(String result) {
    switch (result) {
      case 'success':
        return EnchantmentResult.success;
      case 'failure':
        return EnchantmentResult.failure;
      case 'destroy':
        return EnchantmentResult.destroy;
      default:
        return EnchantmentResult.failure;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toString().split('.').last,
      'before_level': beforeLevel,
      'after_level': afterLevel,
      'cost': cost,
      'success_rate': successRate,
      'materials_used': materialsUsed,
      'message': message,
    };
  }
}

class EnchantmentListResponse {
  final List<EnchantmentType> enchantmentTypes;
  final List<EnchantmentMaterial> materials;
  final List<PlayerEnchantmentMaterial> playerMaterials;
  final EnchantmentStats stats;

  EnchantmentListResponse({
    required this.enchantmentTypes,
    required this.materials,
    required this.playerMaterials,
    required this.stats,
  });

  factory EnchantmentListResponse.fromJson(Map<String, dynamic> json) {
    return EnchantmentListResponse(
      enchantmentTypes: (json['enchantment_types'] as List)
          .map((e) => EnchantmentType.fromJson(e))
          .toList(),
      materials: (json['materials'] as List)
          .map((e) => EnchantmentMaterial.fromJson(e))
          .toList(),
      playerMaterials: (json['player_materials'] as List)
          .map((e) => PlayerEnchantmentMaterial.fromJson(e))
          .toList(),
      stats: EnchantmentStats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enchantment_types': enchantmentTypes.map((e) => e.toJson()).toList(),
      'materials': materials.map((e) => e.toJson()).toList(),
      'player_materials': playerMaterials.map((e) => e.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}
