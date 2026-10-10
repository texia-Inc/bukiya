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
}
