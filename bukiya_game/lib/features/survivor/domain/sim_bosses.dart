part of 'run_simulation.dart';

/// ボスの行動の段階
enum BossState {
  /// プレイヤーへ歩いて近づく
  walk,

  /// 大技の前の溜め（予告を出す）
  windup,

  /// オーガの突進
  charge,

  /// キングスライムの跳躍中
  airborne,

  /// 大技のあとの隙
  recover,
}

/// ボスの大技。歩くたびに順番に繰り出す
enum BossAttack {
  /// オーガ：予告した向きへ突進（怒ると2連続）
  charge,

  /// オーガ：こん棒で地面を叩き、周りに衝撃波
  smash,

  /// オーガ：岩を扇状に投げる
  rocks,

  /// キングスライム：プレイヤーの場所へ跳んで押しつぶす（怒ると2連続）
  jump,

  /// キングスライム：周りにスライム弾を撒く（怒ると向きをずらして3連射）
  spray,

  /// キングスライム：小さいスライムを呼ぶ
  summon,
}

const List<BossAttack> ogreAttacks = [
  BossAttack.charge,
  BossAttack.smash,
  BossAttack.rocks,
];
const List<BossAttack> kingSlimeAttacks = [
  BossAttack.jump,
  BossAttack.spray,
  BossAttack.summon,
];

// オーガ
const double ogreWalkTime = 3.0;
const double ogreEnragedWalkTime = 2.0;
const double ogreWindupTime = 0.8;
const double ogreChargeTime = 0.6;
const double ogreChargeSpeed = 430;
const double ogreRecoverTime = 0.6;
const double ogreSmashWindupTime = 1.0;
const double ogreSmashRadius = 110;
const double ogreEnragedSmashRadius = 135;
const double ogreSmashDamage = 20;
const double ogreRockWindupTime = 0.7;
const double ogreRockSpeed = 250;
const double ogreRockDamage = 12;

// キングスライム（体力が半分で分裂）
const double kingSlimeWalkTime = 4.5;
const double kingSlimeEnragedWalkTime = 3.2;
const double kingSlimeAirTime = 1.1;
const double kingSlimeSlamRadius = 85;
const double kingSlimeSlamDamage = 22;
const double kingSlimeRecoverTime = 0.6;
const double kingSlimeSprayWindupTime = 0.7;
const double kingSlimeSprayRepeatTime = 0.35;
const double kingSlimeSpraySpeed = 150;
const double kingSlimeSprayDamage = 9;
const double kingSlimeSummonWindupTime = 0.9;

/// 怒ると溜めが短くなる
const double enragedWindupScale = 0.7;

/// 怒ると歩くのが速くなる
const double enragedSpeedScale = 1.3;

enum BossShotKind { rock, slime }

/// ボスが放つ弾（岩・スライム弾）。当たるとダメージ
class BossShot {
  final BossShotKind kind;
  double x;
  double y;
  final double vx;
  final double vy;
  final double radius;
  final double damage;
  double life;

  BossShot(this.kind, this.x, this.y, this.vx, this.vy, this.radius,
      this.damage, this.life);
}

/// 大技の溜めにかかる秒数（描画側の予告にも使う）
double bossWindupTime(Enemy e) {
  final base = switch (e.attack) {
    BossAttack.charge => ogreWindupTime,
    BossAttack.smash => ogreSmashWindupTime,
    BossAttack.rocks => ogreRockWindupTime,
    BossAttack.jump => 0.0,
    BossAttack.spray => e.repeatsLeft < e.repeatsTotal
        ? kingSlimeSprayRepeatTime
        : kingSlimeSprayWindupTime,
    BossAttack.summon => kingSlimeSummonWindupTime,
  };
  return e.enraged ? base * enragedWindupScale : base;
}

/// 溜めの進み具合（0〜1）
double bossWindupProgress(Enemy e) {
  if (e.bossState != BossState.windup) return 0;
  final t = bossWindupTime(e);
  return t <= 0 ? 1 : (e.stateTime / t).clamp(0.0, 1.0);
}

/// オーガの地面叩きの範囲
double ogreSmashRadiusOf(Enemy e) =>
    e.enraged ? ogreEnragedSmashRadius : ogreSmashRadius;

