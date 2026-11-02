import 'dart:math';

import 'run_result.dart';
import 'stage.dart';

/// もらえるもの（お金と素材）
class Reward {
  final int gold;
  final Map<MaterialKind, int> materials;

  const Reward({this.gold = 0, this.materials = const {}});

  bool get isEmpty => gold == 0 && materials.values.every((v) => v == 0);
}

/// 日付ごとに変わるもの（毎日のミッション・ギフト）の区切り。端末の日付で数える
int dayKey(DateTime t) => t.year * 10000 + t.month * 100 + t.day;

// ---------------------------------------------------------------------------
// ミッション

/// ミッションで数えるもの
enum MissionStat { runs, kills, bosses, survive3min, forge, returned }

class MissionDef {
  final String id;
  final String title;
  final MissionStat stat;
  final int goal;
  final Reward reward;

  const MissionDef(this.id, this.title, this.stat, this.goal, this.reward);
}

/// 毎日のミッション（日付が変わると数え直す）
const List<MissionDef> dailyMissions = [
  MissionDef('d_runs', '3回出撃する', MissionStat.runs, 3, Reward(gold: 150)),
  MissionDef('d_kills', '敵を800体倒す', MissionStat.kills, 800,
      Reward(gold: 200, materials: {MaterialKind.ironOre: 3})),
  MissionDef('d_boss', 'ボスを1体倒す', MissionStat.bosses, 1,
      Reward(gold: 250, materials: {MaterialKind.manaStone: 2})),
  MissionDef('d_survive', '3分以上生き残る', MissionStat.survive3min, 1,
      Reward(gold: 200, materials: {MaterialKind.fang: 3})),
  MissionDef('d_return', '帰還ゲートから帰る', MissionStat.returned, 1,
      Reward(gold: 150, materials: {MaterialKind.bone: 2})),
  MissionDef('d_forge', '武器を鍛えるか強化する', MissionStat.forge, 1, Reward(gold: 100)),
];

/// 実績（ずっと数え続ける。段階ごとにもらえる）
const List<MissionDef> achievements = [
  MissionDef(
      'a_kills1', '敵を合計1,000体倒す', MissionStat.kills, 1000, Reward(gold: 300)),
  MissionDef('a_kills2', '敵を合計5,000体倒す', MissionStat.kills, 5000,
      Reward(gold: 800, materials: {MaterialKind.bossCore: 1})),
  MissionDef('a_kills3', '敵を合計20,000体倒す', MissionStat.kills, 20000,
      Reward(gold: 2000, materials: {MaterialKind.bossCore: 2})),
  MissionDef('a_kills4', '敵を合計100,000体倒す', MissionStat.kills, 100000,
      Reward(gold: 6000, materials: {MaterialKind.bossCore: 5})),
  MissionDef('a_boss1', 'はじめてボスを倒す', MissionStat.bosses, 1,
      Reward(gold: 300, materials: {MaterialKind.manaStone: 3})),
  MissionDef('a_boss2', 'ボスを合計10体倒す', MissionStat.bosses, 10,
      Reward(gold: 1000, materials: {MaterialKind.bossCore: 1})),
  MissionDef('a_boss3', 'ボスを合計40体倒す', MissionStat.bosses, 40,
      Reward(gold: 3000, materials: {MaterialKind.bossCore: 3})),
  MissionDef('a_runs1', '合計10回出撃する', MissionStat.runs, 10, Reward(gold: 300)),
  MissionDef('a_runs2', '合計50回出撃する', MissionStat.runs, 50, Reward(gold: 1200)),
  MissionDef('a_forge1', '武器を合計10回鍛えるか強化する', MissionStat.forge, 10,
      Reward(gold: 500, materials: {MaterialKind.ironOre: 5})),
];

// ---------------------------------------------------------------------------
// チャプター宝箱：ステージで決まった時間を生き残るともらえる

class ChapterChest {
  final double seconds;
  final Reward Function(StageDef stage) reward;

  const ChapterChest(this.seconds, this.reward);

  String key(StageDef stage) => '${stage.id}:${seconds.round()}';
}

final List<ChapterChest> chapterChests = [
  ChapterChest(60, (s) => Reward(gold: 80 * s.number)),
  ChapterChest(
      180,
      (s) => Reward(gold: 150 * s.number, materials: {
            MaterialKind.ironOre: 2 + s.number,
            MaterialKind.manaStone: 1 + s.number ~/ 2,
          })),
  ChapterChest(
      300,
      (s) => Reward(gold: 300 * s.number, materials: {
            MaterialKind.bossCore: 1 + s.number ~/ 3,
            MaterialKind.bone: 2 + s.number,
          })),
];

// ---------------------------------------------------------------------------
// パトロール：留守の間も店の見回りで、お金と素材が少しずつ貯まる

/// 貯まるのはこの時間まで
const Duration patrolCap = Duration(hours: 8);

/// 素材は、この分数ごとに1つ見つかる
const int patrolMinutesPerMaterial = 20;

/// 1分あたりのお金。解放したステージが多いほど増える
double patrolGoldPerMinute(int unlockedStages) => 2 + 1.5 * unlockedStages;

/// [minutes] 分の見回りで見つかるもの。同じ時間なら同じ結果（[seed] で決まる）
Reward patrolReward(int minutes, int unlockedStages, int seed) {
  final m = minutes.clamp(0, patrolCap.inMinutes);
  final gold = (patrolGoldPerMinute(unlockedStages) * m).floor();
  final found = <MaterialKind, int>{};
  final rng = Random(seed);
  const common = [
    MaterialKind.ironOre,
    MaterialKind.fang,
    MaterialKind.manaStone,
    MaterialKind.bone,
  ];
  for (var i = 0; i < m ~/ patrolMinutesPerMaterial; i++) {
    final k = common[rng.nextInt(common.length)];
    found[k] = (found[k] ?? 0) + 1;
  }
  return Reward(gold: gold, materials: found);
}

// ---------------------------------------------------------------------------
// 毎日のギフト

Reward dailyGift(int day, int unlockedStages) {
  final rng = Random(day);
  const kinds = [
    MaterialKind.ironOre,
    MaterialKind.fang,
    MaterialKind.manaStone,
    MaterialKind.bone,
  ];
  final a = kinds[rng.nextInt(kinds.length)], b = kinds[rng.nextInt(4)];
  return Reward(
    gold: 100 + 50 * unlockedStages,
    materials: a == b ? {a: 4} : {a: 2, b: 2},
  );
}
