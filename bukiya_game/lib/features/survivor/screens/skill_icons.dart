import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/loadout.dart';
import '../domain/skills.dart';
import 'menu_painters.dart';

const _ink = Color(0xFF1E1A16);

Paint _outline([double w = 2]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeJoin = StrokeJoin.round
  ..strokeCap = StrokeCap.round
  ..color = _ink;

/// スキルの効果を表す、右下の小さな記号
enum _Mark { longer, stronger, faster, more, pierce, wider, none }

_Mark _markOf(SkillId id) => switch (id) {
      SkillId.bladeLength || SkillId.spearReach => _Mark.longer,
      SkillId.swordPower || SkillId.staffPower => _Mark.stronger,
      SkillId.swordSpeed ||
      SkillId.bowSpeed ||
      SkillId.spearSpeed ||
      SkillId.staffSpeed =>
        _Mark.faster,
      SkillId.arrowCount || SkillId.spearMulti => _Mark.more,
      SkillId.arrowPierce => _Mark.pierce,
      SkillId.staffRadius => _Mark.wider,
      _ => _Mark.none,
    };

/// スキルの分類ごとの地の色
Color skillColor(SkillId id) {
  if (isEvolution(id)) return const Color(0xFFB8862B);
  if (id == SkillId.potion) return const Color(0xFFA54F7F);
  return switch (skillDefs[id]!.requires) {
    CarriedWeaponType.sword => const Color(0xFF4A6FA5),
    CarriedWeaponType.bow => const Color(0xFF3E7A4A),
    CarriedWeaponType.spear => const Color(0xFFA5682E),
    CarriedWeaponType.staff => const Color(0xFFA53E3E),
    null => const Color(0xFF6A4FA5),
  };
}

/// スキルのアイコン：分類の色の丸い札に、武器（または効果）の絵と、効果の記号
class SkillIconPainter extends CustomPainter {
  final SkillId id;

  SkillIconPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final evo = isEvolution(id);
    // 札
    final badge = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s).deflate(s * 0.04), Radius.circular(s * 0.24));
    canvas.drawRRect(badge, Paint()..color = skillColor(id));
    canvas.drawRRect(
        badge.deflate(s * 0.08),
        Paint()
          ..color = const Color(0x22FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.05);
    if (evo) {
      // 進化は光の筋
      final rays = Paint()..color = const Color(0x55FFF1B8);
      for (var i = 0; i < 8; i++) {
        final a = i * pi / 4;
        final path = Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(
              c.dx + cos(a - 0.15) * s * 0.5, c.dy + sin(a - 0.15) * s * 0.5)
          ..lineTo(
              c.dx + cos(a + 0.15) * s * 0.5, c.dy + sin(a + 0.15) * s * 0.5)
          ..close();
        canvas.drawPath(path, rays);
      }
    }
    canvas.drawRRect(badge, _outline(s * 0.05));

    // 絵
    final weapon = skillDefs[id]!.requires;
    canvas.save();
    canvas.clipRRect(badge);
    if (weapon != null) {
      final inner = s * (evo ? 0.8 : 0.72);
      canvas.translate((s - inner) / 2 - s * 0.04, (s - inner) / 2 - s * 0.04);
      WeaponIconPainter(weapon).paint(canvas, Size(inner, inner));
    } else {
      _common(canvas, s);
    }
    canvas.restore();

    if (evo) _star(canvas, Offset(s * 0.78, s * 0.22), s * 0.15);
    _mark(canvas, _markOf(id), Offset(s * 0.76, s * 0.76), s * 0.2);
  }

  void _common(Canvas canvas, double s) {
    final c = Offset(s / 2, s / 2);
    switch (id) {
      case SkillId.vitality:
        final r = s * 0.17;
        final heart = Path()
          ..moveTo(c.dx, c.dy + r * 1.7)
          ..cubicTo(c.dx - r * 3, c.dy, c.dx - r * 1.6, c.dy - r * 2.2, c.dx,
              c.dy - r * 0.8)
          ..cubicTo(c.dx + r * 1.6, c.dy - r * 2.2, c.dx + r * 3, c.dy, c.dx,
              c.dy + r * 1.7)
          ..close();
        canvas.drawPath(heart, Paint()..color = const Color(0xFFFF6B6B));
        canvas.drawPath(heart, _outline(s * 0.045));
        canvas.drawCircle(c.translate(-r * 0.8, -r * 0.7), r * 0.3,
            Paint()..color = const Color(0x99FFFFFF));
      case SkillId.magnet:
        final rect = Rect.fromCenter(
            center: c.translate(0, -s * 0.02), width: s * 0.5, height: s * 0.5);
        final body = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.14
          ..color = const Color(0xFFE5484D);
        canvas.drawArc(rect, 0, pi, false, _outline(s * 0.2));
        canvas.drawArc(rect, 0, pi, false, body);
        for (final dx in [-s * 0.25, s * 0.25]) {
          final tip = Rect.fromCenter(
              center: Offset(c.dx + dx, c.dy - s * 0.12),
              width: s * 0.14,
              height: s * 0.2);
          canvas.drawRect(tip, Paint()..color = const Color(0xFFDDE6EE));
          canvas.drawRect(tip, _outline(s * 0.035));
        }
      case SkillId.moveSpeed:
        // 羽のついた靴
        final boot = Path()
          ..moveTo(c.dx - s * 0.12, c.dy - s * 0.25)
          ..lineTo(c.dx + s * 0.06, c.dy - s * 0.25)
          ..lineTo(c.dx + s * 0.06, c.dy + s * 0.05)
          ..lineTo(c.dx + s * 0.26, c.dy + s * 0.12)
          ..lineTo(c.dx + s * 0.26, c.dy + s * 0.22)
          ..lineTo(c.dx - s * 0.12, c.dy + s * 0.22)
          ..close();
        canvas.drawPath(boot, Paint()..color = const Color(0xFF8A5A2B));
        canvas.drawPath(boot, _outline(s * 0.04));
        final wing = Path()
          ..moveTo(c.dx - s * 0.12, c.dy - s * 0.12)
          ..lineTo(c.dx - s * 0.38, c.dy - s * 0.26)
          ..lineTo(c.dx - s * 0.3, c.dy - s * 0.1)
          ..lineTo(c.dx - s * 0.36, c.dy - s * 0.04)
          ..lineTo(c.dx - s * 0.12, c.dy + s * 0.0)
          ..close();
        canvas.drawPath(wing, Paint()..color = Colors.white);
        canvas.drawPath(wing, _outline(s * 0.035));
      case SkillId.wisdom:
        // 開いた本
        for (final side in [-1.0, 1.0]) {
          final page = Path()
            ..moveTo(c.dx, c.dy - s * 0.16)
            ..quadraticBezierTo(c.dx + side * s * 0.15, c.dy - s * 0.24,
                c.dx + side * s * 0.32, c.dy - s * 0.18)
            ..lineTo(c.dx + side * s * 0.32, c.dy + s * 0.2)
            ..quadraticBezierTo(
                c.dx + side * s * 0.15, c.dy + s * 0.14, c.dx, c.dy + s * 0.22)
            ..close();
          canvas.drawPath(page, Paint()..color = const Color(0xFFF4EBD0));
          canvas.drawPath(page, _outline(s * 0.04));
          for (var i = 0; i < 3; i++) {
            final y = c.dy - s * 0.08 + i * s * 0.08;
            canvas.drawLine(Offset(c.dx + side * s * 0.08, y),
                Offset(c.dx + side * s * 0.25, y), _outline(s * 0.02));
          }
        }
        canvas.drawCircle(Offset(c.dx, c.dy - s * 0.3), s * 0.07,
            Paint()..color = const Color(0xFF5EC8FF));
      case SkillId.potion:
        final flask = Path()
          ..moveTo(c.dx - s * 0.07, c.dy - s * 0.3)
          ..lineTo(c.dx + s * 0.07, c.dy - s * 0.3)
          ..lineTo(c.dx + s * 0.07, c.dy - s * 0.12)
          ..quadraticBezierTo(
              c.dx + s * 0.3, c.dy, c.dx + s * 0.22, c.dy + s * 0.22)
          ..lineTo(c.dx - s * 0.22, c.dy + s * 0.22)
          ..quadraticBezierTo(
              c.dx - s * 0.3, c.dy, c.dx - s * 0.07, c.dy - s * 0.12)
          ..close();
        canvas.drawPath(flask, Paint()..color = const Color(0xFFE8F3FF));
        canvas.save();
        canvas.clipPath(flask);
        canvas.drawRect(Rect.fromLTWH(0, c.dy - s * 0.02, s, s),
            Paint()..color = const Color(0xFFFF6B9A));
        canvas.restore();
        canvas.drawPath(flask, _outline(s * 0.045));
      default:
        break;
    }
  }

  void _star(Canvas canvas, Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final rr = i.isEven ? r : r * 0.45;
      final p = Offset(c.dx + cos(a) * rr, c.dy + sin(a) * rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD45E));
    canvas.drawPath(path, _outline(r * 0.2));
  }

  void _mark(Canvas canvas, _Mark mark, Offset c, double r) {
    if (mark == _Mark.none) return;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFF7E6));
    canvas.drawCircle(c, r, _outline(r * 0.18));
    final line = _outline(r * 0.22);
    switch (mark) {
      case _Mark.longer:
        // 斜めの両矢印
        final a = c.translate(-r * 0.5, r * 0.5),
            b = c.translate(r * 0.5, -r * 0.5);
        canvas.drawLine(a, b, line);
        canvas.drawLine(b, b.translate(-r * 0.45, 0), line);
        canvas.drawLine(b, b.translate(0, r * 0.45), line);
        canvas.drawLine(a, a.translate(r * 0.45, 0), line);
        canvas.drawLine(a, a.translate(0, -r * 0.45), line);
      case _Mark.stronger:
        final up = Path()
          ..moveTo(c.dx, c.dy - r * 0.65)
          ..lineTo(c.dx + r * 0.55, c.dy)
          ..lineTo(c.dx + r * 0.22, c.dy)
          ..lineTo(c.dx + r * 0.22, c.dy + r * 0.6)
          ..lineTo(c.dx - r * 0.22, c.dy + r * 0.6)
          ..lineTo(c.dx - r * 0.22, c.dy)
          ..lineTo(c.dx - r * 0.55, c.dy)
          ..close();
        canvas.drawPath(up, Paint()..color = const Color(0xFFE5484D));
        canvas.drawPath(up, _outline(r * 0.12));
      case _Mark.faster:
        final bolt = Path()
          ..moveTo(c.dx + r * 0.15, c.dy - r * 0.7)
          ..lineTo(c.dx - r * 0.4, c.dy + r * 0.1)
          ..lineTo(c.dx, c.dy + r * 0.1)
          ..lineTo(c.dx - r * 0.15, c.dy + r * 0.7)
          ..lineTo(c.dx + r * 0.4, c.dy - r * 0.1)
          ..lineTo(c.dx, c.dy - r * 0.1)
          ..close();
        canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFC233));
        canvas.drawPath(bolt, _outline(r * 0.12));
      case _Mark.more:
        canvas.drawLine(
            c.translate(-r * 0.5, 0), c.translate(r * 0.5, 0), line);
        canvas.drawLine(
            c.translate(0, -r * 0.5), c.translate(0, r * 0.5), line);
      case _Mark.pierce:
        canvas.drawCircle(c, r * 0.35, _outline(r * 0.16));
        canvas.drawLine(c.translate(-r * 0.7, r * 0.35),
            c.translate(r * 0.7, -r * 0.35), line);
      case _Mark.wider:
        for (var i = 0; i < 4; i++) {
          final a = i * pi / 2 + pi / 4;
          final from = c + Offset(cos(a), sin(a)) * r * 0.2;
          final to = c + Offset(cos(a), sin(a)) * r * 0.62;
          canvas.drawLine(from, to, line);
        }
        canvas.drawCircle(c, r * 0.12, Paint()..color = _ink);
      case _Mark.none:
        break;
    }
  }

  @override
  bool shouldRepaint(SkillIconPainter old) => old.id != id;
}

/// スキルのアイコン。[level] を渡すと右上にレベルを出す
class SkillIcon extends StatelessWidget {
  final SkillId id;
  final double size;
  final int? level;
  final bool maxed;

  const SkillIcon(this.id,
      {super.key, this.size = 44, this.level, this.maxed = false});

  @override
  Widget build(BuildContext context) {
    final lv = level;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: SkillIconPainter(id))),
          if (lv != null)
            Positioned(
              right: -size * 0.1,
              top: -size * 0.1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size * 0.08),
                constraints: BoxConstraints(minWidth: size * 0.42),
                decoration: BoxDecoration(
                  color:
                      maxed ? const Color(0xFFFFD45E) : const Color(0xFF1E1A16),
                  borderRadius: BorderRadius.circular(size),
                  border: Border.all(color: const Color(0xFFEDE6D6), width: 1),
                ),
                child: Text(maxed ? 'MAX' : '$lv',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: size * (maxed ? 0.22 : 0.28),
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                        color: maxed ? const Color(0xFF1E1A16) : Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
