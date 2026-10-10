import 'dart:math';

import 'loadout.dart';

enum SkillId {
  bladeLength,
  swordPower,
  swordSpeed,
  arrowCount,
  arrowPierce,
  bowSpeed,
  moveSpeed,
  vitality,
  magnet,
  giantSlayer,
  potion,
}

class SkillDef {
  final SkillId id;
  final String name;
  final String description;
  final int maxLevel;

  /// この武器を持ち出しているときだけ候補に出る
  final CarriedWeaponType? requires;

  const SkillDef({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    this.requires,
  });
}

const Map<SkillId, SkillDef> skillDefs = {
  SkillId.bladeLength: SkillDef(
    id: SkillId.bladeLength,
    name: '刃渡り',
    description: '剣が大きくなり、攻撃範囲が広がる',
    maxLevel: 5,
    requires: CarriedWeaponType.sword,
  ),
  SkillId.swordPower: SkillDef(
    id: SkillId.swordPower,
    name: '剛腕',
    description: '剣のダメージ +25%',
    maxLevel: 5,
    requires: CarriedWeaponType.sword,
  ),
  SkillId.swordSpeed: SkillDef(
    id: SkillId.swordSpeed,
    name: '素振り',
    description: '剣を振る間隔 -12%',
    maxLevel: 5,
    requires: CarriedWeaponType.sword,
  ),
  SkillId.arrowCount: SkillDef(
    id: SkillId.arrowCount,
    name: '多重射ち',
    description: '一度に放つ矢 +1',
    maxLevel: 4,
    requires: CarriedWeaponType.bow,
  ),
  SkillId.arrowPierce: SkillDef(
    id: SkillId.arrowPierce,
    name: '貫通矢',
    description: '矢が敵を1体多く貫く',
    maxLevel: 3,
    requires: CarriedWeaponType.bow,
  ),
  SkillId.bowSpeed: SkillDef(
    id: SkillId.bowSpeed,
    name: '速射',
    description: '矢を放つ間隔 -12%',
    maxLevel: 5,
    requires: CarriedWeaponType.bow,
  ),
  SkillId.moveSpeed: SkillDef(
    id: SkillId.moveSpeed,
    name: '俊足',
    description: '移動速度 +10%',
    maxLevel: 5,
  ),
  SkillId.vitality: SkillDef(
    id: SkillId.vitality,
    name: '頑丈',
    description: '最大HP +20、HPを30%回復',
    maxLevel: 5,
  ),
  SkillId.magnet: SkillDef(
    id: SkillId.magnet,
    name: '磁石',
    description: '経験値と素材を拾える距離が広がる',
    maxLevel: 3,
  ),
  SkillId.giantSlayer: SkillDef(
    id: SkillId.giantSlayer,
    name: '進化：巨人殺しの大剣',
    description: '剣が巨大化し、振りも速くなる（刃渡りMAX＋頑丈で解放）',
    maxLevel: 1,
    requires: CarriedWeaponType.sword,
  ),
  SkillId.potion: SkillDef(
    id: SkillId.potion,
    name: '回復薬',
    description: 'HPを50%回復',
    maxLevel: 999,
  ),
};

/// 取得済みスキルのレベルを管理する
class SkillSet {
  final Map<SkillId, int> _levels = {};

  int level(SkillId id) => _levels[id] ?? 0;

  bool isMaxed(SkillId id) => level(id) >= skillDefs[id]!.maxLevel;

  void add(SkillId id) {
    if (id == SkillId.potion) return;
    _levels[id] = level(id) + 1;
  }

  bool get canEvolveSword =>
      isMaxed(SkillId.bladeLength) &&
      level(SkillId.vitality) >= 1 &&
      level(SkillId.giantSlayer) == 0;

  /// レベルアップ時の候補を最大 [count] 個選ぶ。
  /// 進化が可能なら必ず候補に入れる。候補が尽きたら回復薬を出す。
  List<SkillId> offer(
    Set<CarriedWeaponType> carried,
    Random rng, {
    int count = 3,
  }) {
    final result = <SkillId>[];
    if (carried.contains(CarriedWeaponType.sword) && canEvolveSword) {
      result.add(SkillId.giantSlayer);
    }
    final pool = skillDefs.values
        .where((d) =>
            d.id != SkillId.giantSlayer &&
            d.id != SkillId.potion &&
            (d.requires == null || carried.contains(d.requires)) &&
            !isMaxed(d.id))
        .map((d) => d.id)
        .toList()
      ..shuffle(rng);
    for (final id in pool) {
      if (result.length >= count) break;
      result.add(id);
    }
    if (result.isEmpty) result.add(SkillId.potion);
    return result;
  }
}