extension _Bosses on RunSimulation {
  void _spawnBosses() {
    final bosses = stage.bosses;
    if (_nextBoss >= bosses.length || time < bosses[_nextBoss].time) return;
    final kind = bosses[_nextBoss].kind;
    _nextBoss++;
    // プレイヤーの周りに檻を作り、その中にボスを出す
    _closeArena();
    final (x, y) = _bossSpawnPoint();
    final e = Enemy(kind, x, y, enemyStats[kind]!.hp * stage.bossHpScale)
      ..inArena = true;
    enemies.add(e);
    _emit(RunEvent(RunEventType.bossSpawn, e.x, e.y));
  }

  void _updateBosses(double dt) {
    for (final e in enemies) {
      if (!e.isBoss || e.dead) continue;
      e.stateTime += dt;
      switch (e.kind) {
        case EnemyKind.ogre:
          _updateOgre(e, dt);
        case EnemyKind.kingSlime:
          _updateKingSlime(e, dt);
        default:
          break;
      }
    }
  }

  void _walkToward(Enemy e, double dt) {
    final dx = px - e.x, dy = py - e.y;
    final d = sqrt(dx * dx + dy * dy);
    if (d < 0.001) return;
    final speed = e.stats.speed * (e.enraged ? enragedSpeedScale : 1);
    e.x += dx / d * speed * dt;
    e.y += dy / d * speed * dt;
  }

  void _setState(Enemy e, BossState s) {
    e.bossState = s;
    e.stateTime = 0;
  }

  /// プレイヤーへの向きを覚える（突進・投石の向き）
  void _aim(Enemy e) {
    final dx = px - e.x, dy = py - e.y;
    final d = max(1.0, sqrt(dx * dx + dy * dy));
    e.dirX = dx / d;
    e.dirY = dy / d;
  }

  /// 次の大技を順番に選ぶ
  BossAttack _nextAttack(Enemy e, List<BossAttack> rotation) {
    final a = rotation[e.attackCount % rotation.length];
    e.attackCount++;
    e.attack = a;
    return a;
  }

