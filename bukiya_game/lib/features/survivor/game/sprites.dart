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
