import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/enchantment.dart';
import '../../../core/models/inventory.dart';
import '../../../core/constants/app_constants.dart';

/// エンチャント失敗時の結果処理サービス
/// 
/// エンチャント失敗時の詳細な処理と補償システムを提供します
class EnchantmentFailureService {
  static const String _failureHistoryKey = 'enchant_failure_history';
  static const String _failureStatsKey = 'enchant_failure_stats';
  
  // 失敗時の補償レート
  static const double _materialReturnRate = 0.3; // 30%の素材返却
  static const double _goldReturnRate = 0.2; // 20%のゴールド返却
  static const double _pityRate = 0.05; // 5%の同情ボーナス
  
  /// 失敗時の詳細処理
  static Future<EnchantmentFailureResult> processFailure({
    required EnchantmentResponse enchantmentResult,
    required PlayerWeapon weapon,
    required EnchantmentType enchantmentType,
    required List<EnchantmentMaterial> usedMaterials,
    required int cost,
    required bool useProtection,
  }) async {
    final failureType = enchantmentResult.result;
    final now = DateTime.now();
    
    // 失敗統計を更新
    await _updateFailureStats(failureType, enchantmentType.id);
    
    // 失敗結果を計算
    final result = await _calculateFailureConsequences(
      failureType: failureType,
      weapon: weapon,
      enchantmentType: enchantmentType,
      usedMaterials: usedMaterials,
      cost: cost,
      useProtection: useProtection,
    );
    
    // 失敗履歴を記録
    await _recordFailureHistory(EnchantmentFailureLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weaponId: int.parse(weapon.id),
      weaponName: weapon.weaponMaster.name,
      enchantmentTypeId: enchantmentType.id,
      enchantmentTypeName: enchantmentType.name,
      failureType: failureType,
      originalCost: cost,
      usedMaterials: usedMaterials.map((m) => m.name).toList(),
      useProtection: useProtection,
      compensation: result,
      createdAt: now,
    ));
    
