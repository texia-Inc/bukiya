import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:flutter_test/flutter_test.dart';

CarriedWeapon get _sword =>
    mockShopStock.firstWhere((w) => w.type == CarriedWeaponType.sword);

void _step(RunSimulation sim, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    sim.update(1 / 60);
  }
}

/// 武器を持たず（ボスに当てず）、倒れないプレイヤー
RunSimulation _sim() {
  final sim = RunSimulation(
      loadout: const [],
      config: const RunConfig(gateTimes: [], runLength: 9999),
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

void main() {
  group('オーガ', () {
    test('突進・地面叩き・投石を順番に繰り出す', () {
      final sim = _sim();
      final ogre = sim.debugSpawn(EnemyKind.ogre, 600, 0, hp: 1e9);
      final seen = <BossAttack>[];
      for (var i = 0; i < 4; i++) {
        _toWindup(sim, ogre);
        seen.add(ogre.attack);
        _toWalk(sim, ogre);
      }
      expect(seen, [
        BossAttack.charge,
        BossAttack.smash,
        BossAttack.rocks,
        BossAttack.charge,
      ]);
    });

    test('地面叩きは範囲内のプレイヤーに当たり、外なら当たらない', () {
      final sim = _sim();
      final ogre = sim.debugSpawn(EnemyKind.ogre, 600, 0, hp: 1e9)
        ..attackCount = 1;
      _toWindup(sim, ogre);
      expect(ogre.attack, BossAttack.smash);
      // 範囲の内側（接触はしない距離）に立つ
      sim.px = ogre.x - ogreSmashRadius + 20;
      sim.py = ogre.y;
      final hp = sim.hp;
      _step(sim, bossWindupTime(ogre) + 0.05);
      expect(sim.events.map((e) => e.type), contains(RunEventType.bossSmash));
      expect(sim.hp, lessThanOrEqualTo(hp - ogreSmashDamage));

      // 次の叩きは範囲の外で受ける
      ogre.attackCount = 4;
      _toWalk(sim, ogre);
      _toWindup(sim, ogre);
      sim.px = ogre.x - ogreSmashRadius - 40;
      sim.py = ogre.y;
      sim.invulnerable = 0;
      final hp2 = sim.hp;
      _step(sim, bossWindupTime(ogre) + 0.05);
      expect(sim.hp, hp2);
    });

    test('投石は3つの岩を投げ、当たるとダメージ。怒ると5つになる', () {
      final sim = _sim();
      final ogre = sim.debugSpawn(EnemyKind.ogre, 600, 0, hp: 1e9)
        ..attackCount = 2;
      _toWindup(sim, ogre);
      expect(ogre.attack, BossAttack.rocks);
      _step(sim, bossWindupTime(ogre) + 0.05);
      expect(sim.bossShots.length, 3);
      final hp = sim.hp;
      _step(sim, 3);
      expect(sim.hp, lessThan(hp));

      ogre.enraged = true;
      _toWalk(sim, ogre);
      ogre
        ..attackCount = 2
        ..stateTime = 0;
      _toWindup(sim, ogre);
      sim.bossShots.clear();
      // 投げた岩がすぐ当たらないよう離す
      ogre
        ..x = sim.px + 400
        ..y = sim.py;
      _step(sim, bossWindupTime(ogre) + 0.05);
      expect(sim.bossShots.length, 5);
    });

    test('体力が半分を切ると怒り、突進が2連続になる', () {
      final sim = _sim();
      final ogre = sim.debugSpawn(EnemyKind.ogre, 600, 0);
      sim.debugHit(ogre, ogre.maxHp * 0.6, _sword);
      expect(ogre.enraged, isTrue);
      expect(sim.events.map((e) => e.type), contains(RunEventType.bossEnrage));
      _toWindup(sim, ogre);
      expect(ogre.attack, BossAttack.charge);
      var charges = 0;
      var last = ogre.bossState;
      for (var i = 0; i < 60 * 5; i++) {
        sim.update(1 / 60);
        if (ogre.bossState == BossState.charge && last != BossState.charge) {
          charges++;
        }
        last = ogre.bossState;
        if (ogre.bossState == BossState.walk) break;
      }
      expect(charges, 2);
    });
  });

  group('キングスライム', () {
    test('跳躍・スライム弾・手下呼びを順番に繰り出す', () {
      final sim = _sim();
      final king = sim.debugSpawn(EnemyKind.kingSlime, 600, 0, hp: 1e9);
      final seen = <BossAttack>[];
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 60 * 10; j++) {
          sim.update(1 / 60);
          if (king.bossState != BossState.walk) break;
        }
        seen.add(king.attack);
        _toWalk(sim, king);
      }
      expect(seen, [BossAttack.jump, BossAttack.spray, BossAttack.summon]);
    });

    test('スライム弾は輪になって飛ぶ。怒ると向きをずらして3回撒く', () {
      final sim = _sim();
      final king = sim.debugSpawn(EnemyKind.kingSlime, 600, 0, hp: 1e9)
        ..attackCount = 1;
      _toWindup(sim, king);
      _step(sim, bossWindupTime(king) + 0.05);
      expect(sim.bossShots.length, 10);

      sim.bossShots.clear();
      king
        ..enraged = true
        ..attackCount = 1;
      _toWalk(sim, king);
      _toWindup(sim, king);
      sim.events.clear();
      final events = <RunEventType>[];
      for (var i = 0; i < 60 * 3; i++) {
        sim.update(1 / 60);
        events.addAll(sim.events.map((e) => e.type));
        sim.events.clear();
      }
      expect(events.where((t) => t == RunEventType.bossSpray).length, 3);
    });

    test('手下呼びで小さいスライムが出る', () {
      final sim = _sim();
      final king = sim.debugSpawn(EnemyKind.kingSlime, 600, 0, hp: 1e9)
        ..attackCount = 2;
      _toWindup(sim, king);
      // 檻を閉じて雑魚の湧きを止める
      sim.debugCloseArena();
      king
        ..x = sim.px + 100
        ..y = sim.py
        ..inArena = true;
      sim.enemies.removeWhere((e) => !e.isBoss);
      _step(sim, bossWindupTime(king) + 0.05);
      expect(sim.enemies.where((e) => e.kind == EnemyKind.slime).length, 4);
    });

    test('怒ると跳躍が2連続になる', () {
      final sim = _sim();
      final king = sim.debugSpawn(EnemyKind.kingSlime, 600, 0, hp: 1e9)
        ..enraged = true;
      var slams = 0;
      for (var i = 0; i < 60 * 8; i++) {
        sim.update(1 / 60);
        slams +=
            sim.events.where((e) => e.type == RunEventType.bossSlam).length;
        sim.events.clear();
        if (king.attackCount > 0 && king.bossState == BossState.walk) break;
      }
      expect(slams, 2);
    });
  });

  test('ボスを倒すと飛んでいる弾は消える', () {
    final sim = _sim();
    final ogre = sim.debugSpawn(EnemyKind.ogre, 600, 0, hp: 1e9)
      ..attackCount = 2;
    _toWindup(sim, ogre);
    _step(sim, bossWindupTime(ogre) + 0.05);
    expect(sim.bossShots, isNotEmpty);
    sim.debugKill(ogre, _sword);
    expect(sim.bossShots, isEmpty);
  });
}
