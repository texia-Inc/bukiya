import 'sfx_backend_pool.dart'
    if (dart.library.js_interop) 'sfx_backend_web.dart' as impl;

/// 効果音を実際に鳴らす部分。
/// Web では HTML の audio 要素だと iPhone で再生のたびに重くカクつくため、
/// Web Audio API で鳴らす。それ以外は flame_audio のプールで鳴らす。
abstract class SfxBackend {
  /// [path] は assets/audio/ からの相対パス
  Future<void> load(String path, {required int maxPlayers});

  void play(String path, double volume);

  Future<void> dispose();

  static SfxBackend create() => impl.createSfxBackend();

  /// ブラウザは操作をきっかけにしないと音を出せないので、タップなどの直後に呼ぶ
  static void unlock() => impl.unlockSfx();
}
