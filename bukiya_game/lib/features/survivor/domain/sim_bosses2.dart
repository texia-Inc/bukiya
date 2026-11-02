part of 'run_simulation.dart';

// 人食い花：根を張って動かない。種の連射・足元からのとげ・地中を潜って奇襲
const List<BossAttack> flowerAttacks = [
  BossAttack.seeds,
  BossAttack.roots,
  BossAttack.burrow,
];
const double flowerIdleTime = 2.4;
const double flowerEnragedIdleTime = 1.6;
const double flowerSeedWindupTime = 0.7;
const double flowerSeedRepeatTime = 0.3;
const double flowerSeedSpeed = 210;
const double flowerSeedDamage = 9;
const double flowerRootWindupTime = 0.5;
const double flowerRootDelay = 0.9;
const double flowerRootRadius = 42;
const double flowerRootDamage = 18;
const double flowerBurrowWindupTime = 0.5;
const double flowerBurrowTime = 1.3;
const double flowerEmergeRadius = 80;
const double flowerEmergeDamage = 20;
const double flowerRecoverTime = 0.7;

// サソリの王：突進・前方への毒針・毒の水たまり
const List<BossAttack> scorpionAttacks = [
  BossAttack.charge,
  BossAttack.sting,
  BossAttack.poison,
];
const double scorpionWalkTime = 2.8;
const double scorpionEnragedWalkTime = 2.0;
const double scorpionChargeSpeed = 470;
const double scorpionChargeTime = 0.55;
const double scorpionStingWindupTime = 0.9;
const double scorpionStingRange = 150;

/// 毒針が届く扇形の半分の角度
const double scorpionStingHalfAngle = 0.6;
const double scorpionStingDamage = 22;
const double scorpionPoisonWindupTime = 0.6;
const double scorpionPoisonDelay = 0.7;
const double scorpionPoisonRadius = 46;
const double scorpionPoisonLife = 4.5;
const double scorpionPoisonDamage = 7;
const double scorpionRecoverTime = 0.6;

// 魔王：闇の玉の輪・闇の柱・瞬間移動。怒ると黒騎士も呼ぶ
const List<BossAttack> demonAttacks = [
  BossAttack.orbs,
  BossAttack.pillars,
  BossAttack.teleport,
];
const List<BossAttack> demonEnragedAttacks = [
  BossAttack.orbs,
  BossAttack.pillars,
  BossAttack.teleport,
  BossAttack.knights,
];
const double demonWalkTime = 2.8;
const double demonEnragedWalkTime = 1.8;
const double demonOrbWindupTime = 0.8;
const double demonOrbRepeatTime = 0.45;
const double demonOrbSpeed = 140;
const double demonOrbDamage = 10;
const double demonPillarWindupTime = 0.7;
const double demonPillarRadius = 30;
const double demonPillarDamage = 20;
const double demonTeleportWindupTime = 0.6;
const double demonKnightWindupTime = 0.8;
const double demonRecoverTime = 0.5;

// 中ボス：雑魚を大きく強くしたもの。予告してから突進してくる
const double eliteBodyScale = 2.2;
const double eliteBaseHp = 320;
const double eliteDamageScale = 1.8;
const double eliteWalkTime = 3.5;
const double eliteChargeSpeed = 360;
const double eliteChargeTime = 0.45;
const double eliteRecoverTime = 0.5;

/// 中ボスの名前
String eliteName(EnemyKind kind) => switch (kind) {
      EnemyKind.slime => '大スライム',
      EnemyKind.bat => '大コウモリ',
      EnemyKind.goblin => 'ゴブリンの親分',
      EnemyKind.skeleton => '骸骨隊長',
      EnemyKind.ghost => '怨霊',
      EnemyKind.imp => '炎の大鬼',
      EnemyKind.wolf => '群れの長',
      EnemyKind.sprout => '大人食い草',
      EnemyKind.scorpion => '毒サソリ',
      EnemyKind.knight => '黒騎士団長',
      _ => '中ボス',
    };

/// 跳躍・潜行にかかる秒数
double bossAirTime(EnemyKind kind) =>
    kind == EnemyKind.flowerQueen ? flowerBurrowTime : kingSlimeAirTime;

