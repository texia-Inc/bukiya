import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'sfx_backend.dart';

SfxBackend createSfxBackend() => _PoolSfxBackend();

void unlockSfx() {}

/// ネイティブ向け：flame_audio のプールで同時に鳴らす
class _PoolSfxBackend implements SfxBackend {
  final Map<String, AudioPool> _pools = {};

  @override
  Future<void> load(String path, {required int maxPlayers}) async {
    _pools[path] = await FlameAudio.createPool(path, maxPlayers: maxPlayers);
  }

  @override
  void play(String path, double volume) {
    _pools[path]?.start(volume: volume).catchError((Object e) {
      debugPrint('効果音 $path を再生できませんでした: $e');
      return () async {};
    });
  }

  @override
  Future<void> dispose() async {
    for (final p in _pools.values) {
      await p.dispose();
    }
    _pools.clear();
  }
}
