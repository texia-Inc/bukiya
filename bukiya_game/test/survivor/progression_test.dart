import 'dart:convert';

import 'package:bukiya_game/features/survivor/domain/loadout.dart';
import 'package:bukiya_game/features/survivor/domain/profile.dart';
import 'package:bukiya_game/features/survivor/domain/rewards.dart';
import 'package:bukiya_game/features/survivor/domain/run_result.dart';
import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/domain/stage.dart';
import 'package:bukiya_game/features/survivor/domain/talents.dart';
import 'package:flutter_test/flutter_test.dart';

RunResult _result(SurvivorProfile p,
        {double seconds = 100,
        int bosses = 0,
        int kills = 0,
        bool returned = true}) =>
    RunResult.build(
      returned: returned,
      survivedSeconds: seconds,
      level: 5,
      materialsFound: const {},
      loadout: p.loadout,
      killsByWeapon: {p.loadout.first.id: kills},
      bossesDefeated: bosses,
    );

final _day1 = DateTime(2026, 11, 2, 10);
final _day2 = DateTime(2026, 11, 3, 9);

void main() {
  group('才能', () {
    test('お金で上げられ、値段は上がるごとに高くなり、上限で止まる', () {
      final p = SurvivorProfile()..gold = 100000;
      final d = talentDef(TalentId.vitality);
      final first = d.costAt(0);
      p.upgradeTalent(TalentId.vitality);
      expect(p.talentLevel(TalentId.vitality), 1);
      expect(p.gold, 100000 - first);
      expect(d.costAt(1), greaterThan(first));
      for (var i = 0; i < 30; i++) {
        p.upgradeTalent(TalentId.vitality);
      }
      expect(p.talentLevel(TalentId.vitality), d.maxLevel);
      expect(p.canUpgradeTalent(TalentId.vitality), isFalse);
    });

    test('お金が足りないと上げられない', () {
      final p = SurvivorProfile()..gold = 0;
      p.upgradeTalent(TalentId.power);
      expect(p.talentLevel(TalentId.power), 0);
    });

    test('出撃に効く：HP・ダメージ・受けるダメージ', () {
      const t =
          Talents({TalentId.vitality: 3, TalentId.power: 4, TalentId.guard: 5});
      final w = mockShopStock.first;
      final sim = RunSimulation(
          loadout: [w], config: const RunConfig(talents: t), seed: 1);
      expect(sim.maxHp, 130);
      final e = sim.debugSpawn(EnemyKind.slime, 500, 0, hp: 1000);
      sim.debugHit(e, 100, w);
      expect(e.hp, closeTo(1000 - 120, 0.01));
      final plain = RunSimulation(loadout: [w], seed: 1);
      expect(sim.moveSpeed, plain.moveSpeed);
      // 守り Lv5 で、スライムに触れたときのダメージが 15% 減る
      sim.enemies.clear();
      sim.debugSpawn(EnemyKind.slime, sim.px, sim.py, hp: 1e9);
      sim.update(1 / 60);
      expect(sim.hp,
          closeTo(130 - enemyStats[EnemyKind.slime]!.damage * 0.85, 0.01));
    });
  });

  group('ミッション', () {
    test('毎日のミッションは出撃で進み、受け取ると報酬が入る', () {
      final p = SurvivorProfile();
      for (var i = 0; i < 3; i++) {
        p.applyResult(_result(p, kills: 300), forestStage, now: _day1);
      }
      final runs = dailyMissions.firstWhere((m) => m.id == 'd_runs');
      final kills = dailyMissions.firstWhere((m) => m.id == 'd_kills');
      expect(p.missionProgress(runs, now: _day1), 3);
      expect(p.canClaimMission(runs, now: _day1), isTrue);
      expect(p.missionProgress(kills, now: _day1), kills.goal);
      final gold = p.gold;
      p.claimMission(runs, now: _day1);
      expect(p.gold, gold + runs.reward.gold);
      expect(p.canClaimMission(runs, now: _day1), isFalse);
    });

    test('日付が変わると毎日のミッションは数え直す', () {
      final p = SurvivorProfile();
      p.applyResult(_result(p), forestStage, now: _day1);
      final runs = dailyMissions.firstWhere((m) => m.id == 'd_runs');
      expect(p.missionProgress(runs, now: _day1), 1);
      expect(p.missionProgress(runs, now: _day2), 0);
    });

    test('実績は合計で数え、日付が変わっても消えない', () {
      final p = SurvivorProfile();
      p.applyResult(_result(p, kills: 600), forestStage, now: _day1);
      p.applyResult(_result(p, kills: 600, bosses: 1), forestStage, now: _day2);
      final k1 = achievements.firstWhere((m) => m.id == 'a_kills1');
      final b1 = achievements.firstWhere((m) => m.id == 'a_boss1');
      expect(p.canClaimMission(k1, now: _day2), isTrue);
      expect(p.canClaimMission(b1, now: _day2), isTrue);
      p.claimMission(k1, now: _day2);
      expect(p.canClaimMission(k1, now: _day2), isFalse);
    });

    test('3分生き残る・帰還する・鍛えるも数える', () {
      final p = SurvivorProfile()..gold = 100000;
      p.applyResult(_result(p, seconds: 200, returned: true), forestStage,
          now: DateTime.now());
      final survive = dailyMissions.firstWhere((m) => m.id == 'd_survive');
      final ret = dailyMissions.firstWhere((m) => m.id == 'd_return');
      expect(p.canClaimMission(survive), isTrue);
      expect(p.canClaimMission(ret), isTrue);
      p.materials.addAll({for (final k in MaterialKind.values) k: 99});
      p.enchant(p.weapons.first);
      final forge = dailyMissions.firstWhere((m) => m.id == 'd_forge');
      expect(p.canClaimMission(forge), isTrue);
      expect(p.totalForges, 1);
    });
  });

  group('チャプター宝箱', () {
    test('生き残った時間に応じて1回ずつ受け取れる', () {
      final p = SurvivorProfile();
      final c1 = chapterChests[0], c3 = chapterChests[1];
      expect(p.canClaimChest(forestStage, c1), isFalse);
      p.applyResult(_result(p, seconds: 70), forestStage, now: _day1);
      expect(p.canClaimChest(forestStage, c1), isTrue);
      expect(p.canClaimChest(forestStage, c3), isFalse);
      expect(p.hasClaimableChest(), isTrue);
      final gold = p.gold;
      p.claimChest(forestStage, c1);
      expect(p.gold, greaterThan(gold));
      expect(p.canClaimChest(forestStage, c1), isFalse);
      expect(p.hasClaimableChest(), isFalse);
    });
  });

  group('パトロール', () {
    test('留守の時間に応じて貯まり、上限で止まり、受け取ると数え直す', () {
      final p = SurvivorProfile();
      final t0 = DateTime(2026, 11, 2, 8);
      expect(p.patrolMinutes(t0), 0);
      expect(p.canClaimPatrol(t0), isFalse);
      final t1 = t0.add(const Duration(minutes: 60));
      final r = p.patrolPending(t1);
      expect(r.gold, greaterThan(0));
      expect(r.materials.values.fold(0, (a, b) => a + b),
          60 ~/ patrolMinutesPerMaterial);
      final far = t0.add(const Duration(days: 3));
      expect(p.patrolMinutes(far), patrolCap.inMinutes);
      final gold = p.gold;
      final got = p.claimPatrol(t1);
      expect(p.gold, gold + got.gold);
      expect(p.patrolMinutes(t1), 0);
    });

    test('解放したステージが多いほど多く貯まる', () {
      expect(patrolReward(60, 5, 1).gold,
          greaterThan(patrolReward(60, 1, 1).gold));
    });
  });

  group('毎日のギフト', () {
    test('1日1回だけ受け取れる', () {
      final p = SurvivorProfile();
      expect(p.canClaimGift(_day1), isTrue);
      final r = p.claimGift(_day1)!;
      expect(r.gold, greaterThan(0));
      expect(p.canClaimGift(_day1), isFalse);
      expect(p.claimGift(_day1), isNull);
      expect(p.canClaimGift(_day2), isTrue);
    });
  });

  test('新しい記録も保存して読み戻せる', () {
    final p = SurvivorProfile()..gold = 100000;
    p.upgradeTalent(TalentId.power);
    p.applyResult(_result(p, kills: 50, seconds: 200), forestStage, now: _day1);
    p.claimChest(forestStage, chapterChests[0]);
    p.claimGift(_day1);
    p.patrolMinutes(_day1);
    final back = SurvivorProfile.fromJson(
        jsonDecode(jsonEncode(p.toJson())) as Map<String, Object?>);
    expect(back.talentLevel(TalentId.power), 1);
    expect(back.totalKills, 50);
    expect(back.chestClaimed(forestStage, chapterChests[0]), isTrue);
    expect(back.canClaimGift(_day1), isFalse);
    expect(back.patrolSince, p.patrolSince);
    expect(
        back.missionProgress(dailyMissions.firstWhere((m) => m.id == 'd_runs'),
            now: _day1),
        1);
  });
}
