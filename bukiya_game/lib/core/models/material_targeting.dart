import 'package:json_annotation/json_annotation.dart';

part 'material_targeting.g.dart';

/// 素材ターゲティング情報
@JsonSerializable()
class MaterialTargetInfo {
  @JsonKey(defaultValue: 0)
  final int materialId;
  @JsonKey(defaultValue: '')
  final String materialName;
  @JsonKey(defaultValue: 1.0)
  final double boostMultiplier;
  @JsonKey(defaultValue: 0)
  final int targetCost;

  MaterialTargetInfo({
    required this.materialId,
    required this.materialName,
    required this.boostMultiplier,
    required this.targetCost,
  });

  factory MaterialTargetInfo.fromJson(Map<String, dynamic> json) =>
      _$MaterialTargetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialTargetInfoToJson(this);

  /// ブーストレベルに応じた表示テキスト
  String get boostDisplayText {
    if (boostMultiplier >= 3.0) return '特級 (3.0x)';
    if (boostMultiplier >= 2.0) return '高級 (2.0x)';
    if (boostMultiplier >= 1.5) return '基本 (1.5x)';
    return '通常 (1.0x)';
  }

  /// コストに応じた背景色
  String get costColorHex {
    if (targetCost >= 500) return '#FF5722'; // 赤
    if (targetCost >= 150) return '#FF9800'; // オレンジ
    if (targetCost >= 50) return '#4CAF50';  // 緑
    return '#9E9E9E'; // グレー
  }
}

/// クエストエリアのドロップ情報
@JsonSerializable()
class QuestAreaDropInfo {
  @JsonKey(defaultValue: 0)
  final int questAreaId;
  @JsonKey(defaultValue: '')
  final String questAreaName;
  @JsonKey(defaultValue: <MaterialTargetInfo>[])
  final List<MaterialTargetInfo> primaryMaterials;
  @JsonKey(defaultValue: <MaterialTargetInfo>[])
  final List<MaterialTargetInfo> secondaryMaterials;

  QuestAreaDropInfo({
    required this.questAreaId,
    required this.questAreaName,
    required this.primaryMaterials,
    required this.secondaryMaterials,
  });

  factory QuestAreaDropInfo.fromJson(Map<String, dynamic> json) =>
      _$QuestAreaDropInfoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestAreaDropInfoToJson(this);

  /// 全ての素材情報を結合
  List<MaterialTargetInfo> get allMaterials =>
      [...primaryMaterials, ...secondaryMaterials];

  /// 特定の素材IDがドロップするかチェック
  bool containsMaterial(int materialId) {
    return allMaterials.any((material) => material.materialId == materialId);
  }

  /// 主要素材かどうかチェック
  bool isPrimaryMaterial(int materialId) {
    return primaryMaterials.any((material) => material.materialId == materialId);
  }
}

/// 素材ターゲティングのブーストレベル設定
class MaterialTargetingLevel {
  final int level;
  final String name;
  final double multiplier;
  final int cost;
  final String description;

  const MaterialTargetingLevel({
    required this.level,
    required this.name,
    required this.multiplier,
    required this.cost,
    required this.description,
  });

  static const List<MaterialTargetingLevel> levels = [
    MaterialTargetingLevel(
      level: 1,
      name: '基本ターゲティング',
      multiplier: 1.5,
      cost: 50,
      description: 'ドロップ率1.5倍',
    ),
    MaterialTargetingLevel(
      level: 2,
      name: '高級ターゲティング',
      multiplier: 2.0,
      cost: 150,
      description: 'ドロップ率2.0倍',
    ),
    MaterialTargetingLevel(
      level: 3,
      name: '特級ターゲティング',
      multiplier: 3.0,
      cost: 500,
      description: 'ドロップ率3.0倍',
    ),
  ];

  static MaterialTargetingLevel getByLevel(int level) {
    return levels.firstWhere(
      (l) => l.level == level,
      orElse: () => levels.first,
    );
  }

  /// コストに応じた色
  String get colorHex {
    switch (level) {
      case 1:
        return '#4CAF50'; // 緑
      case 2:
        return '#FF9800'; // オレンジ
      case 3:
        return '#F44336'; // 赤
      default:
        return '#9E9E9E'; // グレー
    }
  }
}

/// 素材ターゲティング派遣リクエスト
class MaterialTargetRequest {
  final int? targetMaterialId;
  final int boostLevel;

  MaterialTargetRequest({
    this.targetMaterialId,
    this.boostLevel = 1,
  });

  Map<String, dynamic> toJson() => {
        if (targetMaterialId != null) 'target_material_id': targetMaterialId,
        'boost_level': boostLevel,
      };

  /// コストを計算
  int get cost => MaterialTargetingLevel.getByLevel(boostLevel).cost;

  /// 倍率を取得
  double get multiplier => MaterialTargetingLevel.getByLevel(boostLevel).multiplier;

  /// レベル情報を取得
  MaterialTargetingLevel get levelInfo => MaterialTargetingLevel.getByLevel(boostLevel);
}