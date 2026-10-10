import 'dart:math';

import 'loadout.dart';
import 'run_result.dart';
import 'skills.dart';

/// ラン1回分のゲームルール。描画や入力から切り離してテストできるようにしている。
enum RunPhase { playing, levelUp, ended }

enum EnemyKind { slime, bat, goblin }

class EnemyStats {
  final double hp;
  final double speed;
  final double damage;
  final double radius;
  final int xp;
  final double materialChance;

  const EnemyStats({
    required this.hp,
    required this.speed,
    required this.damage,
    required this.radius,
    required this.xp,
    required this.materialChance,
  });
}

const Map<EnemyKind, EnemyStats> enemyStats = {
  EnemyKind.slime: EnemyStats(
      hp: 12, speed: 42, damage: 5, radius: 11, xp: 1, materialChance: 0.05),
  EnemyKind.bat: EnemyStats(
      hp: 7, speed: 78, damage: 4, radius: 8, xp: 1, materialChance: 0.04),
  EnemyKind.goblin: EnemyStats(
      hp: 45, speed: 52, damage: 10, radius: 15, xp: 4, materialChance: 0.15),
};

class Enemy {
  final EnemyKind kind;
  double x;
  double y;
  double hp;
  final double maxHp;
  double hitFlash = 0;
  double kbx = 0;
  double kby = 0;
  bool dead = false;

  Enemy(this.kind, this.x, this.y, this.hp) : maxHp = hp;

  EnemyStats get stats => enemyStats[kind]!;
}

class Arrow {
  double x;
  double y;
  final double vx;
  final double vy;
  double life;
  final double damage;
  int pierceLeft;
  final Set<Enemy> hit = {};

  Arrow(this.x, this.y, this.vx, this.vy, this.life, this.damage,
      this.pierceLeft);
}

class Pickup {
  double x;
  double y;

  /// null なら経験値の宝石
  final MaterialKind? material;
  int xp;
  bool magnetized = false;
  bool collected = false;

  Pickup.gem(this.x, this.y, this.xp) : material = null;
  Pickup.material(this.x, this.y, MaterialKind this.material) : xp = 0;
}

class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  double life;
  final double maxLife;
  final int color;

  Particle(this.x, this.y, this.vx, this.vy, this.life, this.color)
      : maxLife = life;
}

class SwordSwing {
  final double startAngle;
  final double duration;
  final double radius;
  final double damage;
  double t = 0;
  final Set<Enemy> hit = {};

  SwordSwing(this.startAngle, this.duration, this.radius, this.damage);

  double get progress => (t / duration).clamp(0.0, 1.0);
  double get bladeAngle => startAngle + progress * 2 * pi;
}

class ReturnGate {
  final double x;
  final double y;

  /// null なら最後まで開いている
  final double? closesAt;

  const ReturnGate(this.x, this.y, this.closesAt);
}

/// 演出（ダメージ数字・画面揺れ・効果音）のためにシミュレーションが出す出来事
enum RunEventType {
  hit,
  kill,
  swordSwing,
  bowShot,
  playerHurt,
  gem,
  material,
  levelUp,
  evolve,
  gateOpen,
  returned,
  died,
}

class RunEvent {
  final RunEventType type;
  final double x;
  final double y;

  /// hit ならダメージ量、playerHurt なら受けたダメージ
  final double amount;

  /// hit / kill のとき、どの武器によるものか
  final CarriedWeaponType? weapon;

  const RunEvent(this.type, this.x, this.y, {this.amount = 0, this.weapon});
}

class RunConfig {
  final double runLength;
  final List<double> gateTimes;
  final double gateDuration;
  final int maxEnemies;

  const RunConfig({
    this.runLength = 300,
    this.gateTimes = const [90, 180, 270],
    this.gateDuration = 25,
    this.maxEnemies = 350,
  });
}

class RunSimulation {
  static const double playerRadius = 12;
  static const double gateRadius = 24;

  /// 拾われていない宝石がこれ以上あると、新しい宝石の経験値を一番古い宝石にまとめる
  static const int maxGems = 150;

  /// 敵の出現距離。画面の外になるよう、描画側が画面サイズから設定する
  double spawnDistance = 360;

  final List<CarriedWeapon> loadout;
  final RunConfig config;
  final Random rng;

  RunPhase phase = RunPhase.playing;
  double time = 0;

