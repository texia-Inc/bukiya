import 'run_simulation.dart';

/// 出現する敵と、その時刻からの出やすさ
class SpawnRule {
  final EnemyKind kind;

  /// この秒数から出始める
  final double from;
  final double weight;

  const SpawnRule(this.kind, this.from, this.weight);
}

/// 大群ウェーブの種類
enum WaveType {
  /// プレイヤーを円形に取り囲んで迫ってくる（通路では上下から列になって来る）
  ring,

  /// 一方向から群れで突っ込んでくる
  swarm,
}

/// 決まった時刻に押し寄せる大群
class WaveEvent {
  final double time;
  final WaveType type;
  final EnemyKind kind;
  final int count;

  const WaveEvent(this.time, this.type, this.kind, this.count);
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

  /// 大群ウェーブの予定（時刻順）
  final List<WaveEvent> waves;

  /// 縦長の通路ステージなら、通路の半分の幅（左右は崖で通れない）。null なら制限なし
  final double? corridorHalfWidth;

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
    this.waves = const [],
    this.corridorHalfWidth,
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
  waves: [
    WaveEvent(55, WaveType.ring, EnemyKind.slime, 36),
    WaveEvent(150, WaveType.swarm, EnemyKind.bat, 40),
    WaveEvent(205, WaveType.ring, EnemyKind.goblin, 20),
    WaveEvent(285, WaveType.ring, EnemyKind.skeleton, 24),
  ],
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
  waves: [
    WaveEvent(45, WaveType.swarm, EnemyKind.bat, 40),
    WaveEvent(100, WaveType.ring, EnemyKind.skeleton, 24),
    WaveEvent(165, WaveType.swarm, EnemyKind.ghost, 36),
    WaveEvent(215, WaveType.ring, EnemyKind.ghost, 30),
    WaveEvent(285, WaveType.swarm, EnemyKind.bat, 60),
  ],
  hpScale: 1.2,
  bossHpScale: 1.15,
  groundColor: 0xFF2A2D3A,
  tileColor: 0xFF30344A,
  grassColor: 0xFF4A5068,
  stoneColor: 0xFF6E7488,
);

const canyonStage = StageDef(
  id: 'canyon',
  number: 3,
  name: '断崖の谷道',
  description: '左右を崖にはさまれた細い谷道。上下からしか逃げられない',
  spawns: [
    SpawnRule(EnemyKind.slime, 0, 2),
    SpawnRule(EnemyKind.bat, 0, 3),
    SpawnRule(EnemyKind.goblin, 40, 2),
    SpawnRule(EnemyKind.skeleton, 90, 2),
    SpawnRule(EnemyKind.ghost, 150, 2),
  ],
  bosses: [
    BossSpawn(120, EnemyKind.ogre),
    BossSpawn(240, EnemyKind.kingSlime),
  ],
  mascot: EnemyKind.kingSlime,
  waves: [
    WaveEvent(35, WaveType.swarm, EnemyKind.bat, 20),
    WaveEvent(80, WaveType.ring, EnemyKind.slime, 16),
    WaveEvent(160, WaveType.swarm, EnemyKind.goblin, 16),
    WaveEvent(200, WaveType.ring, EnemyKind.skeleton, 14),
    WaveEvent(280, WaveType.swarm, EnemyKind.ghost, 36),
  ],
  corridorHalfWidth: 160,
  hpScale: 1.15,
  bossHpScale: 1.6,
  groundColor: 0xFF4A3B2A,
  tileColor: 0xFF524230,
  grassColor: 0xFF6B5A3A,
  stoneColor: 0xFF8A7A62,
);

const List<StageDef> allStages = [forestStage, graveyardStage, canyonStage];
