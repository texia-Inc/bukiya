import 'package:flutter/foundation.dart';

import 'sfx_backend.dart';

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
  thrust,
  cast,
  blast,
  boss,
  slam,
  chest,
}

/// 効果音の再生。同じ音は間隔を空けて鳴りすぎを防ぐ。実際の再生は [SfxBackend] に任せる
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
    Sfx.hit: 0.08,
    Sfx.kill: 0.08,
    Sfx.gem: 0.07,
    Sfx.material: 0.1,
    Sfx.blast: 0.08,
    Sfx.thrust: 0.06,
  };

  static const Map<Sfx, double> _volume = {
    Sfx.hit: 0.5,
    Sfx.kill: 0.6,
    Sfx.gem: 0.4,
    Sfx.swing: 0.5,
    Sfx.bow: 0.5,
    Sfx.thrust: 0.5,
    Sfx.cast: 0.45,
    Sfx.blast: 0.5,
  };

  final SfxBackend _backend = SfxBackend.create();
  final Set<Sfx> _loaded = {};
  final Map<Sfx, double> _lastPlayed = {};
  double _clock = 0;

  Future<void> load() async {
    await Future.wait(Sfx.values.map((s) async {
      try {
        await _backend.load(_path(s), maxPlayers: _maxPlayers[s] ?? 1);
        _loaded.add(s);
      } catch (e) {
        // 音が鳴らなくてもゲームは続ける
        debugPrint('効果音 ${s.name} を読み込めませんでした: $e');
      }
    }));
  }

  static String _path(Sfx s) => 'survivor/${s.name}.wav';

  void tick(double dt) => _clock += dt;

  void play(Sfx s) {
    if (muted.value) return;
    if (!_loaded.contains(s)) return;
    final last = _lastPlayed[s];
    if (last != null && _clock - last < (_minInterval[s] ?? 0)) return;
    _lastPlayed[s] = _clock;
    _backend.play(_path(s), _volume[s] ?? 0.8);
  }

  Future<void> dispose() => _backend.dispose();
}
