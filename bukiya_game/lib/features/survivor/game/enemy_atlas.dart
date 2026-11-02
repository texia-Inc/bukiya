import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import '../domain/run_simulation.dart';
import 'sprites.dart';

/// 雑魚敵の絵を、起動時に1枚の画像（アトラス）へ描きためておく。
/// 毎フレーム図形を描く代わりに、この画像から切り抜いて全員分を一度に貼るので、
/// 敵が何百体いても軽い（ボスは数が少ないので、これまでどおり図形で描く）
class EnemyAtlas {
  /// 1コマの大きさ（ワールド座標）と、その中で足元となる点
  static const double cellW = 60;
  static const double cellH = 56;
  static const double pivotX = 30;
  static const double pivotY = 30;

  /// 画像の解像度（ワールド座標1あたりのピクセル数）
  static const double res = 2.5;

  static const int _columns = 16;

  /// 敵ごとのアニメーションの1周の秒数とコマ数。動きの一番目立つ揺れに合わせてある
  static const Map<EnemyKind, (double, int)> _loops = {
    EnemyKind.slime: (2 * pi / 8, 8),
    EnemyKind.bat: (4 * 2 * pi / 22, 16),
    EnemyKind.goblin: (2 * pi / 9, 8),
    EnemyKind.skeleton: (2 * pi / 7, 8),
    EnemyKind.ghost: (2 * 2 * pi / 9, 12),
    EnemyKind.imp: (2 * pi / 7, 16),
    EnemyKind.wolf: (2 * pi / 14, 8),
    EnemyKind.sprout: (2 * pi / 6, 8),
    EnemyKind.scorpion: (2 * pi / 10, 8),
    EnemyKind.knight: (2 * pi / 5, 8),
  };

  static bool supports(EnemyKind kind) => _loops.containsKey(kind);

  Image? image;

  /// (敵, 向き 0=左 1=右) ごとの、コマの切り抜き位置（ピクセル）の左上
  final Map<(EnemyKind, int), List<Offset>> _frames = {};

  bool get ready => image != null;

  Future<void> build(Sprites sprites) async {
    final cells = <(EnemyKind, int, int)>[];
    for (final entry in _loops.entries) {
      for (var dir = 0; dir < 2; dir++) {
        for (var f = 0; f < entry.value.$2; f++) {
          cells.add((entry.key, dir, f));
        }
      }
    }
    final rows = (cells.length / _columns).ceil();
    final w = (_columns * cellW * res).ceil(), h = (rows * cellH * res).ceil();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(res);
    for (var i = 0; i < cells.length; i++) {
      final (kind, dir, f) = cells[i];
      final (period, count) = _loops[kind]!;
      final ox = (i % _columns) * cellW, oy = (i ~/ _columns) * cellH;
      (_frames[(kind, dir)] ??= List.filled(count, Offset.zero))[f] =
          Offset(ox * res, oy * res);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(ox, oy, cellW, cellH));
      canvas.translate(ox + pivotX, oy + pivotY);
      final e = Enemy(kind, 0, 0, 1);
      final t = f * period / count;
      // プレイヤーのいる方を見る（左か右）
      final toX = dir == 0 ? -100.0 : 100.0;
      _draw(sprites, canvas, e, t, toX, 30);
      canvas.restore();
    }
    image = await recorder.endRecording().toImage(w, h);
  }

  void _draw(Sprites s, Canvas c, Enemy e, double t, double toX, double toY) {
    switch (e.kind) {
      case EnemyKind.slime:
        s.slime(c, e, t, toX, toY);
      case EnemyKind.bat:
        s.bat(c, e, t, toX, toY);
      case EnemyKind.goblin:
        s.goblin(c, e, t, toX, toY);
      case EnemyKind.skeleton:
        s.skeleton(c, e, t, toX, toY);
      case EnemyKind.ghost:
        s.ghost(c, e, t, toX, toY);
      case EnemyKind.imp:
        s.imp(c, e, t, toX, toY);
      case EnemyKind.wolf:
        s.wolf(c, e, t, toX, toY);
      case EnemyKind.sprout:
        s.sprout(c, e, t, toX, toY);
      case EnemyKind.scorpion:
        s.scorpion(c, e, t, toX, toY);
      case EnemyKind.knight:
        s.knight(c, e, t, toX, toY);
      case EnemyKind.ogre || EnemyKind.kingSlime:
        break;
    }
  }

  /// その敵の今のコマの切り抜き位置。敵ごとに動きの始まりをずらす
  Offset frameOf(Enemy e, double time, double playerX) {
    final (period, count) = _loops[e.kind]!;
    final phase = (identityHashCode(e) % 997) / 997;
    final f = ((time / period + phase) * count).floor() % count;
    return _frames[(e.kind, playerX >= e.x ? 1 : 0)]![f];
  }
}

/// アトラスから切り抜いた絵を溜めておき、まとめて1回で描く
class AtlasBatch {
  Float32List _transforms = Float32List(4 * 256);
  Float32List _rects = Float32List(4 * 256);
  Int32List _colors = Int32List(256);
  int length = 0;

  final Paint _paint = Paint()..filterQuality = FilterQuality.low;

  /// (x, y) に足元が来るよう、[scale] 倍で置く。[flash] なら白く光らせる
  void add(Offset frame, double x, double y, double scale, bool flash) {
    if (length == _colors.length) _grow();
    final s = scale / EnemyAtlas.res;
    final i = length * 4;
    _transforms[i] = s;
    _transforms[i + 1] = 0;
    _transforms[i + 2] = x - EnemyAtlas.pivotX * scale;
    _transforms[i + 3] = y - EnemyAtlas.pivotY * scale;
    _rects[i] = frame.dx;
    _rects[i + 1] = frame.dy;
    _rects[i + 2] = frame.dx + EnemyAtlas.cellW * EnemyAtlas.res;
    _rects[i + 3] = frame.dy + EnemyAtlas.cellH * EnemyAtlas.res;
    // 当たった瞬間は白く塗る（透明の色なら元の絵のまま）
    _colors[length] = flash ? 0xE6FFFFFF : 0x00000000;
    length++;
  }

  void _grow() {
    final n = _colors.length * 2;
    _transforms = Float32List(4 * n)..setRange(0, length * 4, _transforms);
    _rects = Float32List(4 * n)..setRange(0, length * 4, _rects);
    _colors = Int32List(n)..setRange(0, length, _colors);
  }

  void flush(Canvas canvas, Image image) {
    if (length == 0) return;
    canvas.drawRawAtlas(
      image,
      Float32List.sublistView(_transforms, 0, length * 4),
      Float32List.sublistView(_rects, 0, length * 4),
      Int32List.sublistView(_colors, 0, length),
      // 色（dst）は絵の形（src の不透明な部分）にだけ乗る
      BlendMode.dstATop,
      null,
      _paint,
    );
    length = 0;
  }
}
