import 'dart:math';

/// 才能：お金で上げる、ずっと残る強化。出撃のたびに最初から効く
enum TalentId { vitality, power, swiftness, insight, magnet, guard }

class TalentDef {
  final TalentId id;
  final String name;

  /// 1レベルあたりの効果の説明
  final String perLevel;
  final int maxLevel;

  /// 1レベル目の値段。上がるごとに高くなる
  final int baseCost;

  const TalentDef(
      this.id, this.name, this.perLevel, this.maxLevel, this.baseCost);

  /// [level] から次のレベルへ上げる値段
  int costAt(int level) => (baseCost * pow(1.45, level)).round();
}

const List<TalentDef> talentDefs = [
  TalentDef(TalentId.vitality, '体力', '最大HP +10', 10, 80),
  TalentDef(TalentId.power, '腕力', '武器のダメージ +5%', 10, 120),
  TalentDef(TalentId.swiftness, '健脚', '移動速度 +3%', 8, 100),
  TalentDef(TalentId.insight, '商才', '手に入る経験値 +5%', 8, 100),
  TalentDef(TalentId.magnet, '目ざとさ', '拾える距離 +8%', 6, 90),
  TalentDef(TalentId.guard, '守り', '受けるダメージ -3%', 8, 150),
];

TalentDef talentDef(TalentId id) => talentDefs.firstWhere((d) => d.id == id);

/// 出撃時に効く才能の数値
class Talents {
  final Map<TalentId, int> levels;

  const Talents([this.levels = const {}]);

  int level(TalentId id) => levels[id] ?? 0;

  double get bonusHp => 10.0 * level(TalentId.vitality);
  double get damageMultiplier => 1 + 0.05 * level(TalentId.power);
  double get moveMultiplier => 1 + 0.03 * level(TalentId.swiftness);
  double get xpMultiplier => 1 + 0.05 * level(TalentId.insight);
  double get pickupMultiplier => 1 + 0.08 * level(TalentId.magnet);

  /// 受けるダメージにかける倍率
  double get damageTaken => 1 - 0.03 * level(TalentId.guard);
}
