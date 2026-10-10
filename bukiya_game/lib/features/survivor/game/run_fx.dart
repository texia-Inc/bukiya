import 'dart:math';

import '../domain/loadout.dart';
import '../domain/run_simulation.dart';
import 'survivor_audio.dart';

class FloatingNumber {
  final double x;
  final double y;
  final String text;
  final bool big;
  final CarriedWeaponType? weapon;
  double age = 0;

  FloatingNumber(this.x, this.y, this.text, this.big, this.weapon);

  static const double lifetime = 0.7;
}

/// シミュレーションの出来事を、ダメージ数字・画面揺れ・画面フラッシュ・効果音に変える
class RunFx {
  static const int maxNumbers = 60;

  /// この値以上のダメージは大きく黄色で出す
  static const double bigHit = 40;

  final SurvivorAudio audio;
  final Random _rng = Random();

  final List<FloatingNumber> numbers = [];

  /// 0〜1。揺れの強さは二乗で効かせ、時間で減衰させる
  double trauma = 0;
  double shakeX = 0;
  double shakeY = 0;

  /// 被弾時の赤いフラッシュ（0〜1）
  double hurtFlash = 0;

  /// 進化時の白いフラッシュ（0〜1）
  double whiteFlash = 0;

  RunFx(this.audio);

  void handle(RunSimulation sim) {
    var kills = 0;
    for (final e in sim.events) {
      switch (e.type) {
        case RunEventType.hit:
          _addNumber(e);
          audio.play(Sfx.hit);
        case RunEventType.kill:
          kills++;
          audio.play(Sfx.kill);
        case RunEventType.swordSwing:
          audio.play(Sfx.swing);
          if (sim.swordEvolved) _addTrauma(0.18);
        case RunEventType.bowShot:
          audio.play(Sfx.bow);
        case RunEventType.playerHurt:
          _addTrauma(0.55);
          hurtFlash = 1;
          audio.play(Sfx.hurt);
        case RunEventType.gem:
          audio.play(Sfx.gem);
        case RunEventType.material:
          audio.play(Sfx.material);
        case RunEventType.levelUp:
          audio.play(Sfx.levelup);
        case RunEventType.evolve:
          _addTrauma(0.8);
          whiteFlash = 1;
          audio.play(Sfx.evolve);
        case RunEventType.gateOpen:
          audio.play(Sfx.gate);
        case RunEventType.returned:
          audio.play(Sfx.returned);
        case RunEventType.died:
          _addTrauma(1);
          hurtFlash = 1;
          audio.play(Sfx.died);
      }
    }
    sim.events.clear();
    // まとめて倒したときは軽く揺らして爽快感を出す
    if (kills >= 6) _addTrauma(0.2);
  }

  void update(double dt) {
    audio.tick(dt);
    for (final n in numbers) {
      n.age += dt;
    }
    numbers.removeWhere((n) => n.age >= FloatingNumber.lifetime);

    trauma = max(0, trauma - dt * 2.2);
    hurtFlash = max(0, hurtFlash - dt * 3);
    whiteFlash = max(0, whiteFlash - dt * 2);
    final amp = 9 * trauma * trauma;
    shakeX = (_rng.nextDouble() * 2 - 1) * amp;
    shakeY = (_rng.nextDouble() * 2 - 1) * amp;
  }

  void _addTrauma(double v) => trauma = min(1, trauma + v);

  void _addNumber(RunEvent e) {
    if (numbers.length >= maxNumbers) numbers.removeAt(0);
    numbers.add(FloatingNumber(
      e.x + (_rng.nextDouble() * 2 - 1) * 6,
      e.y - 8,
      e.amount.round().toString(),
      e.amount >= bigHit,
      e.weapon,
    ));
  }
}
