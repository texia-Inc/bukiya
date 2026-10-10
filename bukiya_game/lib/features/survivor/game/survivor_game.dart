import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/services.dart';

import '../domain/run_simulation.dart';
import 'world_renderer.dart';

/// RunSimulation を毎フレーム進め、カメラをプレイヤーに追従させる
class SurvivorGame extends FlameGame {
  final RunSimulation sim;

  /// ジョイスティック（画面ドラッグ）の入力。キー入力と合成する
  double stickX = 0;
  double stickY = 0;

  SurvivorGame(this.sim);

  @override
  Color backgroundColor() => const Color(0xFF243B2A);

  @override
  Future<void> onLoad() async {
    // 縦長・横長どちらでも、短い辺に 380 ほどのワールドが映る
    camera.viewfinder.visibleGameSize = Vector2.all(380);
    world.add(WorldRenderer(sim));
  }

  @override
  void update(double dt) {
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
    camera.viewfinder.position = Vector2(sim.px, sim.py);
    super.update(dt);
  }
}