    return result;
  }
  
  /// 失敗時の補償計算
  static Future<EnchantmentFailureResult> _calculateFailureConsequences({
    required EnchantmentResult failureType,
    required PlayerWeapon weapon,
    required EnchantmentType enchantmentType,
    required List<EnchantmentMaterial> usedMaterials,
    required int cost,
    required bool useProtection,
  }) async {
    switch (failureType) {
      case EnchantmentResult.success:
        // 成功時は補償なし
        return const EnchantmentFailureResult(
          failureType: EnchantmentResult.success,
          weaponDestroyed: false,
          goldCompensation: 0,
          materialCompensation: [],
          protectionUsed: false,
          pityPointsGained: 0,
          nextSuccessRateBonus: 0.0,
          message: '成功しました！',
        );
        
      case EnchantmentResult.failure:
        return await _calculateFailureCompensation(
          weapon: weapon,
          enchantmentType: enchantmentType,
          usedMaterials: usedMaterials,
          cost: cost,
          useProtection: useProtection,
        );
        
      case EnchantmentResult.destroy:
        return await _calculateDestroyCompensation(
          weapon: weapon,
          enchantmentType: enchantmentType,
          usedMaterials: usedMaterials,
          cost: cost,
          useProtection: useProtection,
        );
    }
  }
  
  /// 通常失敗時の補償計算
  static Future<EnchantmentFailureResult> _calculateFailureCompensation({
    required PlayerWeapon weapon,
    required EnchantmentType enchantmentType,
    required List<EnchantmentMaterial> usedMaterials,
    required int cost,
    required bool useProtection,
  }) async {
    final failureStats = await _getFailureStats();
    final consecutiveFailures = failureStats[enchantmentType.id.toString()] ?? 0;
    
    // 連続失敗による同情ボーナス
    final pityBonus = (consecutiveFailures * _pityRate).clamp(0.0, 0.3);
    
    // 基本補償計算
    final goldCompensation = (cost * (_goldReturnRate + pityBonus)).round();
    final materialCompensation = _calculateMaterialReturn(usedMaterials, _materialReturnRate + pityBonus);
    final pityPoints = (consecutiveFailures * 5).clamp(0, 100);
    
    // 次回成功率ボーナス
    final nextSuccessRateBonus = (consecutiveFailures * 0.02).clamp(0.0, 0.2); // 最大20%
    
    return EnchantmentFailureResult(
      failureType: EnchantmentResult.failure,
      weaponDestroyed: false,
      goldCompensation: goldCompensation,
      materialCompensation: materialCompensation,
      protectionUsed: false,
      pityPointsGained: pityPoints,
      nextSuccessRateBonus: nextSuccessRateBonus,
      message: _generateFailureMessage(consecutiveFailures, goldCompensation, materialCompensation.length),
    );
  }
  
  /// 武器破壊時の補償計算
  static Future<EnchantmentFailureResult> _calculateDestroyCompensation({
    required PlayerWeapon weapon,
    required EnchantmentType enchantmentType,
    required List<EnchantmentMaterial> usedMaterials,
    required int cost,
    required bool useProtection,
  }) async {
    // 保護アイテム使用時
    if (useProtection) {
      return const EnchantmentFailureResult(
        failureType: EnchantmentResult.destroy,
        weaponDestroyed: false,
        goldCompensation: 0,
        materialCompensation: [],
        protectionUsed: true,
        pityPointsGained: 10,
        nextSuccessRateBonus: 0.05,
        message: '保護アイテムにより武器が守られました！',
      );
    }
    
    // 武器破壊時の手厚い補償
    final weaponValue = _calculateWeaponValue(weapon);
    final totalLoss = weaponValue + cost;
    
    // 破壊補償（損失の50%）
    final goldCompensation = (totalLoss * 0.5).round();
    final materialCompensation = _calculateMaterialReturn(usedMaterials, 0.8); // 80%返却
    
    // 大量の同情ポイント
    final pityPoints = 50;
    final nextSuccessRateBonus = 0.15; // 15%ボーナス
    
    return EnchantmentFailureResult(
      failureType: EnchantmentResult.destroy,
      weaponDestroyed: true,
      goldCompensation: goldCompensation,
      materialCompensation: materialCompensation,
      protectionUsed: false,
      pityPointsGained: pityPoints,
      nextSuccessRateBonus: nextSuccessRateBonus,
      message: _generateDestroyMessage(weapon.weaponMaster.name, goldCompensation, materialCompensation.length),
    );
  }
  
  /// 武器価値計算
  static int _calculateWeaponValue(PlayerWeapon weapon) {
    // 基本価格 + エンチャント価値
    var value = weapon.weaponMaster.price;
    
    // エンチャントレベルによる価値増加
    // エンチャントによる価値加算（エンチャントレベルから推定）
    value += weapon.enchantLevel * 100;
    
    return value;
  }
  
  /// 素材返却計算
  static List<MaterialCompensation> _calculateMaterialReturn(
    List<EnchantmentMaterial> usedMaterials,
    double returnRate,
  ) {
    final compensation = <MaterialCompensation>[];
    final random = Random();
    
    for (final material in usedMaterials) {
      // 確率的返却
      if (random.nextDouble() < returnRate) {
        compensation.add(MaterialCompensation(
          materialId: material.id,
          materialName: material.name,
          quantity: 1,
          rarity: material.rarity,
        ));
      }
    }
    
    return compensation;
  }
  
  /// 失敗統計更新
  static Future<void> _updateFailureStats(EnchantmentResult result, int enchantmentTypeId) async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final stats = Map<String, int>.from(box.get(_failureStatsKey, defaultValue: <String, int>{}));
      
      final key = enchantmentTypeId.toString();
      
      if (result == EnchantmentResult.success) {
        // 成功時はカウンターリセット
        stats[key] = 0;
      } else {
        // 失敗時はカウンター増加
        stats[key] = (stats[key] ?? 0) + 1;
      }
      
      await box.put(_failureStatsKey, stats);
    } catch (e) {
      debugPrint('失敗統計更新エラー: $e');
    }
  }
  
  /// 失敗統計取得
  static Future<Map<String, int>> _getFailureStats() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      return Map<String, int>.from(box.get(_failureStatsKey, defaultValue: <String, int>{}));
    } catch (e) {
      debugPrint('失敗統計取得エラー: $e');
      return {};
    }
  }
  
  /// 失敗履歴記録
  static Future<void> _recordFailureHistory(EnchantmentFailureLog log) async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final history = List<Map>.from(box.get(_failureHistoryKey, defaultValue: <Map>[]));
      
      history.insert(0, log.toJson());
      
      // 最新100件のみ保持
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }
      
      await box.put(_failureHistoryKey, history);
    } catch (e) {
      debugPrint('失敗履歴記録エラー: $e');
    }
  }
  
  /// 失敗履歴取得
  static Future<List<EnchantmentFailureLog>> getFailureHistory() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final history = List<Map>.from(box.get(_failureHistoryKey, defaultValue: <Map>[]));
      
      return history.map((json) => EnchantmentFailureLog.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('失敗履歴取得エラー: $e');
      return [];
    }
  }
  
  /// 連続失敗回数取得
  static Future<int> getConsecutiveFailures(int enchantmentTypeId) async {
    final stats = await _getFailureStats();
    return stats[enchantmentTypeId.toString()] ?? 0;
  }
  
  /// 次回成功率ボーナス取得
  static Future<double> getNextSuccessRateBonus(int enchantmentTypeId) async {
    final consecutiveFailures = await getConsecutiveFailures(enchantmentTypeId);
    return (consecutiveFailures * 0.02).clamp(0.0, 0.2);
  }
  
  /// 失敗メッセージ生成
  static String _generateFailureMessage(int consecutiveFailures, int goldCompensation, int materialCount) {
    if (consecutiveFailures >= 5) {
      return 'エンチャントに失敗しました...\n'
             '連続失敗により特別補償として ${goldCompensation}G と $materialCount 個の素材を受け取りました。\n'
             '次回の成功率がアップします！';
    } else if (consecutiveFailures >= 3) {
      return 'エンチャントに失敗しました。\n'
             '補償として ${goldCompensation}G と $materialCount 個の素材を受け取りました。';
    } else {
      return 'エンチャントに失敗しました。\n'
             '少額の補償として ${goldCompensation}G を受け取りました。';
    }
  }
  
  /// 破壊メッセージ生成
  static String _generateDestroyMessage(String weaponName, int goldCompensation, int materialCount) {
    return '$weaponName が破壊されてしまいました...\n'
           '申し訳ございません。補償として ${goldCompensation}G と $materialCount 個の素材をお渡しします。\n'
           '次回のエンチャント成功率が大幅にアップします！';
  }
}

