import 'dart:math';

import 'package:flutter/material.dart';

import '../domain/loadout.dart';
import '../domain/run_result.dart';
import '../domain/run_simulation.dart';
import '../domain/stage.dart';
import '../game/sprites.dart';

const _ink = Color(0xFF1E1A16);

Paint _outline([double w = 2]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeJoin = StrokeJoin.round
  ..color = _ink;

/// 店主の顔（左上のアイコン）
class ShopkeeperFacePainter extends CustomPainter {
  final Sprites _sprites = Sprites();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // ゲーム内の店主を拡大して、頭のあたりを切り取って見せる
    final s = size.width / 26;
    canvas.translate(size.width / 2, size.height * 0.62);
    canvas.scale(s);
    _sprites.shopkeeper(canvas,
        x: 0,
        y: 8,
        facingX: 0,
        facingY: 1,
        moving: false,
        walkDistance: 0,
        time: 0);
    canvas.restore();
  }

  @override
  bool shouldRepaint(ShopkeeperFacePainter old) => false;
}

/// ステージの絵：浮島の上に、そのステージの最後のボスが立っている
class StageArtPainter extends CustomPainter {
  final StageDef stage;
  final double time;
  final bool locked;
  final Sprites _sprites = Sprites();

  StageArtPainter(this.stage, this.time, {this.locked = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final island = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.42, w * 0.84, h * 0.42),
        Radius.circular(w * 0.06));
    // 島の側面（土）
    final side = island.shift(Offset(0, h * 0.06));
    canvas.drawRRect(side, Paint()..color = const Color(0xFF6B4A35));
    canvas.drawRRect(side, _outline(3));
    // 島の上面（地面の色）
    canvas.drawRRect(island, Paint()..color = Color(stage.tileColor));
    canvas.drawRRect(
        island.deflate(w * 0.02), Paint()..color = Color(stage.grassColor));
    canvas.drawRRect(island, _outline(3));

    final rnd = Random(stage.number * 7);
    if (stage.id == 'graveyard') {
      _moon(canvas, Offset(w * 0.82, h * 0.16), w * 0.07);
      for (var i = 0; i < 4; i++) {
        _tombstone(
            canvas,
            Offset(w * (0.17 + i * 0.2) + rnd.nextDouble() * 10,
                h * (0.55 + rnd.nextDouble() * 0.06)),
            w * 0.05);
      }
      _deadTree(canvas, Offset(w * 0.2, h * 0.5), w * 0.12);
    } else {
      for (final p in [
        Offset(w * 0.18, h * 0.5),
        Offset(w * 0.3, h * 0.46),
        Offset(w * 0.8, h * 0.5),
      ]) {
        _tree(canvas, p, w * 0.08);
      }
      // 店の看板
      _signboard(canvas, Offset(w * 0.72, h * 0.62), w * 0.07);
    }

    // ボスを島の真ん中に
    final bossKind = stage.mascot;
    final e = Enemy(bossKind, 0, 0, 1);
    canvas.save();
    canvas.translate(w * 0.5, h * 0.6);
    final s = w / 150;
    canvas.scale(s);
    switch (bossKind) {
      case EnemyKind.kingSlime:
        _sprites.kingSlime(canvas, e, time, 0, 400);
      case EnemyKind.ogre:
        _sprites.ogre(canvas, e, time, 0, 400);
      default:
        break;
    }
    canvas.restore();

