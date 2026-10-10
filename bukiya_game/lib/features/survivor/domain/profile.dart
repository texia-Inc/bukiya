import 'dart:math';

import 'loadout.dart';
import 'run_result.dart';
import 'shop.dart';
import 'stage.dart';

/// ランをまたいで残る記録（最長生存時間・お金・素材・店の武器など）
class SurvivorProfile {
  /// ステージごとの最長生存時間（秒）
  final Map<String, double> bestSeconds;

  /// ステージごとのボス撃破数
  final Map<String, int> bossKills;
  final Map<MaterialKind, int> materials;

  /// 店にある武器（熟練度・耐久・強化値は武器ごと）
  final List<OwnedWeapon> weapons;

  /// 持ち出す武器の uid
  List<String> selectedWeapons;
  String selectedStage;
  int gold;
  int runs;
  int _nextWeaponId;

  SurvivorProfile({
    Map<String, double>? bestSeconds,
    Map<String, int>? bossKills,
    Map<MaterialKind, int>? materials,
    List<OwnedWeapon>? weapons,
    List<String>? selectedWeapons,
    this.selectedStage = 'forest',
    this.gold = startingGold,
    this.runs = 0,
    int nextWeaponId = 1,
  })  : bestSeconds = bestSeconds ?? {},
        bossKills = bossKills ?? {},
        materials = materials ?? {},
        weapons = weapons ?? starterWeapons(),
        selectedWeapons = selectedWeapons ?? [],
        _nextWeaponId = nextWeaponId {
    _fixSelection();
  }

  static const int startingGold = 100;

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

  OwnedWeapon? weapon(String uid) =>
      weapons.where((w) => w.uid == uid).firstOrNull;

  /// 持ち出す武器（壊れたものは除く）
  List<CarriedWeapon> get loadout => [
        for (final id in selectedWeapons)
          if (weapon(id) case final w? when !w.broken) w.toCarried(),
      ];

  int get totalMaterials => materials.entries
      .where((e) => e.key != MaterialKind.bossCore)
      .fold(0, (a, e) => a + e.value);

  int have(MaterialKind m) => materials[m] ?? 0;

  // ---- 持ち出す武器の選択 ----

  /// 選択を切り替える。上限を超えたら古い方を外す。壊れた武器は選べない
  void toggleWeapon(String uid) {
    final w = weapon(uid);
    if (w == null) return;
    if (selectedWeapons.contains(uid)) {
      if (selectedWeapons.length > 1) selectedWeapons.remove(uid);
      return;
    }
    if (w.broken) return;
    if (selectedWeapons.length >= maxCarriedWeapons) {
      selectedWeapons.removeAt(0);
    }
    selectedWeapons.add(uid);
  }

  /// 消えた・壊れた武器を選択から外し、空なら使える武器で埋める
  void _fixSelection() {
    selectedWeapons.removeWhere((id) => weapon(id)?.broken ?? true);
    if (selectedWeapons.isEmpty) {
      for (final w in weapons) {
        if (selectedWeapons.length >= maxCarriedWeapons) break;
        if (!w.broken) selectedWeapons.add(w.uid);
      }
    }
    while (selectedWeapons.length > maxCarriedWeapons) {
      selectedWeapons.removeLast();
    }
  }

  // ---- 店：売る・鍛える・強化・修理 ----

  bool _canPay(int g, Map<MaterialKind, int> mats) =>
      gold >= g && mats.entries.every((e) => have(e.key) >= e.value);

  void _pay(int g, Map<MaterialKind, int> mats) {
    gold -= g;
    for (final e in mats.entries) {
      materials[e.key] = have(e.key) - e.value;
    }
  }

  /// 使える武器が1本も残らなくなる売却はできない
  bool canSell(OwnedWeapon w) =>
      weapons.contains(w) && weapons.any((o) => !identical(o, w) && !o.broken);

  void sell(OwnedWeapon w) {
    if (!canSell(w)) return;
    gold += w.sellPrice;
    weapons.remove(w);
    _fixSelection();
  }

  bool canCraft(Recipe r) =>
      weapons.length < maxOwnedWeapons && _canPay(r.gold, r.materials);

