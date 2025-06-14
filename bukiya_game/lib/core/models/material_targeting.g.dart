// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_targeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MaterialTargetInfo _$MaterialTargetInfoFromJson(Map<String, dynamic> json) =>
    MaterialTargetInfo(
      materialId: (json['materialId'] as num?)?.toInt() ?? 0,
      materialName: json['materialName'] as String? ?? '',
      boostMultiplier: (json['boostMultiplier'] as num?)?.toDouble() ?? 1.0,
      targetCost: (json['targetCost'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MaterialTargetInfoToJson(MaterialTargetInfo instance) =>
    <String, dynamic>{
      'materialId': instance.materialId,
      'materialName': instance.materialName,
      'boostMultiplier': instance.boostMultiplier,
      'targetCost': instance.targetCost,
    };

QuestAreaDropInfo _$QuestAreaDropInfoFromJson(Map<String, dynamic> json) =>
    QuestAreaDropInfo(
      questAreaId: (json['questAreaId'] as num?)?.toInt() ?? 0,
      questAreaName: json['questAreaName'] as String? ?? '',
      primaryMaterials: (json['primaryMaterials'] as List<dynamic>?)
              ?.map(
                  (e) => MaterialTargetInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      secondaryMaterials: (json['secondaryMaterials'] as List<dynamic>?)
              ?.map(
                  (e) => MaterialTargetInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$QuestAreaDropInfoToJson(QuestAreaDropInfo instance) =>
    <String, dynamic>{
      'questAreaId': instance.questAreaId,
      'questAreaName': instance.questAreaName,
      'primaryMaterials': instance.primaryMaterials,
      'secondaryMaterials': instance.secondaryMaterials,
    };