  double px = 0;
  double py = 0;
  double facingX = 1;
  double facingY = 0;
  double maxHp = 100;
  double hp = 100;
  double invulnerable = 0;
  double _inputX = 0;
  double _inputY = 0;

  int level = 1;
  int xp = 0;
  int xpToNext = 4;
  final SkillSet skills = SkillSet();
  int _pendingLevelUps = 0;
  List<SkillId> currentOffer = const [];

  final List<Enemy> enemies = [];
  final List<Arrow> arrows = [];
  final List<Pickup> pickups = [];
  final List<Particle> particles = [];
  SwordSwing? swing;
  ReturnGate? gate;
  bool horde = false;

  /// 描画側が毎フレーム取り出して空にする。取り出されなくても溜まり続けないよう上限を設ける
  final List<RunEvent> events = [];
  static const int _maxEvents = 1000;

  final Map<String, int> killsByWeapon = {};
  final Map<MaterialKind, int> materials = {};
  RunResult? result;

  double _spawnAcc = 0;
  double _swordCd = 0.4;
  double _bowCd = 0.2;
  int _nextGate = 0;

  void Function(List<SkillId> offer)? onLevelUp;
  void Function(RunResult result)? onEnd;

  RunSimulation({
    required this.loadout,
    this.config = const RunConfig(),
    int? seed,
  }) : rng = Random(seed);

  CarriedWeapon? _weapon(CarriedWeaponType type) {
    for (final w in loadout) {
      if (w.type == type) return w;
    }
    return null;
  }

  CarriedWeapon? get sword => _weapon(CarriedWeaponType.sword);
  CarriedWeapon? get bow => _weapon(CarriedWeaponType.bow);
  Set<CarriedWeaponType> get carriedTypes => {for (final w in loadout) w.type};

  int get totalKills => killsByWeapon.values.fold(0, (a, b) => a + b);
  double get timeLeft => max(0, config.runLength - time);
  bool get swordEvolved => skills.level(SkillId.giantSlayer) > 0;

  // ---- 数値（スキル反映後） ----

  double get moveSpeed => 140 * (1 + 0.1 * skills.level(SkillId.moveSpeed));
  double get pickupRadius => 50.0 + 28 * skills.level(SkillId.magnet);

  double get swordRadius =>
      (46 + 14 * skills.level(SkillId.bladeLength)) * (swordEvolved ? 1.6 : 1);
  double get swordInterval =>
      1.2 *
      pow(0.88, skills.level(SkillId.swordSpeed)) *
      (swordEvolved ? 0.6 : 1);
  double get swordDamage =>
      14 *
      (1 + 0.25 * skills.level(SkillId.swordPower)) *
      (sword?.damageMultiplier ?? 1) *
      (swordEvolved ? 1.5 : 1);

  double get bowInterval => 0.9 * pow(0.88, skills.level(SkillId.bowSpeed));
  int get arrowCount => 1 + skills.level(SkillId.arrowCount);
  double get arrowDamage => 14 * (bow?.damageMultiplier ?? 1);

  // ---- 入力 ----

  /// 長さ1以下の移動入力（ジョイスティックやキー入力）
  void setInput(double x, double y) {
    final len = sqrt(x * x + y * y);
    if (len > 1) {
      x /= len;
      y /= len;
    }
    _inputX = x;
    _inputY = y;
  }

  // ---- 進行 ----

  void update(double dt) {
    if (phase != RunPhase.playing) return;
    dt = min(dt, 1 / 20);
    time += dt;

    _movePlayer(dt);
    _updateGate();
    if (phase != RunPhase.playing) return;
    _spawnEnemies(dt);
    _moveEnemies(dt);
    _separateEnemies();
    _contactDamage(dt);
    if (phase != RunPhase.playing) return;
    _updateSword(dt);
    _updateBow(dt);
    _updateArrows(dt);
    _updatePickups(dt);
    _updateParticles(dt);
    enemies.removeWhere((e) => e.dead);

    if (_pendingLevelUps > 0) _openLevelUp();
  }

  void chooseSkill(SkillId id) {
    if (phase != RunPhase.levelUp || !currentOffer.contains(id)) return;
    skills.add(id);
    if (id == SkillId.giantSlayer) _emit(RunEvent(RunEventType.evolve, px, py));
    switch (id) {
      case SkillId.vitality:
        maxHp += 20;
        hp = min(maxHp, hp + maxHp * 0.3);
      case SkillId.potion:
        hp = min(maxHp, hp + maxHp * 0.5);
      default:
        break;
    }
    _pendingLevelUps--;
    if (_pendingLevelUps > 0) {
      _openLevelUp();
    } else {
      currentOffer = const [];
      phase = RunPhase.playing;
    }
  }

