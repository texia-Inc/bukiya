import 'package:bukiya_game/features/survivor/domain/run_simulation.dart';
import 'package:bukiya_game/features/survivor/game/enemy_atlas.dart';
import 'package:bukiya_game/features/survivor/game/sprites.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ボス以外の敵はすべてアトラスに入っている（新しい敵の入れ忘れを防ぐ）', () {
    for (final kind in EnemyKind.values) {
      expect(EnemyAtlas.supports(kind), !enemyStats[kind]!.boss,
          reason: kind.name);
    }
  });

  test('アトラスを作ると、どの敵・どの時刻のコマも画像の中にある', () async {
    final atlas = EnemyAtlas();
    await atlas.build(Sprites());
    final image = atlas.image!;
    for (final kind in EnemyKind.values.where(EnemyAtlas.supports)) {
      final e = Enemy(kind, 0, 0, 1);
      for (var t = 0.0; t < 3; t += 0.13) {
        for (final px in [-50.0, 50.0]) {
          final f = atlas.frameOf(e, t, px);
          expect(f.dx, greaterThanOrEqualTo(0));
          expect(f.dy, greaterThanOrEqualTo(0));
          expect(f.dx + EnemyAtlas.cellW * EnemyAtlas.res,
              lessThanOrEqualTo(image.width + 0.5));
          expect(f.dy + EnemyAtlas.cellH * EnemyAtlas.res,
              lessThanOrEqualTo(image.height + 0.5));
        }
      }
    }
  });

  test('まとめ描きは、溜めた数が増えても受け付ける', () {
    final batch = AtlasBatch();
    for (var i = 0; i < 1000; i++) {
      batch.add(Offset.zero, i.toDouble(), 0, 1, i.isEven);
    }
    expect(batch.length, 1000);
  });
}
