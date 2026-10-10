import 'dart:math';

import 'loadout.dart';
import 'run_result.dart';
import 'stage.dart';

/// ランをまたいで残る記録（最長生存時間・素材・武器の熟練度など）
class SurvivorProfile {
  /// ステージごとの最長生存時間（秒）
  final Map<String, double> bestSeconds;

  /// ステージごとのボス撃破数
  final Map<String, int> bossKills;
  final Map<MaterialKind, int> materials;

  /// 武器ごとの累計撃破数（熟練度）
  final Map<String, int> weaponKills;
  List<String> selectedWeapons;
  String selectedStage;
  int runs;

  SurvivorProfile({
    Map<String, double>? bestSeconds,
    Map<String, int>? bossKills,
    Map<MaterialKind, int>? materials,
    Map<String, int>? weaponKills,
    List<String>? selectedWeapons,
    this.selectedStage = 'forest',
    this.runs = 0,
  })  : bestSeconds = bestSeconds ?? {},
        bossKills = bossKills ?? {},
        materials = materials ?? {},
        weaponKills = weaponKills ?? {},
        selectedWeapons = selectedWeapons ??
            [for (final w in mockShopStock.take(maxCarriedWeapons)) w.id];

  /// 前のステージで 3:00 生き残るか、ボスを1体倒すと次のステージが開く
  static const double unlockSeconds = 180;

  bool isUnlocked(StageDef stage) {
    final i = allStages.indexOf(stage);
    if (i <= 0) return true;
    final prev = allStages[i - 1];
    return (bestSeconds[prev.id] ?? 0) >= unlockSeconds ||
        (bossKills[prev.id] ?? 0) > 0;
  }

  StageDef get stage => allStages.firstWhere((s) => s.id == selectedStage,
      orElse: () => allStages.first);

  List<CarriedWeapon> get loadout => [
        for (final w in mockShopStock)
          if (selectedWeapons.contains(w.id)) w,
      ];

  int get totalMaterials => materials.entries
      .where((e) => e.key != MaterialKind.bossCore)
      .fold(0, (a, e) => a + e.value);

  /// 武器の今の売値（累計の熟練度で上がる）
  int priceOf(CarriedWeapon w) =>
      (w.basePrice * proficiencyMultiplier(weaponKills[w.id] ?? 0)).round();

  /// ランの結果を記録に反映する
  void applyResult(RunResult r, StageDef stage) {
    runs++;
    bestSeconds[stage.id] = max(bestSeconds[stage.id] ?? 0, r.survivedSeconds);
    if (r.bossesDefeated > 0) {
      bossKills[stage.id] = (bossKills[stage.id] ?? 0) + r.bossesDefeated;
    }
    for (final e in r.materialsKept.entries) {
      materials[e.key] = (materials[e.key] ?? 0) + e.value;
    }
    for (final w in r.weapons) {
      weaponKills[w.weapon.id] = (weaponKills[w.weapon.id] ?? 0) + w.kills;
    }
  }

  Map<String, Object?> toJson() => {
        'bestSeconds': bestSeconds,
        'bossKills': bossKills,
        'materials': {for (final e in materials.entries) e.key.name: e.value},
        'weaponKills': weaponKills,
        'selectedWeapons': selectedWeapons,
        'selectedStage': selectedStage,
        'runs': runs,
      };

  /// 壊れた・古い形式のデータでも落ちないよう、読めた分だけ使う
  factory SurvivorProfile.fromJson(Map<String, Object?> j) {
    Map<String, T> map<T>(Object? v, T Function(num) conv) => {
          if (v is Map)
            for (final e in v.entries)
              if (e.value is num) '${e.key}': conv(e.value as num),
        };
    final mats = map(j['materials'], (n) => n.toInt());
    final weapons = j['selectedWeapons'];
    final known = {for (final w in mockShopStock) w.id};
    final selected = weapons is List
        ? [
            for (final w in weapons)
              if (w is String && known.contains(w)) w
          ].take(maxCarriedWeapons).toList()
        : null;
    final stage = j['selectedStage'];
    return SurvivorProfile(
      bestSeconds: map(j['bestSeconds'], (n) => n.toDouble()),
      bossKills: map(j['bossKills'], (n) => n.toInt()),
      materials: {
        for (final k in MaterialKind.values)
          if (mats[k.name] != null) k: mats[k.name]!,
      },
      weaponKills: map(j['weaponKills'], (n) => n.toInt()),
      selectedWeapons: selected == null || selected.isEmpty ? null : selected,
      selectedStage: stage is String && allStages.any((s) => s.id == stage)
          ? stage
          : 'forest',
      runs: j['runs'] is num ? (j['runs'] as num).toInt() : 0,
    );
  }
}
