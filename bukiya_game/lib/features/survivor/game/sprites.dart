import 'dart:math';
import 'dart:ui';

import '../domain/run_simulation.dart';

/// キャラクターと敵の絵。画像を使わず図形で描く（黒い縁取りのフラットな絵柄）。
/// どれも足元の少し上を (x, y) として描く。
class Sprites {
  final Paint _fill = Paint();
  final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF1A1A1A);
  final Paint _shadow = Paint()..color = const Color(0x40000000);
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static const _ink = Color(0xFF1A1A1A);
  static const _white = Color(0xFFFFFFFF);

  // 店主の色
  static const _skin = Color(0xFFF2CDA0);
  static const _shirt = Color(0xFFF1E3C6);
  static const _apron = Color(0xFF3F6E9E);
  static const _apronDark = Color(0xFF2F5478);
  static const _bandana = Color(0xFFD64545);
  static const _boots = Color(0xFF4A3426);
  static const _cheek = Color(0x66F28B82);

  // 原点基準の形（毎フレーム作らない）
  static final Path _bandanaKnot = Path()
    ..moveTo(0, 0)
    ..lineTo(-5, -3)
    ..lineTo(-4, 2)
    ..close()
    ..moveTo(0, 0)
    ..lineTo(-5, 4)
    ..lineTo(-1, 4)
    ..close();
  static final Path _batWing = Path()
    ..moveTo(0, -0.2)
    ..lineTo(1.2, -1.0)
    ..lineTo(2.4, -0.6)
    ..quadraticBezierTo(2.0, 0.0, 1.7, 0.1)
    ..quadraticBezierTo(1.4, -0.1, 1.1, 0.25)
    ..quadraticBezierTo(0.8, 0.0, 0.5, 0.3)
    ..close();
  static final Path _batEars = Path()
    ..moveTo(-0.7, -0.5)
    ..lineTo(-0.55, -1.25)
    ..lineTo(-0.2, -0.85)
    ..close()
    ..moveTo(0.7, -0.5)
    ..lineTo(0.55, -1.25)
    ..lineTo(0.2, -0.85)
    ..close();
  static final Path _goblinEar = Path()
    ..moveTo(0, 0)
    ..lineTo(1.0, -0.55)
    ..lineTo(0.35, 0.3)
    ..close();

  void _shadowAt(Canvas canvas, double x, double y, double w) {
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.32),
        _shadow);
  }

  void _filled(Canvas canvas, Color color, void Function(Paint p) draw) {
    _fill.color = color;
    draw(_fill);
    draw(_outline);
  }

  /// canvas.scale した中で描くとき用。縁取りの太さが拡大されないよう割り戻す
  void _filledScaled(
      Canvas canvas, Color color, double scale, void Function(Paint p) draw) {
    final width = _outline.strokeWidth;
    _outline.strokeWidth = width / scale;
    _filled(canvas, color, draw);
    _outline.strokeWidth = width;
  }

  /// 武器屋の店主（プレイヤー）。2.5頭身のちびキャラ
  void shopkeeper(
    Canvas canvas, {
    required double x,
    required double y,
    required double facingX,
    required double facingY,
    required bool moving,
    required double walkDistance,
    required double time,
  }) {
    // 歩くと体が上下し、足と腕が交互に動く
    final phase = walkDistance / 9;
    final bob = moving ? sin(phase * 2).abs() * 1.6 : sin(time * 2.4) * 0.5;
    final step = moving ? sin(phase) : 0.0;
    final back = facingY < -0.6 && facingX.abs() < 0.6;
    final look = back ? 0.0 : facingX.clamp(-1.0, 1.0) * 2.6;

    _shadowAt(canvas, x, y + 13, 22);

    canvas.save();
    canvas.translate(x, y - bob);

    // 足
    _filled(
        canvas,
        _boots,
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(-5.5, 6 + step * 1.8, 4.5, 6.5 - step * 1.2),
                const Radius.circular(2)),
            p));
    _filled(
        canvas,
        _boots,
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(1, 6 - step * 1.8, 4.5, 6.5 + step * 1.2),
                const Radius.circular(2)),
            p));

    // 腕（体の後ろ）
    _filled(canvas, _skin,
        (p) => canvas.drawCircle(Offset(-7.5, 3 - step * 1.5), 2.6, p));
    _filled(canvas, _skin,
        (p) => canvas.drawCircle(Offset(7.5, 3 + step * 1.5), 2.6, p));

    // 体（シャツとエプロン）
    _filled(
        canvas,
        _shirt,
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(-7, -2, 14, 11), const Radius.circular(4)),
            p));
    if (!back) {
      _filled(
          canvas,
          _apron,
          (p) => canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(-5 + look * 0.3, 0.5, 10, 9),
                  const Radius.circular(2.5)),
              p));
      _fill.color = _apronDark;
      canvas.drawRect(Rect.fromLTWH(-2.5 + look * 0.3, 4, 5, 2.5), _fill);
    } else {
      // 後ろ姿はエプロンのひもだけ見える
      _fill.color = _apron;
      canvas.drawRect(const Rect.fromLTWH(-7, 2.5, 14, 1.8), _fill);
    }

    // 頭
    const head = Offset(0, -8);
    _filled(canvas, _skin, (p) => canvas.drawCircle(head, 9.5, p));

    // バンダナ（頭の上半分）と結び目
    _fill.color = _bandana;
    canvas.drawArc(Rect.fromCircle(center: head, radius: 9.5), pi * 1.02,
        pi * 0.96, true, _fill);
    canvas.drawArc(
        Rect.fromCircle(center: head, radius: 9.5), pi, pi, false, _outline);
    canvas.drawLine(const Offset(-9.5, -8), const Offset(9.5, -8), _outline);
    final knotX = back ? 0.0 : -facingX.sign * 8.5;
    if (knotX != 0 || back) {
      canvas.save();
      canvas.translate(knotX, back ? -9 : -10);
      if (facingX < 0 && !back) canvas.scale(-1, 1);
      _filled(canvas, _bandana, (p) => canvas.drawPath(_bandanaKnot, p));
      canvas.restore();
    }

    if (!back) {
      // 目とほっぺ（向いている方に寄せる）
      _fill.color = _ink;
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(-3 + look, -5.5), width: 2.2, height: 3.2),
          _fill);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(3 + look, -5.5), width: 2.2, height: 3.2),
          _fill);
      _fill.color = _cheek;
      canvas.drawCircle(Offset(-5.5 + look, -2.8), 1.8, _fill);
      canvas.drawCircle(Offset(5.5 + look, -2.8), 1.8, _fill);
    }
    canvas.restore();
  }

  /// 目（プレイヤーの方を見る）
  void _eyes(
      Canvas canvas, double x, double y, double r, double toX, double toY,
      {double spread = 0.32, double size = 0.17}) {
    final a = atan2(toY - y, toX - x);
    final ex = cos(a) * r * 0.25, ey = sin(a) * r * 0.2;
    _fill.color = _white;
    canvas.drawCircle(
        Offset(x + ex - r * spread, y + ey), r * size * 1.7, _fill);
    canvas.drawCircle(
        Offset(x + ex + r * spread, y + ey), r * size * 1.7, _fill);
    _fill.color = _ink;
    final px = cos(a) * r * 0.06, py = sin(a) * r * 0.06;
    canvas.drawCircle(
        Offset(x + ex - r * spread + px, y + ey + py), r * size, _fill);
    canvas.drawCircle(
        Offset(x + ex + r * spread + px, y + ey + py), r * size, _fill);
  }

  void slime(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final squash = sin(time * 8 + e.x * 0.05);
    _shadowAt(canvas, e.x, e.y + r * 0.75, r * 2.1);
    // ぷるぷる弾むしずく型
    final w = r * 2 + squash * 2, h = r * 1.75 - squash * 2;
    final body = Rect.fromCenter(
        center: Offset(e.x, e.y + r * 0.75 - h / 2), width: w, height: h);
    _filled(
        canvas,
        flash ? _white : const Color(0xFF6CC47A),
        (p) => canvas.drawRRect(
            RRect.fromRectAndCorners(body,
                topLeft: Radius.elliptical(w / 2, h * 0.75),
                topRight: Radius.elliptical(w / 2, h * 0.75),
                bottomLeft: Radius.elliptical(w * 0.3, h * 0.25),
                bottomRight: Radius.elliptical(w * 0.3, h * 0.25)),
            p));
    // つや
    _fill.color = const Color(0x88FFFFFF);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(e.x - r * 0.45, body.top + h * 0.28),
            width: r * 0.5,
            height: r * 0.32),
        _fill);
    _eyes(canvas, e.x, body.top + h * 0.5, r, toX, toY);
  }

  void bat(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    // 宙に浮いているので影は小さく下に
    final hover = sin(time * 6 + e.x) * 2;
    _shadowAt(canvas, e.x, e.y + r + 7, r * 1.6);
    final y = e.y + hover;
    final flap = sin(time * 22 + e.y);
    final wingColor = flash ? _white : const Color(0xFF5E3D8F);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(e.x + side * r * 0.5, y);
      canvas.scale(side * r * 1.1, r * (1.1 + 0.6 * flap));
      _filledScaled(
          canvas, wingColor, r * 1.1, (p) => canvas.drawPath(_batWing, p));
      canvas.restore();
    }
    canvas.save();
    canvas.translate(e.x, y);
    canvas.scale(r);
    _filledScaled(canvas, flash ? _white : const Color(0xFF8E6BC9), r,
        (p) => canvas.drawPath(_batEars, p));
    canvas.restore();
    _filled(canvas, flash ? _white : const Color(0xFF8E6BC9),
        (p) => canvas.drawCircle(Offset(e.x, y), r, p));
    _eyes(canvas, e.x, y - r * 0.05, r, toX, toY, spread: 0.36);
  }

  void goblin(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final step = sin(time * 9 + e.x * 0.1);
    _shadowAt(canvas, e.x, e.y + r * 0.95, r * 1.7);
    // 腰布をまとった体
    _filled(
        canvas,
        flash ? _white : const Color(0xFF8A6A3B),
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(e.x, e.y + r * 0.45),
                    width: r * 1.2,
                    height: r * 0.9),
                Radius.circular(r * 0.3)),
            p));
    // 足
    _fill.color = flash ? _white : const Color(0xFF4F7A2F);
    canvas.drawCircle(
        Offset(e.x - r * 0.3, e.y + r * 0.9 + step * 1.2), r * 0.18, _fill);
    canvas.drawCircle(
        Offset(e.x + r * 0.3, e.y + r * 0.9 - step * 1.2), r * 0.18, _fill);
    // とがった耳
    final skin = flash ? _white : const Color(0xFF7FB24F);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(e.x + side * r * 0.6, e.y - r * 0.35);
      canvas.scale(side * r, r);
      _filledScaled(canvas, skin, r, (p) => canvas.drawPath(_goblinEar, p));
      canvas.restore();
    }
    // 頭
    final head = Offset(e.x, e.y - r * 0.3);
    _filled(canvas, skin, (p) => canvas.drawCircle(head, r * 0.72, p));
    _eyes(canvas, head.dx, head.dy - r * 0.08, r * 0.72, toX, toY,
        spread: 0.38, size: 0.2);
    // 牙
    _fill.color = _white;
    canvas.drawRect(
        Rect.fromLTWH(head.dx - r * 0.22, head.dy + r * 0.3, r * 0.1, r * 0.14),
        _fill);
    canvas.drawRect(
        Rect.fromLTWH(head.dx + r * 0.12, head.dy + r * 0.3, r * 0.1, r * 0.14),
        _fill);
    // 体力バー
    if (e.hp < e.maxHp) {
      final w = r * 1.6;
      _fill.color = const Color(0xAA000000);
      canvas.drawRect(Rect.fromLTWH(e.x - w / 2, e.y - r * 1.35, w, 3), _fill);
      _fill.color = const Color(0xFFE5484D);
      canvas.drawRect(
          Rect.fromLTWH(
              e.x - w / 2, e.y - r * 1.35, w * (e.hp / e.maxHp).clamp(0, 1), 3),
          _fill);
    }
  }

  void skeleton(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final bone = flash ? _white : const Color(0xFFEDE6D6);
    final step = sin(time * 7 + e.x * 0.1);
    _shadowAt(canvas, e.x, e.y + r * 0.95, r * 1.6);
    // あばら骨の体
    final body = Rect.fromCenter(
        center: Offset(e.x, e.y + r * 0.42), width: r * 1.0, height: r * 0.8);
    _filled(
        canvas,
        bone,
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(body, Radius.circular(r * 0.2)), p));
    _fill.color = const Color(0xFF6B6455);
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
          Rect.fromLTWH(body.left + r * 0.15, body.top + r * (0.15 + i * 0.22),
              r * 0.7, r * 0.07),
          _fill);
    }
    // 足の骨
    _fill.color = bone;
    canvas.drawRect(
        Rect.fromLTWH(e.x - r * 0.35, e.y + r * 0.8 + step, r * 0.18, r * 0.3),
        _fill);
    canvas.drawRect(
        Rect.fromLTWH(e.x + r * 0.17, e.y + r * 0.8 - step, r * 0.18, r * 0.3),
        _fill);
    // 頭蓋骨
    final head = Offset(e.x, e.y - r * 0.3);
    _filled(canvas, bone, (p) => canvas.drawCircle(head, r * 0.7, p));
    final a = atan2(toY - head.dy, toX - head.dx);
    final lx = cos(a) * r * 0.12, ly = sin(a) * r * 0.08;
    _fill.color = _ink;
    canvas.drawCircle(Offset(head.dx - r * 0.27 + lx, head.dy - r * 0.02 + ly),
        r * 0.19, _fill);
    canvas.drawCircle(Offset(head.dx + r * 0.27 + lx, head.dy - r * 0.02 + ly),
        r * 0.19, _fill);
    // 目の奥の赤い光
    _fill.color = const Color(0xFFFF5A4E);
    canvas.drawCircle(Offset(head.dx - r * 0.27 + lx, head.dy - r * 0.02 + ly),
        r * 0.07, _fill);
    canvas.drawCircle(Offset(head.dx + r * 0.27 + lx, head.dy - r * 0.02 + ly),
        r * 0.07, _fill);
    _fill.color = _ink;
    canvas.drawRect(
        Rect.fromLTWH(head.dx - r * 0.2, head.dy + r * 0.35, r * 0.4, r * 0.06),
        _fill);
  }

  void ghost(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final hover = sin(time * 4 + e.x * 0.07) * 2.5;
    _shadowAt(canvas, e.x, e.y + r + 6, r * 1.3);
    final y = e.y + hover;
    // すそが波打つ布
    final wave = time * 9 + e.y * 0.1;
    final path = Path()
      ..moveTo(e.x - r, y + r * 0.6)
      ..lineTo(e.x - r, y - r * 0.1)
      ..arcToPoint(Offset(e.x + r, y - r * 0.1),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(e.x + r, y + r * 0.6);
    for (var i = 0; i < 4; i++) {
      final x0 = e.x + r - i * r * 0.5;
      path.quadraticBezierTo(x0 - r * 0.25,
          y + r * (0.95 + 0.15 * sin(wave + i)), x0 - r * 0.5, y + r * 0.6);
    }
    path.close();
    _fill.color = flash ? _white : const Color(0xCCE8F3FF);
    canvas.drawPath(path, _fill);
    canvas.drawPath(path, _outline);
    _eyes(canvas, e.x, y - r * 0.1, r, toX, toY, spread: 0.35, size: 0.16);
    _fill.color = const Color(0x55F28B82);
    canvas.drawCircle(Offset(e.x - r * 0.55, y + r * 0.2), r * 0.15, _fill);
    canvas.drawCircle(Offset(e.x + r * 0.55, y + r * 0.2), r * 0.15, _fill);
  }

  /// 火の小鬼：角と小さな翼としっぽ。頭の炎がゆらめく
  void imp(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final hover = sin(time * 7 + e.x * 0.09) * 2;
    _shadowAt(canvas, e.x, e.y + r + 6, r * 1.4);
    final y = e.y + hover - 4;
    final body = flash ? _white : const Color(0xFFE0553A);
    final dark = flash ? _white : const Color(0xFF9C2F22);
    // 翼（はばたく）
    final flap = 0.6 + 0.4 * sin(time * 22 + e.y * 0.1);
    for (final side in const [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(e.x + side * r * 0.5, y - r * 0.2)
        ..lineTo(e.x + side * r * 1.7, y - r * (0.6 + 0.6 * flap))
        ..lineTo(e.x + side * r * 1.35, y + r * 0.05)
        ..lineTo(e.x + side * r * 1.0, y - r * 0.05)
        ..close();
      _filled(canvas, dark, (p) => canvas.drawPath(wing, p));
    }
    // しっぽ
    final tail = Path()
      ..moveTo(e.x, y + r * 0.7)
      ..quadraticBezierTo(e.x + r * 1.1, y + r * 1.0 + sin(time * 6) * 2,
          e.x + r * 1.2, y + r * 0.3);
    _stroke(canvas, tail, dark, 2.2);
    final tip = Path()
      ..moveTo(e.x + r * 1.2, y + r * 0.05)
      ..lineTo(e.x + r * 1.45, y + r * 0.4)
      ..lineTo(e.x + r * 1.0, y + r * 0.4)
      ..close();
    _filled(canvas, dark, (p) => canvas.drawPath(tip, p));
    // 頭の炎
    final f = 1 + 0.2 * sin(time * 18 + e.x);
    _fill.color = const Color(0xCCFFB13D);
    final flame = Path()
      ..moveTo(e.x - r * 0.45, y - r * 0.6)
      ..quadraticBezierTo(e.x - r * 0.3, y - r * 1.5 * f, e.x, y - r * 1.7 * f)
      ..quadraticBezierTo(
          e.x + r * 0.3, y - r * 1.4 * f, e.x + r * 0.45, y - r * 0.6)
      ..close();
    canvas.drawPath(flame, _fill);
    _fill.color = const Color(0xCCFFF1B8);
    canvas.drawCircle(Offset(e.x, y - r * 0.95), r * 0.22, _fill);
    // 体と角
    _filled(canvas, body, (p) => canvas.drawCircle(Offset(e.x, y), r, p));
    for (final side in const [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(e.x + side * r * 0.35, y - r * 0.8)
        ..lineTo(e.x + side * r * 0.7, y - r * 1.35)
        ..lineTo(e.x + side * r * 0.7, y - r * 0.6)
        ..close();
      _filled(canvas, flash ? _white : const Color(0xFFF1E3C6),
          (p) => canvas.drawPath(horn, p));
    }
    _eyes(canvas, e.x, y - r * 0.05, r, toX, toY, spread: 0.32, size: 0.16);
    // にやりと笑う口と牙
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(e.x, y + r * 0.25), width: r * 0.9, height: r * 0.5),
        0.2,
        pi - 0.4,
        false,
        _outline);
  }

  /// 雪狼：走る四つ足。プレイヤーの方を向き、しっぽをなびかせる
  void wolf(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final dir = toX >= e.x ? 1.0 : -1.0;
    final run = time * 14 + e.y * 0.2;
    _shadowAt(canvas, e.x, e.y + r * 0.85, r * 2.4);
    final fur = flash ? _white : const Color(0xFFC9D4E0);
    final furDark = flash ? _white : const Color(0xFF8E9CB0);
    final bob = sin(run * 2).abs() * 1.5;
    final y = e.y - bob;
    // 脚（前後で交互に動く）
    for (final (lx, ph) in [(-0.6, 0.0), (-0.3, pi), (0.35, pi), (0.65, 0.0)]) {
      final sw = sin(run + ph) * r * 0.3;
      final x0 = e.x + dir * lx * r;
      final top = Offset(x0, y + r * 0.2),
          foot = Offset(x0 + dir * sw, e.y + r * 0.8);
      _line
        ..color = _ink
        ..strokeWidth = 4.6;
      canvas.drawLine(top, foot, _line);
      _line
        ..color = furDark
        ..strokeWidth = 2.8;
      canvas.drawLine(top, foot, _line);
    }
    // しっぽ
    final tail = Path()
      ..moveTo(e.x - dir * r * 0.8, y - r * 0.15)
      ..quadraticBezierTo(e.x - dir * r * 1.5, y - r * (0.5 + 0.2 * sin(run)),
          e.x - dir * r * 1.6, y - r * 0.9)
      ..quadraticBezierTo(
          e.x - dir * r * 1.2, y - r * 0.4, e.x - dir * r * 0.75, y + r * 0.1)
      ..close();
    _filled(canvas, fur, (p) => canvas.drawPath(tail, p));
    // 胴
    _filled(
        canvas,
        fur,
        (p) => canvas.drawOval(
            Rect.fromCenter(
                center: Offset(e.x, y), width: r * 2, height: r * 1.05),
            p));
    _fill.color = furDark;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(e.x - dir * r * 0.1, y - r * 0.32),
            width: r * 1.3,
            height: r * 0.3),
        _fill);
    // 頭・耳・鼻先
    final head = Offset(e.x + dir * r * 0.95, y - r * 0.45);
    for (final ex in const [-0.25, 0.2]) {
      final ear = Path()
        ..moveTo(head.dx + dir * (ex - 0.12) * r, head.dy - r * 0.3)
        ..lineTo(head.dx + dir * (ex + 0.05) * r, head.dy - r * 0.85)
        ..lineTo(head.dx + dir * (ex + 0.22) * r, head.dy - r * 0.3)
        ..close();
      _filled(canvas, furDark, (p) => canvas.drawPath(ear, p));
    }
    _filled(canvas, fur, (p) => canvas.drawCircle(head, r * 0.5, p));
    final snout = Path()
      ..moveTo(head.dx + dir * r * 0.25, head.dy - r * 0.15)
      ..lineTo(head.dx + dir * r * 0.85, head.dy + r * 0.05)
      ..lineTo(head.dx + dir * r * 0.25, head.dy + r * 0.3)
      ..close();
    _filled(canvas, fur, (p) => canvas.drawPath(snout, p));
    _fill.color = _ink;
    canvas.drawCircle(
        Offset(head.dx + dir * r * 0.82, head.dy + r * 0.04), r * 0.1, _fill);
    // 鋭い目
    _fill.color = const Color(0xFF5BC8FF);
    canvas.drawCircle(
        Offset(head.dx + dir * r * 0.18, head.dy - r * 0.1), r * 0.13, _fill);
    _fill.color = _ink;
    canvas.drawCircle(
        Offset(head.dx + dir * r * 0.22, head.dy - r * 0.1), r * 0.06, _fill);
  }

  /// 人食い草：葉の上の大きな花の口がぱくぱく開く。跳ねながら近づく
  void sprout(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final hop = sin(time * 6 + e.x * 0.05).abs() * 4;
    _shadowAt(canvas, e.x, e.y + r * 0.85, r * 2);
    final leaf = flash ? _white : const Color(0xFF3E8E4E);
    // 根元の葉
    for (final side in const [-1.0, 1.0]) {
      final p = Path()
        ..moveTo(e.x, e.y + r * 0.8)
        ..quadraticBezierTo(e.x + side * r * 1.4, e.y + r * 0.6,
            e.x + side * r * 1.3, e.y + r * 0.05)
        ..quadraticBezierTo(
            e.x + side * r * 0.6, e.y + r * 0.35, e.x, e.y + r * 0.8)
        ..close();
      _filled(canvas, leaf, (q) => canvas.drawPath(p, q));
    }
    final y = e.y - hop;
    // 茎
    _line
      ..color = _ink
      ..strokeWidth = 5;
    canvas.drawLine(
        Offset(e.x, e.y + r * 0.7), Offset(e.x, y - r * 0.1), _line);
    _line
      ..color = leaf
      ..strokeWidth = 3;
    canvas.drawLine(
        Offset(e.x, e.y + r * 0.7), Offset(e.x, y - r * 0.1), _line);
    // 花びら
    final petal = flash ? _white : const Color(0xFFF07AA0);
    for (var i = 0; i < 5; i++) {
      final a = -pi / 2 + i * 2 * pi / 5;
      _filled(
          canvas,
          petal,
          (q) => canvas.drawCircle(
              Offset(e.x + cos(a) * r * 0.62, y - r * 0.55 + sin(a) * r * 0.62),
              r * 0.48,
              q));
    }
    // 口（ぱくぱく開く）
    final open = 0.25 + 0.2 * (sin(time * 12 + e.y * 0.1) + 1) / 2;
    final mouth = Rect.fromCenter(
        center: Offset(e.x, y - r * 0.5),
        width: r * 0.95,
        height: r * open * 2);
    _filled(canvas, flash ? _white : const Color(0xFF5A1E2A),
        (q) => canvas.drawOval(mouth, q));
    _fill.color = _white;
    for (var i = 0; i < 3; i++) {
      final tx = mouth.left + mouth.width * (0.25 + i * 0.25);
      final tooth = Path()
        ..moveTo(tx - r * 0.09, mouth.top + 1)
        ..lineTo(tx, mouth.top + mouth.height * 0.45)
        ..lineTo(tx + r * 0.09, mouth.top + 1)
        ..close();
      canvas.drawPath(tooth, _fill);
    }
    // 小さな目
    _eyes(canvas, e.x, y - r * 1.25, r * 0.55, toX, toY,
        spread: 0.55, size: 0.22);
  }

  /// サソリ：はさみを振り上げ、しっぽの毒針を背中の上に構える
  void scorpion(Canvas canvas, Enemy e, double time, double toX, double toY) {
    _scorpionBody(canvas, e, time, toX >= e.x ? 1.0 : -1.0,
        shellColor: const Color(0xFFC77A2E),
        darkColor: const Color(0xFF8E5320),
        stingColor: const Color(0xFF5A1E2A));
  }

  /// サソリの王（ボス）：赤黒い甲羅に金の冠。毒針を構えると尾が前へ伸び、怒ると甲羅の割れ目が光る
  void scorpionKing(
      Canvas canvas, Enemy e, double time, double toX, double toY) {
    // 溜めや突進の間は、狙った向きを向く
    final aiming =
        e.bossState == BossState.windup || e.bossState == BossState.charge;
    final dir = aiming ? (e.dirX >= 0 ? 1.0 : -1.0) : (toX >= e.x ? 1.0 : -1.0);
    final wp = bossWindupProgress(e);
    final windup = e.bossState == BossState.windup;
    final shake = windup ? sin(time * 50) * (1 + wp) : 0.0;
    canvas.save();
    canvas.translate(shake, 0);
    _scorpionBody(canvas, e, time, dir,
        shellColor:
            e.enraged ? const Color(0xFFB0283A) : const Color(0xFF8E2A36),
        darkColor: const Color(0xFF4A1620),
        stingColor: const Color(0xFF9CFF6A),
        tailForward: e.attack == BossAttack.sting && windup ? wp : 0.0,
        king: true);
    canvas.restore();
  }

  void _scorpionBody(Canvas canvas, Enemy e, double time, double dir,
      {required Color shellColor,
      required Color darkColor,
      required Color stingColor,
      double tailForward = 0,
      bool king = false}) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final walk = time * (king ? 7 : 10) + e.y * 0.1;
    _shadowAt(canvas, e.x, e.y + r * 0.6, r * 2.4);
    final shell = flash ? _white : shellColor;
    final dark = flash ? _white : darkColor;
    // 脚
    final legs = king ? 4 : 3;
    for (var i = 0; i < legs; i++) {
      for (final side in const [-1.0, 1.0]) {
        final lx = e.x + dir * (i - (legs - 1) / 2) * r * 0.4;
        final sw = sin(walk + i * 2 + (side > 0 ? pi : 0)) * r * 0.15;
        final knee = Offset(lx + sw * 0.5, e.y + r * 0.05 + side * r * 0.45);
        _line
          ..color = _ink
          ..strokeWidth = king ? r * 0.16 : 2.6;
        canvas.drawLine(Offset(lx, e.y + r * 0.1), knee, _line);
        canvas.drawLine(
            knee, Offset(lx + sw, e.y + r * 0.1 + side * r * 0.6), _line);
        if (king) {
          _line
            ..color = dark
            ..strokeWidth = r * 0.09;
          canvas.drawLine(Offset(lx, e.y + r * 0.1), knee, _line);
          canvas.drawLine(
              knee, Offset(lx + sw, e.y + r * 0.1 + side * r * 0.6), _line);
        }
      }
    }
    // しっぽ（体の後ろから背中の上へ）。毒針を構えると、先が前へ伸びる
    final f = tailForward;
    final tipX = e.x + dir * r * (-0.2 + 1.3 * f);
    final tipY = e.y - r * (1.2 + 0.25 * f);
    final tail = Path()
      ..moveTo(e.x - dir * r * 0.7, e.y)
      ..quadraticBezierTo(e.x - dir * r * 1.6, e.y - r * 0.6,
          e.x - dir * r * (0.9 - 0.4 * f), e.y - r * (1.35 + 0.35 * f))
      ..quadraticBezierTo(e.x + dir * r * (-0.5 + 0.9 * f),
          e.y - r * (1.6 + 0.2 * f), tipX, tipY);
    _stroke(canvas, tail, shell, king ? r * 0.36 : 5);
    if (king) {
      // 尾の節
      _fill.color = dark;
      for (var k = 1; k <= 3; k++) {
        final t = k / 4;
        final m = _quadPoint(
            Offset(e.x - dir * r * 0.7, e.y),
            Offset(e.x - dir * r * 1.6, e.y - r * 0.6),
            Offset(
                e.x - dir * r * (0.9 - 0.4 * f), e.y - r * (1.35 + 0.35 * f)),
            t);
        canvas.drawCircle(m, r * 0.08, _fill);
      }
    }
    final sting = Path()
      ..moveTo(tipX - dir * r * 0.05, tipY - r * 0.15)
      ..lineTo(tipX + dir * r * 0.35, tipY + r * 0.1)
      ..lineTo(tipX - dir * r * 0.1, tipY + r * 0.2)
      ..close();
    if (king && !flash) {
      _fill.color = stingColor.withValues(alpha: 0.35 + 0.25 * sin(time * 8));
      canvas.drawCircle(Offset(tipX + dir * r * 0.1, tipY + r * 0.05),
          r * (0.35 + 0.25 * f), _fill);
    }
    _filled(
        canvas, flash ? _white : stingColor, (q) => canvas.drawPath(sting, q));
    // 胴
    _filled(
        canvas,
        shell,
        (q) => canvas.drawOval(
            Rect.fromCenter(
                center: Offset(e.x, e.y), width: r * 1.9, height: r * 1.0),
            q));
    for (var i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(e.x + i * r * 0.4, e.y - r * 0.45),
          Offset(e.x + i * r * 0.4, e.y + r * 0.4), _outline);
    }
    if (king) {
      // 甲羅のつやと、怒ると光る割れ目
      _fill.color = const Color(0x44FFFFFF);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(e.x - dir * r * 0.2, e.y - r * 0.25),
              width: r * 0.9,
              height: r * 0.22),
          _fill);
      if (e.enraged && !flash) {
        _line
          ..color = Color.fromRGBO(255, 160, 60, 0.6 + 0.3 * sin(time * 10))
          ..strokeWidth = r * 0.06;
        canvas.drawLine(Offset(e.x - r * 0.6, e.y - r * 0.1),
            Offset(e.x - r * 0.2, e.y + r * 0.2), _line);
        canvas.drawLine(Offset(e.x + r * 0.1, e.y - r * 0.3),
            Offset(e.x + r * 0.5, e.y + r * 0.05), _line);
      }
    }
    // はさみ
    final snap = sin(time * (king ? 5 : 8) + e.x * 0.1) * 0.25;
    for (final side in const [-1.0, 1.0]) {
      final base = Offset(e.x + dir * r * 0.9, e.y + side * r * 0.25);
      final claw = base + Offset(dir * r * 0.55, side * r * 0.25 - r * 0.15);
      _line
        ..color = _ink
        ..strokeWidth = king ? r * 0.22 : 4.5;
      canvas.drawLine(base, claw, _line);
      _line
        ..color = shell
        ..strokeWidth = king ? r * 0.13 : 2.6;
      canvas.drawLine(base, claw, _line);
      canvas.save();
      canvas.translate(claw.dx, claw.dy);
      canvas.rotate(dir > 0 ? snap * side : pi - snap * side);
      if (king) canvas.scale(1.3);
      final pincer = Path()
        ..moveTo(0, -r * 0.28)
        ..quadraticBezierTo(r * 0.55, -r * 0.3, r * 0.5, -r * 0.02)
        ..lineTo(r * 0.12, 0)
        ..lineTo(r * 0.5, r * 0.06)
        ..quadraticBezierTo(r * 0.5, r * 0.32, 0, r * 0.26)
        ..close();
      if (king) {
        _filledScaled(canvas, shell, 1.3, (q) => canvas.drawPath(pincer, q));
      } else {
        _filled(canvas, shell, (q) => canvas.drawPath(pincer, q));
      }
      canvas.restore();
    }
    // 目
    _fill.color = king && !flash ? const Color(0xFFFFD45E) : _ink;
    canvas.drawCircle(
        Offset(e.x + dir * r * 0.65, e.y - r * 0.2), r * 0.1, _fill);
    canvas.drawCircle(
        Offset(e.x + dir * r * 0.65, e.y + r * 0.08), r * 0.1, _fill);
    if (king) {
      // 金の冠
      final cx = e.x + dir * r * 0.45, cy = e.y - r * 0.45;
      final crown = Path()
        ..moveTo(cx - r * 0.35, cy)
        ..lineTo(cx - r * 0.4, cy - r * 0.35)
        ..lineTo(cx - r * 0.18, cy - r * 0.18)
        ..lineTo(cx, cy - r * 0.45)
        ..lineTo(cx + r * 0.18, cy - r * 0.18)
        ..lineTo(cx + r * 0.4, cy - r * 0.35)
        ..lineTo(cx + r * 0.35, cy)
        ..close();
      _filled(canvas, flash ? _white : const Color(0xFFFFD45E),
          (q) => canvas.drawPath(crown, q));
      _fill.color = const Color(0xFF5BA8E8);
      canvas.drawCircle(Offset(cx, cy - r * 0.12), r * 0.07, _fill);
    }
  }

  Offset _quadPoint(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }

  /// 大輪の人食い花（ボス）：根を張った巨大な花。トゲのつるに囲まれ、花の真ん中の口が開く。
  /// 地中を潜る間は土の盛り上がりだけが動く。怒ると花びらが紫に染まる
  void flowerQueen(
      Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    if (e.airborne) {
      // 土の中を進む：盛り上がった土と、のぞく葉先
      final wob = sin(time * 30) * 2;
      _filled(
          canvas,
          const Color(0xFF6B4A35),
          (q) => canvas.drawOval(
              Rect.fromCenter(
                  center: Offset(e.x + wob, e.y + r * 0.4),
                  width: r * 1.8,
                  height: r * 0.7),
              q));
      for (final dx in const [-0.4, 0.0, 0.4]) {
        final leaf = Path()
          ..moveTo(e.x + dx * r - r * 0.12, e.y + r * 0.2)
          ..lineTo(e.x + dx * r, e.y - r * 0.25)
          ..lineTo(e.x + dx * r + r * 0.12, e.y + r * 0.2)
          ..close();
        _filled(
            canvas, const Color(0xFF3E8E4E), (q) => canvas.drawPath(leaf, q));
      }
      return;
    }
    final wp = bossWindupProgress(e);
    final windup = e.bossState == BossState.windup;
    // 潜る前は沈み、種を撃つ前はのけぞる
    final sink = windup && e.attack == BossAttack.burrow ? wp : 0.0;
    final rear = windup && e.attack == BossAttack.seeds ? wp : 0.0;
    final sway = sin(time * 1.8) * r * 0.06;
    final base = Offset(e.x, e.y + r * 0.6);
    _shadowAt(canvas, e.x, base.dy + r * 0.1, r * 2.6);
    // 根元の穴
    _filled(
        canvas,
        flash ? _white : const Color(0xFF4A3426),
        (q) => canvas.drawOval(
            Rect.fromCenter(center: base, width: r * 2.0, height: r * 0.6), q));
    // トゲのつる（3本、ゆっくりうねる）
    final vine = flash ? _white : const Color(0xFF2F6B3A);
    for (var k = 0; k < 3; k++) {
      final side = k == 0 ? -1.0 : (k == 1 ? 1.0 : 0.3);
      final wave = sin(time * 2 + k * 2) * r * 0.15;
      final p = Path()
        ..moveTo(base.dx + side * r * 0.3, base.dy)
        ..cubicTo(
            base.dx + side * r * 1.5,
            base.dy - r * 0.3 + wave,
            base.dx + side * r * 1.3,
            base.dy - r * 1.4,
            base.dx + side * r * 0.6 + wave,
            base.dy - r * 1.9);
      _stroke(canvas, p, vine, r * 0.13);
      _fill.color = vine;
      for (var t = 0.2; t < 1; t += 0.2) {
        final pt = _cubicPoint(
            Offset(base.dx + side * r * 0.3, base.dy),
            Offset(base.dx + side * r * 1.5, base.dy - r * 0.3 + wave),
            Offset(base.dx + side * r * 1.3, base.dy - r * 1.4),
            Offset(base.dx + side * r * 0.6 + wave, base.dy - r * 1.9),
            t);
        final thorn = Path()
          ..moveTo(pt.dx - r * 0.06, pt.dy)
          ..lineTo(pt.dx + side * r * 0.16, pt.dy - r * 0.12)
          ..lineTo(pt.dx + r * 0.06, pt.dy + r * 0.04)
          ..close();
        _filled(canvas, vine, (q) => canvas.drawPath(thorn, q));
      }
    }
    // 根元の大きな葉
    final leafColor = flash ? _white : const Color(0xFF4E9A5A);
    for (final (ang, len) in const [
      (-2.7, 1.3),
      (-0.45, 1.3),
      (-2.3, 1.0),
      (-0.85, 1.0),
    ]) {
      final tip = base +
          Offset(cos(ang) * r * len, sin(ang) * r * len * 0.45 + r * 0.1);
      final leaf = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
            (base.dx + tip.dx) / 2, base.dy - r * 0.35, tip.dx, tip.dy)
        ..quadraticBezierTo(
            (base.dx + tip.dx) / 2, base.dy + r * 0.2, base.dx, base.dy)
        ..close();
      _filled(canvas, leafColor, (q) => canvas.drawPath(leaf, q));
    }
    canvas.save();
    // 沈むときは縦に縮む
    canvas.translate(base.dx, base.dy);
    canvas.scale(1, 1 - 0.8 * sink);
    canvas.translate(-base.dx, -base.dy);
    // 太い茎
    final head =
        Offset(e.x + sway - rear * r * 0.1, e.y - r * 0.75 - rear * r * 0.25);
    final stem = Path()
      ..moveTo(base.dx - r * 0.25, base.dy)
      ..quadraticBezierTo(e.x - r * 0.4, e.y, head.dx - r * 0.15, head.dy)
      ..lineTo(head.dx + r * 0.15, head.dy)
      ..quadraticBezierTo(e.x + r * 0.35, e.y, base.dx + r * 0.25, base.dy)
      ..close();
    _filled(canvas, flash ? _white : const Color(0xFF3E8E4E),
        (q) => canvas.drawPath(stem, q));
    // 茎の目（花の下でぎょろりと動く）
    _eyes(canvas, e.x, e.y + r * 0.05, r * 0.7, toX, toY,
        spread: 0.55, size: 0.24);
    // 花びら
    final petalColor = flash
        ? _white
        : e.enraged
            ? const Color(0xFFB06AD9)
            : const Color(0xFFF07AA0);
    final petalDark = flash
        ? _white
        : e.enraged
            ? const Color(0xFF7A3AA8)
            : const Color(0xFFD04A78);
    final bloom = 1 + 0.15 * rear + 0.04 * sin(time * 3);
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4 + time * 0.2;
      final c = head + Offset(cos(a), sin(a) * 0.8) * r * 0.62 * bloom;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a + pi / 2);
      _filled(
          canvas,
          i.isEven ? petalColor : petalDark,
          (q) => canvas.drawOval(
              Rect.fromCenter(
                  center: Offset.zero, width: r * 0.55, height: r * 0.8),
              q));
      canvas.restore();
    }
    // 真ん中の口（溜めると大きく開く）
    final open = 0.35 + 0.15 * sin(time * 4) + 0.4 * rear;
    _filled(canvas, flash ? _white : const Color(0xFFFFF1C8),
        (q) => canvas.drawCircle(head, r * 0.45, q));
    final mouth = Rect.fromCenter(
        center: head, width: r * 0.62, height: r * 0.62 * open + r * 0.08);
    _filled(canvas, flash ? _white : const Color(0xFF5A1E2A),
        (q) => canvas.drawOval(mouth, q));
    _fill.color = _white;
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final p0 = head + Offset(cos(a) * r * 0.3, sin(a) * r * 0.3 * open);
      final tooth = Path()
        ..moveTo(p0.dx - r * 0.05, p0.dy)
        ..lineTo(p0.dx - cos(a) * r * 0.12, p0.dy - sin(a) * r * 0.12 * open)
        ..lineTo(p0.dx + r * 0.05, p0.dy)
        ..close();
      canvas.drawPath(tooth, _fill);
    }
    canvas.restore();
  }

  Offset _cubicPoint(Offset a, Offset b, Offset c, Offset d, double t) {
    final u = 1 - t;
    return a * (u * u * u) +
        b * (3 * u * u * t) +
        c * (3 * u * t * t) +
        d * (t * t * t);
  }

  /// 魔王（ボス）：角の兜と紫のマント、闇の宝玉の杖。宙に浮いていて、
  /// 瞬間移動の前は薄れて消える。怒ると赤い炎のオーラをまとう
  void demonLord(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final wp = bossWindupProgress(e);
    final windup = e.bossState == BossState.windup;
    final hover = sin(time * 2.2) * r * 0.12;
    final dir = toX >= e.x ? 1.0 : -1.0;
    _shadowAt(canvas, e.x, e.y + r * 1.05, r * 1.8 * (1 - hover / r * 0.3));
    final fade =
        windup && e.attack == BossAttack.teleport ? 1 - wp * 0.85 : 1.0;
    final layered = fade < 1;
    if (layered) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, fade));
    }
    final y = e.y + hover - r * 0.2;
    // オーラ
    final auraColor =
        e.enraged ? const Color(0xFFFF4A3D) : const Color(0xFF9A6BD9);
    for (var i = 0; i < 3; i++) {
      final t = (time * 0.8 + i / 3) % 1;
      _fill.color = auraColor.withValues(alpha: 0.25 * (1 - t));
      canvas.drawCircle(Offset(e.x, y), r * (1.0 + 0.6 * t), _fill);
    }
    if (e.enraged && !flash) {
      for (var i = 0; i < 5; i++) {
        final t = (time * 1.4 + i / 5) % 1;
        final fx = e.x + (i - 2) * r * 0.35 + sin(t * 8 + i) * 3;
        _fill.color = Color.fromRGBO(255, 120, 60, 0.6 * (1 - t));
        canvas.drawCircle(
            Offset(fx, y + r * 0.6 - t * r * 1.8), r * (0.18 - 0.1 * t), _fill);
      }
    }
    // マント（裾が波打つ）
    final cape = Path()..moveTo(e.x - r * 0.45, y - r * 0.4);
    cape.quadraticBezierTo(
        e.x - r * 1.2, y + r * 0.3, e.x - r * 1.05, y + r * 1.1);
    for (var i = 0; i < 4; i++) {
      final x0 = e.x - r * 1.05 + (i + 1) * r * 0.525;
      cape.quadraticBezierTo(x0 - r * 0.26,
          y + r * (1.25 + 0.12 * sin(time * 5 + i)), x0, y + r * 1.1);
    }
    cape.quadraticBezierTo(
        e.x + r * 1.2, y + r * 0.3, e.x + r * 0.45, y - r * 0.4);
    cape.close();
    _filled(canvas, flash ? _white : const Color(0xFF3A2458),
        (q) => canvas.drawPath(cape, q));
    _fill.color = flash ? _white : const Color(0xFF8E2A36);
    canvas.drawPath(
        Path()
          ..moveTo(e.x - r * 0.35, y - r * 0.3)
          ..lineTo(e.x + r * 0.35, y - r * 0.3)
          ..lineTo(e.x + r * 0.25, y + r * 0.95)
          ..lineTo(e.x - r * 0.25, y + r * 0.95)
          ..close(),
        _fill);
    // 胸の鎧と金の飾り
    _filled(
        canvas,
        flash ? _white : const Color(0xFF2A2236),
        (q) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(e.x, y + r * 0.1),
                    width: r * 0.95,
                    height: r * 0.8),
                Radius.circular(r * 0.2)),
            q));
    _fill.color = flash ? _white : const Color(0xFFFFD45E);
    canvas.drawCircle(Offset(e.x, y + r * 0.1), r * 0.12, _fill);
    // 肩当て
    for (final s2 in const [-1.0, 1.0]) {
      final sh = Path()
        ..moveTo(e.x + s2 * r * 0.35, y - r * 0.35)
        ..lineTo(e.x + s2 * r * 0.85, y - r * 0.45)
        ..lineTo(e.x + s2 * r * 0.75, y - r * 0.05)
        ..close();
      _filled(canvas, flash ? _white : const Color(0xFF4E4A66),
          (q) => canvas.drawPath(sh, q));
    }
    // 頭：青白い顔に光る目、曲がった角と金の冠
    final head = Offset(e.x, y - r * 0.65);
    for (final s2 in const [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(head.dx + s2 * r * 0.25, head.dy - r * 0.2)
        ..quadraticBezierTo(head.dx + s2 * r * 0.9, head.dy - r * 0.3,
            head.dx + s2 * r * 0.75, head.dy - r * 0.95)
        ..quadraticBezierTo(head.dx + s2 * r * 0.6, head.dy - r * 0.45,
            head.dx + s2 * r * 0.15, head.dy - r * 0.38)
        ..close();
      _filled(canvas, flash ? _white : const Color(0xFF2A2236),
          (q) => canvas.drawPath(horn, q));
    }
    _filled(canvas, flash ? _white : const Color(0xFFC8C2DC),
        (q) => canvas.drawCircle(head, r * 0.36, q));
    final eye = e.enraged ? const Color(0xFFFF4A3D) : const Color(0xFFE05AFF);
    _fill.color = flash ? _white : eye.withValues(alpha: 0.4);
    canvas.drawCircle(head.translate(0, r * 0.02), r * 0.3, _fill);
    _fill.color = flash ? _white : eye;
    for (final s2 in const [-1.0, 1.0]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: head.translate(s2 * r * 0.14 + dir * r * 0.03, 0),
              width: r * 0.14,
              height: r * 0.08),
          _fill);
    }
    final crown = Path()
      ..moveTo(head.dx - r * 0.3, head.dy - r * 0.25)
      ..lineTo(head.dx - r * 0.32, head.dy - r * 0.55)
      ..lineTo(head.dx - r * 0.12, head.dy - r * 0.38)
      ..lineTo(head.dx, head.dy - r * 0.62)
      ..lineTo(head.dx + r * 0.12, head.dy - r * 0.38)
      ..lineTo(head.dx + r * 0.32, head.dy - r * 0.55)
      ..lineTo(head.dx + r * 0.3, head.dy - r * 0.25)
      ..close();
    _filled(canvas, flash ? _white : const Color(0xFFFFD45E),
        (q) => canvas.drawPath(crown, q));
    // 杖：大技の溜めでは高く掲げ、宝玉が強く光る
    final raise = windup && e.attack != BossAttack.teleport ? wp : 0.0;
    final hand = Offset(e.x + dir * r * 0.8, y - r * 0.05 - raise * r * 0.4);
    _line
      ..color = _ink
      ..strokeWidth = r * 0.16;
    canvas.drawLine(
        hand.translate(0, r * 0.9), hand.translate(0, -r * 0.7), _line);
    _line
      ..color = flash ? _white : const Color(0xFF5A3A28)
      ..strokeWidth = r * 0.09;
    canvas.drawLine(
        hand.translate(0, r * 0.9), hand.translate(0, -r * 0.7), _line);
    final orb = hand.translate(0, -r * 0.85);
    _fill.color = auraColor.withValues(alpha: 0.35 + 0.4 * raise);
    canvas.drawCircle(orb, r * (0.3 + 0.25 * raise), _fill);
    _filled(canvas, flash ? _white : const Color(0xFF7A3AD9),
        (q) => canvas.drawCircle(orb, r * 0.18, q));
    _fill.color = const Color(0xAAFFFFFF);
    canvas.drawCircle(orb.translate(-r * 0.05, -r * 0.05), r * 0.06, _fill);
    // 手
    _filled(canvas, flash ? _white : const Color(0xFFC8C2DC),
        (q) => canvas.drawCircle(hand, r * 0.13, q));
    if (layered) canvas.restore();
  }

  /// 中ボスが落とす小さな銀の宝箱
  void miniChest(Canvas canvas, double x, double y, double time) {
    final bob = sin(time * 4) * 1.2;
    _fill.color = Color.fromRGBO(200, 230, 255, 0.2 + 0.12 * sin(time * 6));
    canvas.drawCircle(Offset(x, y - 3 + bob), 15, _fill);
    _shadowAt(canvas, x, y + 7, 16);
    final box =
        Rect.fromCenter(center: Offset(x, y + bob), width: 16, height: 11);
    _filled(
        canvas,
        const Color(0xFF8E9CB0),
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(2.5)), p));
    _filled(
        canvas,
        const Color(0xFFB8C4D0),
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(box.left, box.top - 4, box.width, 6),
                const Radius.circular(3)),
            p));
    _fill.color = const Color(0xFF5BC8FF);
    canvas.drawRect(Rect.fromLTWH(x - 2, box.top - 1.5, 4, 5), _fill);
  }

  /// 黒騎士：重い鎧と盾。兜のすき間から赤い目が光る
  void knight(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final dir = toX >= e.x ? 1.0 : -1.0;
    final step = sin(time * 5 + e.x * 0.1);
    _shadowAt(canvas, e.x, e.y + r * 0.95, r * 1.9);
    final armor = flash ? _white : const Color(0xFF4E4A66);
    final steel = flash ? _white : const Color(0xFF7C78A0);
    // 脚
    for (final (sx, st) in [(-0.35, step), (0.35, -step)]) {
      _filled(
          canvas,
          armor,
          (q) => canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(e.x + sx * r - r * 0.2, e.y + r * 0.35 + st,
                      r * 0.4, r * 0.55),
                  Radius.circular(r * 0.1)),
              q));
    }
    // 剣（後ろの手）
    canvas.save();
    canvas.translate(e.x - dir * r * 0.75, e.y);
    canvas.rotate(dir * (0.5 + 0.1 * step));
    _filled(
        canvas,
        flash ? _white : const Color(0xFFDDE6EE),
        (q) => canvas.drawRect(
            Rect.fromLTWH(-r * 0.09, -r * 1.5, r * 0.18, r * 1.3), q));
    _filled(
        canvas,
        flash ? _white : const Color(0xFF8A5A2B),
        (q) => canvas.drawRect(
            Rect.fromLTWH(-r * 0.3, -r * 0.25, r * 0.6, r * 0.15), q));
    canvas.restore();
    // 胴
    _filled(
        canvas,
        armor,
        (q) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(e.x, e.y + r * 0.05),
                    width: r * 1.5,
                    height: r * 1.0),
                Radius.circular(r * 0.3)),
            q));
    _fill.color = steel;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(e.x, e.y + r * 0.05),
            width: r * 0.2,
            height: r * 0.8),
        _fill);
    // 兜と羽飾り
    final head = Offset(e.x, e.y - r * 0.65);
    final plume = Path()
      ..moveTo(head.dx, head.dy - r * 0.45)
      ..quadraticBezierTo(head.dx - dir * r * 0.9, head.dy - r * 1.2,
          head.dx - dir * r * 1.1, head.dy - r * 0.4)
      ..quadraticBezierTo(head.dx - dir * r * 0.5, head.dy - r * 0.7, head.dx,
          head.dy - r * 0.3)
      ..close();
    _filled(canvas, flash ? _white : const Color(0xFFB0303A),
        (q) => canvas.drawPath(plume, q));
    _filled(
        canvas,
        steel,
        (q) => canvas.drawRRect(
            RRect.fromRectAndCorners(
                Rect.fromCenter(center: head, width: r * 1.15, height: r * 1.0),
                topLeft: Radius.circular(r * 0.55),
                topRight: Radius.circular(r * 0.55),
                bottomLeft: Radius.circular(r * 0.15),
                bottomRight: Radius.circular(r * 0.15)),
            q));
    _fill.color = _ink;
    canvas.drawRect(
        Rect.fromCenter(
            center: head.translate(dir * r * 0.08, r * 0.02),
            width: r * 0.85,
            height: r * 0.18),
        _fill);
    _fill.color = flash ? _white : const Color(0xFFFF4A3D);
    canvas.drawCircle(
        head.translate(dir * r * 0.05 - r * 0.17, r * 0.02), r * 0.07, _fill);
    canvas.drawCircle(
        head.translate(dir * r * 0.05 + r * 0.17, r * 0.02), r * 0.07, _fill);
    // 盾（前の手）
    final shield = Path()
      ..moveTo(e.x + dir * r * 0.55, e.y - r * 0.35)
      ..lineTo(e.x + dir * r * 1.15, e.y - r * 0.35)
      ..lineTo(e.x + dir * r * 1.15, e.y + r * 0.2)
      ..quadraticBezierTo(e.x + dir * r * 1.1, e.y + r * 0.65,
          e.x + dir * r * 0.85, e.y + r * 0.75)
      ..quadraticBezierTo(e.x + dir * r * 0.6, e.y + r * 0.65,
          e.x + dir * r * 0.55, e.y + r * 0.2)
      ..close();
    _filled(canvas, flash ? _white : const Color(0xFF6A3A8E),
        (q) => canvas.drawPath(shield, q));
    _fill.color = flash ? _white : const Color(0xFFFFD45E);
    canvas.drawCircle(
        Offset(e.x + dir * r * 0.85, e.y + r * 0.1), r * 0.12, _fill);
  }

  void _stroke(Canvas canvas, Path path, Color color, double width) {
    _line
      ..style = PaintingStyle.stroke
      ..color = _ink
      ..strokeWidth = width + 2;
    canvas.drawPath(path, _line);
    _line
      ..color = color
      ..strokeWidth = width;
    canvas.drawPath(path, _line);
  }

  /// オーガ（ボス）：牙と角のある大男。トゲ付きの棍棒を持ち、大技ごとに構えが変わる。
  /// 怒ると赤くなり、頭から湯気が出る
  void ogre(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final windup = e.bossState == BossState.windup;
    final wp = bossWindupProgress(e);
    final shake = windup ? sin(time * 60) * (1 + wp * 1.5) : 0.0;
    final x = e.x + shake;
    final walking = e.bossState == BossState.walk;
    final step = walking ? sin(time * (e.enraged ? 8 : 6)) : 0.0;
    final breath = 1 + 0.035 * sin(time * 3);
    final smashed = e.attack == BossAttack.smash &&
        e.bossState == BossState.recover &&
        e.stateTime < 0.5;
    // 突進の溜めと突進中は前のめり
    final lean = e.attack == BossAttack.charge &&
            (windup || e.bossState == BossState.charge)
        ? 1.0
        : 0.0;
    final leanX = e.dirX * r * 0.15 * lean;
    _shadowAt(canvas, x, e.y + r * 0.95, r * 2.1);

    Color c(Color normal, Color angry) =>
        flash ? _white : (e.enraged ? angry : normal);
    final skin = flash
        ? _white
        : windup
            ? Color.lerp(c(const Color(0xFFB98A6B), const Color(0xFFC9705A)),
                const Color(0xFFE5484D), 0.35 * wp)!
            : c(const Color(0xFFB98A6B), const Color(0xFFC9705A));
    final skinDark = c(const Color(0xFF8E6650), const Color(0xFF9C4E3E));
    final club = flash ? _white : const Color(0xFF7A5230);

    // 足（太い脚と革のブーツ）
    for (final (sx, st) in [(-1.0, step), (1.0, -step)]) {
      final legX = x + sx * r * 0.33 - r * 0.18;
      _filled(
          canvas,
          skinDark,
          (p) => canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(
                      legX, e.y + r * 0.45 + st * 2, r * 0.36, r * 0.38),
                  Radius.circular(r * 0.12)),
              p));
      _filled(
          canvas,
          flash ? _white : const Color(0xFF4A3426),
          (p) => canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(legX - r * 0.04, e.y + r * 0.72 + st * 2,
                      r * 0.44, r * 0.22),
                  Radius.circular(r * 0.1)),
              p));
    }

    final side = toX >= x ? 1.0 : -1.0;
    final bodyC = Offset(x + leanX, e.y + r * 0.12);
    // 棍棒を持つ腕は、体の後ろ側から描き始める
    void arm(double sx, double angle) {
      canvas.save();
      canvas.translate(bodyC.dx + sx * r * 0.82, bodyC.dy - r * 0.2);
      canvas.rotate(angle);
      _filled(
          canvas,
          skin,
          (p) => canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(-r * 0.2, -r * 0.05, r * 0.4, r * 0.75),
                  Radius.circular(r * 0.2)),
              p));
      // 腕輪
      _filled(
          canvas,
          flash ? _white : const Color(0xFF6E7488),
          (p) => canvas.drawRect(
              Rect.fromLTWH(-r * 0.22, r * 0.38, r * 0.44, r * 0.12), p));
      canvas.restore();
    }

    // 棍棒の構え：地面叩きは振りかぶる、叩いた直後は地面に、普段は肩に
    final clubAngle = smashed
        ? side * -1.3
        : windup && e.attack == BossAttack.smash
            ? side * (-0.4 - 2.4 * wp)
            : windup
                ? side * -0.9
                : side * (-0.3 + 0.08 * step);
    // 体（胸と腹）
    canvas.save();
    canvas.translate(bodyC.dx, bodyC.dy);
    canvas.scale(1, breath);
    _filledScaled(
        canvas,
        skin,
        breath,
        (p) => canvas.drawOval(
            Rect.fromCenter(
                center: Offset.zero, width: r * 1.85, height: r * 1.35),
            p));
    // 胸の筋肉とおへそ
    _fill.color = skinDark;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-r * 0.3, -r * 0.25),
            width: r * 0.6,
            height: r * 0.3),
        _fill);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(r * 0.3, -r * 0.25),
            width: r * 0.6,
            height: r * 0.3),
        _fill);
    canvas.drawCircle(Offset(0, r * 0.12), r * 0.05, _fill);
    // 古傷
    _outline.strokeWidth = 1.6 / breath;
    canvas.drawLine(
        Offset(r * 0.15, -r * 0.45), Offset(r * 0.5, -r * 0.05), _outline);
    canvas.drawLine(
        Offset(r * 0.25, -r * 0.3), Offset(r * 0.4, -r * 0.33), _outline);
    _outline.strokeWidth = 1.6;
    canvas.restore();
    // 腰布とベルト
    final waist = bodyC.dy + r * 0.3;
    final cloth = Path()
      ..moveTo(bodyC.dx - r * 0.7, waist)
      ..lineTo(bodyC.dx + r * 0.7, waist)
      ..lineTo(bodyC.dx + r * 0.5, waist + r * 0.45)
      ..lineTo(bodyC.dx + r * 0.15, waist + r * 0.32)
      ..lineTo(bodyC.dx - r * 0.1, waist + r * 0.5)
      ..lineTo(bodyC.dx - r * 0.55, waist + r * 0.38)
      ..close();
    _filled(canvas, flash ? _white : const Color(0xFF6E5A2E),
        (p) => canvas.drawPath(cloth, p));
    _filled(
        canvas,
        flash ? _white : const Color(0xFF4A3426),
        (p) => canvas.drawRect(
            Rect.fromLTWH(
                bodyC.dx - r * 0.78, waist - r * 0.08, r * 1.56, r * 0.18),
            p));
    _filled(
        canvas,
        flash ? _white : const Color(0xFFFFD45E),
        (p) => canvas.drawRect(
            Rect.fromCenter(
                center: Offset(bodyC.dx, waist + r * 0.01),
                width: r * 0.26,
                height: r * 0.24),
            p));

    // 反対の腕：投石の溜めでは岩を頭上に持ち上げる
    final throwing = windup && e.attack == BossAttack.rocks;
    arm(-side, throwing ? side * (2.6 + 0.3 * wp) : side * 0.25);
    if (throwing) {
      final rockC = Offset(bodyC.dx - side * r * 0.7, bodyC.dy - r * 1.35);
      _filled(canvas, flash ? _white : const Color(0xFF7A6A55),
          (p) => canvas.drawCircle(rockC, r * 0.42, p));
      _fill.color = const Color(0xFF9C8B72);
      canvas.drawCircle(rockC.translate(-r * 0.12, -r * 0.12), r * 0.15, _fill);
    }
    // 棍棒の腕と、トゲ付きの棍棒
    arm(side, clubAngle);
    canvas.save();
    canvas.translate(bodyC.dx + side * r * 0.82, bodyC.dy - r * 0.2);
    canvas.rotate(clubAngle + pi);
    canvas.translate(0, -r * 0.6);
    _filled(
        canvas,
        club,
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(-r * 0.12, -r * 1.05, r * 0.24, r * 1.1),
                Radius.circular(r * 0.12)),
            p));
    final headC = Offset(0, -r * 1.1);
    _fill.color = flash ? _white : const Color(0xFFD9D4C7);
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3 + 0.3;
      final spike = Path()
        ..moveTo(headC.dx + cos(a - 0.25) * r * 0.3,
            headC.dy + sin(a - 0.25) * r * 0.3)
        ..lineTo(headC.dx + cos(a) * r * 0.55, headC.dy + sin(a) * r * 0.55)
        ..lineTo(headC.dx + cos(a + 0.25) * r * 0.3,
            headC.dy + sin(a + 0.25) * r * 0.3)
        ..close();
      canvas.drawPath(spike, _fill);
      canvas.drawPath(spike, _outline);
    }
    _filled(canvas, club, (p) => canvas.drawCircle(headC, r * 0.36, p));
    _fill.color = const Color(0xFF9C6B40);
    canvas.drawCircle(headC.translate(-r * 0.1, -r * 0.1), r * 0.12, _fill);
    canvas.restore();

    // 頭と角
    final head = Offset(x + leanX * 1.6, e.y - r * 0.6);
    _fill.color = flash ? _white : const Color(0xFFF1E3C6);
    for (final s2 in const [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(head.dx + s2 * r * 0.28, head.dy - r * 0.38)
        ..quadraticBezierTo(head.dx + s2 * r * 0.75, head.dy - r * 0.6,
            head.dx + s2 * r * 0.6, head.dy - r * 1.0)
        ..lineTo(head.dx + s2 * r * 0.08, head.dy - r * 0.48)
        ..close();
      canvas.drawPath(horn, _fill);
      canvas.drawPath(horn, _outline);
    }
    // 耳
    for (final s2 in const [-1.0, 1.0]) {
      _filled(
          canvas,
          skin,
          (p) => canvas.drawOval(
              Rect.fromCenter(
                  center: head.translate(s2 * r * 0.55, 0),
                  width: r * 0.22,
                  height: r * 0.32),
              p));
    }
    _filled(canvas, skin, (p) => canvas.drawCircle(head, r * 0.56, p));
    // 怒ると目が赤く光る
    if (e.enraged && !flash) {
      _fill.color = Color.fromRGBO(255, 80, 60, 0.35 + 0.2 * sin(time * 10));
      canvas.drawCircle(head.translate(0, -r * 0.05), r * 0.42, _fill);
    }
    _eyes(canvas, head.dx, head.dy - r * 0.05, r * 0.56, toX, toY,
        spread: 0.38, size: 0.2);
    // 太い眉
    _outline.strokeWidth = 2.6;
    canvas.drawLine(head.translate(-r * 0.38, -r * 0.32),
        head.translate(-r * 0.08, -r * 0.2), _outline);
    canvas.drawLine(head.translate(r * 0.38, -r * 0.32),
        head.translate(r * 0.08, -r * 0.2), _outline);
    _outline.strokeWidth = 1.6;
    // 口と下あごの牙。溜めの間は口を開けて吠える
    final mouthOpen = windup || e.bossState == BossState.charge;
    final mouth = head.translate(0, r * 0.28);
    if (mouthOpen) {
      _filled(
          canvas,
          flash ? _white : const Color(0xFF5A1E1E),
          (p) => canvas.drawOval(
              Rect.fromCenter(center: mouth, width: r * 0.5, height: r * 0.24),
              p));
    } else {
      canvas.drawLine(mouth.translate(-r * 0.22, 0),
          mouth.translate(r * 0.22, 0), _outline);
    }
    _fill.color = flash ? _white : const Color(0xFFFFFBEF);
    for (final s2 in const [-1.0, 1.0]) {
      final tusk = Path()
        ..moveTo(mouth.dx + s2 * r * 0.24, mouth.dy + r * 0.04)
        ..lineTo(mouth.dx + s2 * r * 0.3, mouth.dy - r * 0.22)
        ..lineTo(mouth.dx + s2 * r * 0.14, mouth.dy + r * 0.02)
        ..close();
      canvas.drawPath(tusk, _fill);
      canvas.drawPath(tusk, _outline);
    }
    // 怒っている間は頭から湯気
    if (e.enraged) {
      for (var i = 0; i < 3; i++) {
        final t = (time * 0.9 + i / 3) % 1;
        _fill.color = Color.fromRGBO(240, 240, 240, 0.55 * (1 - t));
        canvas.drawCircle(
            head.translate((i - 1) * r * 0.35 + sin(t * 6 + i) * 3,
                -r * 0.6 - t * r * 1.1),
            r * (0.12 + 0.18 * t),
            _fill);
      }
    }
  }

  /// キングスライム（ボス）：宝石の王冠をかぶった巨大スライム。
  /// 中に泡が浮かび、体からしずくが垂れる。跳んでいる間は浮き上がり、怒ると紫がかって目がつり上がる
  void kingSlime(Canvas canvas, Enemy e, double time, double toX, double toY) {
    final r = e.stats.radius;
    final flash = e.hitFlash > 0;
    final p = e.airProgress;
    final wp = bossWindupProgress(e);
    final windup = e.bossState == BossState.windup;
    final lift = e.airborne ? sin(p * pi) * 90 : 0.0;
    final squash = e.airborne
        ? -0.15
        : e.bossState == BossState.recover
            ? 0.25 * (1 - e.stateTime / kingSlimeRecoverTime)
            : windup && e.attack == BossAttack.spray
                // 弾を撒く前は、ためるように膨らんでからつぶれる
                ? -0.12 * wp + (wp > 0.85 ? 0.3 : 0)
                : windup && e.attack == BossAttack.summon
                    ? 0.1 * sin(time * 30)
                    : 0.06 * sin(time * 5);
    _shadowAt(canvas, e.x, e.y + r * 0.75, r * 2.2 * (1 - lift / 200));
    final w = r * 2 * (1 + squash), h = r * 1.7 * (1 - squash);
    final bottom = e.y + r * 0.75 - lift;
    final body = Rect.fromCenter(
        center: Offset(e.x, bottom - h / 2), width: w, height: h);
    final bodyColor = flash
        ? _white
        : e.enraged
            ? const Color(0xFF55A86E)
            : const Color(0xFF4FB86A);
    final shape = RRect.fromRectAndCorners(body,
        topLeft: Radius.elliptical(w / 2, h * 0.75),
        topRight: Radius.elliptical(w / 2, h * 0.75),
        bottomLeft: Radius.elliptical(w * 0.3, h * 0.25),
        bottomRight: Radius.elliptical(w * 0.3, h * 0.25));
    // 垂れるしずく（体の後ろに描いて、根元を体で隠す）
    if (!e.airborne) {
      for (var i = 0; i < 3; i++) {
        final t = (time * 0.6 + i * 0.37) % 1;
        final dx = e.x + (i - 1) * w * 0.32;
        final len = r * (0.15 + 0.35 * t);
        _filled(
            canvas,
            bodyColor,
            (pt) => canvas.drawOval(
                Rect.fromCenter(
                    center: Offset(dx, bottom - r * 0.05 + len / 2),
                    width: r * 0.22,
                    height: len),
                pt));
      }
    }
    _filled(canvas, bodyColor, (pt) => canvas.drawRRect(shape, pt));
    // 体の中の泡と、飲み込んだ剣
    canvas.save();
    canvas.clipRRect(shape);
    if (!flash) {
      _fill.color =
          e.enraged ? const Color(0x55B38BE8) : const Color(0x332F7A45);
      canvas.drawOval(
          Rect.fromLTWH(body.left, body.top + h * 0.55, w, h * 0.6), _fill);
      canvas.save();
      canvas.translate(e.x + r * 0.35, body.top + h * 0.72);
      canvas.rotate(0.9);
      _fill.color = const Color(0x667A8090);
      canvas.drawRect(
          Rect.fromLTWH(-r * 0.05, -r * 0.4, r * 0.1, r * 0.6), _fill);
      canvas.drawRect(
          Rect.fromLTWH(-r * 0.16, r * 0.18, r * 0.32, r * 0.07), _fill);
      canvas.restore();
      for (var i = 0; i < 5; i++) {
        final t = (time * 0.35 + i * 0.21) % 1;
        final bx = e.x + sin(i * 2.3 + time) * w * 0.3;
        final by = body.bottom - t * h * 0.9;
        _fill.color = Color.fromRGBO(255, 255, 255, 0.35 * (1 - t));
        canvas.drawCircle(Offset(bx, by), r * (0.06 + 0.05 * (i % 3)), _fill);
      }
    }
    canvas.restore();
    // つや
    _fill.color = const Color(0x77FFFFFF);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(e.x - r * 0.45, body.top + h * 0.25),
            width: r * 0.55,
            height: r * 0.3),
        _fill);
    _fill.color = const Color(0x55FFFFFF);
    canvas.drawCircle(
        Offset(e.x - r * 0.15, body.top + h * 0.17), r * 0.07, _fill);
    // 顔
    final eyeY = body.top + h * 0.48;
    _eyes(canvas, e.x, eyeY, r, toX, toY, spread: 0.3, size: 0.14);
    if (e.enraged) {
      // つり上がった眉
      _outline.strokeWidth = 2.6;
      canvas.drawLine(Offset(e.x - r * 0.52, eyeY - r * 0.36),
          Offset(e.x - r * 0.12, eyeY - r * 0.2), _outline);
      canvas.drawLine(Offset(e.x + r * 0.52, eyeY - r * 0.36),
          Offset(e.x + r * 0.12, eyeY - r * 0.2), _outline);
      _outline.strokeWidth = 1.6;
    }
    final mouthY = eyeY + r * 0.33;
    if (e.enraged || windup) {
      // 大きく開いた口
      _filled(
          canvas,
          const Color(0xFF2F5E3A),
          (pt) => canvas.drawOval(
              Rect.fromCenter(
                  center: Offset(e.x, mouthY),
                  width: r * 0.45,
                  height: r * (0.2 + 0.12 * wp)),
              pt));
    } else {
      canvas.drawArc(
          Rect.fromCenter(
              center: Offset(e.x, mouthY - r * 0.08),
              width: r * 0.4,
              height: r * 0.22),
          0.3,
          pi - 0.6,
          false,
          _outline);
    }
    _fill.color = const Color(0x55F28B82);
    canvas.drawCircle(Offset(e.x - r * 0.62, eyeY + r * 0.22), r * 0.13, _fill);
    canvas.drawCircle(Offset(e.x + r * 0.62, eyeY + r * 0.22), r * 0.13, _fill);
    // 王冠（帯と宝石つき）。跳ぶと少し遅れて浮く
    final cy = body.top + 3 - (e.airborne ? 4 * sin(p * pi) : 0);
    final tilt = 0.08 * sin(time * 2.5);
    canvas.save();
    canvas.translate(e.x, cy);
    canvas.rotate(tilt);
    final crown = Path()
      ..moveTo(-r * 0.48, 0)
      ..lineTo(-r * 0.56, -r * 0.5)
      ..lineTo(-r * 0.26, -r * 0.24)
      ..lineTo(0, -r * 0.62)
      ..lineTo(r * 0.26, -r * 0.24)
      ..lineTo(r * 0.56, -r * 0.5)
      ..lineTo(r * 0.48, 0)
      ..close();
    _fill.color = flash ? _white : const Color(0xFFFFD45E);
    canvas.drawPath(crown, _fill);
    canvas.drawPath(crown, _outline);
    _filled(
        canvas,
        flash ? _white : const Color(0xFFE0A93A),
        (pt) => canvas.drawRect(
            Rect.fromLTWH(-r * 0.5, -r * 0.14, r * 1.0, r * 0.16), pt));
    // 先の玉
    _fill.color = flash ? _white : const Color(0xFFFFF1B8);
    for (final tip in [
      Offset(-r * 0.56, -r * 0.5),
      Offset(0, -r * 0.62),
      Offset(r * 0.56, -r * 0.5),
    ]) {
      canvas.drawCircle(tip, r * 0.07, _fill);
    }
    // 宝石：真ん中は赤、両脇は青
    const gems = [Color(0xFF5BA8E8), Color(0xFFE5484D), Color(0xFF5BA8E8)];
    for (var i = 0; i < 3; i++) {
      final gx = (i - 1) * r * 0.3;
      _filled(
          canvas,
          flash ? _white : gems[i],
          (pt) => canvas.drawCircle(
              Offset(gx, -r * 0.06), r * (i == 1 ? 0.1 : 0.07), pt));
    }
    // きらめき
    final sparkle = (sin(time * 3) + 1) / 2;
    _fill.color = Color.fromRGBO(255, 255, 255, 0.9 * sparkle);
    canvas.drawCircle(Offset(-r * 0.03, -r * 0.1), r * 0.035, _fill);
    canvas.restore();
  }

  /// ボスを倒すと出る宝箱。ふわふわ光る
  void chest(Canvas canvas, double x, double y, double time) {
    final bob = sin(time * 4) * 1.5;
    _fill.color = Color.fromRGBO(255, 212, 94, 0.25 + 0.15 * sin(time * 6));
    canvas.drawCircle(Offset(x, y - 4 + bob), 20, _fill);
    _shadowAt(canvas, x, y + 9, 22);
    final box =
        Rect.fromCenter(center: Offset(x, y + bob), width: 22, height: 15);
    _filled(
        canvas,
        const Color(0xFF9C5B2E),
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(3)), p));
    _filled(
        canvas,
        const Color(0xFFB8733F),
        (p) => canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(box.left, box.top - 5, box.width, 8),
                const Radius.circular(4)),
            p));
    _fill.color = const Color(0xFFFFD45E);
    canvas.drawRect(Rect.fromLTWH(x - 2.5, box.top - 2, 5, 7), _fill);
    canvas.drawRect(Rect.fromLTWH(x - 2.5, box.top - 2, 5, 7), _outline);
  }
}