  void _emit(RunEvent e) {
    if (events.length >= _maxEvents) events.removeAt(0);
    events.add(e);
  }

  void _openLevelUp() {
    _emit(RunEvent(RunEventType.levelUp, px, py));
    phase = RunPhase.levelUp;
    currentOffer = skills.offer(carriedTypes, rng);
    onLevelUp?.call(currentOffer);
  }

  void _end({required bool returned}) {
    phase = RunPhase.ended;
    _emit(
        RunEvent(returned ? RunEventType.returned : RunEventType.died, px, py));
    result = RunResult.build(
      returned: returned,
      survivedSeconds: time,
      level: level,
      materialsFound: materials,
      loadout: loadout,
      killsByWeapon: killsByWeapon,
    );
    onEnd?.call(result!);
  }

  void _movePlayer(double dt) {
    if (_inputX != 0 || _inputY != 0) {
      px += _inputX * moveSpeed * dt;
      py += _inputY * moveSpeed * dt;
      final len = sqrt(_inputX * _inputX + _inputY * _inputY);
      facingX = _inputX / len;
      facingY = _inputY / len;
    }
    if (invulnerable > 0) invulnerable -= dt;
  }

  void _updateGate() {
    if (_nextGate < config.gateTimes.length &&
        time >= config.gateTimes[_nextGate]) {
      _nextGate++;
      _openGateNear(closesAt: time + config.gateDuration);
    }
    if (!horde && time >= config.runLength) {
      // 時間切れ後は大群が押し寄せる。最後のゲートは閉じない
      horde = true;
      _openGateNear(closesAt: null);
    }
    final g = gate;
    if (g == null) return;
    if (g.closesAt != null && time > g.closesAt!) {
      gate = null;
      return;
    }
    final dx = g.x - px, dy = g.y - py;
    if (dx * dx + dy * dy < gateRadius * gateRadius) {
      _end(returned: true);
    }
  }

  void _openGateNear({required double? closesAt}) {
    final a = rng.nextDouble() * 2 * pi;
    gate = ReturnGate(px + cos(a) * 170, py + sin(a) * 170, closesAt);
    _emit(RunEvent(RunEventType.gateOpen, gate!.x, gate!.y));
  }

  void _spawnEnemies(double dt) {
    final rate = (1.4 + time / 40) * (horde ? 2.5 : 1);
    _spawnAcc += rate * dt;
    while (_spawnAcc >= 1) {
      _spawnAcc -= 1;
      if (enemies.length >= config.maxEnemies) continue;
      final a = rng.nextDouble() * 2 * pi;
      final kind = _pickEnemyKind();
      final hpScale = 1 + time / 150;
      enemies.add(Enemy(
        kind,
        px + cos(a) * spawnDistance,
        py + sin(a) * spawnDistance,
        enemyStats[kind]!.hp * hpScale,
      ));
    }
  }

  EnemyKind _pickEnemyKind() {
    final r = rng.nextDouble();
    if (time >= 100 && r < 0.2) return EnemyKind.goblin;
    if (time >= 45 && r < 0.5) return EnemyKind.bat;
    return EnemyKind.slime;
  }

  void _moveEnemies(double dt) {
    for (final e in enemies) {
      final dx = px - e.x, dy = py - e.y;
      final d = sqrt(dx * dx + dy * dy);
      if (d > 0.001) {
        e.x += dx / d * e.stats.speed * dt;
        e.y += dy / d * e.stats.speed * dt;
      }
      e.x += e.kbx * dt;
      e.y += e.kby * dt;
      final decay = pow(0.001, dt).toDouble();
      e.kbx *= decay;
      e.kby *= decay;
      if (e.hitFlash > 0) e.hitFlash -= dt;
      // 遠く離れた敵はプレイヤーの近くに出し直す
      if (d > spawnDistance * 1.6) {
        final a = rng.nextDouble() * 2 * pi;
        e.x = px + cos(a) * spawnDistance;
        e.y = py + sin(a) * spawnDistance;
      }
    }
  }

