part of 'run_simulation.dart';

/// ボス戦の檻。ボスが出ると現れ、ボスがいなくなるまでプレイヤーは外に出られない
class Arena {
  final double left;
  final double top;
  final double right;
  final double bottom;

  /// 檻ができた時刻（柵がせり上がる演出に使う）
  final double closedAt;

  const Arena(this.left, this.top, this.right, this.bottom, this.closedAt);

  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  bool contains(double x, double y) =>
      x > left && x < right && y > top && y < bottom;
}

const double arenaHalfWidth = 180;
const double arenaHalfHeight = 280;

/// 一方向から群れが流れ込んでいる最中の状態
class _Swarm {
  final EnemyKind kind;
  final double angle;
  final int total;
  int remaining;
  double acc = 0;

  _Swarm(this.kind, this.angle, this.total) : remaining = total;
}

/// 突撃の群れは、この秒数をかけて流れ込む
const double swarmDuration = 4;

/// 大群の警告は、この秒数前に出す
const double waveWarningTime = 2.5;

extension _Field on RunSimulation {
  double? get _corridor => stage.corridorHalfWidth;

  /// 敵が出てくる位置（画面の外）。通路では上か下から
  (double, double) _spawnPoint() {
    final c = _corridor;
    if (c != null) {
      final x = (rng.nextDouble() * 2 - 1) * (c - 20);
      final y = py + (rng.nextBool() ? 1 : -1) * spawnDistance;
      return (x, y);
    }
    final a = rng.nextDouble() * 2 * pi;
    return (px + cos(a) * spawnDistance, py + sin(a) * spawnDistance);
  }

  /// プレイヤーを通路と檻の中に収める
  void _clampPlayer() {
    final c = _corridor;
    if (c != null) {
      px = px.clamp(
          -c + RunSimulation.playerRadius, c - RunSimulation.playerRadius);
    }
    final a = arena;
    if (a != null) {
      const r = RunSimulation.playerRadius;
      px = px.clamp(a.left + r, a.right - r);
      py = py.clamp(a.top + r, a.bottom - r);
    }
  }

  /// 敵を通路に収め、檻の内と外を行き来できないようにする
  void _clampEnemies() {
    final c = _corridor;
    final a = arena;
    for (final e in enemies) {
      if (e.airborne) continue;
      final r = e.stats.radius;
      if (c != null) e.x = e.x.clamp(-c + r, c - r);
      if (a == null) continue;
      if (e.inArena) {
        e.x = e.x.clamp(a.left + r, a.right - r);
        e.y = e.y.clamp(a.top + r, a.bottom - r);
      } else if (e.x > a.left - r &&
          e.x < a.right + r &&
          e.y > a.top - r &&
          e.y < a.bottom + r) {
        // 外の敵が柵に食い込んだら、一番近い辺の外へ押し戻す
        final dl = e.x - (a.left - r), dr = (a.right + r) - e.x;
        final dt = e.y - (a.top - r), db = (a.bottom + r) - e.y;
        final m = [dl, dr, dt, db].reduce(min);
        if (m == dl) {
          e.x = a.left - r;
        } else if (m == dr) {
          e.x = a.right + r;
        } else if (m == dt) {
          e.y = a.top - r;
        } else {
          e.y = a.bottom + r;
        }
      }
    }
  }

  /// ボスが出たときに、プレイヤーを囲む檻を作る
  void _closeArena() {
    if (arena != null) return;
    var cx = px;
    final c = _corridor;
    var hw = arenaHalfWidth;
    if (c != null) {
      // 通路では、檻の幅を通路に合わせる
      hw = min(hw, c);
      cx = 0;
    }
    final a = Arena(
        cx - hw, py - arenaHalfHeight, cx + hw, py + arenaHalfHeight, time);
    arena = a;
    for (final e in enemies) {
      e.inArena = a.contains(e.x, e.y);
      // 一騎打ちにするため、檻の中にいた雑魚は煙とともに消える（経験値は出ない）
      if (e.inArena && !e.isBoss) {
        e.dead = true;
        _burst(e.x, e.y, 0xFFB9BECB, 3);
      }
    }
    _emit(RunEvent(RunEventType.arenaClose, a.centerX, a.centerY));
  }