    if (locked) {
      canvas.drawRRect(
          island.inflate(4), Paint()..color = const Color(0xAA000000));
    }
  }

  void _tree(Canvas canvas, Offset base, double r) {
    canvas.drawRect(
        Rect.fromCenter(
            center: base.translate(0, r * 0.3), width: r * 0.35, height: r),
        Paint()..color = const Color(0xFF7A5230));
    for (final o in [
      Offset(0, -r * 0.6),
      Offset(-r * 0.4, -r * 0.2),
      Offset(r * 0.4, -r * 0.2)
    ]) {
      canvas.drawCircle(
          base + o, r * 0.55, Paint()..color = const Color(0xFF3E8E4E));
      canvas.drawCircle(base + o, r * 0.55, _outline(2.5));
    }
    canvas.drawCircle(base.translate(0, -r * 0.6), r * 0.42,
        Paint()..color = const Color(0xFF4FA860));
  }

  void _signboard(Canvas canvas, Offset base, double r) {
    canvas.drawRect(Rect.fromLTWH(base.dx - r * 0.08, base.dy - r, r * 0.16, r),
        Paint()..color = const Color(0xFF7A5230));
    final board = Rect.fromCenter(
        center: base.translate(0, -r), width: r * 1.6, height: r * 0.8);
    canvas.drawRect(board, Paint()..color = const Color(0xFFE8C07A));
    canvas.drawRect(board, _outline(2));
    // 剣のマーク
    canvas.drawLine(board.center.translate(-r * 0.4, r * 0.2),
        board.center.translate(r * 0.4, -r * 0.2), _outline(2.5));
  }

  void _tombstone(Canvas canvas, Offset base, double r) {
    final rect = Rect.fromCenter(center: base, width: r * 1.4, height: r * 1.8);
    final stone = RRect.fromRectAndCorners(rect,
        topLeft: Radius.circular(r * 0.7), topRight: Radius.circular(r * 0.7));
    canvas.drawRRect(stone, Paint()..color = const Color(0xFF9AA0B4));
    canvas.drawRRect(stone, _outline(2));
    canvas.drawLine(
        base.translate(0, -r * 0.5), base.translate(0, r * 0.2), _outline(2));
    canvas.drawLine(base.translate(-r * 0.3, -r * 0.2),
        base.translate(r * 0.3, -r * 0.2), _outline(2));
  }

  void _deadTree(Canvas canvas, Offset base, double r) {
    final p = Paint()
      ..color = const Color(0xFF4A3A30)
      ..strokeWidth = r * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base.translate(0, -r * 1.2), p);
    canvas.drawLine(
        base.translate(0, -r * 0.7), base.translate(-r * 0.5, -r * 1.1), p);
    canvas.drawLine(
        base.translate(0, -r * 0.9), base.translate(r * 0.45, -r * 1.4), p);
  }

  void _moon(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r * 1.6, Paint()..color = const Color(0x33FFF4C8));
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFF1B8));
    canvas.drawCircle(c, r, _outline(2));
  }

  @override
  bool shouldRepaint(StageArtPainter old) =>
      old.stage != stage || old.time != time || old.locked != locked;
}

/// 武器のアイコン
class WeaponIconPainter extends CustomPainter {
  final CarriedWeaponType type;

  WeaponIconPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(-pi / 4);
    final steel = Paint()..color = const Color(0xFFDDE6EE);
    final wood = Paint()..color = const Color(0xFF8A5A2B);
    switch (type) {
      case CarriedWeaponType.sword:
        final blade = RRect.fromRectAndRadius(
            Rect.fromLTWH(-s * 0.08, -s * 0.42, s * 0.16, s * 0.6),
            Radius.circular(s * 0.08));
        canvas.drawRRect(blade, steel);
        canvas.drawRRect(blade, _outline());
        final guard = Rect.fromLTWH(-s * 0.2, s * 0.17, s * 0.4, s * 0.07);
        canvas.drawRect(guard, wood);
        canvas.drawRect(guard, _outline());
        final grip = Rect.fromLTWH(-s * 0.05, s * 0.24, s * 0.1, s * 0.18);
        canvas.drawRect(grip, wood);
        canvas.drawRect(grip, _outline());
      case CarriedWeaponType.bow:
        canvas.rotate(pi / 4);
        final arc = Rect.fromCenter(
            center: Offset(-s * 0.05, 0), width: s * 0.5, height: s * 0.8);
        canvas.drawArc(arc, -pi / 2, pi, false, _outline(6));
        canvas.drawArc(
            arc,
            -pi / 2,
            pi,
            false,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5
              ..color = const Color(0xFF9C6B3F));
        canvas.drawLine(
            Offset(-s * 0.05, -s * 0.4),
            Offset(-s * 0.05, s * 0.4),
            Paint()
              ..color = const Color(0xFFE8E0C8)
              ..strokeWidth = 1.5);
      case CarriedWeaponType.spear:
        final shaft = Rect.fromLTWH(-s * 0.04, -s * 0.25, s * 0.08, s * 0.7);
        canvas.drawRect(shaft, wood);
        canvas.drawRect(shaft, _outline());
        final tip = Path()
          ..moveTo(0, -s * 0.47)
          ..lineTo(s * 0.11, -s * 0.24)
          ..lineTo(-s * 0.11, -s * 0.24)
          ..close();
        canvas.drawPath(tip, steel);
        canvas.drawPath(tip, _outline());
      case CarriedWeaponType.staff:
        final shaft = Rect.fromLTWH(-s * 0.045, -s * 0.2, s * 0.09, s * 0.62);
        canvas.drawRect(shaft, Paint()..color = const Color(0xFF7A4E2A));
        canvas.drawRect(shaft, _outline());
        canvas.drawCircle(Offset(0, -s * 0.3), s * 0.2,
            Paint()..color = const Color(0x55FF8A3D));
        canvas.drawCircle(Offset(0, -s * 0.3), s * 0.12,
            Paint()..color = const Color(0xFFFF6A2B));
        canvas.drawCircle(Offset(0, -s * 0.3), s * 0.12, _outline());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WeaponIconPainter old) => old.type != type;
}

/// 素材のアイコン
class MaterialIconPainter extends CustomPainter {
  final MaterialKind kind;

  MaterialIconPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    void diamond(double r, Color color) {
      final p = Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r * 0.7, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r * 0.7, c.dy)
        ..close();
      canvas.drawPath(p, Paint()..color = color);
      canvas.drawPath(p, _outline());
    }

    switch (kind) {
      case MaterialKind.ironOre:
        final r = Rect.fromCenter(center: c, width: s * 0.6, height: s * 0.5);
        canvas.drawRect(r, Paint()..color = const Color(0xFFA7B1B8));
        canvas.drawRect(r, _outline());
      case MaterialKind.fang:
        final p = Path()
          ..moveTo(c.dx - s * 0.25, c.dy - s * 0.25)
          ..lineTo(c.dx + s * 0.25, c.dy - s * 0.25)
          ..lineTo(c.dx, c.dy + s * 0.35)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFFF4EBD0));
        canvas.drawPath(p, _outline());
      case MaterialKind.manaStone:
        canvas.drawCircle(
            c, s * 0.42, Paint()..color = const Color(0x55C77DFF));
        diamond(s * 0.35, const Color(0xFFC77DFF));
      case MaterialKind.bone:
        final p = Paint()..color = const Color(0xFFEDE6D6);
        final bar = RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: s * 0.6, height: s * 0.18),
            Radius.circular(s * 0.09));
        canvas.drawRRect(bar, p);
        canvas.drawRRect(bar, _outline());
        for (final dx in [-s * 0.3, s * 0.3]) {
          for (final dy in [-s * 0.1, s * 0.1]) {
            canvas.drawCircle(c.translate(dx, dy), s * 0.11, p);
          }
        }
      case MaterialKind.bossCore:
        canvas.drawCircle(
            c, s * 0.45, Paint()..color = const Color(0x66FF6B6B));
        diamond(s * 0.4, const Color(0xFFFF6B6B));
    }
  }

  @override
  bool shouldRepaint(MaterialIconPainter old) => old.kind != kind;
}

/// お金のアイコン（金貨）
class CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    canvas.drawCircle(c, s * 0.42, Paint()..color = const Color(0xFFFFC93C));
    canvas.drawCircle(c, s * 0.42, _outline());
    canvas.drawCircle(c, s * 0.26, Paint()..color = const Color(0xFFFFE08A));
    canvas.drawCircle(
        c,
        s * 0.26,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFFC98A1E));
  }

  @override
  bool shouldRepaint(CoinPainter old) => false;
}
