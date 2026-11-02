import 'dart:math';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:flutter_test/flutter_test.dart';

CarriedWeapon get _bow =>
    mockShopStock.firstWhere((w) => w.type == CarriedWeaponType.bow);

void _step(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

RunSimulation _sim({StageDef stage = forestStage, RunConfig? config}) {
  final sim = RunSimulation(
      loadout: [_bow], config: config ?? RunConfig(stage: stage), seed: 1);
  sim.hp = sim.maxHp = 1e9;
  return sim;
}

/// ボスが出ない、大群だけのステージ（ウェーブの確認用）
const _waveOnlyStage = StageDef(
  id: 'test',
  number: 9,
  name: 'test',
  description: '',
  spawns: [SpawnRule(EnemyKind.slime, 0, 1)],
  bosses: [],
  mascot: EnemyKind.ogre,
  waves: [
    WaveEvent(20, WaveType.ring, EnemyKind.slime, 30),
    WaveEvent(40, WaveType.swarm, EnemyKind.bat, 40),
  ],
  hpScale: 1,
  bossHpScale: 1,
  groundColor: 0,
  tileColor: 0,
  grassColor: 0,
  stoneColor: 0,
);

void main() {
  group('ボス戦の檻', () {
    test('ボスが出るとプレイヤーの周りに檻ができ、外に出られない', () {
      final sim = _sim();
      sim.time = 119.9;
      _step(sim, 0.2);
      final a = sim.arena!;
      expect(sim.boss, isNotNull);
      expect(a.contains(sim.boss!.x, sim.boss!.y), isTrue);
      expect(sim.events.map((e) => e.type), contains(RunEventType.arenaClose));
      // 右へ歩き続けても柵で止まる
      sim.setInput(1, 0);
      _step(sim, 5);
      expect(sim.px, lessThanOrEqualTo(a.right));
      expect(sim.arena, isNotNull);
    });

    test('檻の外の敵は中に入れず、中の敵は外に出られない', () {
      final sim = _sim();
      final outside = sim.debugSpawn(EnemyKind.goblin, 400, 0, hp: 1e9);
      sim.time = 119.9;
      _step(sim, 0.2);
      final a = sim.arena!;
      expect(outside.inArena, isFalse);
      _step(sim, 8);
      // プレイヤーへ向かってきても柵の外で止まる
      expect(a.contains(outside.x, outside.y), isFalse);
      expect(a.contains(sim.boss!.x, sim.boss!.y), isTrue);
    });

    test('ボス戦の間は雑魚が湧かず、ボスを倒すと檻が開く', () {
      final sim = _sim();
      sim.time = 119.9;
      _step(sim, 0.2);
      sim.enemies.removeWhere((e) => !e.isBoss);
      _step(sim, 3);
      expect(sim.enemies.where((e) => !e.isBoss), isEmpty);
      sim.debugKill(sim.boss!, _bow);
      sim.update(1 / 60);
      expect(sim.arena, isNull);
      expect(sim.events.map((e) => e.type), contains(RunEventType.arenaOpen));
    });

    test('檻がある間に開く帰還ゲートは、檻の中に置かれる', () {
      final sim = _sim(
          config: const RunConfig(
              stage: forestStage, gateTimes: [125], gateDuration: 30));
      sim.time = 119.9;
      _step(sim, 0.2);
      _step(sim, 5.5);
      final g = sim.gate!;
      expect(sim.arena!.contains(g.x, g.y), isTrue);
    });
  });

  group('縦長の通路', () {
    test('左右の崖より外には出られない', () {
      final sim = _sim(stage: canyonStage);
      final c = canyonStage.corridorHalfWidth!;
      sim.setInput(1, 0);
      _step(sim, 5);
      expect(sim.px, lessThanOrEqualTo(c));
      sim.setInput(-1, 0);
      _step(sim, 8);
      expect(sim.px, greaterThanOrEqualTo(-c));
    });

    test('敵は通路の上か下から出てきて、通路の外へははみ出さない', () {
      final sim = _sim(stage: canyonStage);
      final c = canyonStage.corridorHalfWidth!;
      _step(sim, 10);
      expect(sim.enemies, isNotEmpty);
      for (final e in sim.enemies) {
        expect(e.x.abs(), lessThanOrEqualTo(c));
      }
    });

    test('通路の檻は通路の幅に合わせる', () {
      final sim = _sim(stage: canyonStage);
      sim.time = 119.9;
      _step(sim, 0.2);
      final a = sim.arena!;
      final c = canyonStage.corridorHalfWidth!;
      expect(a.left, greaterThanOrEqualTo(-c));
      expect(a.right, lessThanOrEqualTo(c));
    });
  });

  group('大群ウェーブ', () {
    test('少し前に警告が出て、時刻になると輪になって取り囲む', () {
      final sim = _sim();
      final wave = forestStage.waves.first;
      expect(wave.type, WaveType.ring);
      sim.time = wave.time - waveWarningTime - 0.1;
      _step(sim, 0.2);
      expect(sim.events.map((e) => e.type), contains(RunEventType.waveWarning));
      sim.events.clear();
      sim.enemies.clear();
      sim.time = wave.time - 0.05;
      _step(sim, 0.1);
      expect(sim.events.map((e) => e.type), contains(RunEventType.waveStart));
      final ring = sim.enemies.where((e) => e.kind == wave.kind).toList();
      expect(ring.length, greaterThanOrEqualTo(wave.count));
    });

    test('突撃は一方向から、決まった数がしばらくかけて流れ込む', () {
      // 2:00 のボスで大群が見送られないよう、ボスのいないステージで確かめる
      final sim = _sim(stage: _waveOnlyStage);
      final wave =
          _waveOnlyStage.waves.firstWhere((w) => w.type == WaveType.swarm);
      sim.time = wave.time - 0.05;
      sim.enemies.clear();
      _step(sim, 0.1);
      final early = sim.enemies.where((e) => e.kind == wave.kind).length;
      expect(early, lessThan(wave.count));
      _step(sim, swarmDuration + 0.5);
      // 弓で倒された分も数える
      final spawned =
          sim.enemies.where((e) => e.kind == wave.kind).length + sim.totalKills;
      expect(spawned, greaterThanOrEqualTo(wave.count));
    });

    test('大群の予告から押し寄せ終わるまではラッシュ中（カメラを引く）', () {
      final sim = _sim(stage: _waveOnlyStage);
      final wave = _waveOnlyStage.waves.first;
      expect(sim.rush, isFalse);
      sim.time = wave.time - waveWarningTime - 0.1;
      _step(sim, 0.2);
      expect(sim.rush, isTrue);
      sim.time = wave.time + waveRushTime + 0.1;
      _step(sim, 0.1);
      expect(sim.rush, isFalse);
    });

    test('柔らかい大群はふだんより打たれ弱く、硬い大群は遅くて硬く、大きく経験値も多い', () {
      // 武器なし（敵が倒されず、動きだけを比べられる）
      final sim = RunSimulation(
          loadout: const [],
          config: const RunConfig(stage: _waveOnlyStage),
          seed: 1);
      final normalHp = enemyStats[EnemyKind.goblin]!.hp * (1 + sim.time / 150);
      final normal = sim.debugSpawn(EnemyKind.goblin, -300, 150, hp: normalHp);
      sim.debugSpawnRing(EnemyKind.slime, 10, hpScale: 0.35);
      sim.debugSpawnRing(EnemyKind.goblin, 10, hpScale: 3, speedScale: 0.6);
      sim.update(1 / 60);
      final soft = sim.enemies.firstWhere((e) => e.kind == EnemyKind.slime);
      final heavy = sim.enemies
          .firstWhere((e) => e.kind == EnemyKind.goblin && e != normal);
      expect(soft.maxHp, lessThan(enemyStats[EnemyKind.slime]!.hp * 0.5));
      expect(soft.bodyScale, 1);
      expect(heavy.maxHp, greaterThan(normalHp * 2.5));
      expect(heavy.speedScale, lessThan(1));
      expect(heavy.bodyScale, greaterThan(1));
      expect(heavy.xpScale, greaterThan(1));
      // 遅い：同じ時間で歩く距離が短い
      double dist(Enemy e) => sqrt(
          (e.x - sim.px) * (e.x - sim.px) + (e.y - sim.py) * (e.y - sim.py));
      final d0 = dist(heavy), n0 = dist(normal);
      _step(sim, 0.5);
      final d1 = dist(heavy), n1 = dist(normal);
      expect(d0 - d1, lessThan((n0 - n1) * 0.8));
    });

    test('どのステージも、最初の大群は柔らかく、最後の大群は遅くて硬い', () {
      for (final st in allStages) {
        expect(st.waves.first.hpScale, lessThan(1), reason: st.id);
        expect(st.waves.last.hpScale, greaterThanOrEqualTo(heavyWaveHp),
            reason: st.id);
        expect(st.waves.last.speedScale, lessThan(1), reason: st.id);
      }
    });

    test('数の多い輪は何重にも重なり、上限を超えては出ない', () {
      final sim = _sim(stage: _waveOnlyStage);
      sim.debugSpawnRing(EnemyKind.slime, 120);
      sim.update(1 / 60);
      final ring = sim.enemies.where((e) => e.kind == EnemyKind.slime).toList();
      expect(ring.length, greaterThanOrEqualTo(120));
      final dists = ring
          .map((e) => ((e.x - sim.px) * (e.x - sim.px) +
                  (e.y - sim.py) * (e.y - sim.py))
              .round())
          .toSet();
      expect(dists.length, greaterThan(1));
      sim.debugSpawnRing(EnemyKind.slime, 2000);
      sim.update(1 / 60);
      expect(sim.enemies.length,
          lessThanOrEqualTo(sim.config.maxEnemies + 400 + 10));
    });

    test('ボス戦（檻の中）の最中の大群は見送る', () {
      final sim = _sim();
      final wave = forestStage.waves.first;
      sim.time = wave.time - 5;
      sim.enemies.clear();
      // ボスがいる間は檻が開かない
      sim.debugSpawn(EnemyKind.ogre, sim.px + 100, sim.py, hp: 1e9);
      sim.debugCloseArena();
      _step(sim, 5.2);
      expect(sim.events.map((e) => e.type),
          isNot(contains(RunEventType.waveStart)));
      expect(sim.enemies.where((e) => !e.isBoss), isEmpty);
    });
  });
}
