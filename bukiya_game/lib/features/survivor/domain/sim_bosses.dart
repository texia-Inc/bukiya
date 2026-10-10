part of 'run_simulation.dart';

/// ボスの行動の段階
enum BossState {
  /// プレイヤーへ歩いて近づく
  walk,

  /// 突進や跳躍の前の溜め（予告を出す）
  windup,

  /// オーガの突進
  charge,

  /// キングスライムの跳躍中
  airborne,

  /// 大技のあとの隙
  recover,
}

// オーガ：歩く → 溜め（突進の向きを予告）→ 突進 → 隙
const double ogreWalkTime = 3.0;
const double ogreWindupTime = 0.8;
const double ogreChargeTime = 0.6;
const double ogreChargeSpeed = 430;
const double ogreRecoverTime = 0.6;

// キングスライム：歩く → 跳躍（着地点に影を予告）→ 着地の衝撃波 → 隙。体力が半分で分裂
const double kingSlimeWalkTime = 4.5;
const double kingSlimeAirTime = 1.1;
const double kingSlimeSlamRadius = 85;
const double kingSlimeSlamDamage = 22;
const double kingSlimeRecoverTime = 0.6;

extension _Bosses on RunSimulation {
  void _spawnBosses() {
    final bosses = stage.bosses;
    if (_nextBoss >= bosses.length || time < bosses[_nextBoss].time) return;
    final kind = bosses[_nextBoss].kind;
    _nextBoss++;
    final a = rng.nextDouble() * 2 * pi;
    final d = spawnDistance * 0.8;
    final e = Enemy(kind, px + cos(a) * d, py + sin(a) * d,
        enemyStats[kind]!.hp * stage.bossHpScale);
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
    e.x += dx / d * e.stats.speed * dt;
    e.y += dy / d * e.stats.speed * dt;
  }

  void _setState(Enemy e, BossState s) {
    e.bossState = s;
    e.stateTime = 0;
  }

  void _updateOgre(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        if (e.stateTime >= ogreWalkTime) {
          // 突進の向きを決めて溜める（描画側がこの向きに予告線を出す）
          final dx = px - e.x, dy = py - e.y;
          final d = max(1.0, sqrt(dx * dx + dy * dy));
          e.dirX = dx / d;
          e.dirY = dy / d;
          _setState(e, BossState.windup);
        }
      case BossState.windup:
        if (e.stateTime >= ogreWindupTime) _setState(e, BossState.charge);
      case BossState.charge:
        e.x += e.dirX * ogreChargeSpeed * dt;
        e.y += e.dirY * ogreChargeSpeed * dt;
        if (e.stateTime >= ogreChargeTime) _setState(e, BossState.recover);
      case BossState.recover:
        if (e.stateTime >= ogreRecoverTime) _setState(e, BossState.walk);
      case BossState.airborne:
        _setState(e, BossState.walk);
    }
  }

  void _updateKingSlime(Enemy e, double dt) {
    switch (e.bossState) {
      case BossState.walk:
        _walkToward(e, dt);
        if (e.stateTime >= kingSlimeWalkTime) {
          // プレイヤーのいる場所へ跳ぶ（着地点は跳んだ瞬間に決まる）
          e.fromX = e.x;
          e.fromY = e.y;
          e.toX = px;
          e.toY = py;
          _setState(e, BossState.airborne);
        }
      case BossState.airborne:
        final p = e.airProgress;
        e.x = e.fromX + (e.toX - e.fromX) * p;
        e.y = e.fromY + (e.toY - e.fromY) * p;
        if (e.stateTime >= kingSlimeAirTime) {
          e.x = e.toX;
          e.y = e.toY;
          _setState(e, BossState.recover);
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
      case BossState.recover:
        if (e.stateTime >= kingSlimeRecoverTime) _setState(e, BossState.walk);
      case BossState.windup:
      case BossState.charge:
        _setState(e, BossState.walk);
    }
  }

  void _onBossDamaged(Enemy e) {
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