  /// 敵同士が1点に重ならないよう、格子で近傍だけを押し分ける
  void _separateEnemies() {
    const cell = 32.0;
    final grid = <int, List<Enemy>>{};
    int key(int cx, int cy) => cx * 73856093 ^ cy * 19349663;
    for (final e in enemies) {
      final k = key((e.x / cell).floor(), (e.y / cell).floor());
      (grid[k] ??= []).add(e);
    }
    for (final e in enemies) {
      final cx = (e.x / cell).floor(), cy = (e.y / cell).floor();
      for (var ox = -1; ox <= 1; ox++) {
        for (var oy = -1; oy <= 1; oy++) {
          final list = grid[key(cx + ox, cy + oy)];
          if (list == null) continue;
          for (final o in list) {
            if (identical(o, e)) continue;
            final dx = e.x - o.x, dy = e.y - o.y;
            final minD = e.stats.radius + o.stats.radius;
            final d2 = dx * dx + dy * dy;
            if (d2 >= minD * minD || d2 < 0.0001) continue;
            final d = sqrt(d2);
            final push = (minD - d) * 0.25;
            e.x += dx / d * push;
            e.y += dy / d * push;
          }
        }
      }
    }
  }

  void _contactDamage(double dt) {
    if (invulnerable > 0) return;
    for (final e in enemies) {
      final r = e.stats.radius + playerRadius;
      final dx = e.x - px, dy = e.y - py;
      if (dx * dx + dy * dy < r * r) {
        hp -= e.stats.damage;
        invulnerable = 0.6;
        _emit(
            RunEvent(RunEventType.playerHurt, px, py, amount: e.stats.damage));
        if (hp <= 0) {
          hp = 0;
          _end(returned: false);
        }
        return;
      }
    }
  }

  void _updateSword(double dt) {
    final w = sword;
    if (w == null) return;
    final s = swing;
    if (s != null) {
      s.t += dt;
      final swept = s.progress * 2 * pi;
      for (final e in enemies) {
        if (e.dead || s.hit.contains(e)) continue;
        final dx = e.x - px, dy = e.y - py;
        final reach = s.radius + e.stats.radius;
        if (dx * dx + dy * dy > reach * reach) continue;
        var rel = (atan2(dy, dx) - s.startAngle) % (2 * pi);
        if (rel < 0) rel += 2 * pi;
        if (rel <= swept) {
          s.hit.add(e);
          _damage(e, s.damage, w, knockFromX: px, knockFromY: py);
        }
      }
      if (s.t >= s.duration) swing = null;
    }
    _swordCd -= dt;
    if (_swordCd <= 0 && swing == null) {
      _swordCd = swordInterval;
      swing =
          SwordSwing(atan2(facingY, facingX), 0.28, swordRadius, swordDamage);
      _emit(RunEvent(RunEventType.swordSwing, px, py));
    }
  }

  void _updateBow(double dt) {
    final w = bow;
    if (w == null) return;
    _bowCd -= dt;
    if (_bowCd > 0) return;
    const range = 300.0;
    final targets = enemies.where((e) {
      final dx = e.x - px, dy = e.y - py;
      return dx * dx + dy * dy < range * range;
    }).toList()
      ..sort((a, b) {
        final da = (a.x - px) * (a.x - px) + (a.y - py) * (a.y - py);
        final db = (b.x - px) * (b.x - px) + (b.y - py) * (b.y - py);
        return da.compareTo(db);
      });
    if (targets.isEmpty) return;
    _bowCd = bowInterval;
    _emit(RunEvent(RunEventType.bowShot, px, py));
    const speed = 380.0;
    for (var i = 0; i < arrowCount; i++) {
      final t = targets[i % targets.length];
      var a = atan2(t.y - py, t.x - px);
      if (i >= targets.length) a += (i.isOdd ? 1 : -1) * 0.15 * (i ~/ 2 + 1);
      arrows.add(Arrow(px, py, cos(a) * speed, sin(a) * speed, 1.0, arrowDamage,
          skills.level(SkillId.arrowPierce)));
    }
  }

  void _updateArrows(double dt) {
    final w = bow;
    for (final a in arrows) {
      a.x += a.vx * dt;
      a.y += a.vy * dt;
      a.life -= dt;
      for (final e in enemies) {
        if (e.dead || a.hit.contains(e)) continue;
        final r = e.stats.radius + 4;
        final dx = e.x - a.x, dy = e.y - a.y;
        if (dx * dx + dy * dy > r * r) continue;
        a.hit.add(e);
        _damage(e, a.damage, w!,
            knockFromX: a.x - a.vx, knockFromY: a.y - a.vy);
        a.pierceLeft--;
        if (a.pierceLeft < 0) {
          a.life = 0;
          break;
        }
      }
    }
    arrows.removeWhere((a) => a.life <= 0);
  }

