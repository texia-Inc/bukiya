part of 'run_simulation.dart';

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

/// 槍の一突き。伸びて、戻る
class SpearThrust {
  final double angle;
  final double length;
  final double damage;
  final double delay;
  double t = 0;
  final Set<Enemy> hit = {};

  static const double duration = 0.22;
  static const double width = 12;

  SpearThrust(this.angle, this.length, this.damage, {this.delay = 0});

  /// 今の穂先までの長さ。前半で一気に伸び、後半で戻る
  double get reach {
    final p = ((t - delay) / duration).clamp(0.0, 1.0);
    final out = p < 0.4 ? p / 0.4 : 1 - (p - 0.4) / 0.6 * 0.7;
    return length * out;
  }

  bool get active => t >= delay;
  bool get done => t >= delay + duration;
}

/// 杖の火の玉。敵に当たるか目標に着くと爆発する
class Fireball {
  double x;
  double y;
  final double vx;
  final double vy;
  double life;
  final double damage;
  final double radius;

  Fireball(
      this.x, this.y, this.vx, this.vy, this.life, this.damage, this.radius);
}

/// 爆発の見た目（ダメージは発生した瞬間に与える）
class Blast {
  final double x;
  final double y;
  final double radius;
  double life;
  static const double duration = 0.35;

  Blast(this.x, this.y, this.radius) : life = duration;

  double get progress => 1 - life / duration;
}

extension _Weapons on RunSimulation {
  // ---- 剣 ----

