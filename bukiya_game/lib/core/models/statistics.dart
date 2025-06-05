import 'package:flutter/material.dart';

/// 統計データの期間
enum StatisticsPeriod {
  daily,    // 日別
  weekly,   // 週別
  monthly,  // 月別
  allTime,  // 全期間
}

/// 統計データポイント
class StatisticsDataPoint {
  final DateTime date;
  final double value;
  final Map<String, dynamic>? metadata;

  const StatisticsDataPoint({
    required this.date,
    required this.value,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'value': value,
    'metadata': metadata,
  };

  factory StatisticsDataPoint.fromJson(Map<String, dynamic> json) => StatisticsDataPoint(
    date: DateTime.parse(json['date']),
    value: json['value']?.toDouble() ?? 0.0,
    metadata: json['metadata'],
  );
}

/// 売上統計
class SalesStatistics {
  final int totalSales;              // 総売上額
  final int totalTransactions;       // 総取引数
  final double averageTransactionValue; // 平均取引額
  final Map<String, int> salesByWeaponType; // 武器種別売上
  final Map<String, int> salesByRarity;     // レアリティ別売上
  final List<StatisticsDataPoint> dailySales; // 日別売上
  final DateTime lastUpdated;

  const SalesStatistics({
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.salesByWeaponType,
    required this.salesByRarity,
    required this.dailySales,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'total_sales': totalSales,
    'total_transactions': totalTransactions,
    'average_transaction_value': averageTransactionValue,
    'sales_by_weapon_type': salesByWeaponType,
    'sales_by_rarity': salesByRarity,
    'daily_sales': dailySales.map((e) => e.toJson()).toList(),
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory SalesStatistics.fromJson(Map<String, dynamic> json) => SalesStatistics(
    totalSales: json['total_sales'] ?? 0,
    totalTransactions: json['total_transactions'] ?? 0,
    averageTransactionValue: json['average_transaction_value']?.toDouble() ?? 0.0,
    salesByWeaponType: Map<String, int>.from(json['sales_by_weapon_type'] ?? {}),
    salesByRarity: Map<String, int>.from(json['sales_by_rarity'] ?? {}),
    dailySales: (json['daily_sales'] as List<dynamic>?)
        ?.map((e) => StatisticsDataPoint.fromJson(e))
        .toList() ?? [],
    lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
  );

  // 空の統計データ
  static SalesStatistics empty() => SalesStatistics(
    totalSales: 0,
    totalTransactions: 0,
    averageTransactionValue: 0.0,
    salesByWeaponType: {},
    salesByRarity: {},
    dailySales: [],
    lastUpdated: DateTime.now(),
  );
}

/// 製造統計
class CraftingStatistics {
  final int totalCrafted;            // 総製造数
  final int successfulCrafts;        // 成功数
  final int failedCrafts;            // 失敗数
  final double successRate;          // 成功率
  final Map<String, int> craftsByWeaponType; // 武器種別製造数
  final Map<String, int> craftsByRarity;     // レアリティ別製造数
  final List<StatisticsDataPoint> dailyCrafts; // 日別製造数
  final int materialsUsed;           // 使用素材数
  final DateTime lastUpdated;

  const CraftingStatistics({
    required this.totalCrafted,
    required this.successfulCrafts,
    required this.failedCrafts,
    required this.successRate,
    required this.craftsByWeaponType,
    required this.craftsByRarity,
    required this.dailyCrafts,
    required this.materialsUsed,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'total_crafted': totalCrafted,
    'successful_crafts': successfulCrafts,
    'failed_crafts': failedCrafts,
    'success_rate': successRate,
    'crafts_by_weapon_type': craftsByWeaponType,
    'crafts_by_rarity': craftsByRarity,
    'daily_crafts': dailyCrafts.map((e) => e.toJson()).toList(),
    'materials_used': materialsUsed,
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory CraftingStatistics.fromJson(Map<String, dynamic> json) => CraftingStatistics(
    totalCrafted: json['total_crafted'] ?? 0,
    successfulCrafts: json['successful_crafts'] ?? 0,
    failedCrafts: json['failed_crafts'] ?? 0,
    successRate: json['success_rate']?.toDouble() ?? 0.0,
    craftsByWeaponType: Map<String, int>.from(json['crafts_by_weapon_type'] ?? {}),
    craftsByRarity: Map<String, int>.from(json['crafts_by_rarity'] ?? {}),
    dailyCrafts: (json['daily_crafts'] as List<dynamic>?)
        ?.map((e) => StatisticsDataPoint.fromJson(e))
        .toList() ?? [],
    materialsUsed: json['materials_used'] ?? 0,
    lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
  );

  static CraftingStatistics empty() => CraftingStatistics(
    totalCrafted: 0,
    successfulCrafts: 0,
    failedCrafts: 0,
    successRate: 0.0,
    craftsByWeaponType: {},
    craftsByRarity: {},
    dailyCrafts: [],
    materialsUsed: 0,
    lastUpdated: DateTime.now(),
  );
}

/// エンチャント統計
class EnchantmentStatistics {
  final int totalEnchantments;       // 総エンチャント回数
  final int successfulEnchantments;  // 成功回数
  final int failedEnchantments;      // 失敗回数
  final int destroyedWeapons;        // 破壊された武器数
  final double successRate;          // 成功率
  final double destructionRate;      // 破壊率
  final Map<String, int> enchantmentsByType; // タイプ別エンチャント回数
  final Map<int, int> enchantmentsByLevel;   // レベル別エンチャント回数
  final List<StatisticsDataPoint> dailyEnchantments; // 日別エンチャント回数
  final int totalCostSpent;          // 総費用
  final DateTime lastUpdated;

  const EnchantmentStatistics({
    required this.totalEnchantments,
    required this.successfulEnchantments,
    required this.failedEnchantments,
    required this.destroyedWeapons,
    required this.successRate,
    required this.destructionRate,
    required this.enchantmentsByType,
    required this.enchantmentsByLevel,
    required this.dailyEnchantments,
    required this.totalCostSpent,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'total_enchantments': totalEnchantments,
    'successful_enchantments': successfulEnchantments,
    'failed_enchantments': failedEnchantments,
    'destroyed_weapons': destroyedWeapons,
    'success_rate': successRate,
    'destruction_rate': destructionRate,
    'enchantments_by_type': enchantmentsByType,
    'enchantments_by_level': enchantmentsByLevel.map((k, v) => MapEntry(k.toString(), v)),
    'daily_enchantments': dailyEnchantments.map((e) => e.toJson()).toList(),
    'total_cost_spent': totalCostSpent,
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory EnchantmentStatistics.fromJson(Map<String, dynamic> json) => EnchantmentStatistics(
    totalEnchantments: json['total_enchantments'] ?? 0,
    successfulEnchantments: json['successful_enchantments'] ?? 0,
    failedEnchantments: json['failed_enchantments'] ?? 0,
    destroyedWeapons: json['destroyed_weapons'] ?? 0,
    successRate: json['success_rate']?.toDouble() ?? 0.0,
    destructionRate: json['destruction_rate']?.toDouble() ?? 0.0,
    enchantmentsByType: Map<String, int>.from(json['enchantments_by_type'] ?? {}),
    enchantmentsByLevel: (json['enchantments_by_level'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(int.parse(k), v as int)) ?? {},
    dailyEnchantments: (json['daily_enchantments'] as List<dynamic>?)
        ?.map((e) => StatisticsDataPoint.fromJson(e))
        .toList() ?? [],
    totalCostSpent: json['total_cost_spent'] ?? 0,
    lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
  );

  static EnchantmentStatistics empty() => EnchantmentStatistics(
    totalEnchantments: 0,
    successfulEnchantments: 0,
    failedEnchantments: 0,
    destroyedWeapons: 0,
    successRate: 0.0,
    destructionRate: 0.0,
    enchantmentsByType: {},
    enchantmentsByLevel: {},
    dailyEnchantments: [],
    totalCostSpent: 0,
    lastUpdated: DateTime.now(),
  );
}

/// 冒険者統計
class AdventurerStatistics {
  final int totalAdventurersServed;  // 総対応冒険者数
  final int totalTransactions;       // 総取引数
  final double averageTransactionValue; // 平均取引額
  final Map<String, int> transactionsByWeaponType; // 武器種別取引数
  final Map<String, int> transactionsByAdventurerType; // 冒険者タイプ別取引数
  final List<StatisticsDataPoint> dailyTransactions; // 日別取引数
  final int totalQuestsCompleted;    // 完了クエスト数
  final DateTime lastUpdated;

  const AdventurerStatistics({
    required this.totalAdventurersServed,
    required this.totalTransactions,
    required this.averageTransactionValue,
    required this.transactionsByWeaponType,
    required this.transactionsByAdventurerType,
    required this.dailyTransactions,
    required this.totalQuestsCompleted,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'total_adventurers_served': totalAdventurersServed,
    'total_transactions': totalTransactions,
    'average_transaction_value': averageTransactionValue,
    'transactions_by_weapon_type': transactionsByWeaponType,
    'transactions_by_adventurer_type': transactionsByAdventurerType,
    'daily_transactions': dailyTransactions.map((e) => e.toJson()).toList(),
    'total_quests_completed': totalQuestsCompleted,
    'last_updated': lastUpdated.toIso8601String(),
  };

  factory AdventurerStatistics.fromJson(Map<String, dynamic> json) => AdventurerStatistics(
    totalAdventurersServed: json['total_adventurers_served'] ?? 0,
    totalTransactions: json['total_transactions'] ?? 0,
    averageTransactionValue: json['average_transaction_value']?.toDouble() ?? 0.0,
    transactionsByWeaponType: Map<String, int>.from(json['transactions_by_weapon_type'] ?? {}),
    transactionsByAdventurerType: Map<String, int>.from(json['transactions_by_adventurer_type'] ?? {}),
    dailyTransactions: (json['daily_transactions'] as List<dynamic>?)
        ?.map((e) => StatisticsDataPoint.fromJson(e))
        .toList() ?? [],
    totalQuestsCompleted: json['total_quests_completed'] ?? 0,
    lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
  );

  static AdventurerStatistics empty() => AdventurerStatistics(
    totalAdventurersServed: 0,
    totalTransactions: 0,
    averageTransactionValue: 0.0,
    transactionsByWeaponType: {},
    transactionsByAdventurerType: {},
    dailyTransactions: [],
    totalQuestsCompleted: 0,
    lastUpdated: DateTime.now(),
  );
}

/// 総合統計データ
class PlayerStatisticsData {
  final SalesStatistics sales;
  final CraftingStatistics crafting;
  final EnchantmentStatistics enchantment;
  final AdventurerStatistics adventurer;
  final DateTime lastUpdated;
  final StatisticsPeriod currentPeriod;

  const PlayerStatisticsData({
    required this.sales,
    required this.crafting,
    required this.enchantment,
    required this.adventurer,
    required this.lastUpdated,
    this.currentPeriod = StatisticsPeriod.weekly,
  });

  Map<String, dynamic> toJson() => {
    'sales': sales.toJson(),
    'crafting': crafting.toJson(),
    'enchantment': enchantment.toJson(),
    'adventurer': adventurer.toJson(),
    'last_updated': lastUpdated.toIso8601String(),
    'current_period': currentPeriod.name,
  };

  factory PlayerStatisticsData.fromJson(Map<String, dynamic> json) => PlayerStatisticsData(
    sales: SalesStatistics.fromJson(json['sales'] ?? {}),
    crafting: CraftingStatistics.fromJson(json['crafting'] ?? {}),
    enchantment: EnchantmentStatistics.fromJson(json['enchantment'] ?? {}),
    adventurer: AdventurerStatistics.fromJson(json['adventurer'] ?? {}),
    lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    currentPeriod: StatisticsPeriod.values.firstWhere(
      (e) => e.name == json['current_period'],
      orElse: () => StatisticsPeriod.weekly,
    ),
  );

  static PlayerStatisticsData empty() => PlayerStatisticsData(
    sales: SalesStatistics.empty(),
    crafting: CraftingStatistics.empty(),
    enchantment: EnchantmentStatistics.empty(),
    adventurer: AdventurerStatistics.empty(),
    lastUpdated: DateTime.now(),
  );

  /// 総収益を計算
  int get totalRevenue => sales.totalSales;

  /// 総アクティビティ数
  int get totalActivities => 
      sales.totalTransactions + 
      crafting.totalCrafted + 
      enchantment.totalEnchantments +
      adventurer.totalTransactions;

  /// 効率指標（収益/アクティビティ）
  double get efficiencyRatio => 
      totalActivities > 0 ? totalRevenue / totalActivities : 0.0;

  PlayerStatisticsData copyWith({
    SalesStatistics? sales,
    CraftingStatistics? crafting,
    EnchantmentStatistics? enchantment,
    AdventurerStatistics? adventurer,
    DateTime? lastUpdated,
    StatisticsPeriod? currentPeriod,
  }) {
    return PlayerStatisticsData(
      sales: sales ?? this.sales,
      crafting: crafting ?? this.crafting,
      enchantment: enchantment ?? this.enchantment,
      adventurer: adventurer ?? this.adventurer,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentPeriod: currentPeriod ?? this.currentPeriod,
    );
  }
}

/// チャート用のデータセット
class ChartDataSet {
  final String label;
  final List<StatisticsDataPoint> dataPoints;
  final Color color;
  final bool showTrend;

  const ChartDataSet({
    required this.label,
    required this.dataPoints,
    required this.color,
    this.showTrend = false,
  });

  /// 最大値を取得
  double get maxValue => dataPoints.isEmpty 
      ? 0.0 
      : dataPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b);

  /// 最小値を取得
  double get minValue => dataPoints.isEmpty 
      ? 0.0 
      : dataPoints.map((e) => e.value).reduce((a, b) => a < b ? a : b);

  /// 平均値を取得
  double get averageValue => dataPoints.isEmpty 
      ? 0.0 
      : dataPoints.map((e) => e.value).reduce((a, b) => a + b) / dataPoints.length;

  /// トレンド方向を取得（1: 上昇, 0: 横ばい, -1: 下降）
  int get trendDirection {
    if (dataPoints.length < 2) return 0;
    
    final first = dataPoints.first.value;
    final last = dataPoints.last.value;
    
    if (last > first * 1.05) return 1;  // 5%以上の上昇
    if (last < first * 0.95) return -1; // 5%以上の下降
    return 0; // 横ばい
  }
}