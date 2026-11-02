import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:flutter_test/flutter_test.dart';

CarriedWeapon get _sword =>
    mockShopStock.firstWhere((w) => w.type == CarriedWeaponType.sword);

void _step(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

/// 武器を持たず、倒れないプレイヤー（雑魚は湧かない）
RunSimulation _sim({StageDef stage = forestStage}) {
  final sim = RunSimulation(
      loadout: const [],
      config: RunConfig(stage: stage, gateTimes: const [], runLength: 9999),
      seed: 1);
  sim.hp = sim.maxHp = 1e9;
  return sim;
}

/// 次の大技の溜めに入るまで進める
void _toWindup(RunSimulation sim, Enemy boss) {
  for (var i = 0; i < 60 * 20; i++) {
    sim.update(1 / 60);
    if (boss.bossState == BossState.windup) return;
  }
  fail('溜めに入らなかった');
}

void _toWalk(RunSimulation sim, Enemy boss) {
  for (var i = 0; i < 60 * 10; i++) {
    sim.update(1 / 60);
    if (boss.bossState == BossState.walk) return;
  }
  fail('歩きに戻らなかった');
}

/// 檻の中にボスを置く
Enemy _boss(RunSimulation sim, EnemyKind kind, {double dx = 150}) {
  sim.debugCloseArena();
  return sim.debugSpawn(kind, sim.px + dx, sim.py, hp: 1e9)..inArena = true;
}

void main() {
  group('大輪の人食い花', () {
    test('種・根のとげ・潜行を順番に繰り出す', () {
      final sim = _sim();
      final f = _boss(sim, EnemyKind.flowerQueen);
      final seen = <BossAttack>[];
      for (var i = 0; i < 3; i++) {
        _toWindup(sim, f);
        seen.add(f.attack);
        _toWalk(sim, f);
      }
      expect(seen, [BossAttack.seeds, BossAttack.roots, BossAttack.burrow]);
    });

    test('根を張っていて、歩いて近づいてはこない', () {
      final sim = _sim();
      final f = _boss(sim, EnemyKind.flowerQueen, dx: 100);
      final x = f.x;
      _step(sim, 1);
      expect(f.x, x);
    });

    test('種は扇状に5つ飛ぶ', () {
      final sim = _sim();
      final f = _boss(sim, EnemyKind.flowerQueen);
      _toWindup(sim, f);
      _step(sim, bossWindupTime(f) + 0.02);
      expect(sim.bossShots.length, 5);
    });

    test('根のとげは予告のあと足元から噴き出し、その上にいると痛い', () {
      final sim = _sim();
      final f = _boss(sim, EnemyKind.flowerQueen)..attackCount = 1;
      _toWindup(sim, f);
      expect(f.attack, BossAttack.roots);
      _step(sim, bossWindupTime(f) + 0.02);
      expect(sim.hazards, isNotEmpty);
      final first = sim.hazards.first;
      expect(first.erupted, isFalse);
      // プレイヤーはとげの真上（ボスから離れた所）にいる
      expect(
          (first.x - sim.px).abs() < 1 && (first.y - sim.py).abs() < 1, isTrue);
      final hp = sim.hp;
      sim.invulnerable = 0;
      _step(sim, 1.0);
      expect(sim.events.map((e) => e.type), contains(RunEventType.hazardBurst));
      expect(sim.hp, lessThan(hp));
    });

    test('潜ってプレイヤーの所から飛び出し、潜っている間は攻撃が当たらない', () {
      final sim = _sim();
      final f = _boss(sim, EnemyKind.flowerQueen)..attackCount = 2;
      _toWindup(sim, f);
      expect(f.attack, BossAttack.burrow);
      _step(sim, bossWindupTime(f) + 0.05);
      expect(f.airborne, isTrue);
      sim.invulnerable = 0;
      final hp = sim.hp;
      _step(sim, flowerBurrowTime);
      expect(f.airborne, isFalse);
      expect((f.x - sim.px).abs(), lessThan(5));
      expect(sim.hp, lessThan(hp));
    });
  });

  group('サソリの王', () {
    test('突進・毒針・毒の水たまりを順番に繰り出す', () {
      final sim = _sim();
      final s = _boss(sim, EnemyKind.scorpionKing, dx: 250);
      final seen = <BossAttack>[];
      for (var i = 0; i < 3; i++) {
        _toWindup(sim, s);
        seen.add(s.attack);
        _toWalk(sim, s);
      }
      expect(seen, [BossAttack.charge, BossAttack.sting, BossAttack.poison]);
    });

    test('毒針は前の扇形にだけ届く', () {
      final e = Enemy(EnemyKind.scorpionKing, 0, 0, 1)
        ..dirX = 1
        ..dirY = 0;
      expect(inStingCone(e, 100, 10), isTrue);
      expect(inStingCone(e, -100, 0), isFalse);
      expect(inStingCone(e, 0, 120), isFalse);
      expect(inStingCone(e, 400, 0), isFalse);
    });

    test('毒の水たまりはしばらく残り、上にいる間ずっと痛い', () {
      final sim = _sim();
      final s = _boss(sim, EnemyKind.scorpionKing, dx: 250)..attackCount = 2;
      _toWindup(sim, s);
      expect(s.attack, BossAttack.poison);
      _step(sim, bossWindupTime(s) + 1.0);
      final puddles = sim.hazards.where((h) => h.erupted).toList();
      expect(puddles, isNotEmpty);
      final hp = sim.hp;
      _step(sim, 2);
      // 無敵時間ごとに何度も削られる
      expect(hp - sim.hp, greaterThan(scorpionPoisonDamage * 2));
    });
  });

  group('魔王', () {
    test('闇の玉・闇の柱・瞬間移動を順番に、怒ると黒騎士も呼ぶ', () {
      final sim = _sim();
      final d = _boss(sim, EnemyKind.demonLord, dx: 200);
      final seen = <BossAttack>[];
      for (var i = 0; i < 3; i++) {
        _toWindup(sim, d);
        seen.add(d.attack);
        _toWalk(sim, d);
      }
      expect(seen, [BossAttack.orbs, BossAttack.pillars, BossAttack.teleport]);
      d
        ..enraged = true
        ..attackCount = 3;
      _toWindup(sim, d);
      expect(d.attack, BossAttack.knights);
      sim.enemies.removeWhere((e) => !e.isBoss);
      _step(sim, bossWindupTime(d) + 0.05);
      expect(sim.enemies.where((e) => e.kind == EnemyKind.knight).length, 3);
    });

    test('闇の玉は輪になって16個飛ぶ', () {
      final sim = _sim();
      final d = _boss(sim, EnemyKind.demonLord, dx: 200);
      _toWindup(sim, d);
      _step(sim, bossWindupTime(d) + 0.02);
      expect(sim.bossShots.length, 16);
    });

    test('闇の柱はプレイヤーへ向かって一列に7本、手前から順に噴き出す', () {
      final sim = _sim();
      final d = _boss(sim, EnemyKind.demonLord, dx: 200)..attackCount = 1;
      _toWindup(sim, d);
      _step(sim, bossWindupTime(d) + 0.02);
      expect(sim.hazards.length, 7);
      final delays = sim.hazards.map((h) => h.delay).toList();
      expect(delays, [...delays]..sort());
    });

    test('瞬間移動は檻の中の、プレイヤーから離れた所へ', () {
      final sim = _sim();
      final d = _boss(sim, EnemyKind.demonLord, dx: 200)..attackCount = 2;
      _toWindup(sim, d);
      _step(sim, bossWindupTime(d) + 0.02);
      expect(
          sim.events.map((e) => e.type), contains(RunEventType.bossTeleport));
      expect(sim.arena!.contains(d.x, d.y), isTrue);
    });
  });

  group('中ボス', () {
    test('1分で現れ、大きく・硬く、知らせが出る', () {
      final sim = _sim();
      sim.time = 59.9;
      _step(sim, 0.2);
      final e = sim.elite!;
      expect(e.kind, forestStage.midBosses.first.kind);
      expect(e.bodyScale, greaterThan(2));
      expect(e.maxHp, greaterThan(enemyStats[e.kind]!.hp * 5));
      expect(sim.events.map((x) => x.type), contains(RunEventType.eliteSpawn));
    });

    test('予告してから突進してくる', () {
      final sim = _sim();
      final e = sim.debugSpawn(EnemyKind.goblin, 200, 0, hp: 1e9)
        ..elite = true
        ..bodyScale = eliteBodyScale;
      var charged = false;
      var warned = false;
      for (var i = 0; i < 60 * 6; i++) {
        sim.update(1 / 60);
        if (e.bossState == BossState.windup) warned = true;
        if (e.bossState == BossState.charge) {
          charged = true;
          break;
        }
      }
      expect(warned, isTrue);
      expect(charged, isTrue);
    });

    test('倒すと小さな宝箱を落とし、拾うとレベルが上がる', () {
      final sim = RunSimulation(loadout: [_sword], seed: 1);
      final e = sim.debugSpawn(EnemyKind.goblin, 30, 0, hp: 100)
        ..elite = true
        ..bodyScale = eliteBodyScale;
      sim.debugKill(e, _sword);
      expect(sim.pickups.any((p) => p.kind == PickupKind.miniChest), isTrue);
      expect(
          sim.events.map((x) => x.type), contains(RunEventType.eliteDefeated));
      final chest =
          sim.pickups.firstWhere((p) => p.kind == PickupKind.miniChest);
      sim.px = chest.x;
      sim.py = chest.y;
      final lv = sim.level;
      sim.update(1 / 60);
      expect(sim.level, greaterThan(lv));
    });

    test('ボス戦の檻がある間は出てこない', () {
      final sim = _sim();
      sim.debugSpawn(EnemyKind.ogre, sim.px + 100, sim.py, hp: 1e9);
      sim.debugCloseArena();
      sim.time = 59.9;
      _step(sim, 1);
      expect(sim.elite, isNull);
    });
  });

  test('後半のステージの最後のボスは、新しいボス', () {
    expect(farmStage.bosses.last.kind, EnemyKind.flowerQueen);
    expect(desertStage.bosses.last.kind, EnemyKind.scorpionKing);
    expect(castleStage.bosses.last.kind, EnemyKind.demonLord);
    for (final s in allStages) {
      expect(s.midBosses.length, 2, reason: s.id);
    }
  });
}