  void _damage(Enemy e, double amount, CarriedWeapon weapon,
      {required double knockFromX, required double knockFromY}) {
    e.hp -= amount;
    _emit(RunEvent(RunEventType.hit, e.x, e.y,
        amount: amount, weapon: weapon.type));
    e.hitFlash = 0.12;
    final dx = e.x - knockFromX, dy = e.y - knockFromY;
    final d = sqrt(dx * dx + dy * dy);
    if (d > 0.001) {
      e.kbx = dx / d * 160;
      e.kby = dy / d * 160;
    }
    if (e.hp > 0) return;
    e.dead = true;
    _emit(RunEvent(RunEventType.kill, e.x, e.y, weapon: weapon.type));
    killsByWeapon[weapon.id] = (killsByWeapon[weapon.id] ?? 0) + 1;
    _dropGem(e.x, e.y, e.stats.xp);
    if (rng.nextDouble() < e.stats.materialChance) {
      pickups.add(Pickup.material(e.x + 6, e.y - 6, _materialFor(e.kind)));
    }
    _burst(e);
  }

  /// 宝石が増えすぎると描画が重くなるので、上限を超えた分は古い宝石に経験値をまとめる
  void _dropGem(double x, double y, int value) {
    Pickup? oldest;
    var gems = 0;
    for (final p in pickups) {
      if (p.material != null || p.magnetized) continue;
      oldest ??= p;
      gems++;
    }
    if (gems >= maxGems && oldest != null) {
      oldest.xp += value;
    } else {
      pickups.add(Pickup.gem(x, y, value));
    }
  }

  MaterialKind _materialFor(EnemyKind kind) => switch (kind) {
        EnemyKind.slime => MaterialKind.ironOre,
        EnemyKind.bat => MaterialKind.fang,
        EnemyKind.goblin =>
          rng.nextDouble() < 0.3 ? MaterialKind.manaStone : MaterialKind.fang,
      };

  void _burst(Enemy e) {
    if (particles.length > 300) return;
    final color = switch (e.kind) {
      EnemyKind.slime => 0xFF7BD389,
      EnemyKind.bat => 0xFFB38BE8,
      EnemyKind.goblin => 0xFFE0A458,
    };
    for (var i = 0; i < 5; i++) {
      final a = rng.nextDouble() * 2 * pi;
      final s = 40 + rng.nextDouble() * 80;
      particles.add(Particle(e.x, e.y, cos(a) * s, sin(a) * s,
          0.3 + rng.nextDouble() * 0.2, color));
    }
  }

  void _updatePickups(double dt) {
    final r = pickupRadius;
    for (final p in pickups) {
      final dx = px - p.x, dy = py - p.y;
      final d2 = dx * dx + dy * dy;
      if (!p.magnetized && d2 < r * r) p.magnetized = true;
      if (!p.magnetized) continue;
      final d = sqrt(d2);
      if (d < playerRadius + 4) {
        p.collected = true;
        _collect(p);
        continue;
      }
      final step = min(d, 320 * dt);
      p.x += dx / d * step;
      p.y += dy / d * step;
    }
    pickups.removeWhere((p) => p.collected);
  }

  void _collect(Pickup p) {
    final m = p.material;
    if (m != null) {
      materials[m] = (materials[m] ?? 0) + 1;
      _emit(RunEvent(RunEventType.material, p.x, p.y));
      return;
    }
    _emit(RunEvent(RunEventType.gem, p.x, p.y));
    xp += p.xp;
    while (xp >= xpToNext) {
      xp -= xpToNext;
      level++;
      xpToNext = 4 + (level - 1) * 2;
      _pendingLevelUps++;
    }
  }

  void _updateParticles(double dt) {
    for (final p in particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.life -= dt;
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  /// テスト用：敵をその武器で倒す
  void debugKill(Enemy e, CarriedWeapon weapon) =>
      _damage(e, e.hp + 1, weapon, knockFromX: e.x, knockFromY: e.y);

  /// テスト用：敵を直接置く
  Enemy debugSpawn(EnemyKind kind, double x, double y, {double? hp}) {
    final e = Enemy(kind, x, y, hp ?? enemyStats[kind]!.hp);
    enemies.add(e);
    return e;
  }
}