  OwnedWeapon? craft(Recipe r) {
    if (!canCraft(r)) return null;
    _pay(r.gold, r.materials);
    final w = OwnedWeapon(uid: 'w${_nextWeaponId++}', type: r.type);
    weapons.add(w);
    return w;
  }

  bool canEnchant(OwnedWeapon w) {
    if (w.enchantLevel >= maxEnchantLevel) return false;
    final c = enchantCost(w);
    return _canPay(c.gold, c.materials);
  }

  void enchant(OwnedWeapon w) {
    if (!canEnchant(w)) return;
    final c = enchantCost(w);
    _pay(c.gold, c.materials);
    w.enchantLevel++;
  }

  bool canRepair(OwnedWeapon w) => w.durability < 100 && gold >= repairCost(w);

  void repair(OwnedWeapon w) {
    if (!canRepair(w)) return;
    gold -= repairCost(w);
    w.durability = 100;
    _fixSelection();
  }

  /// ランの結果を記録に反映する
  void applyResult(RunResult r, StageDef stage) {
    runs++;
    bestSeconds[stage.id] = max(bestSeconds[stage.id] ?? 0, r.survivedSeconds);
    if (r.bossesDefeated > 0) {
      bossKills[stage.id] = (bossKills[stage.id] ?? 0) + r.bossesDefeated;
    }
    for (final e in r.materialsKept.entries) {
      materials[e.key] = have(e.key) + e.value;
    }
    for (final o in r.weapons) {
      final w = weapon(o.weapon.id);
      if (w == null) continue;
      w.kills += o.kills;
      w.durability = o.durabilityAfter;
    }
    _fixSelection();
  }

  Map<String, Object?> toJson() => {
        'version': 2,
        'bestSeconds': bestSeconds,
        'bossKills': bossKills,
        'materials': {for (final e in materials.entries) e.key.name: e.value},
        'weapons': [for (final w in weapons) w.toJson()],
        'selectedWeapons': selectedWeapons,
        'selectedStage': selectedStage,
        'gold': gold,
        'runs': runs,
        'nextWeaponId': _nextWeaponId,
      };

  /// 壊れた・古い形式のデータでも落ちないよう、読めた分だけ使う
  factory SurvivorProfile.fromJson(Map<String, Object?> j) {
    Map<String, T> map<T>(Object? v, T Function(num) conv) => {
          if (v is Map)
            for (final e in v.entries)
              if (e.value is num) '${e.key}': conv(e.value as num),
        };
    int number(Object? v, int fallback) => v is num ? v.toInt() : fallback;

    final mats = map(j['materials'], (n) => n.toInt());
    final rawWeapons = j['weapons'];
    final List<OwnedWeapon> weapons;
    if (rawWeapons is List) {
      weapons = rawWeapons
          .map(OwnedWeapon.fromJson)
          .whereType<OwnedWeapon>()
          .toList();
    } else {
      // 1つ前の形式：はじめの武器に、武器ごとの撃破数を引き継ぐ
      final oldKills = map(j['weaponKills'], (n) => n.toInt());
      weapons = starterWeapons();
      for (final w in weapons) {
        w.kills = oldKills[w.uid] ?? 0;
      }
    }
    final selected = j['selectedWeapons'];
    final stage = j['selectedStage'];
    return SurvivorProfile(
      bestSeconds: map(j['bestSeconds'], (n) => n.toDouble()),
      bossKills: map(j['bossKills'], (n) => n.toInt()),
      materials: {
        for (final k in MaterialKind.values)
          if (mats[k.name] != null) k: mats[k.name]!,
      },
      weapons: weapons.isEmpty ? starterWeapons() : weapons,
      selectedWeapons: selected is List
          ? [
              for (final w in selected)
                if (w is String) w
            ]
          : null,
      selectedStage: stage is String && allStages.any((s) => s.id == stage)
          ? stage
          : 'forest',
      gold: max(0, number(j['gold'], startingGold)),
      runs: max(0, number(j['runs'], 0)),
      nextWeaponId: max(1, number(j['nextWeaponId'], 1)),
    );
  }
}