/// 着地・飛び出しの衝撃の範囲
double bossLandRadius(EnemyKind kind) =>
    kind == EnemyKind.flowerQueen ? flowerEmergeRadius : kingSlimeSlamRadius;

/// 突進の速さと時間（オーガ・サソリの王・中ボスで違う）
double chargeSpeedOf(Enemy e) => e.elite
    ? eliteChargeSpeed
    : e.kind == EnemyKind.scorpionKing
        ? scorpionChargeSpeed
        : ogreChargeSpeed;

double chargeTimeOf(Enemy e) => e.elite
    ? eliteChargeTime
    : e.kind == EnemyKind.scorpionKing
        ? scorpionChargeTime
        : ogreChargeTime;

/// 突進の予告線の長さ
double chargeLengthOf(Enemy e) => chargeSpeedOf(e) * chargeTimeOf(e) + e.radius;

enum HazardKind { rootSpike, poison, pillar }

/// 地面に出る攻撃。予告（[delay] 秒）のあとに噴き出す。毒は [life] 秒のあいだ残る
class BossHazard {
  final HazardKind kind;
  final double x;
  final double y;
  final double radius;
  final double damage;
  double delay;
  double life;

  /// 噴き出してからの秒数（描画用）
  double age = 0;

  BossHazard(this.kind, this.x, this.y, this.radius, this.damage, this.delay,
      {this.life = 0.4});

  bool get erupted => delay <= 0;
}

extension _Bosses2 on RunSimulation {
  // ---- 地面に出る攻撃 ----

  void _updateHazards(double dt) {
    if (hazards.isEmpty) return;
    for (final h in hazards) {
      if (!h.erupted) {
        h.delay -= dt;
        if (!h.erupted) continue;
        if (h.kind != HazardKind.poison) {
          _emit(RunEvent(RunEventType.hazardBurst, h.x, h.y));
          _burst(h.x, h.y,
              h.kind == HazardKind.pillar ? 0xFF9A6BD9 : 0xFF8A7A62, 6);
          if (_playerIn(h.x, h.y, h.radius)) _hurtPlayer(h.damage);
        }
        continue;
      }
      h.age += dt;
      h.life -= dt;
      // 毒の水たまりは、上にいる間ずっと痛い（無敵時間ごとに）
      if (h.kind == HazardKind.poison && _playerIn(h.x, h.y, h.radius)) {
        _hurtPlayer(h.damage);
      }
    }
    hazards.removeWhere((h) => h.erupted && h.life <= 0);
  }

  bool _playerIn(double x, double y, double r) {
    final dx = px - x, dy = py - y;
    return dx * dx + dy * dy < r * r;
  }

  /// 檻の中に収めた位置
  (double, double) _inArena(double x, double y, double margin) {
    final a = arena;
    if (a == null) return (x, y);
    return (
      x.clamp(a.left + margin, a.right - margin),
      y.clamp(a.top + margin, a.bottom - margin)
    );
  }

  void _startAttack(Enemy e, List<BossAttack> rotation,
      {required int Function(BossAttack a) repeats}) {
    final a = _nextAttack(e, rotation);
    e.repeatsTotal = repeats(a);
    e.repeatsLeft = e.repeatsTotal;
    _aim(e);
    _setState(e, BossState.windup);
  }

  /// 連射の残りがあれば次の溜めへ、なければ隙へ
  void _repeatOrRecover(Enemy e) {
    e.repeatsLeft--;
    if (e.repeatsLeft > 0) {
      _aim(e);
      _setState(e, BossState.windup);
    } else {
      _setState(e, BossState.recover);
    }
  }

  // ---- 人食い花 ----