/// エンチャント失敗結果
class EnchantmentFailureResult {
  final EnchantmentResult failureType;
  final bool weaponDestroyed;
  final int goldCompensation;
  final List<MaterialCompensation> materialCompensation;
  final bool protectionUsed;
  final int pityPointsGained;
  final double nextSuccessRateBonus;
  final String message;
  
  const EnchantmentFailureResult({
    required this.failureType,
    required this.weaponDestroyed,
    required this.goldCompensation,
    required this.materialCompensation,
    required this.protectionUsed,
    required this.pityPointsGained,
    required this.nextSuccessRateBonus,
    required this.message,
  });
  
  /// 補償があるかどうか
  bool get hasCompensation => goldCompensation > 0 || materialCompensation.isNotEmpty || pityPointsGained > 0;
  
  /// 総補償価値
  int get totalCompensationValue => goldCompensation + (materialCompensation.length * 50);
}

/// 素材補償
class MaterialCompensation {
  final int materialId;
  final String materialName;
  final int quantity;
  final String rarity;
  
  const MaterialCompensation({
    required this.materialId,
    required this.materialName,
    required this.quantity,
    required this.rarity,
  });
  
  Map<String, dynamic> toJson() => {
    'material_id': materialId,
    'material_name': materialName,
    'quantity': quantity,
    'rarity': rarity,
  };
  
  factory MaterialCompensation.fromJson(Map<String, dynamic> json) => MaterialCompensation(
    materialId: json['material_id'],
    materialName: json['material_name'],
    quantity: json['quantity'],
    rarity: json['rarity'],
  );
}

/// エンチャント失敗ログ
class EnchantmentFailureLog {
  final String id;
  final int weaponId;
  final String weaponName;
  final int enchantmentTypeId;
  final String enchantmentTypeName;
  final EnchantmentResult failureType;
  final int originalCost;
  final List<String> usedMaterials;
  final bool useProtection;
  final EnchantmentFailureResult compensation;
  final DateTime createdAt;
  
  const EnchantmentFailureLog({
    required this.id,
    required this.weaponId,
    required this.weaponName,
    required this.enchantmentTypeId,
    required this.enchantmentTypeName,
    required this.failureType,
    required this.originalCost,
    required this.usedMaterials,
    required this.useProtection,
    required this.compensation,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'weapon_id': weaponId,
    'weapon_name': weaponName,
    'enchantment_type_id': enchantmentTypeId,
    'enchantment_type_name': enchantmentTypeName,
    'failure_type': failureType.toString(),
    'original_cost': originalCost,
    'used_materials': usedMaterials,
    'use_protection': useProtection,
    'gold_compensation': compensation.goldCompensation,
    'material_compensation': compensation.materialCompensation.map((m) => m.toJson()).toList(),
    'pity_points_gained': compensation.pityPointsGained,
    'next_success_rate_bonus': compensation.nextSuccessRateBonus,
    'created_at': createdAt.toIso8601String(),
  };
  
  factory EnchantmentFailureLog.fromJson(Map<String, dynamic> json) => EnchantmentFailureLog(
    id: json['id'],
    weaponId: json['weapon_id'],
    weaponName: json['weapon_name'],
    enchantmentTypeId: json['enchantment_type_id'],
    enchantmentTypeName: json['enchantment_type_name'],
    failureType: EnchantmentResult.values.firstWhere((e) => e.toString() == json['failure_type']),
    originalCost: json['original_cost'],
    usedMaterials: List<String>.from(json['used_materials']),
    useProtection: json['use_protection'],
    compensation: EnchantmentFailureResult(
      failureType: EnchantmentResult.values.firstWhere((e) => e.toString() == json['failure_type']),
      weaponDestroyed: json['failure_type'] == 'EnchantmentResult.destroy',
      goldCompensation: json['gold_compensation'],
      materialCompensation: (json['material_compensation'] as List)
          .map((m) => MaterialCompensation.fromJson(m))
          .toList(),
      protectionUsed: json['use_protection'],
      pityPointsGained: json['pity_points_gained'],
      nextSuccessRateBonus: json['next_success_rate_bonus'],
      message: '',
    ),
    createdAt: DateTime.parse(json['created_at']),
  );
}