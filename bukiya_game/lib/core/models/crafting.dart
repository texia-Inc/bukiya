import 'package:flutter/material.dart';
import 'weapon.dart';

class CraftingRecipe {
  final int id;
  final int weaponId;
  final String name;
  final String description;
  final int goldCost;
  final double successRate;
  final int requiredLevel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Weapon weapon;
  final List<RecipeMaterial> materials;
  final bool? canCraft;
  final List<String>? missingRequirements;

  CraftingRecipe({
    required this.id,
    required this.weaponId,
    required this.name,
    required this.description,
    required this.goldCost,
    required this.successRate,
    required this.requiredLevel,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.weapon,
    required this.materials,
    this.canCraft,
    this.missingRequirements,
  });

  factory CraftingRecipe.fromJson(Map<String, dynamic> json) {
    return CraftingRecipe(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      weaponId: json['weapon_id'] is int ? json['weapon_id'] : int.tryParse(json['weapon_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      goldCost: json['gold_cost'] is int ? json['gold_cost'] : int.tryParse(json['gold_cost'].toString()) ?? 0,
      successRate: (json['success_rate'] as num).toDouble(),
      requiredLevel: json['required_level'] is int ? json['required_level'] : int.tryParse(json['required_level'].toString()) ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      weapon: Weapon.fromJson(json['weapon']),
      materials: (json['materials'] as List)
          .map((material) => RecipeMaterial.fromJson(material))
          .toList(),
      canCraft: json['can_craft'],
      missingRequirements: json['missing_requirements'] != null
          ? List<String>.from(json['missing_requirements'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weapon_id': weaponId,
      'name': name,
      'description': description,
      'gold_cost': goldCost,
      'success_rate': successRate,
      'required_level': requiredLevel,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'weapon': weapon.toJson(),
      'materials': materials.map((material) => material.toJson()).toList(),
      'can_craft': canCraft,
      'missing_requirements': missingRequirements,
    };
  }

  // 成功率をパーセンテージで取得
  int get successRatePercentage => (successRate * 100).round();

  // 合成可能かどうか
  bool get isCraftable => canCraft ?? false;

  // 必要素材の総数
  int get totalMaterialsRequired => 
      materials.fold(0, (sum, material) => sum + material.quantity);

  // 合成コストの表示用文字列
  String get goldCostFormatted {
    return goldCost.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
  }

  CraftingRecipe copyWith({
    int? id,
    int? weaponId,
    String? name,
    String? description,
    int? goldCost,
    double? successRate,
    int? requiredLevel,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Weapon? weapon,
    List<RecipeMaterial>? materials,
    bool? canCraft,
    List<String>? missingRequirements,
  }) {
    return CraftingRecipe(
      id: id ?? this.id,
      weaponId: weaponId ?? this.weaponId,
      name: name ?? this.name,
      description: description ?? this.description,
      goldCost: goldCost ?? this.goldCost,
      successRate: successRate ?? this.successRate,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weapon: weapon ?? this.weapon,
      materials: materials ?? this.materials,
      canCraft: canCraft ?? this.canCraft,
      missingRequirements: missingRequirements ?? this.missingRequirements,
    );
  }
}

class RecipeMaterial {
  final int materialId;
  final int quantity;
  final Material material;

  RecipeMaterial({
    required this.materialId,
    required this.quantity,
    required this.material,
  });

  factory RecipeMaterial.fromJson(Map<String, dynamic> json) {
    return RecipeMaterial(
      materialId: json['material_id'] is int ? json['material_id'] : int.tryParse(json['material_id'].toString()) ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      material: Material.fromJson(json['material']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'quantity': quantity,
      'material': material.toJson(),
    };
  }
}

class Material {
  final int id;
  final String name;
  final String description;
  final String rarity;
  final int sellPrice;
  final bool isActive;

  Material({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.sellPrice,
    required this.isActive,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      rarity: json['rarity']?.toString() ?? 'common',
      sellPrice: json['sell_price'] is int ? json['sell_price'] : int.tryParse(json['sell_price'].toString()) ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rarity': rarity,
      'sell_price': sellPrice,
      'is_active': isActive,
    };
  }

  // レアリティに基づく色を取得
  Color get rarityColor {
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
}

class CraftingRequest {
  final int recipeId;

  CraftingRequest({
    required this.recipeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
    };
  }
}

class CraftingResult {
  final bool success;
  final bool weaponCreated;
  final String? weaponId;
  final int goldSpent;
  final List<ConsumedMaterial> materialsConsumed;
  final String message;

  CraftingResult({
    required this.success,
    required this.weaponCreated,
    this.weaponId,
    required this.goldSpent,
    required this.materialsConsumed,
    required this.message,
  });

  factory CraftingResult.fromJson(Map<String, dynamic> json) {
    return CraftingResult(
      success: json['success'],
      weaponCreated: json['weapon_created'],
      weaponId: json['weapon_id'],
      goldSpent: json['gold_spent'],
      materialsConsumed: (json['materials_consumed'] as List)
          .map((material) => ConsumedMaterial.fromJson(material))
          .toList(),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'weapon_created': weaponCreated,
      'weapon_id': weaponId,
      'gold_spent': goldSpent,
      'materials_consumed': materialsConsumed.map((m) => m.toJson()).toList(),
      'message': message,
    };
  }
}

class ConsumedMaterial {
  final int materialId;
  final String materialName;
  final int quantity;

  ConsumedMaterial({
    required this.materialId,
    required this.materialName,
    required this.quantity,
  });

  factory ConsumedMaterial.fromJson(Map<String, dynamic> json) {
    return ConsumedMaterial(
      materialId: json['material_id'],
      materialName: json['material_name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'material_name': materialName,
      'quantity': quantity,
    };
  }
}

class PlayerMaterial {
  final int materialId;
  final int quantity;
  final Material material;

  PlayerMaterial({
    required this.materialId,
    required this.quantity,
    required this.material,
  });

  factory PlayerMaterial.fromJson(Map<String, dynamic> json) {
    return PlayerMaterial(
      materialId: json['material_id'] is int ? json['material_id'] : int.tryParse(json['material_id'].toString()) ?? 0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      material: Material.fromJson(json['material']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'quantity': quantity,
      'material': material.toJson(),
    };
  }
}

class CraftingAvailability {
  final int recipeId;
  final bool canCraft;
  final List<String> missingRequirements;
  final List<RequiredMaterial> requiredMaterials;
  final List<PlayerMaterialInfo> playerMaterials;

  CraftingAvailability({
    required this.recipeId,
    required this.canCraft,
    required this.missingRequirements,
    required this.requiredMaterials,
    required this.playerMaterials,
  });

  factory CraftingAvailability.fromJson(Map<String, dynamic> json) {
    return CraftingAvailability(
      recipeId: json['recipe_id'],
      canCraft: json['can_craft'],
      missingRequirements: List<String>.from(json['missing_requirements']),
      requiredMaterials: (json['required_materials'] as List)
          .map((material) => RequiredMaterial.fromJson(material))
          .toList(),
      playerMaterials: (json['player_materials'] as List)
          .map((material) => PlayerMaterialInfo.fromJson(material))
          .toList(),
    );
  }
}

class RequiredMaterial {
  final int materialId;
  final String materialName;
  final int requiredQuantity;

  RequiredMaterial({
    required this.materialId,
    required this.materialName,
    required this.requiredQuantity,
  });

  factory RequiredMaterial.fromJson(Map<String, dynamic> json) {
    return RequiredMaterial(
      materialId: json['material_id'],
      materialName: json['material_name'],
      requiredQuantity: json['required_quantity'],
    );
  }
}

class PlayerMaterialInfo {
  final int materialId;
  final int quantity;

  PlayerMaterialInfo({
    required this.materialId,
    required this.quantity,
  });

  factory PlayerMaterialInfo.fromJson(Map<String, dynamic> json) {
    return PlayerMaterialInfo(
      materialId: json['material_id'],
      quantity: json['quantity'],
    );
  }
}
