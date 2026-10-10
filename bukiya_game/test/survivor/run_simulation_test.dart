import 'dart:math';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/run_result.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/domain/skills.dart';
import 'package:flutter_test/flutter_test.dart';

RunSimulation _sim({List<CarriedWeapon>? loadout, RunConfig? config}) =>
    RunSimulation(
      loadout: loadout ?? mockShopStock,
      config: config ?? const RunConfig(),
      seed: 1,
    );

void _step(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

void main() {
  group('SkillSet', () {
    test('持っていない武器のスキルは候補に出ない', () {
      final skills = SkillSet();
      for (var i = 0; i < 50; i++) {
        final offer =
            skills.offer({CarriedWeaponType.bow}, Random(i), count: 3);
        for (final id in offer) {
          expect(skillDefs[id]!.requires, isNot(CarriedWeaponType.sword));
        }
      }
    });

    test('刃渡りMAXと頑丈で進化が必ず候補に入る', () {
      final skills = SkillSet();
      for (var i = 0; i < 5; i++) {
        skills.add(SkillId.bladeLength);
      }
      expect(skills.offer({CarriedWeaponType.sword}, Random(0)),
          isNot(contains(SkillId.giantSlayer)));
      skills.add(SkillId.vitality);
      expect(skills.offer({CarriedWeaponType.sword}, Random(0)).first,
          SkillId.giantSlayer);
    });

    test('取り尽くしたら回復薬が出る', () {
      final skills = SkillSet();
      for (final d in skillDefs.values) {
        if (d.id == SkillId.potion) continue;
        for (var i = 0; i < d.maxLevel; i++) {
          skills.add(d.id);
        }
      }
      expect(
          skills.offer(
              {CarriedWeaponType.sword, CarriedWeaponType.bow}, Random(0)),
          [SkillId.potion]);
    });
  });

  group('RunResult', () {
    test('熟練度の売値倍率は500体で+50%が上限', () {
      expect(proficiencyMultiplier(0), 1.0);
      expect(proficiencyMultiplier(250), 1.25);
      expect(proficiencyMultiplier(500), 1.5);
      expect(proficiencyMultiplier(2000), 1.5);
    });

    test('倒れると素材は半分、耐久は40減る', () {
      final r = RunResult.build(
        returned: false,
        survivedSeconds: 100,
        level: 5,
        materialsFound: {MaterialKind.ironOre: 5, MaterialKind.fang: 1},
        loadout: mockShopStock,
        killsByWeapon: {'iron_sword': 100},
      );
      expect(r.materialsKept[MaterialKind.ironOre], 2);
      expect(r.materialsKept[MaterialKind.fang], 0);
      expect(r.weapons.first.durabilityAfter, 60);
      expect(r.weapons.first.priceAfter, 880); // 800 × 1.1
    });

    test('生還すれば素材はそのまま、耐久は10減る', () {
      final r = RunResult.build(
        returned: true,
        survivedSeconds: 100,
        level: 5,
        materialsFound: {MaterialKind.ironOre: 5},
        loadout: mockShopStock,
        killsByWeapon: const {},
      );
      expect(r.materialsKept[MaterialKind.ironOre], 5);
      expect(r.weapons.first.durabilityAfter, 90);
    });
  });

  group('RunSimulation', () {
    test('剣の回転斬りで近くの敵を倒し、撃破数が剣に入る', () {
      final sim = _sim(loadout: [mockShopStock[0]]);
      sim.debugSpawn(EnemyKind.slime, 30, 0, hp: 1);
      _step(sim, 1.0);
      expect(sim.killsByWeapon['iron_sword'], greaterThanOrEqualTo(1));
    });

    test('弓は近くの敵に矢を放って倒す', () {
      final sim = _sim(loadout: [mockShopStock[1]]);
      sim.debugSpawn(EnemyKind.slime, 150, 0, hp: 1);
      _step(sim, 1.0);
      expect(sim.killsByWeapon['hunter_bow'], greaterThanOrEqualTo(1));
    });

    test('経験値が溜まるとレベルアップで一時停止し、選ぶと再開する', () {
      final sim = _sim(loadout: [mockShopStock[0]]);
      List<SkillId>? offered;
      sim.onLevelUp = (o) => offered = o;
      // 拾える距離に収まるよう、プレイヤーを囲むように置く
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * pi / 5;
        sim.debugSpawn(EnemyKind.slime, cos(a) * 26, sin(a) * 26, hp: 1);
      }
      for (var i = 0; i < 600 && sim.phase == RunPhase.playing; i++) {
        sim.update(1 / 60);
      }
      expect(sim.phase, RunPhase.levelUp);
      expect(offered, isNotEmpty);
      sim.chooseSkill(offered!.first);
      expect(sim.phase, RunPhase.playing);
      expect(sim.skills.level(offered!.first), 1);
    });

    test('帰還ゲートに入ると生還で終わる', () {
      final sim =
          _sim(config: const RunConfig(gateTimes: [0.1], gateDuration: 30));
      RunResult? ended;
      sim.onEnd = (r) => ended = r;
      _step(sim, 0.2);
      final g = sim.gate!;
      sim.px = g.x;
      sim.py = g.y;
      sim.update(1 / 60);
      expect(ended?.returned, isTrue);
      expect(sim.phase, RunPhase.ended);
    });

    test('ゲートは時間が過ぎると閉じ、時間切れ後は開きっぱなしになる', () {
      final sim = _sim(
          loadout: [mockShopStock[0]],
          config: const RunConfig(
              runLength: 2, gateTimes: [0.1], gateDuration: 0.5));
      _step(sim, 0.2);
      expect(sim.gate, isNotNull);
      _step(sim, 0.6);
      expect(sim.gate, isNull);
      sim.hp = 1e9;
      sim.maxHp = 1e9;
      _step(sim, 1.5);
      expect(sim.horde, isTrue);
      expect(sim.gate?.closesAt, isNull);
    });

    test('命中・撃破・被弾が演出用の出来事として出る', () {
      final sim = _sim(loadout: [mockShopStock[0]]);
      sim.debugSpawn(EnemyKind.slime, 30, 0, hp: 1);
      _step(sim, 1.0);
      final types = sim.events.map((e) => e.type).toSet();
      expect(
          types,
          containsAll(
              [RunEventType.swordSwing, RunEventType.hit, RunEventType.kill]));
      final hit = sim.events.firstWhere((e) => e.type == RunEventType.hit);
      expect(hit.weapon, CarriedWeaponType.sword);
      expect(hit.amount, sim.swordDamage);

      sim.events.clear();
      sim.debugSpawn(EnemyKind.goblin, sim.px, sim.py, hp: 1e9);
      sim.invulnerable = 0;
      sim.update(1 / 60);
      expect(sim.events.map((e) => e.type), contains(RunEventType.playerHurt));
    });

    test('宝石が上限を超えると古い宝石に経験値がまとまり、総量は減らない', () {
      final sim = _sim(loadout: [mockShopStock[0]]);
      const n = RunSimulation.maxGems + 20;
      for (var i = 0; i < n; i++) {
        // プレイヤーから離れた場所で倒す（拾われないように）
        sim.debugSpawn(EnemyKind.slime, 1000.0 + i, 1000, hp: 1);
      }
      for (final e in sim.enemies.toList()) {
        sim.debugKill(e, mockShopStock[0]);
      }
      final gems = sim.pickups.where((p) => p.material == null).toList();
      expect(gems.length, RunSimulation.maxGems);
      expect(gems.fold<int>(0, (a, p) => a + p.xp), n);
    });

    test('HPが0になると倒れて終わる', () {
      final sim = _sim(loadout: [mockShopStock[1]]);
      RunResult? ended;
      sim.onEnd = (r) => ended = r;
      sim.hp = 1;
      sim.debugSpawn(EnemyKind.goblin, 0, 0, hp: 1e9);
      sim.update(1 / 60);
      expect(ended?.returned, isFalse);
    });
  });
}
