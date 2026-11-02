import 'dart:math';

import 'loadout.dart';
import 'rewards.dart';
import 'run_result.dart';
import 'shop.dart';
import 'stage.dart';
import 'talents.dart';

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

  /// 才能のレベル
  final Map<TalentId, int> talentLevels;

  /// これまでの合計（実績用）
  int totalKills;
  int totalBosses;
  int totalForges;

  /// 毎日のミッション：数えている日と、その日の進み具合・受け取り済み
  int dailyDay;
  final Map<MissionStat, int> dailyProgress;
  final Set<String> dailyClaimed;

  /// 受け取り済みの実績とチャプター宝箱
  final Set<String> achievementsClaimed;
  final Set<String> chestsClaimed;

  /// 最後にパトロールの成果を受け取った時刻（ミリ秒）。null ならまだ始めていない
  int? patrolSince;

  /// 最後にギフトを受け取った日
  int giftDay;

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
    Map<TalentId, int>? talentLevels,
    this.totalKills = 0,
    this.totalBosses = 0,
    this.totalForges = 0,
    this.dailyDay = 0,
    Map<MissionStat, int>? dailyProgress,
    Set<String>? dailyClaimed,
    Set<String>? achievementsClaimed,
    Set<String>? chestsClaimed,
    this.patrolSince,
    this.giftDay = 0,
  })  : talentLevels = talentLevels ?? {},
        dailyProgress = dailyProgress ?? {},
        dailyClaimed = dailyClaimed ?? {},
        achievementsClaimed = achievementsClaimed ?? {},
        chestsClaimed = chestsClaimed ?? {},
        bestSeconds = bestSeconds ?? {},
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
    _countForge();
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
    _countForge();
  }

  bool canRepair(OwnedWeapon w) => w.durability < 100 && gold >= repairCost(w);

  void repair(OwnedWeapon w) {
    if (!canRepair(w)) return;
    gold -= repairCost(w);
    w.durability = 100;
    _fixSelection();
  }

  /// ランの結果を記録に反映する
  void applyResult(RunResult r, StageDef stage, {DateTime? now}) {
    runs++;
    totalKills += r.totalKills;
    totalBosses += r.bossesDefeated;
    _rollDay(now ?? DateTime.now());
    _addDaily(MissionStat.runs, 1);
    _addDaily(MissionStat.kills, r.totalKills);
    _addDaily(MissionStat.bosses, r.bossesDefeated);
    if (r.survivedSeconds >= 180) _addDaily(MissionStat.survive3min, 1);
    if (r.returned) _addDaily(MissionStat.returned, 1);
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

  // ---- 受け取り ----

  void grant(Reward r) {
    gold += r.gold;
    for (final e in r.materials.entries) {
      materials[e.key] = have(e.key) + e.value;
    }
  }

  int get unlockedStageCount => allStages.where(isUnlocked).length;

  // ---- 才能 ----

  Talents get talents => Talents(Map.of(talentLevels));

  int talentLevel(TalentId id) => talentLevels[id] ?? 0;

  bool canUpgradeTalent(TalentId id) {
    final d = talentDef(id), lv = talentLevel(id);
    return lv < d.maxLevel && gold >= d.costAt(lv);
  }

  void upgradeTalent(TalentId id) {
    if (!canUpgradeTalent(id)) return;
    gold -= talentDef(id).costAt(talentLevel(id));
    talentLevels[id] = talentLevel(id) + 1;
  }

  // ---- ミッション ----

  void _countForge() {
    totalForges++;
    _rollDay(DateTime.now());
    _addDaily(MissionStat.forge, 1);
  }

  /// 日付が変わっていたら、毎日のミッションを数え直す
  void _rollDay(DateTime now) {
    final d = dayKey(now);
    if (dailyDay == d) return;
    dailyDay = d;
    dailyProgress.clear();
    dailyClaimed.clear();
  }

  void _addDaily(MissionStat stat, int n) {
    if (n <= 0) return;
    dailyProgress[stat] = (dailyProgress[stat] ?? 0) + n;
  }

  int _total(MissionStat stat) => switch (stat) {
        MissionStat.runs => runs,
        MissionStat.kills => totalKills,
        MissionStat.bosses => totalBosses,
        MissionStat.forge => totalForges,
        MissionStat.survive3min || MissionStat.returned => 0,
      };

  bool _isDaily(MissionDef m) => dailyMissions.contains(m);

  /// ミッションの進み具合（目標で頭打ち）
  int missionProgress(MissionDef m, {DateTime? now}) {
    if (_isDaily(m)) {
      _rollDay(now ?? DateTime.now());
      return min(m.goal, dailyProgress[m.stat] ?? 0);
    }
    return min(m.goal, _total(m.stat));
  }

  bool missionClaimed(MissionDef m, {DateTime? now}) {
    if (_isDaily(m)) {
      _rollDay(now ?? DateTime.now());
      return dailyClaimed.contains(m.id);
    }
    return achievementsClaimed.contains(m.id);
  }

  bool canClaimMission(MissionDef m, {DateTime? now}) =>
      !missionClaimed(m, now: now) && missionProgress(m, now: now) >= m.goal;

  void claimMission(MissionDef m, {DateTime? now}) {
    if (!canClaimMission(m, now: now)) return;
    (_isDaily(m) ? dailyClaimed : achievementsClaimed).add(m.id);
    grant(m.reward);
  }

  bool hasClaimableMission({DateTime? now}) => [
        ...dailyMissions,
        ...achievements
      ].any((m) => canClaimMission(m, now: now));

  // ---- チャプター宝箱 ----

  bool chestClaimed(StageDef s, ChapterChest c) =>
      chestsClaimed.contains(c.key(s));

  bool canClaimChest(StageDef s, ChapterChest c) =>
      !chestClaimed(s, c) && (bestSeconds[s.id] ?? 0) >= c.seconds;

  void claimChest(StageDef s, ChapterChest c) {
    if (!canClaimChest(s, c)) return;
    chestsClaimed.add(c.key(s));
    grant(c.reward(s));
  }

  bool hasClaimableChest() =>
      allStages.any((s) => chapterChests.any((c) => canClaimChest(s, c)));

  // ---- パトロール ----

  /// 見回りを始めてからの分数（上限つき）。初めてなら今から始める
  int patrolMinutes(DateTime now) {
    final since = patrolSince ??= now.millisecondsSinceEpoch;
    final m = (now.millisecondsSinceEpoch - since) ~/ 60000;
    return m.clamp(0, patrolCap.inMinutes);
  }

  Reward patrolPending(DateTime now) =>
      patrolReward(patrolMinutes(now), unlockedStageCount, patrolSince ?? 0);

  bool canClaimPatrol(DateTime now) => !patrolPending(now).isEmpty;

  /// 受け取ると、また今から見回りを始める
  Reward claimPatrol(DateTime now) {
    final r = patrolPending(now);
    if (r.isEmpty) return r;
    grant(r);
    patrolSince = now.millisecondsSinceEpoch;
    return r;
  }

  // ---- 毎日のギフト ----

  bool canClaimGift(DateTime now) => giftDay != dayKey(now);

  Reward giftFor(DateTime now) => dailyGift(dayKey(now), unlockedStageCount);

  Reward? claimGift(DateTime now) {
    if (!canClaimGift(now)) return null;
    final r = giftFor(now);
    giftDay = dayKey(now);
    grant(r);
    return r;
  }

  Map<String, Object?> toJson() => {
        'version': 3,
        'talents': {for (final e in talentLevels.entries) e.key.name: e.value},
        'totalKills': totalKills,
        'totalBosses': totalBosses,
        'totalForges': totalForges,
        'dailyDay': dailyDay,
        'dailyProgress': {
          for (final e in dailyProgress.entries) e.key.name: e.value
        },
        'dailyClaimed': dailyClaimed.toList(),
        'achievementsClaimed': achievementsClaimed.toList(),
        'chestsClaimed': chestsClaimed.toList(),
        'patrolSince': patrolSince,
        'giftDay': giftDay,
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
    final talents = map(j['talents'], (n) => n.toInt());
    final daily = map(j['dailyProgress'], (n) => n.toInt());
    Set<String> strings(Object? v) => {
          if (v is List)
            for (final s in v)
              if (s is String) s
        };
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
      talentLevels: {
        for (final d in talentDefs)
          if (talents[d.id.name] case final lv?) d.id: lv.clamp(0, d.maxLevel),
      },
      totalKills: max(0, number(j['totalKills'], 0)),
      totalBosses: max(0, number(j['totalBosses'], 0)),
      totalForges: max(0, number(j['totalForges'], 0)),
      dailyDay: number(j['dailyDay'], 0),
      dailyProgress: {
        for (final s in MissionStat.values)
          if (daily[s.name] case final n?) s: max(0, n),
      },
      dailyClaimed: strings(j['dailyClaimed']),
      achievementsClaimed: strings(j['achievementsClaimed']),
      chestsClaimed: strings(j['chestsClaimed']),
      patrolSince:
          j['patrolSince'] is num ? (j['patrolSince'] as num).toInt() : null,
      giftDay: number(j['giftDay'], 0),
    );
  }
}
