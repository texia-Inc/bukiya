import 'dart:math';

import 'loadout.dart';

enum SkillId {
  // 剣
  bladeLength,
  swordPower,
  swordSpeed,
  // 弓
  arrowCount,
  arrowPierce,
  bowSpeed,
  // 槍
  spearReach,
  spearMulti,
  spearSpeed,
  // 杖
  staffPower,
  staffRadius,
  staffSpeed,
  // 共通
  moveSpeed,
  vitality,
  magnet,
  wisdom,
  // 進化
  giantSlayer,
  stormBow,
  dragoonSpear,
  sageStaff,
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

/// 武器の進化：[maxed] を最大まで上げ、[passive] を1つ以上持つと候補に出る
class EvolutionDef {
  final SkillId evolution;
  final CarriedWeaponType weapon;
  final SkillId maxed;
  final SkillId passive;

  const EvolutionDef(this.evolution, this.weapon, this.maxed, this.passive);
}

const List<EvolutionDef> evolutions = [
  EvolutionDef(SkillId.giantSlayer, CarriedWeaponType.sword,
      SkillId.bladeLength, SkillId.vitality),
  EvolutionDef(SkillId.stormBow, CarriedWeaponType.bow, SkillId.arrowCount,
      SkillId.magnet),
  EvolutionDef(SkillId.dragoonSpear, CarriedWeaponType.spear,
      SkillId.spearReach, SkillId.moveSpeed),
  EvolutionDef(SkillId.sageStaff, CarriedWeaponType.staff, SkillId.staffRadius,
      SkillId.wisdom),
];

bool isEvolution(SkillId id) => evolutions.any((e) => e.evolution == id);

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
  SkillId.spearReach: SkillDef(
    id: SkillId.spearReach,
    name: '長柄',
    description: '槍が長くなり、遠くまで届く',
    maxLevel: 5,
    requires: CarriedWeaponType.spear,
  ),
  SkillId.spearMulti: SkillDef(
    id: SkillId.spearMulti,
    name: '連突き',
    description: '一度に突く本数 +1（扇状に広がる）',
    maxLevel: 3,
    requires: CarriedWeaponType.spear,
  ),
  SkillId.spearSpeed: SkillDef(
    id: SkillId.spearSpeed,
    name: '槍術',
    description: '突く間隔 -12%、ダメージ +10%',
    maxLevel: 5,
    requires: CarriedWeaponType.spear,
  ),
  SkillId.staffPower: SkillDef(
    id: SkillId.staffPower,
    name: '火力',
    description: '爆発のダメージ +25%',
    maxLevel: 5,
    requires: CarriedWeaponType.staff,
  ),
  SkillId.staffRadius: SkillDef(
    id: SkillId.staffRadius,
    name: '大爆発',
    description: '爆発の範囲が広がる',
    maxLevel: 5,
    requires: CarriedWeaponType.staff,
  ),
  SkillId.staffSpeed: SkillDef(
    id: SkillId.staffSpeed,
    name: '詠唱',
    description: '火の玉を放つ間隔 -12%',
    maxLevel: 5,
    requires: CarriedWeaponType.staff,
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
  SkillId.wisdom: SkillDef(
    id: SkillId.wisdom,
    name: '知恵',
    description: '手に入る経験値 +15%',
    maxLevel: 3,
  ),
  SkillId.giantSlayer: SkillDef(
    id: SkillId.giantSlayer,
    name: '進化：巨人殺しの大剣',
    description: '剣が巨大化し、振りも速くなる（刃渡りMAX＋頑丈で解放）',
    maxLevel: 1,
    requires: CarriedWeaponType.sword,
  ),
  SkillId.stormBow: SkillDef(
    id: SkillId.stormBow,
    name: '進化：嵐の弓',
    description: '射るたびに全方向へ矢の嵐。矢がさらに2体貫く（多重射ちMAX＋磁石で解放）',
    maxLevel: 1,
    requires: CarriedWeaponType.bow,
  ),
  SkillId.dragoonSpear: SkillDef(
    id: SkillId.dragoonSpear,
    name: '進化：竜騎士の槍',
    description: '三方向へ同時に突き、槍がさらに長く鋭くなる（長柄MAX＋俊足で解放）',
    maxLevel: 1,
    requires: CarriedWeaponType.spear,
  ),
  SkillId.sageStaff: SkillDef(
    id: SkillId.sageStaff,
    name: '進化：賢者の杖',
    description: '火の玉を3つ同時に放ち、爆発も大きくなる（大爆発MAX＋知恵で解放）',
    maxLevel: 1,
    requires: CarriedWeaponType.staff,
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

  /// 今すぐ選べる進化
  List<SkillId> availableEvolutions(Set<CarriedWeaponType> carried) => [
        for (final e in evolutions)
          if (carried.contains(e.weapon) &&
              isMaxed(e.maxed) &&
              level(e.passive) >= 1 &&
              level(e.evolution) == 0)
            e.evolution,
      ];

  /// レベルアップ時の候補を最大 [count] 個選ぶ。
  /// 進化が可能なら必ず候補に入れる。候補が尽きたら回復薬を出す。
  List<SkillId> offer(
    Set<CarriedWeaponType> carried,
    Random rng, {
    int count = 3,
  }) {
    final result = availableEvolutions(carried).take(count).toList();
    final pool = skillDefs.values
        .where((d) =>
            !isEvolution(d.id) &&
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
