import 'dart:math';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../domain/run_simulation.dart';
import 'run_fx.dart';
import 'survivor_audio.dart';
import 'world_renderer.dart';

/// RunSimulation を毎フレーム進め、カメラをプレイヤーに追従させる
class SurvivorGame extends FlameGame {
  final RunSimulation sim;

  /// ジョイスティック（画面ドラッグ）の入力。キー入力と合成する
  double stickX = 0;
  double stickY = 0;

  final SurvivorAudio audio = SurvivorAudio();
  late final RunFx fx = RunFx(audio);

  /// URL に ?fps=1 を付けると、FPS と処理時間を画面に出す
  static final bool showPerf = Uri.base.queryParameters['fps'] == '1';
  final PerfStats perf = PerfStats();

  SurvivorGame(this.sim);

  @override
  void onMount() {
    super.onMount();
    if (showPerf) SchedulerBinding.instance.addTimingsCallback(perf.onTimings);
  }

  @override
  Color backgroundColor() => Color(sim.stage.groundColor);

  @override
  Future<void> onLoad() async {
    // 縦長・横長どちらでも、短い辺に 380 ほどのワールドが映る
    camera.viewfinder.visibleGameSize = Vector2.all(380);
    world.add(WorldRenderer(sim, fx));
    // 音の読み込みを待たずに始める
    audio.load();
  }

  @override
  void onRemove() {
    if (showPerf) {
      SchedulerBinding.instance.removeTimingsCallback(perf.onTimings);
    }
    // 生還・力尽きたの音を最後まで鳴らしてから解放する
    Future.delayed(const Duration(seconds: 2), audio.dispose);
    super.onRemove();
  }

  @override
  void update(double dt) {
    final sw = showPerf ? (Stopwatch()..start()) : null;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    var kx = 0.0, ky = 0.0;
    if (keys.contains(LogicalKeyboardKey.arrowLeft) ||
        keys.contains(LogicalKeyboardKey.keyA)) {
      kx -= 1;
    }
    if (keys.contains(LogicalKeyboardKey.arrowRight) ||
        keys.contains(LogicalKeyboardKey.keyD)) {
      kx += 1;
    }
    if (keys.contains(LogicalKeyboardKey.arrowUp) ||
        keys.contains(LogicalKeyboardKey.keyW)) {
      ky -= 1;
    }
    if (keys.contains(LogicalKeyboardKey.arrowDown) ||
        keys.contains(LogicalKeyboardKey.keyS)) {
      ky += 1;
    }
    if (kx != 0 || ky != 0) {
      final len = sqrt(kx * kx + ky * ky);
      sim.setInput(kx / len, ky / len);
    } else {
      sim.setInput(stickX, stickY);
    }

    final view = camera.visibleWorldRect;
    sim.spawnDistance =
        sqrt(view.width * view.width + view.height * view.height) / 2 + 40;
    sim.update(dt);
    fx.handle(sim);
    fx.update(dt);
    camera.viewfinder.position =
        Vector2(sim.px + fx.shakeX, sim.py + fx.shakeY);
    super.update(dt);
    if (sw != null) {
      perf.addUpdate(dt, sw.elapsedMicroseconds, sim.enemies.length);
    }
  }

  @override
  void render(Canvas canvas) {
    if (!showPerf) return super.render(canvas);
    final sw = Stopwatch()..start();
    super.render(canvas);
    perf.addRender(sw.elapsedMicroseconds);
  }
}

/// 1秒ごとに平均を取る、簡易の処理時間計測
class PerfStats {
  int _frames = 0;
  double _elapsed = 0;
  int _updateUs = 0;
  int _renderUs = 0;
  int _rasterUs = 0;
  int _buildUs = 0;
  int _timings = 0;
  int _enemies = 0;
  double _maxDt = 0;

  double fps = 0;

  /// この1秒で一番長かったフレームの間隔。カクつきはここに出る
  double worstFrameMs = 0;
  double updateMs = 0;
  double renderMs = 0;
  double buildMs = 0;
  double rasterMs = 0;
  int enemies = 0;

  void addUpdate(double dt, int us, int enemyCount) {
    _frames++;
    _elapsed += dt;
    _updateUs += us;
    _enemies = enemyCount;
    _maxDt = max(_maxDt, dt);
    if (_elapsed < 1) return;
    fps = _frames / _elapsed;
    worstFrameMs = _maxDt * 1000;
    _maxDt = 0;
    updateMs = _updateUs / _frames / 1000;
    renderMs = _renderUs / _frames / 1000;
    buildMs = _timings == 0 ? 0 : _buildUs / _timings / 1000;
    rasterMs = _timings == 0 ? 0 : _rasterUs / _timings / 1000;
    enemies = _enemies;
    _frames = 0;
    _elapsed = 0;
    _updateUs = _renderUs = _buildUs = _rasterUs = _timings = 0;
  }

  void addRender(int us) => _renderUs += us;

  void onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _buildUs += t.buildDuration.inMicroseconds;
      _rasterUs += t.rasterDuration.inMicroseconds;
      _timings++;
    }
  }

  @override
  String toString() =>
      '${fps.toStringAsFixed(0)} fps  最長 ${worstFrameMs.toStringAsFixed(0)}ms  敵 $enemies\n'
      '更新 ${updateMs.toStringAsFixed(1)}ms  描画 ${renderMs.toStringAsFixed(1)}ms\n'
      'build ${buildMs.toStringAsFixed(1)}ms  raster ${rasterMs.toStringAsFixed(1)}ms';
}
