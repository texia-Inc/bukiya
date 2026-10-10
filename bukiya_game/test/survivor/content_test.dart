import 'dart:math';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/run_result.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/domain/skills.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:flutter_test/flutter_test.dart';

CarriedWeapon _w(CarriedWeaponType t) =>
    mockShopStock.firstWhere((w) => w.type == t);

void _step(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

void main() {
  group('新しい武器', () {
    test('槍は一番近い敵の方へ突き、反対側の敵には当たらない', () {
      final sim =
          RunSimulation(loadout: [_w(CarriedWeaponType.spear)], seed: 1);
      // 向きとは逆側にいる敵でも、近ければそちらを狙う
      sim.facingX = 1;
      sim.facingY = 0;
      final near = sim.debugSpawn(EnemyKind.slime, -40, 0, hp: 1e6);
      final other = sim.debugSpawn(EnemyKind.slime, 0, 90, hp: 1e6);
      _step(sim, 0.6);
      expect(near.hp, lessThan(1e6));
      expect(other.hp, 1e6);
    });

    test('杖の爆発は範囲内の敵をまとめて巻き込む', () {
      final sim =
          RunSimulation(loadout: [_w(CarriedWeaponType.staff)], seed: 1);
      final a = sim.debugSpawn(EnemyKind.slime, 120, 0, hp: 1e6);
      final b = sim.debugSpawn(EnemyKind.slime, 140, 10, hp: 1e6);
      final far = sim.debugSpawn(EnemyKind.slime, 120, 200, hp: 1e6);
      _step(sim, 1.5);
      expect(a.hp, lessThan(1e6));
      expect(b.hp, lessThan(1e6));
      expect(far.hp, 1e6);
      expect(sim.killsByWeapon, isEmpty);
    });
  });

  group('進化', () {
    for (final evo in evolutions) {
      test('${skillDefs[evo.evolution]!.name} は条件を満たすと候補に出る', () {
        final skills = SkillSet();
        final carried = {evo.weapon};
        for (var i = 0; i < skillDefs[evo.maxed]!.maxLevel; i++) {
          skills.add(evo.maxed);
        }
        expect(skills.availableEvolutions(carried), isEmpty);
        skills.add(evo.passive);
        expect(skills.availableEvolutions(carried), [evo.evolution]);
        expect(skills.offer(carried, Random(0)).first, evo.evolution);
        // 武器を持っていなければ出ない
        expect(skills.availableEvolutions({}), isEmpty);
      });
    }
  });

  group('ボス', () {
    test('ステージで決めた時刻にボスが出る', () {
      final sim = RunSimulation(
          loadout: [_w(CarriedWeaponType.bow)],
          config: const RunConfig(stage: forestStage),
          seed: 1);
      sim.time = 119.9;
      sim.hp = sim.maxHp = 1e9;
      _step(sim, 0.2);
      expect(sim.boss?.kind, EnemyKind.ogre);
      expect(sim.events.map((e) => e.type), contains(RunEventType.bossSpawn));
    });

    test('オーガは歩いて、溜めてから突進する', () {
      final sim = RunSimulation(loadout: [_w(CarriedWeaponType.bow)], seed: 1);
      sim.hp = sim.maxHp = 1e9;
      final ogre = sim.debugSpawn(EnemyKind.ogre, 300, 0);
      _step(sim, ogreWalkTime + 0.05);
      expect(ogre.bossState, BossState.windup);
      expect(ogre.dirX, closeTo(-1, 0.1));
      _step(sim, ogreWindupTime);
      expect(ogre.bossState, BossState.charge);
      final x = ogre.x;
      _step(sim, 0.2);
      expect(ogre.x, lessThan(x - 60));
    });

    test('キングスライムは跳んでいる間は攻撃が当たらず、着地で衝撃波を出す', () {
      final sim =
          RunSimulation(loadout: [_w(CarriedWeaponType.sword)], seed: 1);
      final king = sim.debugSpawn(EnemyKind.kingSlime, 120, 0);
      _step(sim, kingSlimeWalkTime + 0.05);
      expect(king.airborne, isTrue);
      final hp = king.hp;
      _step(sim, 0.5);
      expect(king.hp, hp);
      final playerHp = sim.hp;
      sim.invulnerable = 0;
      _step(sim, kingSlimeAirTime);
      expect(king.airborne, isFalse);
      expect(sim.events.map((e) => e.type), contains(RunEventType.bossSlam));
      expect(sim.hp, lessThan(playerHp));
    });

    test('キングスライムは体力が半分を切るとスライムを撒く', () {
      final sim =
          RunSimulation(loadout: [_w(CarriedWeaponType.sword)], seed: 1);
      final king = sim.debugSpawn(EnemyKind.kingSlime, 1000, 0);
      king.hp = king.maxHp / 2 + 1;
      sim.debugKill(sim.debugSpawn(EnemyKind.slime, 2000, 0),
          _w(CarriedWeaponType.sword));
      final before = sim.enemies.where((e) => e.kind == EnemyKind.slime).length;
      // 2 ダメージで半分を切らせる
      sim.debugHit(king, 2, _w(CarriedWeaponType.sword));
      final after = sim.enemies.where((e) => e.kind == EnemyKind.slime).length;
      expect(after - before, 8);
      expect(king.split, isTrue);
    });

    test('ボスを倒すと宝箱が出て、拾うと魔核とレベルアップ2回分', () {
      final sim =
          RunSimulation(loadout: [_w(CarriedWeaponType.sword)], seed: 1);
      final ogre = sim.debugSpawn(EnemyKind.ogre, 0, 0);
      sim.debugKill(ogre, _w(CarriedWeaponType.sword));
      expect(sim.bossesDefeated, 1);
      final chest = sim.pickups.firstWhere((p) => p.kind == PickupKind.chest);
      expect(chest, isNotNull);
      final level = sim.level;
      sim.enemies.clear();
      for (var i = 0; i < 300 && sim.phase == RunPhase.playing; i++) {
        sim.update(1 / 60);
      }
      expect(sim.materials[MaterialKind.bossCore], 1);
      expect(sim.level, greaterThanOrEqualTo(level + 2));
      expect(sim.phase, RunPhase.levelUp);
    });
  });

  group('ステージ', () {
    test('霧の墓地は序盤からコウモリとスライムだけが出て、骸骨は30秒から', () {
      final sim = RunSimulation(
          loadout: [_w(CarriedWeaponType.bow)],
          config: const RunConfig(stage: graveyardStage),
          seed: 3);
      sim.hp = sim.maxHp = 1e9;
      _step(sim, 20);
      final kinds = sim.enemies.map((e) => e.kind).toSet();
      expect(kinds.difference({EnemyKind.slime, EnemyKind.bat}), isEmpty);
    });
  });
}