  /// 檻の中で、ボスが現れる位置（プレイヤーから離れた側の端）
  (double, double) _bossSpawnPoint() {
    final a = arena!;
    final ex = px < a.centerX ? a.right - 50 : a.left + 50;
    final ey = py < a.centerY ? a.bottom - 60 : a.top + 60;
    return (ex, ey);
  }

  void _openArenaIfCleared() {
    if (arena == null) return;
    if (enemies.any((e) => e.isBoss && !e.dead) ||
        _spawnQueue.any((e) => e.isBoss)) {
      return;
    }
    final a = arena!;
    arena = null;
    for (final e in enemies) {
      e.inArena = false;
    }
    _emit(RunEvent(RunEventType.arenaOpen, a.centerX, a.centerY));
  }

  // ---- 大群ウェーブ ----

  void _updateWaves(double dt) {
    final waves = stage.waves;
    if (_nextWave < waves.length) {
      final w = waves[_nextWave];
      if (!_waveWarned && time >= w.time - waveWarningTime) {
        _waveWarned = true;
        // ボス戦の最中は大群を見送る
        if (arena == null) {
          _emit(RunEvent(RunEventType.waveWarning, px, py,
              amount: w.type.index.toDouble()));
        }
      }
      if (time >= w.time) {
        _nextWave++;
        _waveWarned = false;
        if (arena == null) _startWave(w);
      }
    }
    final s = _swarm;
    if (s != null) {
      s.acc += s.total / swarmDuration * dt;
      while (s.acc >= 1 && s.remaining > 0) {
        s.acc -= 1;
        s.remaining--;
        _spawnSwarmMember(s);
      }
      if (s.remaining <= 0) _swarm = null;
    }
  }

  void _startWave(WaveEvent w) {
    _emit(RunEvent(RunEventType.waveStart, px, py,
        amount: w.type.index.toDouble()));
    switch (w.type) {
      case WaveType.ring:
        _spawnRing(w.kind, w.count);
      case WaveType.swarm:
        final c = _corridor;
        final angle = c != null
            ? (rng.nextBool() ? pi / 2 : -pi / 2)
            : rng.nextDouble() * 2 * pi;
        _swarm = _Swarm(w.kind, angle, w.count);
    }
  }

  double get _waveHp => (1 + time / 150) * stage.hpScale;

  /// 取り囲む輪（通路では上下の列）
  void _spawnRing(EnemyKind kind, int count) {
    final hp = enemyStats[kind]!.hp * _waveHp;
    final c = _corridor;
    final r = spawnDistance * 0.75;
    for (var i = 0; i < count; i++) {
      double x, y;
      if (c != null) {
        final top = i.isEven;
        final k = i ~/ 2, n = (count + 1) ~/ 2;
        x = -c + 20 + (2 * c - 40) * (n <= 1 ? 0.5 : k / (n - 1));
        y = py + (top ? -r : r);
      } else {
        final a = i * 2 * pi / count;
        x = px + cos(a) * r;
        y = py + sin(a) * r;
      }
      _spawnQueue.add(Enemy(kind, x, y, hp));
    }
  }

  void _spawnSwarmMember(_Swarm s) {
    final spread = (rng.nextDouble() - 0.5) * 0.5;
    final a = s.angle + spread;
    var x = px + cos(a) * spawnDistance;
    final y = py + sin(a) * spawnDistance;
    final c = _corridor;
    if (c != null) x = (rng.nextDouble() * 2 - 1) * (c - 20);
    _spawnQueue.add(Enemy(s.kind, x, y, enemyStats[s.kind]!.hp * _waveHp));
  }
}
