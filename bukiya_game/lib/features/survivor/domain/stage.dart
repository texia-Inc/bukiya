import 'run_simulation.dart';

/// 出現する敵と、その時刻からの出やすさ
class SpawnRule {
  final EnemyKind kind;

  /// この秒数から出始める
  final double from;
  final double weight;

  const SpawnRule(this.kind, this.from, this.weight);
}

class BossSpawn {
  final double time;
  final EnemyKind kind;

  const BossSpawn(this.time, this.kind);
}

/// ステージ（出てくる敵・ボス・地面の色）
class StageDef {
  final String id;
  final int number;
  final String name;
  final String description;
  final List<SpawnRule> spawns;
  final List<BossSpawn> bosses;

  /// ホーム画面のステージの絵に立たせるボス
  final EnemyKind mascot;

  /// 雑魚の体力倍率
  final double hpScale;
  final double bossHpScale;

  final int groundColor;
  final int tileColor;
  final int grassColor;
  final int stoneColor;

  const StageDef({
    required this.id,
    required this.number,
    required this.name,
    required this.description,
    required this.spawns,
    required this.bosses,
    required this.mascot,
    required this.hpScale,
    required this.bossHpScale,
    required this.groundColor,
    required this.tileColor,
    required this.grassColor,
    required this.stoneColor,
  });
}

const forestStage = StageDef(
  id: 'forest',
  number: 1,
  name: '魔物の森',
  description: 'スライムやゴブリンが住む、店の裏手の森',
  spawns: [
    SpawnRule(EnemyKind.slime, 0, 5),
    SpawnRule(EnemyKind.bat, 45, 3),
    SpawnRule(EnemyKind.goblin, 100, 2),
    SpawnRule(EnemyKind.skeleton, 200, 1.5),
  ],
  bosses: [
    BossSpawn(120, EnemyKind.ogre),
    BossSpawn(240, EnemyKind.kingSlime),
  ],
  mascot: EnemyKind.kingSlime,
  hpScale: 1,
  bossHpScale: 1,
  groundColor: 0xFF243B2A,
  tileColor: 0xFF284330,
  grassColor: 0xFF3E6B48,
  stoneColor: 0xFF5B6660,
);

const graveyardStage = StageDef(
  id: 'graveyard',
  number: 2,
  name: '霧の墓地',
  description: '骸骨とおばけがさまよう、町はずれの古い墓地',
  spawns: [
    SpawnRule(EnemyKind.slime, 0, 2),
    SpawnRule(EnemyKind.bat, 0, 3),
    SpawnRule(EnemyKind.skeleton, 30, 2),
    SpawnRule(EnemyKind.ghost, 60, 3),
    SpawnRule(EnemyKind.goblin, 150, 1),
  ],
  bosses: [
    BossSpawn(120, EnemyKind.ogre),
    BossSpawn(240, EnemyKind.kingSlime),
  ],
  mascot: EnemyKind.ogre,
  hpScale: 1.2,
  bossHpScale: 1.3,
  groundColor: 0xFF2A2D3A,
  tileColor: 0xFF30344A,
  grassColor: 0xFF4A5068,
  stoneColor: 0xFF6E7488,
);

const List<StageDef> allStages = [forestStage, graveyardStage];