  void _updateFlowerQueen(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        // 根を張っていて動かない。少し待ってから大技
        if (e.stateTime >=
            (e.enraged ? flowerEnragedIdleTime : flowerIdleTime)) {
          _startAttack(e, flowerAttacks,
              repeats: (a) => a == BossAttack.seeds ? (e.enraged ? 4 : 3) : 1);
        }
      case BossState.windup:
        if (e.stateTime < bossWindupTime(e)) return;
        switch (e.attack) {
          case BossAttack.seeds:
            _flowerSeeds(e);
            _repeatOrRecover(e);
          case BossAttack.roots:
            _flowerRoots(e);
            _setState(e, BossState.recover);
          case BossAttack.burrow:
            // プレイヤーのいる所へ潜って向かう
            e.fromX = e.x;
            e.fromY = e.y;
            final (tx, ty) = _inArena(px, py, e.radius);
            e.toX = tx;
            e.toY = ty;
            _setState(e, BossState.airborne);
          default:
            _setState(e, BossState.walk);
        }
      case BossState.airborne:
        final p = e.airProgress;
        e.x = e.fromX + (e.toX - e.fromX) * p;
        e.y = e.fromY + (e.toY - e.fromY) * p;
        if (e.stateTime >= flowerBurrowTime) {
          e.x = e.toX;
          e.y = e.toY;
          _emit(RunEvent(RunEventType.bossSlam, e.x, e.y));
          _burst(e.x, e.y, 0xFF8A7A62, 14);
          if (_playerIn(e.x, e.y, flowerEmergeRadius)) {
            _hurtPlayer(flowerEmergeDamage);
          }
          if (e.enraged) _summon(e, EnemyKind.sprout, 4);
          _setState(e, BossState.recover);
        }
      case BossState.recover:
        if (e.stateTime >= flowerRecoverTime) _setState(e, BossState.walk);
      case BossState.charge:
        _setState(e, BossState.walk);
    }
  }

  void _flowerSeeds(Enemy e) {
    final n = e.enraged ? 7 : 5;
    final base = atan2(e.dirY, e.dirX);
    for (var i = 0; i < n; i++) {
      final a = base + (i - (n - 1) / 2) * 0.22;
      bossShots.add(BossShot(
          BossShotKind.seed,
          e.x + cos(a) * e.radius,
          e.y + sin(a) * e.radius,
          cos(a) * flowerSeedSpeed,
          sin(a) * flowerSeedSpeed,
          7,
          flowerSeedDamage,
          3));
    }
    _emit(RunEvent(RunEventType.bossSpray, e.x, e.y));
  }

  /// 足元と、その周りに根のとげを予告する（少しずつ時間をずらして噴き出す）
  void _flowerRoots(Enemy e) {
    final n = e.enraged ? 5 : 3;
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * 2 * pi;
      final d = i == 0 ? 0.0 : 50 + rng.nextDouble() * 50;
      final (x, y) = _inArena(px + cos(a) * d, py + sin(a) * d, 10);
      hazards.add(BossHazard(HazardKind.rootSpike, x, y, flowerRootRadius,
          flowerRootDamage, flowerRootDelay + i * 0.25));
    }
  }

  /// 手下を周りに呼ぶ（檻の中に出る）
  void _summon(Enemy e, EnemyKind kind, int n) {
    final hp = enemyStats[kind]!.hp * (1 + time / 150) * stage.hpScale;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n + rng.nextDouble() * 0.5;
      final s = Enemy(kind, e.x + cos(a) * (e.radius + 24),
          e.y + sin(a) * (e.radius + 24), hp);
      s.kbx = cos(a) * 160;
      s.kby = sin(a) * 160;
      _spawnQueue.add(s);
      _burst(s.x, s.y, _burstColor(kind), 3);
    }
    _emit(RunEvent(RunEventType.bossSummon, e.x, e.y));
  }

  // ---- サソリの王 ----

  void _updateScorpionKing(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        if (e.stateTime >=
            (e.enraged ? scorpionEnragedWalkTime : scorpionWalkTime)) {
          _startAttack(e, scorpionAttacks,
              repeats: (a) => e.enraged && a != BossAttack.poison ? 2 : 1);
        }
      case BossState.windup:
        if (e.stateTime < bossWindupTime(e)) return;
        switch (e.attack) {
          case BossAttack.charge:
            _setState(e, BossState.charge);
          case BossAttack.sting:
            _scorpionSting(e);
            _repeatOrRecover(e);
          case BossAttack.poison:
            _scorpionPoison(e);
            _setState(e, BossState.recover);
          default:
            _setState(e, BossState.walk);
        }
      case BossState.charge:
        e.x += e.dirX * scorpionChargeSpeed * dt;
        e.y += e.dirY * scorpionChargeSpeed * dt;
        if (e.stateTime >= scorpionChargeTime) _repeatOrRecover(e);
      case BossState.recover:
        if (e.stateTime >= scorpionRecoverTime) _setState(e, BossState.walk);
      case BossState.airborne:
        _setState(e, BossState.walk);
    }
  }

  /// 予告した向きの扇形に毒針（扇形の中にいると当たる）
  void _scorpionSting(Enemy e) {
    _emit(
        RunEvent(RunEventType.bossSmash, e.x, e.y, amount: scorpionStingRange));
    if (inStingCone(e, px, py)) _hurtPlayer(scorpionStingDamage);
    _burst(e.x + e.dirX * 80, e.y + e.dirY * 80, 0xFFD9963E, 10);
  }

  void _scorpionPoison(Enemy e) {
    final n = e.enraged ? 5 : 3;
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * 2 * pi;
      final d = i == 0 ? 0.0 : 60 + rng.nextDouble() * 60;
      final (x, y) = _inArena(px + cos(a) * d, py + sin(a) * d, 10);
      hazards.add(BossHazard(HazardKind.poison, x, y, scorpionPoisonRadius,
          scorpionPoisonDamage, scorpionPoisonDelay + i * 0.1,
          life: scorpionPoisonLife));
    }
    _emit(RunEvent(RunEventType.bossThrow, e.x, e.y));
  }

  // ---- 魔王 ----

  void _updateDemonLord(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        if (e.stateTime >= (e.enraged ? demonEnragedWalkTime : demonWalkTime)) {
          _startAttack(e, e.enraged ? demonEnragedAttacks : demonAttacks,
              repeats: (a) => a == BossAttack.orbs && e.enraged ? 2 : 1);
        }
      case BossState.windup:
        if (e.stateTime < bossWindupTime(e)) return;
        switch (e.attack) {
          case BossAttack.orbs:
            _demonOrbs(e);
            _repeatOrRecover(e);
          case BossAttack.pillars:
            _demonPillars(e);
            _setState(e, BossState.recover);
          case BossAttack.teleport:
            _demonTeleport(e);
            _setState(e, BossState.recover);
          case BossAttack.knights:
            _summon(e, EnemyKind.knight, 3);
            _setState(e, BossState.recover);
          default:
            _setState(e, BossState.walk);
        }
      case BossState.recover:
        if (e.stateTime >= demonRecoverTime) _setState(e, BossState.walk);
      case BossState.charge:
      case BossState.airborne:
        _setState(e, BossState.walk);
    }
  }

  void _demonOrbs(Enemy e) {
    final n = e.enraged ? 20 : 16;
    final volley = e.repeatsTotal - e.repeatsLeft;
    final offset = volley * pi / n;
    for (var i = 0; i < n; i++) {
      final a = offset + i * 2 * pi / n;
      bossShots.add(BossShot(
          BossShotKind.darkOrb,
          e.x + cos(a) * e.radius,
          e.y + sin(a) * e.radius,
          cos(a) * demonOrbSpeed,
          sin(a) * demonOrbSpeed,
          9,
          demonOrbDamage,
          4));
    }
    _emit(RunEvent(RunEventType.bossSpray, e.x, e.y));
  }

  /// プレイヤーへ向かって、闇の柱が手前から順に噴き上がる（怒ると3列）
  void _demonPillars(Enemy e) {
    final base = atan2(e.dirY, e.dirX);
    final lines = e.enraged ? [-0.5, 0.0, 0.5] : [0.0];
    for (final off in lines) {
      final a = base + off;
      for (var i = 0; i < 7; i++) {
        final d = 50.0 + i * 48;
        final (x, y) = _inArena(e.x + cos(a) * d, e.y + sin(a) * d, 0);
        hazards.add(BossHazard(HazardKind.pillar, x, y, demonPillarRadius,
            demonPillarDamage, 0.5 + i * 0.1));
      }
    }
  }

  /// プレイヤーから少し離れた所へ瞬間移動する
  void _demonTeleport(Enemy e) {
    _burst(e.x, e.y, 0xFF9A6BD9, 10);
    final a = rng.nextDouble() * 2 * pi;
    final (nx, ny) = _inArena(px + cos(a) * 150, py + sin(a) * 150, e.radius);
    e.x = nx;
    e.y = ny;
    _burst(e.x, e.y, 0xFF9A6BD9, 10);
    _emit(RunEvent(RunEventType.bossTeleport, e.x, e.y));
  }

  // ---- 中ボス ----

  void _spawnElites() {
    final list = stage.midBosses;
    if (_nextElite >= list.length || time < list[_nextElite].time) return;
    // ボス戦の最中は、檻が開くまで待つ
    if (arena != null) return;
    final kind = list[_nextElite].kind;
    _nextElite++;
    final (x, y) = _spawnPoint();
    final e = Enemy(kind, x, y, eliteBaseHp * (1 + time / 300) * stage.hpScale)
      ..elite = true
      ..bodyScale = eliteBodyScale;
    _spawnQueue.add(e);
    _emit(RunEvent(RunEventType.eliteSpawn, x, y));
  }

  void _updateElites(double dt) {
    for (final e in enemies) {
      if (!e.elite || e.dead) continue;
      e.stateTime += dt;
      e.x += e.kbx * dt;
      e.y += e.kby * dt;
      final decay = pow(0.001, dt).toDouble();
      e.kbx *= decay;
      e.kby *= decay;
      switch (e.bossState) {
        case BossState.walk:
          final dx = px - e.x, dy = py - e.y;
          final d = sqrt(dx * dx + dy * dy);
          if (d > 0.001) {
            final speed = e.stats.speed * 1.15;
            e.x += dx / d * speed * dt;
            e.y += dy / d * speed * dt;
          }
          // 置いていかれたら、近くに出し直す
          if (d > spawnDistance * 1.6) {
            final (nx, ny) = _spawnPoint();
            e.x = nx;
            e.y = ny;
          }
          if (e.stateTime >= eliteWalkTime && d < spawnDistance) {
            e.attack = BossAttack.charge;
            _aim(e);
            _setState(e, BossState.windup);
          }
        case BossState.windup:
          if (e.stateTime >= bossWindupTime(e)) {
            _setState(e, BossState.charge);
          }
        case BossState.charge:
          e.x += e.dirX * eliteChargeSpeed * dt;
          e.y += e.dirY * eliteChargeSpeed * dt;
          if (e.stateTime >= eliteChargeTime) _setState(e, BossState.recover);
        case BossState.recover:
          if (e.stateTime >= eliteRecoverTime) _setState(e, BossState.walk);
        case BossState.airborne:
          _setState(e, BossState.walk);
      }
    }
  }

  void _onEliteDefeated(Enemy e) {
    pickups.add(Pickup.miniChest(e.x, e.y));
    for (var i = 0; i < 2; i++) {
      pickups.add(Pickup.material(
          e.x + (i * 2 - 1) * 14, e.y + 10, _materialFor(e.kind)));
    }
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      _dropGem(e.x + cos(a) * 24, e.y + sin(a) * 24, 3);
    }
    for (var i = 0; i < 3; i++) {
      _burst(e.x, e.y, _burstColor(e.kind), 8);
    }
    _emit(RunEvent(RunEventType.eliteDefeated, e.x, e.y));
  }
}

/// サソリの王の毒針の扇形に (x, y) が入っているか
bool inStingCone(Enemy e, double x, double y) {
  final dx = x - e.x, dy = y - e.y;
  final d = sqrt(dx * dx + dy * dy);
  if (d > scorpionStingRange + e.radius) return false;
  if (d < e.radius) return true;
  final diff = (atan2(dy, dx) - atan2(e.dirY, e.dirX) + 3 * pi) % (2 * pi) - pi;
  return diff.abs() < scorpionStingHalfAngle;
}
