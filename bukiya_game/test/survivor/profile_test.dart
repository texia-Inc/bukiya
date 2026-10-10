import 'dart:convert';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/profile.dart';
import 'package:bukiya_game/features/survivor/domain/run_result.dart';
import 'package:bukiya_game/features/survivor/domain/shop.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:flutter_test/flutter_test.dart';

/// [p] の持ち出す武器（はじめは剣と弓）で走ったランの結果
RunResult _result({
  SurvivorProfile? p,
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
      loadout: (p ?? SurvivorProfile()).loadout,
      killsByWeapon: kills,
      bossesDefeated: bosses,
    );

void main() {
  group('記録', () {
    test('最初は1つ目のステージだけ遊べ、はじめの武器を2本持ち出す', () {
      final p = SurvivorProfile();
      expect(p.isUnlocked(forestStage), isTrue);
      expect(p.isUnlocked(graveyardStage), isFalse);
      expect(p.loadout.map((w) => w.id), ['iron_sword', 'hunter_bow']);
      expect(p.gold, SurvivorProfile.startingGold);
    });

    test('前のステージで3分生き残るか、ボスを倒すと次が開く', () {
      final a = SurvivorProfile();
      a.applyResult(_result(seconds: 179), forestStage);
      expect(a.isUnlocked(graveyardStage), isFalse);
      a.applyResult(_result(seconds: 181, returned: false), forestStage);
      expect(a.isUnlocked(graveyardStage), isTrue);

      final b = SurvivorProfile();
      b.applyResult(_result(seconds: 150, bosses: 1), forestStage);
      expect(b.isUnlocked(graveyardStage), isTrue);
    });

    test('素材・熟練度・耐久が武器ごとに反映される。倒れると素材は半分', () {
      final p = SurvivorProfile();
      p.applyResult(
          _result(
              p: p,
              mats: {MaterialKind.ironOre: 4},
              kills: {'iron_sword': 100}),
          forestStage);
      p.applyResult(
          _result(
              p: p,
              returned: false,
              mats: {MaterialKind.ironOre: 4},
              kills: {'iron_sword': 150}),
          forestStage);
      final sword = p.weapon('iron_sword')!;
      expect(p.have(MaterialKind.ironOre), 6);
      expect(sword.kills, 250);
      // 帰還で -10、倒れて -40
      expect(sword.durability, 50);
      expect(p.runs, 2);
    });

    test('壊れた武器は持ち出しから外れ、修理すると選べる', () {
      final p = SurvivorProfile();
      final sword = p.weapon('iron_sword')!..durability = 30;
      p.applyResult(_result(p: p, returned: false), forestStage);
      expect(sword.broken, isTrue);
      expect(p.loadout.map((w) => w.id), ['hunter_bow']);
      p.toggleWeapon('iron_sword');
      expect(p.selectedWeapons, isNot(contains('iron_sword')));
      p.gold = 1000;
      p.repair(sword);
      expect(sword.durability, 100);
      expect(p.gold, 1000 - 100);
      p.toggleWeapon('iron_sword');
      expect(p.selectedWeapons, contains('iron_sword'));
    });
  });

  group('店', () {
    test('売値は強化・熟練度・耐久で決まる', () {
      final w = OwnedWeapon(uid: 'x', type: CarriedWeaponType.sword);
      expect(w.sellPrice, 120);
      w.enchantLevel = 2; // ×1.8
      expect(w.sellPrice, 216);
      w.kills = 500; // ×1.5
      expect(w.sellPrice, 324);
      w.durability = 0; // 半額
      expect(w.sellPrice, 162);
    });

    test('売るとお金が入り、使える武器が1本も残らない売却はできない', () {
      final p = SurvivorProfile();
      final gold = p.gold;
      final bow = p.weapon('hunter_bow')!;
      p.sell(bow);
      expect(p.gold, gold + 100);
      expect(p.weapon('hunter_bow'), isNull);
      expect(p.selectedWeapons, isNot(contains('hunter_bow')));
      // 残りを1本になるまで売る
      for (final w in [...p.weapons].skip(1)) {
        p.sell(w);
      }
      expect(p.weapons.length, 1);
      expect(p.canSell(p.weapons.single), isFalse);
      p.sell(p.weapons.single);
      expect(p.weapons.length, 1);
      expect(p.loadout, isNotEmpty);
    });

    test('鍛冶は素材とお金を使い、足りないと作れない', () {
      final p = SurvivorProfile(gold: 39);
      final recipe =
          recipes.firstWhere((r) => r.type == CarriedWeaponType.sword);
      p.materials[MaterialKind.ironOre] = 5;
      expect(p.canCraft(recipe), isFalse); // お金が足りない
      p.gold = 40;
      final made = p.craft(recipe)!;
      expect(made.type, CarriedWeaponType.sword);
      expect(made.enchantLevel, 0);
      expect(p.gold, 0);
      expect(p.have(MaterialKind.ironOre), 0);
      expect(p.craft(recipe), isNull);
      // uid は重ならない
      p.gold = 40;
      p.materials[MaterialKind.ironOre] = 5;
      expect(p.craft(recipe)!.uid, isNot(made.uid));
    });

    test('倉庫がいっぱいだと鍛えられない', () {
      final p = SurvivorProfile(gold: 10000);
      p.materials[MaterialKind.ironOre] = 100;
      final recipe =
          recipes.firstWhere((r) => r.type == CarriedWeaponType.sword);
      while (p.weapons.length < maxOwnedWeapons) {
        p.craft(recipe);
      }
      expect(p.canCraft(recipe), isFalse);
    });

    test('強化は魔石とお金、+3 からは魔核も要り、+5 が上限', () {
      final p = SurvivorProfile(gold: 10000);
      final bow = p.weapon('hunter_bow')!;
      p.materials[MaterialKind.manaStone] = 100;
      p.enchant(bow);
      p.enchant(bow);
      expect(bow.enchantLevel, 2);
      expect(p.canEnchant(bow), isFalse); // 魔核がない
      p.materials[MaterialKind.bossCore] = 10;
      p.enchant(bow);
      p.enchant(bow);
      p.enchant(bow);
      expect(bow.enchantLevel, maxEnchantLevel);
      expect(p.canEnchant(bow), isFalse);
      expect(p.have(MaterialKind.manaStone), 100 - (1 + 2 + 3 + 4 + 5));
      expect(p.have(MaterialKind.bossCore), 10 - 3);
      expect(p.gold, 10000 - 60 * (1 + 2 + 3 + 4 + 5));
    });
  });

  group('保存', () {
    test('保存して読み直すと同じ記録になる', () {
      final p = SurvivorProfile(selectedStage: 'graveyard', gold: 321);
      p.materials[MaterialKind.ironOre] = 5;
      final made = p.craft(recipes.first)!;
      p.toggleWeapon(made.uid);
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
      expect(q.gold, p.gold);
      expect(q.selectedWeapons, p.selectedWeapons);
      expect(q.selectedStage, 'graveyard');
      expect([for (final w in q.weapons) w.toJson()],
          [for (final w in p.weapons) w.toJson()]);
      // 読み直したあとに鍛えても uid が重ならない
      q.gold = 1000;
      q.materials[MaterialKind.ironOre] = 5;
      q.craft(recipes.first);
      expect(q.weapons.map((w) => w.uid).toSet().length, q.weapons.length);
    });

    test('1つ前の形式（武器ごとの撃破数だけ）から、はじめの武器に熟練度を引き継ぐ', () {
      final q = SurvivorProfile.fromJson({
        'bestSeconds': {'forest': 200},
        'weaponKills': {'iron_sword': 120, 'iron_spear': 7},
        'selectedWeapons': ['iron_spear', 'apprentice_staff'],
        'runs': 3,
      });
      expect(q.weapon('iron_sword')!.kills, 120);
      expect(q.weapon('iron_spear')!.kills, 7);
      expect(q.selectedWeapons, ['iron_spear', 'apprentice_staff']);
      expect(q.gold, SurvivorProfile.startingGold);
      expect(q.runs, 3);
    });

    test('壊れたデータや知らない値が混ざっていても落ちずに読める', () {
      final q = SurvivorProfile.fromJson({
        'bestSeconds': {'forest': 'abc', 'graveyard': 12},
        'materials': {'ironOre': 3, 'unknown': 9},
        'weapons': [
          {'uid': 'a', 'type': 'bow', 'enchant': 99, 'durability': -5},
          {'uid': 'b', 'type': 'laser'},
          'junk',
        ],
        'selectedWeapons': ['no_such', 1, 'a'],
        'selectedStage': 'moon',
        'gold': -50,
        'runs': 'x',
      });
      expect(q.bestSeconds, {'graveyard': 12});
      expect(q.materials, {MaterialKind.ironOre: 3});
      expect(q.weapons.single.uid, 'a');
      expect(q.weapons.single.enchantLevel, maxEnchantLevel);
      expect(q.weapons.single.durability, 0);
      // 壊れた武器しかないので選択は空。スタートは押せない
      expect(q.loadout, isEmpty);
      expect(q.selectedStage, 'forest');
      expect(q.gold, 0);
      expect(q.runs, 0);
    });
  });
}