  void _updateSword(double dt) {
    final w = sword;
    if (w == null) return;
    final s = swing;
    if (s != null) {
      s.t += dt;
      final swept = s.progress * 2 * pi;
      for (final e in enemies) {
        if (!_hittable(e) || s.hit.contains(e)) continue;
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

  // ---- 弓 ----

  void _updateBow(double dt) {
    final w = bow;
    if (w == null) return;
    _bowCd -= dt;
    if (_bowCd > 0) return;
    const range = 300.0;
    final targets = _withBossFirst(_nearest(range));
    if (targets.isEmpty) return;
    _bowCd = bowInterval;
    _emit(RunEvent(RunEventType.bowShot, px, py));
    const speed = 380.0;
    final pierce = skills.level(SkillId.arrowPierce) + (bowEvolved ? 2 : 0);
    for (var i = 0; i < arrowCount; i++) {
      final t = targets[i % targets.length];
      var a = atan2(t.y - py, t.x - px);
      if (i >= targets.length) a += (i.isOdd ? 1 : -1) * 0.15 * (i ~/ 2 + 1);
      arrows.add(Arrow(
          px, py, cos(a) * speed, sin(a) * speed, 1.0, arrowDamage, pierce));
    }
    if (bowEvolved) {
      // 嵐の弓：全方向へ矢を放つ
      final base = time * 1.7;
      for (var i = 0; i < 8; i++) {
        final a = base + i * pi / 4;
        arrows.add(Arrow(px, py, cos(a) * speed, sin(a) * speed, 0.8,
            arrowDamage * 0.8, pierce));
      }
    }
  }

  void _updateArrows(double dt) {
    final w = bow;
    for (final a in arrows) {
      a.x += a.vx * dt;
      a.y += a.vy * dt;
      a.life -= dt;
      for (final e in enemies) {
        if (!_hittable(e) || a.hit.contains(e)) continue;
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

  // ---- 槍 ----

  void _updateSpear(double dt) {
    final w = spear;
    if (w == null) return;
    for (final t in thrusts) {
      t.t += dt;
      if (!t.active) continue;
      final reach = t.reach;
      final ux = cos(t.angle), uy = sin(t.angle);
      for (final e in enemies) {
        if (!_hittable(e) || t.hit.contains(e)) continue;
        // 槍の線分と敵の円が重なるか
        final dx = e.x - px, dy = e.y - py;
        final along = dx * ux + dy * uy;
        if (along < 0 || along > reach + e.stats.radius) continue;
        final side = (dx * uy - dy * ux).abs();
        if (side > SpearThrust.width / 2 + e.stats.radius) continue;
        t.hit.add(e);
        _damage(e, t.damage, w,
            knockFromX: px - ux * 20, knockFromY: py - uy * 20);
      }
    }
    thrusts.removeWhere((t) => t.done);

    _spearCd -= dt;
    if (_spearCd > 0) return;
    _spearCd = spearInterval;
    _emit(RunEvent(RunEventType.spearThrust, px, py));
    // 届く範囲の一番近い敵を狙う。いなければ向いている方向へ
    final near = _nearest(spearLength * 1.6);
    final base = near.isEmpty
        ? atan2(facingY, facingX)
        : atan2(near.first.y - py, near.first.x - px);
    final n = 1 + skills.level(SkillId.spearMulti);
    // 本数が増えると扇状に広がる
    final fan = [
      for (var i = 0; i < n; i++) base + (i - (n - 1) / 2) * 0.32,
    ];
    // 竜騎士の槍：三方向へ同時に
    final dirs = spearEvolved
        ? [
            for (final d in fan) ...[d, d + 2 * pi / 3, d - 2 * pi / 3],
          ]
        : fan;
    for (final a in dirs) {
      thrusts.add(SpearThrust(a, spearLength, spearDamage));
    }
  }

  // ---- 杖 ----

  void _updateStaff(double dt) {
    final w = staff;
    if (w == null) return;
    for (final f in fireballs) {
      f.x += f.vx * dt;
      f.y += f.vy * dt;
      f.life -= dt;
      var explode = f.life <= 0;
      if (!explode) {
        for (final e in enemies) {
          if (!_hittable(e)) continue;
          final r = e.stats.radius + 6;
          final dx = e.x - f.x, dy = e.y - f.y;
          if (dx * dx + dy * dy < r * r) {
            explode = true;
            break;
          }
        }
      }
      if (explode) {
        f.life = 0;
        _explode(f.x, f.y, f.radius, f.damage, w);
      }
    }
    fireballs.removeWhere((f) => f.life <= 0);
    for (final b in blasts) {
      b.life -= dt;
    }
    blasts.removeWhere((b) => b.life <= 0);

    _staffCd -= dt;
    if (_staffCd > 0) return;
    final targets = _nearest(320);
    if (targets.isEmpty) return;
    final boss = targets.where((e) => e.isBoss).firstOrNull;
    _staffCd = staffInterval;
    _emit(RunEvent(RunEventType.staffCast, px, py));
    final n = staffEvolved ? 3 : 1;
    const speed = 260.0;
    for (var i = 0; i < n; i++) {
      // 1発目はボスを狙い、残りは近い敵の中からばらけて狙う
      final t = i == 0 && boss != null
          ? boss
          : targets[rng.nextInt(min(6, targets.length))];
      final dx = t.x - px, dy = t.y - py;
      final d = max(1.0, sqrt(dx * dx + dy * dy));
      fireballs.add(Fireball(px, py, dx / d * speed, dy / d * speed,
          d / speed + 0.05, staffDamage, staffRadius));
    }
  }

  void _explode(
      double x, double y, double radius, double damage, CarriedWeapon w) {
    blasts.add(Blast(x, y, radius));
    _emit(RunEvent(RunEventType.blast, x, y));
    for (final e in enemies) {
      if (!_hittable(e)) continue;
      final r = radius + e.stats.radius;
      final dx = e.x - x, dy = e.y - y;
      if (dx * dx + dy * dy > r * r) continue;
      _damage(e, damage, w, knockFromX: x, knockFromY: y);
    }
  }

  // ---- 共通 ----

  /// 範囲内にボスがいれば先頭にする
  List<Enemy> _withBossFirst(List<Enemy> list) {
    final i = list.indexWhere((e) => e.isBoss);
    if (i <= 0) return list;
    return [list[i], ...list.take(i), ...list.skip(i + 1)];
  }

  /// 範囲内の敵を近い順に
  List<Enemy> _nearest(double range) {
    return enemies.where((e) {
      if (!_hittable(e)) return false;
      final dx = e.x - px, dy = e.y - py;
      return dx * dx + dy * dy < range * range;
    }).toList()
      ..sort((a, b) {
        final da = (a.x - px) * (a.x - px) + (a.y - py) * (a.y - py);
        final db = (b.x - px) * (b.x - px) + (b.y - py) * (b.y - py);
        return da.compareTo(db);
      });
  }
}

/// 描画やテストから読む、武器の数値（スキル反映後）
extension WeaponStats on RunSimulation {
  bool get swordEvolved => skills.level(SkillId.giantSlayer) > 0;
  bool get bowEvolved => skills.level(SkillId.stormBow) > 0;
  bool get spearEvolved => skills.level(SkillId.dragoonSpear) > 0;
  bool get staffEvolved => skills.level(SkillId.sageStaff) > 0;

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

  double get spearLength =>
      (70 + 16 * skills.level(SkillId.spearReach)) * (spearEvolved ? 1.4 : 1);
  double get spearInterval =>
      1.15 * pow(0.88, skills.level(SkillId.spearSpeed));
  double get spearDamage =>
      22 *
      (1 + 0.1 * skills.level(SkillId.spearSpeed)) *
      (spear?.damageMultiplier ?? 1) *
      (spearEvolved ? 1.5 : 1);

  double get staffRadius =>
      (36 + 10 * skills.level(SkillId.staffRadius)) * (staffEvolved ? 1.4 : 1);
  double get staffInterval => 1.3 * pow(0.88, skills.level(SkillId.staffSpeed));
  double get staffDamage =>
      20 *
      (1 + 0.25 * skills.level(SkillId.staffPower)) *
      (staff?.damageMultiplier ?? 1) *
      (staffEvolved ? 1.3 : 1);
}
