import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

enum Sfx {
  swing,
  hit,
  kill,
  bow,
  gem,
  material,
  hurt,
  levelup,
  evolve,
  gate,
  returned,
  died,
}

/// 効果音の再生。頻繁に鳴る音はプールで同時に鳴らし、間隔を空けて鳴りすぎを防ぐ
class SurvivorAudio {
  /// ミュート設定はランをまたいで保つ
  static final ValueNotifier<bool> muted = ValueNotifier(false);

  static const Map<Sfx, int> _maxPlayers = {
    Sfx.hit: 4,
    Sfx.kill: 4,
    Sfx.gem: 3,
    Sfx.swing: 2,
    Sfx.bow: 2,
  };

  /// 同じ音を続けて鳴らすときの最短間隔（秒）
  static const Map<Sfx, double> _minInterval = {
    Sfx.hit: 0.05,
    Sfx.kill: 0.06,
    Sfx.gem: 0.05,
    Sfx.material: 0.1,
  };

  static const Map<Sfx, double> _volume = {
    Sfx.hit: 0.5,
    Sfx.kill: 0.6,
    Sfx.gem: 0.4,
    Sfx.swing: 0.5,
    Sfx.bow: 0.5,
  };

  final Map<Sfx, AudioPool> _pools = {};
  final Map<Sfx, double> _lastPlayed = {};
  double _clock = 0;

  Future<void> load() async {
    await Future.wait(Sfx.values.map((s) async {
      try {
        _pools[s] = await FlameAudio.createPool(
          'survivor/${s.name}.wav',
          maxPlayers: _maxPlayers[s] ?? 1,
        );
      } catch (e) {
        // 音が鳴らなくてもゲームは続ける
        debugPrint('効果音 ${s.name} を読み込めませんでした: $e');
      }
    }));
  }

  void tick(double dt) => _clock += dt;

  void play(Sfx s) {
    if (muted.value) return;
    final pool = _pools[s];
    if (pool == null) return;
    final last = _lastPlayed[s];
    if (last != null && _clock - last < (_minInterval[s] ?? 0)) return;
    _lastPlayed[s] = _clock;
    pool.start(volume: _volume[s] ?? 0.8).catchError((Object e) {
      debugPrint('効果音 ${s.name} を再生できませんでした: $e');
      return () async {};
    });
  }

  Future<void> dispose() async {
    for (final p in _pools.values) {
      await p.dispose();
    }
    _pools.clear();
  }
}
