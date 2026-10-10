import 'dart:convert';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/profile.dart';
import 'package:bukiya_game/features/survivor/domain/run_result.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:flutter_test/flutter_test.dart';

RunResult _result({
  bool returned = true,
  double seconds = 100,
  int bosses = 0,
  Map<MaterialKind, int> mats = const {},
  Map<String, int> kills = const {},
}) =>
    RunResult.build(
      returned: returned,
      survivedSeconds: seconds,
      level: 5,
      materialsFound: mats,
      loadout: mockShopStock.take(2).toList(),
      killsByWeapon: kills,
      bossesDefeated: bosses,
    );

void main() {
  test('最初は1つ目のステージだけ遊べる', () {
    final p = SurvivorProfile();
    expect(p.isUnlocked(forestStage), isTrue);
    expect(p.isUnlocked(graveyardStage), isFalse);
    expect(p.loadout.length, maxCarriedWeapons);
  });

  test('前のステージで3分生き残ると次が開く', () {
    final p = SurvivorProfile();
    p.applyResult(_result(seconds: 179), forestStage);
    expect(p.isUnlocked(graveyardStage), isFalse);
    p.applyResult(_result(seconds: 181, returned: false), forestStage);
    expect(p.isUnlocked(graveyardStage), isTrue);
    expect(p.bestSeconds['forest'], 181);
  });

  test('ボスを倒しても次が開く', () {
    final p = SurvivorProfile();
    p.applyResult(_result(seconds: 150, bosses: 1), forestStage);
    expect(p.isUnlocked(graveyardStage), isTrue);
  });

  test('持ち帰った素材と熟練度が積み上がる。倒れたときは素材が半分', () {
    final p = SurvivorProfile();
    p.applyResult(
        _result(mats: {MaterialKind.ironOre: 4}, kills: {'iron_sword': 100}),
        forestStage);
    p.applyResult(
        _result(
            returned: false,
            mats: {MaterialKind.ironOre: 4},
            kills: {'iron_sword': 150}),
        forestStage);
    expect(p.materials[MaterialKind.ironOre], 6);
    expect(p.weaponKills['iron_sword'], 250);
    expect(p.priceOf(mockShopStock.first), 1000); // 800 × 1.25
    expect(p.runs, 2);
  });

  test('保存して読み直すと同じ記録になる', () {
    final p = SurvivorProfile(selectedStage: 'graveyard')
      ..selectedWeapons = ['iron_spear', 'apprentice_staff'];
    p.applyResult(
        _result(
            seconds: 200,
            bosses: 1,
            mats: {MaterialKind.bossCore: 1, MaterialKind.bone: 3},
            kills: {'iron_sword': 42}),
        forestStage);
    final q = SurvivorProfile.fromJson(
        jsonDecode(jsonEncode(p.toJson())) as Map<String, Object?>);
    expect(q.bestSeconds, p.bestSeconds);
    expect(q.bossKills, p.bossKills);
    expect(q.materials, p.materials);
    expect(q.weaponKills, p.weaponKills);
    expect(q.selectedWeapons, p.selectedWeapons);
    expect(q.selectedStage, 'graveyard');
    expect(q.runs, 1);
  });

  test('壊れたデータや知らない値が混ざっていても落ちずに読める', () {
    final q = SurvivorProfile.fromJson({
      'bestSeconds': {'forest': 'abc', 'graveyard': 12},
      'materials': {'ironOre': 3, 'unknown': 9},
      'selectedWeapons': [
        'no_such_weapon',
        1,
        'hunter_bow',
        'iron_spear',
        'iron_sword'
      ],
      'selectedStage': 'moon',
      'runs': 'x',
    });
    expect(q.bestSeconds, {'graveyard': 12});
    expect(q.materials, {MaterialKind.ironOre: 3});
    expect(q.selectedWeapons, ['hunter_bow', 'iron_spear']);
    expect(q.selectedStage, 'forest');
    expect(q.runs, 0);
  });
}