  void _updateOgre(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        if (e.stateTime >= (e.enraged ? ogreEnragedWalkTime : ogreWalkTime)) {
          final a = _nextAttack(e, ogreAttacks);
          e.repeatsTotal = a == BossAttack.charge && e.enraged ? 2 : 1;
          e.repeatsLeft = e.repeatsTotal;
          // 向きを決めて溜める（描画側がこの向きに予告を出す）
          _aim(e);
          _setState(e, BossState.windup);
        }
      case BossState.windup:
        if (e.stateTime < bossWindupTime(e)) return;
        switch (e.attack) {
          case BossAttack.charge:
            _setState(e, BossState.charge);
          case BossAttack.smash:
            _ogreSmash(e);
            _setState(e, BossState.recover);
          case BossAttack.rocks:
            _ogreThrow(e);
            _setState(e, BossState.recover);
          default:
            _setState(e, BossState.walk);
        }
      case BossState.charge:
        e.x += e.dirX * ogreChargeSpeed * dt;
        e.y += e.dirY * ogreChargeSpeed * dt;
        if (e.stateTime >= ogreChargeTime) {
          e.repeatsLeft--;
          if (e.repeatsLeft > 0) {
            // 怒っていると、向き直ってもう一度突進する
            _aim(e);
            _setState(e, BossState.windup);
          } else {
            _setState(e, BossState.recover);
          }
        }
      case BossState.recover:
        if (e.stateTime >= ogreRecoverTime) _setState(e, BossState.walk);
      case BossState.airborne:
        _setState(e, BossState.walk);
    }
  }

  void _ogreSmash(Enemy e) {
    final r = ogreSmashRadiusOf(e);
    _emit(RunEvent(RunEventType.bossSmash, e.x, e.y, amount: r));
    final dx = px - e.x, dy = py - e.y;
    if (dx * dx + dy * dy < r * r) _hurtPlayer(ogreSmashDamage);
    _burst(e.x, e.y, 0xFF8A7A62, 14);
  }

  /// 岩を扇状に投げる（怒ると数が増える）
  void _ogreThrow(Enemy e) {
    final n = e.enraged ? 5 : 3;
    const spread = 0.32;
    final base = atan2(e.dirY, e.dirX);
    for (var i = 0; i < n; i++) {
      final a = base + (i - (n - 1) / 2) * spread;
      bossShots.add(BossShot(
          BossShotKind.rock,
          e.x + cos(a) * e.stats.radius,
          e.y + sin(a) * e.stats.radius,
          cos(a) * ogreRockSpeed,
          sin(a) * ogreRockSpeed,
          13,
          ogreRockDamage,
          3));
    }
    _emit(RunEvent(RunEventType.bossThrow, e.x, e.y));
  }

  void _updateKingSlime(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        final walk = e.enraged ? kingSlimeEnragedWalkTime : kingSlimeWalkTime;
        if (e.stateTime >= walk) {
          final a = _nextAttack(e, kingSlimeAttacks);
          e.repeatsTotal = !e.enraged
              ? 1
              : switch (a) {
                  BossAttack.jump => 2,
                  BossAttack.spray => 3,
                  _ => 1,
                };
          e.repeatsLeft = e.repeatsTotal;
          if (a == BossAttack.jump) {
            _kingSlimeJump(e);
          } else {
            _setState(e, BossState.windup);
          }
        }
      case BossState.windup:
        if (e.stateTime < bossWindupTime(e)) return;
        switch (e.attack) {
          case BossAttack.spray:
            _kingSlimeSpray(e);
            e.repeatsLeft--;
            if (e.repeatsLeft > 0) {
              _setState(e, BossState.windup);
            } else {
              _setState(e, BossState.recover);
            }
          case BossAttack.summon:
            _kingSlimeSummon(e);
            _setState(e, BossState.recover);
          default:
            _setState(e, BossState.walk);
        }
      case BossState.airborne:
        final p = e.airProgress;
        e.x = e.fromX + (e.toX - e.fromX) * p;
        e.y = e.fromY + (e.toY - e.fromY) * p;
        if (e.stateTime >= kingSlimeAirTime) {
          e.x = e.toX;
          e.y = e.toY;
          _kingSlimeLand(e);
          e.repeatsLeft--;
          if (e.repeatsLeft > 0) {
            // 怒っていると、着地してすぐもう一度跳ぶ
            _kingSlimeJump(e);
          } else {
            _setState(e, BossState.recover);
          }
        }
      case BossState.recover:
        if (e.stateTime >= kingSlimeRecoverTime) _setState(e, BossState.walk);
      case BossState.charge:
        _setState(e, BossState.walk);
    }
  }

  /// プレイヤーのいる場所へ跳ぶ（着地点は跳んだ瞬間に決まる）
  void _kingSlimeJump(Enemy e) {
    e.fromX = e.x;
    e.fromY = e.y;
    e.toX = px;
    e.toY = py;
    final a = arena;
    if (a != null) {
      final r = e.stats.radius;
      e.toX = e.toX.clamp(a.left + r, a.right - r);
      e.toY = e.toY.clamp(a.top + r, a.bottom - r);
    }
    _setState(e, BossState.airborne);
  }

  void _kingSlimeLand(Enemy e) {
    _emit(RunEvent(RunEventType.bossSlam, e.x, e.y));
    final dx = px - e.x, dy = py - e.y;
    if (dx * dx + dy * dy < kingSlimeSlamRadius * kingSlimeSlamRadius) {
      _hurtPlayer(kingSlimeSlamDamage);
    }
    // 着地の衝撃で周りの雑魚を吹き飛ばす
    for (final o in enemies) {
      if (o.isBoss) continue;
      final ox = o.x - e.x, oy = o.y - e.y;
      final od = sqrt(ox * ox + oy * oy);
      if (od < kingSlimeSlamRadius && od > 0.001) {
        o.kbx = ox / od * 260;
        o.kby = oy / od * 260;
      }
    }
  }

  /// 周りにスライム弾を撒く。連射のたびに向きを半分ずらし、すき間を埋めていく
  void _kingSlimeSpray(Enemy e) {
    final n = e.enraged ? 14 : 10;
    final volley = e.repeatsTotal - e.repeatsLeft;
    final offset = volley * pi / n;
    for (var i = 0; i < n; i++) {
      final a = offset + i * 2 * pi / n;
      bossShots.add(BossShot(
          BossShotKind.slime,
          e.x + cos(a) * e.stats.radius,
          e.y + sin(a) * e.stats.radius,
          cos(a) * kingSlimeSpraySpeed,
          sin(a) * kingSlimeSpraySpeed,
          9,
          kingSlimeSprayDamage,
          3.5));
    }
    _emit(RunEvent(RunEventType.bossSpray, e.x, e.y));
  }

  /// 小さいスライムを呼ぶ（檻の中に出る）
  void _kingSlimeSummon(Enemy e) {
    final n = e.enraged ? 6 : 4;
    final hp =
        enemyStats[EnemyKind.slime]!.hp * (1 + time / 150) * stage.hpScale;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n + rng.nextDouble() * 0.5;
      final s = Enemy(EnemyKind.slime, e.x + cos(a) * (e.stats.radius + 20),
          e.y + sin(a) * (e.stats.radius + 20), hp);
      s.kbx = cos(a) * 160;
      s.kby = sin(a) * 160;
      _spawnQueue.add(s);
      _burst(s.x, s.y, _burstColor(EnemyKind.slime), 3);
    }
    _emit(RunEvent(RunEventType.bossSummon, e.x, e.y));
  }

  void _updateBossShots(double dt) {
    if (bossShots.isEmpty) return;
    final a = arena;
    for (final s in bossShots) {
      s.x += s.vx * dt;
      s.y += s.vy * dt;
      s.life -= dt;
      final dx = s.x - px, dy = s.y - py;
      final r = s.radius + RunSimulation.playerRadius;
      if (dx * dx + dy * dy < r * r) {
        _hurtPlayer(s.damage);
        s.life = 0;
        _burst(
            s.x, s.y, s.kind == BossShotKind.rock ? 0xFF8A7A62 : 0xFF7BD389, 4);
      }
      // 檻の柵に当たると砕ける
      if (a != null &&
          (s.x < a.left || s.x > a.right || s.y < a.top || s.y > a.bottom)) {
        s.life = 0;
        _burst(
            s.x, s.y, s.kind == BossShotKind.rock ? 0xFF8A7A62 : 0xFF7BD389, 3);
      }
    }
    bossShots.removeWhere((s) => s.life <= 0);
  }

  void _onBossDamaged(Enemy e) {
    if (!e.enraged && e.hp < e.maxHp / 2 && e.hp > 0) {
      // 体力が半分を切ると怒る（速く、溜めが短く、大技が強くなる）
      e.enraged = true;
      _emit(RunEvent(RunEventType.bossEnrage, e.x, e.y));
    }
    // キングスライムは体力が半分を切ると、スライムを撒き散らす
    if (e.kind == EnemyKind.kingSlime && !e.split && e.hp < e.maxHp / 2) {
      e.split = true;
      for (var i = 0; i < 8; i++) {
        final a = i * pi / 4;
        final s = Enemy(EnemyKind.slime, e.x + cos(a) * 45, e.y + sin(a) * 45,
            enemyStats[EnemyKind.slime]!.hp * (1 + time / 150) * stage.hpScale);
        s.kbx = cos(a) * 200;
        s.kby = sin(a) * 200;
        _spawnQueue.add(s);
      }
      _burst(e.x, e.y, _burstColor(e.kind), 12);
    }
  }

  void _onBossDefeated(Enemy e) {
    bossesDefeated++;
    // 飛んでいる弾は消える
    bossShots.clear();
    pickups.add(Pickup.chest(e.x, e.y));
    _emit(RunEvent(RunEventType.bossDefeated, e.x, e.y));
    for (var i = 0; i < 4; i++) {
      _burst(e.x, e.y, _burstColor(e.kind), 8);
    }
    // ボスの周りに経験値をばらまく
    for (var i = 0; i < 12; i++) {
      final a = i * pi / 6;
      _dropGem(e.x + cos(a) * 30, e.y + sin(a) * 30, 3);
    }
  }
}
