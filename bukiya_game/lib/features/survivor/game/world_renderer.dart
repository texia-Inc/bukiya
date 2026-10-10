import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show FontWeight, Shadow, TextStyle;

import '../domain/run_result.dart';
import '../domain/loadout.dart';
import '../domain/run_simulation.dart';
import 'run_fx.dart';
import 'sprites.dart';
import 'survivor_game.dart';

/// シミュレーションの状態をワールド座標でまとめて描く。
/// 敵を1体ずつコンポーネントにすると数百体で重くなるため、1つの描画コンポーネントで処理する。
class WorldRenderer extends Component with HasGameReference<SurvivorGame> {
  final RunSimulation sim;
  final RunFx fx;

  WorldRenderer(this.sim, this.fx);

  final Sprites _sprites = Sprites();

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = const Color(0xFF1A1A1A);

  static final TextPaint _gateLabel = TextPaint(
    style: const TextStyle(
      color: Color(0xFFE6FBFF),
      fontSize: 13,
      fontWeight: FontWeight.bold,
    ),
  );

  static TextPaint _numberPaint(Color color, double size) => TextPaint(
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
                color: Color(0xFF000000),
                blurRadius: 0,
                offset: Offset(1.5, 1.5)),
            Shadow(
                color: Color(0xFF000000),
                blurRadius: 0,
                offset: Offset(-1, -1)),
          ],
        ),
      );

  static final TextPaint _swordNumber =
      _numberPaint(const Color(0xFFFFFFFF), 17);
  static final TextPaint _bowNumber = _numberPaint(const Color(0xFFBFE8FF), 17);
  static final TextPaint _bigNumber = _numberPaint(const Color(0xFFFFD45E), 23);
  static final TextPaint _spearNumber =
      _numberPaint(const Color(0xFFFFE2B8), 17);
  static final TextPaint _staffNumber =
      _numberPaint(const Color(0xFFFF9A6B), 17);

  // 毎フレーム Path を作らないよう、原点基準の形を1回だけ作って移動・拡大して使う
  static final Path _unitDiamond = Path()
    ..moveTo(0, -1)
    ..lineTo(0.7, 0)
    ..lineTo(0, 1)
    ..lineTo(-0.7, 0)
    ..close();
  static final Path _fangPath = Path()
    ..moveTo(-5, -5)
    ..lineTo(5, -5)
    ..lineTo(0, 7)
    ..close();

  /// 画面外のものは描かない
  late Rect _cull;

  @override
  void render(Canvas canvas) {
    final view = game.camera.visibleWorldRect;
    _cull = view.inflate(40);
    _drawGround(canvas, view);
    _drawGate(canvas);
    _drawPickups(canvas);
    _drawBossTelegraphs(canvas);
    _drawEnemies(canvas);
    _drawBlasts(canvas);
    _drawArrows(canvas);
    _drawThrusts(canvas);
    _drawPlayer(canvas);
    _drawFireballs(canvas);
    _drawParticles(canvas);
    _drawNumbers(canvas);
    _drawGateArrow(canvas, view);
    _drawFlashes(canvas, view);
  }

  void _drawNumbers(Canvas canvas) {
    for (final n in fx.numbers) {
      final t = n.age / FloatingNumber.lifetime;
      // 出た瞬間に大きく弾み、最後は縮んで消える
      final scale = t < 0.15
          ? 1.6 - t / 0.15 * 0.6
          : t > 0.75
              ? 1 - (t - 0.75) / 0.25
              : 1.0;
      if (scale <= 0) continue;
      final y = n.y - 34 * (1 - pow(1 - t, 2));
      final paint = n.big
          ? _bigNumber
          : switch (n.weapon) {
              CarriedWeaponType.bow => _bowNumber,
              CarriedWeaponType.spear => _spearNumber,
              CarriedWeaponType.staff => _staffNumber,
              _ => _swordNumber,
            };
      canvas.save();
      canvas.translate(n.x, y);
      canvas.scale(scale);
      paint.render(canvas, n.text, Vector2.zero(), anchor: Anchor.center);
      canvas.restore();
    }
  }

  void _drawFlashes(Canvas canvas, Rect view) {
    if (fx.hurtFlash > 0) {
      // 画面のふちを赤くする
      final rect = view.inflate(20);
      final shader = Gradient.radial(
        view.center,
        view.longestSide * 0.6,
        [
          const Color(0x00E5484D),
          Color.fromRGBO(229, 72, 77, 0.55 * fx.hurtFlash)
        ],
        [0.55, 1],
      );
      canvas.drawRect(rect, Paint()..shader = shader);
    }
    if (fx.whiteFlash > 0) {
      canvas.drawRect(view.inflate(20),
          Paint()..color = Color.fromRGBO(255, 244, 200, 0.7 * fx.whiteFlash));
    }
  }

  void _drawGround(Canvas canvas, Rect view) {
    const tile = 64.0;
    final x0 = (view.left / tile).floor(), x1 = (view.right / tile).ceil();
    final y0 = (view.top / tile).floor(), y1 = (view.bottom / tile).ceil();
    for (var tx = x0; tx < x1; tx++) {
      for (var ty = y0; ty < y1; ty++) {
        final h = _hash(tx, ty);
        if ((tx + ty).isEven) {
          _fill.color = Color(sim.stage.tileColor);
          canvas.drawRect(
              Rect.fromLTWH(tx * tile, ty * tile, tile, tile), _fill);
        }
        if (h % 5 == 0) {
          // 草むら
          _fill.color = Color(sim.stage.grassColor);
          final gx = tx * tile + (h % 37) + 10, gy = ty * tile + (h % 29) + 14;
          canvas.drawCircle(Offset(gx, gy), 3, _fill);
          canvas.drawCircle(Offset(gx + 5, gy + 2), 2.5, _fill);
          canvas.drawCircle(Offset(gx - 4, gy + 3), 2, _fill);
        } else if (h % 11 == 0) {
          // 小石
          _fill.color = Color(sim.stage.stoneColor);
          canvas.drawOval(
              Rect.fromLTWH(
                  tx * tile + (h % 41) + 8, ty * tile + (h % 23) + 20, 7, 5),
              _fill);
        }
      }
    }
  }

  int _hash(int x, int y) => ((x * 73856093) ^ (y * 19349663)).abs() % 1000003;

  void _drawGate(Canvas canvas) {
    final g = sim.gate;
    if (g == null) return;
    final pulse = 0.5 + 0.5 * sin(sim.time * 5);
    final c = Offset(g.x, g.y);
    _fill.color = Color.fromRGBO(120, 220, 255, 0.18 + 0.12 * pulse);
    canvas.drawCircle(c, RunSimulation.gateRadius + 10 + pulse * 6, _fill);
    _fill.color = const Color(0xFF1B3A4B);
    canvas.drawCircle(c, RunSimulation.gateRadius, _fill);
    _stroke
      ..color = const Color(0xFF8BE9FF)
      ..strokeWidth = 3;
    canvas.drawCircle(c, RunSimulation.gateRadius, _stroke);
    _stroke.strokeWidth = 2;
    _gateLabel.render(canvas, '帰還', Vector2(g.x, g.y - 40),
        anchor: Anchor.center);
  }

  void _drawGateArrow(Canvas canvas, Rect view) {
    final g = sim.gate;
    if (g == null || view.deflate(20).contains(Offset(g.x, g.y))) return;
    final a = atan2(g.y - sim.py, g.x - sim.px);
    final cx = sim.px + cos(a) * 44, cy = sim.py + sin(a) * 44;
    final path = Path()
      ..moveTo(cx + cos(a) * 10, cy + sin(a) * 10)
      ..lineTo(cx + cos(a + 2.4) * 8, cy + sin(a + 2.4) * 8)
      ..lineTo(cx + cos(a - 2.4) * 8, cy + sin(a - 2.4) * 8)
      ..close();
    _fill.color = const Color(0xFF8BE9FF);
    canvas.drawPath(path, _fill);
  }

  void _drawPickups(Canvas canvas) {
    for (final p in sim.pickups) {
      if (!_cull.contains(Offset(p.x, p.y))) continue;
      if (p.kind == PickupKind.chest) {
        _sprites.chest(canvas, p.x, p.y, sim.time);
        continue;
      }
      final m = p.material;
      if (m == null) {
        // まとめられて価値が高い宝石は大きく緑に
        final big = p.xp >= 5;
        _diamond(canvas, p.x, p.y, big ? 7 : 5,
            big ? const Color(0xFF6BE08A) : const Color(0xFF5EC8FF));
        continue;
      }
      switch (m) {
        case MaterialKind.ironOre:
          _fill.color = const Color(0xFFA7B1B8);
          final r =
              Rect.fromCenter(center: Offset(p.x, p.y), width: 10, height: 9);
          canvas.drawRect(r, _fill);
          canvas.drawRect(r, _outline);
        case MaterialKind.fang:
          _fill.color = const Color(0xFFF4EBD0);
          canvas.save();
          canvas.translate(p.x, p.y);
          canvas.drawPath(_fangPath, _fill);
          canvas.drawPath(_fangPath, _outline);
          canvas.restore();
        case MaterialKind.manaStone:
          _fill.color = const Color(0x55C77DFF);
          canvas.drawCircle(Offset(p.x, p.y), 11, _fill);
          _diamond(canvas, p.x, p.y, 7, const Color(0xFFC77DFF));
        case MaterialKind.bone:
          _fill.color = const Color(0xFFEDE6D6);
          final bone = RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(p.x, p.y), width: 12, height: 4),
              const Radius.circular(2));
          canvas.drawRRect(bone, _fill);
          canvas.drawRRect(bone, _outline);
          for (final dx in const [-6.0, 6.0]) {
            canvas.drawCircle(Offset(p.x + dx, p.y - 2), 2.4, _fill);
            canvas.drawCircle(Offset(p.x + dx, p.y + 2), 2.4, _fill);
          }
        case MaterialKind.bossCore:
          _fill.color = const Color(0x66FF6B6B);
          canvas.drawCircle(Offset(p.x, p.y), 13, _fill);
          _diamond(canvas, p.x, p.y, 9, const Color(0xFFFF6B6B));
      }
    }
  }

  void _diamond(Canvas canvas, double x, double y, double s, Color color) {
    _fill.color = color;
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(s);
    // 拡大しても線の太さが変わらないよう、太さを割り戻す
    final width = _outline.strokeWidth;
    _outline.strokeWidth = width / s;
    canvas.drawPath(_unitDiamond, _fill);
    canvas.drawPath(_unitDiamond, _outline);
    _outline.strokeWidth = width;
    canvas.restore();
  }

  void _drawEnemies(Canvas canvas) {
    // 奥（画面の上）にいる敵から描いて、手前の敵が上に重なるようにする
    final visible = [
      for (final e in sim.enemies)
        if (e.isBoss || _cull.contains(Offset(e.x, e.y))) e
    ]..sort((a, b) => a.y.compareTo(b.y));
    for (final e in visible) {
      switch (e.kind) {
        case EnemyKind.slime:
          _sprites.slime(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.bat:
          _sprites.bat(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.goblin:
          _sprites.goblin(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.skeleton:
          _sprites.skeleton(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.ghost:
          _sprites.ghost(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.ogre:
          _sprites.ogre(canvas, e, sim.time, sim.px, sim.py);
        case EnemyKind.kingSlime:
          _sprites.kingSlime(canvas, e, sim.time, sim.px, sim.py);
      }
    }
  }

  /// ボスの大技の予告：オーガの突進線と、キングスライムの着地点
  void _drawBossTelegraphs(Canvas canvas) {
    for (final e in sim.enemies) {
      if (!e.isBoss) continue;
      if (e.kind == EnemyKind.ogre && e.bossState == BossState.windup) {
        final len = ogreChargeSpeed * ogreChargeTime + e.stats.radius;
        final a = atan2(e.dirY, e.dirX);
        final blink = 0.25 + 0.2 * sin(sim.time * 30).abs();
        canvas.save();
        canvas.translate(e.x, e.y);
        canvas.rotate(a);
        _fill.color = Color.fromRGBO(229, 72, 77, blink);
        canvas.drawRect(
            Rect.fromLTWH(0, -e.stats.radius, len, e.stats.radius * 2), _fill);
        canvas.restore();
      }
      if (e.kind == EnemyKind.kingSlime && e.airborne) {
        final p = e.airProgress;
        _fill.color = Color.fromRGBO(229, 72, 77, 0.15 + 0.25 * p);
        canvas.drawCircle(Offset(e.toX, e.toY), kingSlimeSlamRadius, _fill);
        _stroke
          ..color = const Color(0xCCE5484D)
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(e.toX, e.toY),
            kingSlimeSlamRadius * (0.3 + 0.7 * p), _stroke);
      }
    }
  }

  void _drawThrusts(Canvas canvas) {
    final evolved = sim.spearEvolved;
    for (final t in sim.thrusts) {
      if (!t.active) continue;
      final reach = t.reach;
      if (reach < 4) continue;
      canvas.save();
      canvas.translate(sim.px, sim.py);
      canvas.rotate(t.angle);
      // 突きの残像
      _fill.color = evolved ? const Color(0x44FFD45E) : const Color(0x33FFFFFF);
      canvas.drawRect(
          Rect.fromLTWH(
              8, -SpearThrust.width / 2, reach - 8, SpearThrust.width),
          _fill);
      // 柄と穂先
      _fill.color = const Color(0xFF8A5A2B);
      final shaft = Rect.fromLTWH(reach - 46, -2, 38, 4);
      canvas.drawRect(shaft, _fill);
      canvas.drawRect(shaft, _outline);
      final tip = Path()
        ..moveTo(reach, 0)
        ..lineTo(reach - 12, -5)
        ..lineTo(reach - 12, 5)
        ..close();
      _fill.color = evolved ? const Color(0xFFFFD45E) : const Color(0xFFDDE6EE);
      canvas.drawPath(tip, _fill);
      canvas.drawPath(tip, _outline);
      canvas.restore();
    }
  }

  void _drawFireballs(Canvas canvas) {
    for (final f in sim.fireballs) {
      if (!_cull.contains(Offset(f.x, f.y))) continue;
      final flick = 1 + 0.15 * sin(sim.time * 40 + f.x);
      _fill.color = const Color(0x55FF8A3D);
      canvas.drawCircle(Offset(f.x, f.y), 11 * flick, _fill);
      _fill.color = const Color(0xFFFF6A2B);
      canvas.drawCircle(Offset(f.x, f.y), 6.5 * flick, _fill);
      _fill.color = const Color(0xFFFFE08A);
      canvas.drawCircle(Offset(f.x, f.y), 3.2, _fill);
    }
  }

  void _drawBlasts(Canvas canvas) {
    for (final b in sim.blasts) {
      final p = b.progress;
      final r = b.radius * (0.5 + 0.5 * p);
      _fill.color = Color.fromRGBO(255, 140, 60, 0.45 * (1 - p));
      canvas.drawCircle(Offset(b.x, b.y), r, _fill);
      _stroke
        ..color = Color.fromRGBO(255, 230, 150, 0.9 * (1 - p))
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(b.x, b.y), r, _stroke);
    }
    _stroke.strokeWidth = 2;
  }

  void _drawArrows(Canvas canvas) {
    _stroke
      ..color = const Color(0xFFF2E3C2)
      ..strokeWidth = 2.5;
    for (final a in sim.arrows) {
      final len = sqrt(a.vx * a.vx + a.vy * a.vy);
      final ux = a.vx / len, uy = a.vy / len;
      canvas.drawLine(
          Offset(a.x - ux * 14, a.y - uy * 14), Offset(a.x, a.y), _stroke);
    }
    _stroke.strokeWidth = 2;
  }

  void _drawPlayer(Canvas canvas) {
    final c = Offset(sim.px, sim.py);
    final facing = atan2(sim.facingY, sim.facingX);

    if (sim.sword != null) _drawSword(canvas, c, facing);
    if (sim.bow != null) {
      // 背中に背負った弓（向きと反対側に見える）
      final side = sim.facingX >= 0 ? -1.0 : 1.0;
      final bow = Rect.fromCenter(
          center: Offset(sim.px + side * 6, sim.py - 2), width: 10, height: 24);
      _stroke
        ..color = const Color(0xFF1A1A1A)
        ..strokeWidth = 4.5;
      canvas.drawArc(bow, side < 0 ? pi / 2 : -pi / 2, pi, false, _stroke);
      _stroke
        ..color = const Color(0xFF9C6B3F)
        ..strokeWidth = 2.5;
      canvas.drawArc(bow, side < 0 ? pi / 2 : -pi / 2, pi, false, _stroke);
      _stroke
        ..color = const Color(0xFFE8E0C8)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(bow.center.dx, bow.top + 1),
          Offset(bow.center.dx, bow.bottom - 1), _stroke);
      _stroke.strokeWidth = 2;
    }

    final side = sim.facingX >= 0 ? -1.0 : 1.0;
    if (sim.spear != null && sim.thrusts.isEmpty) {
      // 突いていない間は槍を背負う
      final a = Offset(sim.px + side * 4, sim.py + 8);
      final b = Offset(sim.px - side * 10, sim.py - 26);
      _stroke
        ..color = const Color(0xFF1A1A1A)
        ..strokeWidth = 4.5;
      canvas.drawLine(a, b, _stroke);
      _stroke
        ..color = const Color(0xFF8A5A2B)
        ..strokeWidth = 2.5;
      canvas.drawLine(a, b, _stroke);
      _stroke.strokeWidth = 2;
      _fill.color = const Color(0xFFDDE6EE);
      canvas.drawCircle(b, 3, _fill);
      canvas.drawCircle(b, 3, _outline);
    }

    final blink =
        sim.invulnerable > 0 && (sim.invulnerable * 20).floor().isEven;
    if (blink) return;
    _sprites.shopkeeper(
      canvas,
      x: sim.px,
      y: sim.py,
      facingX: sim.facingX,
      facingY: sim.facingY,
      moving: sim.moving,
      walkDistance: sim.walkDistance,
      time: sim.time,
    );
    if (sim.staff != null) {
      // 杖は前の手に持つ。先の宝玉が光る
      final hx = sim.px - side * 9, hy = sim.py + 2;
      _stroke
        ..color = const Color(0xFF1A1A1A)
        ..strokeWidth = 4;
      canvas.drawLine(Offset(hx, hy + 8), Offset(hx, hy - 16), _stroke);
      _stroke
        ..color = const Color(0xFF7A4E2A)
        ..strokeWidth = 2.2;
      canvas.drawLine(Offset(hx, hy + 8), Offset(hx, hy - 16), _stroke);
      _stroke.strokeWidth = 2;
      final glow = 0.5 + 0.5 * sin(sim.time * 5);
      _fill.color = Color.fromRGBO(255, 140, 60, 0.25 + 0.2 * glow);
      canvas.drawCircle(Offset(hx, hy - 19), 7, _fill);
      _fill.color = const Color(0xFFFF6A2B);
      canvas.drawCircle(Offset(hx, hy - 19), 3.8, _fill);
      canvas.drawCircle(Offset(hx, hy - 19), 3.8, _outline);
    }
  }

  void _drawSword(Canvas canvas, Offset c, double facing) {
    final radius = sim.swordRadius;
    final evolved = sim.swordEvolved;
    final bladeColor =
        evolved ? const Color(0xFFFFD45E) : const Color(0xFFDDE6EE);
    final width = 5 + radius / 14;
    final s = sim.swing;
    double angle;
    double length;
    if (s != null) {
      angle = s.bladeAngle;
      length = radius;
      // 斬撃の軌跡
      final trail = Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(Rect.fromCircle(center: c, radius: radius), s.startAngle,
            s.progress * 2 * pi, false)
        ..close();
      _fill.color = evolved ? const Color(0x44FFD45E) : const Color(0x33FFFFFF);
      canvas.drawPath(trail, _fill);
    } else {
      angle = facing + 2.4;
      length = radius * 0.6;
    }
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    final blade = RRect.fromRectAndRadius(
        Rect.fromLTWH(10, -width / 2, length - 10, width),
        Radius.circular(width / 2));
    _fill.color = bladeColor;
    canvas.drawRRect(blade, _fill);
    canvas.drawRRect(blade, _outline);
    // 鍔
    _fill.color = const Color(0xFF8A5A2B);
    canvas.drawRect(Rect.fromLTWH(8, -width, 4, width * 2), _fill);
    canvas.restore();
  }

  void _drawParticles(Canvas canvas) {
    for (final p in sim.particles) {
      if (!_cull.contains(Offset(p.x, p.y))) continue;
      final t = p.life / p.maxLife;
      _fill.color = Color(p.color).withValues(alpha: t);
      canvas.drawCircle(Offset(p.x, p.y), 2 + 2 * t, _fill);
    }
  }
}
