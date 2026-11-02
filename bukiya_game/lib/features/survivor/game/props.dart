import 'dart:math';
import 'dart:ui';

/// 地面に置く、高さのある小物（茂み・切り株・墓石・岩など）。
/// 当たり判定はなく、キャラの手前や奥に重なって奥行きを見せるためだけに置く
enum PropKind {
  bush,
  stump,
  tombstone,
  cross,
  boulder,
  shrub,
  lavaRock,
  pine,
  iceCrystal,
}

class Prop {
  final PropKind kind;
  final double x;
  final double y;

  /// 大きさや向きのばらつき（0〜1）
  final double v;

  const Prop(this.kind, this.x, this.y, this.v);
}

/// ステージごとに置く小物の種類
List<PropKind> propKindsFor(String stageId) => switch (stageId) {
      'graveyard' => const [PropKind.tombstone, PropKind.cross, PropKind.shrub],
      'canyon' => const [PropKind.boulder, PropKind.shrub],
      'volcano' => const [PropKind.lavaRock, PropKind.lavaRock, PropKind.shrub],
      'snowfield' => const [PropKind.pine, PropKind.iceCrystal, PropKind.pine],
      _ => const [PropKind.bush, PropKind.stump, PropKind.bush],
    };

/// 小物の絵。どれも根元を (x, y) にして、上へ伸びるように描く
class PropPainter {
  final Paint _fill = Paint();
  final Paint _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0xFF1A1A1A);
  final Paint _shadow = Paint()..color = const Color(0x40000000);

  void _both(void Function(Paint p) draw, Color color) {
    _fill.color = color;
    draw(_fill);
    draw(_outline);
  }

  void paint(Canvas canvas, Prop p) {
    final x = p.x, y = p.y, s = 0.85 + 0.35 * p.v;
    canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 30 * s, height: 9 * s),
        _shadow);
    switch (p.kind) {
      case PropKind.bush:
        for (final (dx, dy, r) in const [
          (-7.0, -7.0, 8.0),
          (7.0, -7.0, 8.0),
          (0.0, -12.0, 9.5),
        ]) {
          _both(
              (q) =>
                  canvas.drawCircle(Offset(x + dx * s, y + dy * s), r * s, q),
              const Color(0xFF3E7A4A));
        }
        _fill.color = const Color(0xFF3E7A4A);
        canvas.drawRect(
            Rect.fromLTWH(x - 9 * s, y - 9 * s, 18 * s, 7 * s), _fill);
        _fill.color = const Color(0x66A8E0A0);
        canvas.drawCircle(Offset(x - 3 * s, y - 16 * s), 3 * s, _fill);
        if (p.v > 0.6) {
          _fill.color = const Color(0xFFE5484D);
          canvas.drawCircle(Offset(x + 5 * s, y - 10 * s), 1.8, _fill);
          canvas.drawCircle(Offset(x - 6 * s, y - 6 * s), 1.8, _fill);
        }
      case PropKind.stump:
        final w = 16 * s, h = 10 * s;
        _both((q) => canvas.drawRect(Rect.fromLTWH(x - w / 2, y - h, w, h), q),
            const Color(0xFF7A5230));
        _both(
            (q) => canvas.drawOval(
                Rect.fromCenter(
                    center: Offset(x, y - h), width: w, height: w * 0.45),
                q),
            const Color(0xFFC79A62));
        _outline.strokeWidth = 1;
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(x, y - h), width: w * 0.5, height: w * 0.2),
            _outline);
        _outline.strokeWidth = 1.6;
      case PropKind.tombstone:
        final w = 16 * s, h = 22 * s;
        final stone = RRect.fromRectAndCorners(
            Rect.fromLTWH(x - w / 2, y - h, w, h),
            topLeft: Radius.circular(w / 2),
            topRight: Radius.circular(w / 2));
        _both((q) => canvas.drawRRect(stone, q), const Color(0xFF8E94A6));
        _fill.color = const Color(0xFF6E7488);
        canvas.drawRect(Rect.fromLTWH(x - 1, y - h * 0.75, 2, h * 0.45), _fill);
        canvas.drawRect(Rect.fromLTWH(x - 4, y - h * 0.62, 8, 2), _fill);
        _both(
            (q) => canvas.drawOval(
                Rect.fromCenter(
                    center: Offset(x, y), width: w * 1.5, height: 6 * s),
                q),
            const Color(0xFF4A4436));
      case PropKind.cross:
        final h = 20 * s;
        _both((q) => canvas.drawRect(Rect.fromLTWH(x - 2, y - h, 4, h), q),
            const Color(0xFF7A5A3A));
        _both(
            (q) => canvas.drawRect(
                Rect.fromLTWH(x - 7 * s, y - h * 0.75, 14 * s, 4), q),
            const Color(0xFF7A5A3A));
      case PropKind.boulder:
        final path = Path()
          ..moveTo(x - 13 * s, y)
          ..lineTo(x - 14 * s, y - 8 * s)
          ..lineTo(x - 7 * s, y - 16 * s)
          ..lineTo(x + 5 * s, y - 17 * s)
          ..lineTo(x + 13 * s, y - 9 * s)
          ..lineTo(x + 12 * s, y)
          ..close();
        _both((q) => canvas.drawPath(path, q), const Color(0xFF9C8B72));
        _fill.color = const Color(0xFF7A6A55);
        canvas.drawRect(
            Rect.fromLTWH(x - 12 * s, y - 5 * s, 24 * s, 4 * s), _fill);
        _fill.color = const Color(0xFFBBA98C);
        canvas.drawCircle(Offset(x - 4 * s, y - 12 * s), 3 * s, _fill);
      case PropKind.lavaRock:
        final path = Path()
          ..moveTo(x - 12 * s, y)
          ..lineTo(x - 11 * s, y - 10 * s)
          ..lineTo(x - 3 * s, y - 15 * s)
          ..lineTo(x + 8 * s, y - 12 * s)
          ..lineTo(x + 12 * s, y)
          ..close();
        _both((q) => canvas.drawPath(path, q), const Color(0xFF3A3030));
        // 溶岩が光る割れ目
        _outline
          ..color = const Color(0xFFFFA24D)
          ..strokeWidth = 2.4;
        canvas.drawLine(Offset(x - 6 * s, y - 2 * s),
            Offset(x - 2 * s, y - 9 * s), _outline);
        canvas.drawLine(Offset(x - 2 * s, y - 9 * s),
            Offset(x + 5 * s, y - 7 * s), _outline);
        _outline
          ..color = const Color(0xFF1A1A1A)
          ..strokeWidth = 1.6;
      case PropKind.pine:
        _both(
            (q) => canvas.drawRect(
                Rect.fromLTWH(x - 2.5 * s, y - 7 * s, 5 * s, 7 * s), q),
            const Color(0xFF6B4A35));
        for (var i = 0; i < 3; i++) {
          final by = y - 5 * s - i * 8 * s, hw = (13 - i * 3.5) * s;
          final tier = Path()
            ..moveTo(x - hw, by)
            ..lineTo(x, by - 13 * s)
            ..lineTo(x + hw, by)
            ..close();
          _both((q) => canvas.drawPath(tier, q), const Color(0xFF2F6B55));
          // 枝に積もった雪
          _fill.color = const Color(0xFFF2F6FA);
          canvas.drawOval(
              Rect.fromCenter(
                  center: Offset(x - hw * 0.2, by - 2 * s),
                  width: hw * 1.1,
                  height: 3.5 * s),
              _fill);
        }
        _fill.color = const Color(0xFFF2F6FA);
        canvas.drawCircle(Offset(x, y - 34 * s), 2.5 * s, _fill);
      case PropKind.iceCrystal:
        for (final (dx, h, w) in const [
          (-5.0, 12.0, 5.0),
          (4.0, 18.0, 6.0),
          (0.0, 9.0, 4.0),
        ]) {
          final shard = Path()
            ..moveTo(x + (dx - w) * s, y)
            ..lineTo(x + dx * s, y - h * s)
            ..lineTo(x + (dx + w) * s, y)
            ..close();
          _both((q) => canvas.drawPath(shard, q), const Color(0xCCA8DCF5));
        }
        canvas.drawLine(
            Offset(x + 3 * s, y - 3 * s),
            Offset(x + 4 * s, y - 14 * s),
            _outline..color = const Color(0xBBFFFFFF));
        _outline.color = const Color(0xFF1A1A1A);
      case PropKind.shrub:
        _outline.strokeWidth = 2.2;
        _outline.color = const Color(0xFF6B5A3A);
        for (var i = 0; i < 5; i++) {
          final a = -pi / 2 + (i - 2) * 0.35;
          final len = (10 + (i.isEven ? 4 : 0)) * s;
          canvas.drawLine(Offset(x, y),
              Offset(x + cos(a) * len, y + sin(a) * len), _outline);
        }
        _outline
          ..strokeWidth = 1.6
          ..color = const Color(0xFF1A1A1A);
    }
  }
}
