import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../domain/loadout.dart';
import '../domain/run_result.dart';
import '../domain/run_simulation.dart';
import '../domain/skills.dart';
import '../game/survivor_audio.dart';
import '../game/survivor_game.dart';

const _bg = Color(0xFF14181D);
const _panel = Color(0xFF1F262E);
const _ink = Color(0xFFEDE6D6);
const _muted = Color(0xFF9AA39D);
const _accent = Color(0xFFF2C230);
const _gateBlue = Color(0xFF8BE9FF);

enum _Stage { loadout, running, result }

/// ブキヤ・サバイバーのプロトタイプ画面。持ち出す武器を選ぶ → ラン → 結果
class SurvivorScreen extends StatefulWidget {
  const SurvivorScreen({super.key});

  @override
  State<SurvivorScreen> createState() => _SurvivorScreenState();
}

class _SurvivorScreenState extends State<SurvivorScreen> {
  _Stage _stage = _Stage.loadout;
  final Set<String> _selected = {for (final w in mockShopStock) w.id};
  RunSimulation? _sim;
  SurvivorGame? _game;
  RunResult? _result;

  void _start() {
    final loadout =
        mockShopStock.where((w) => _selected.contains(w.id)).toList();
    final sim = RunSimulation(loadout: loadout);
    sim.onLevelUp = (_) => setState(() {});
    sim.onEnd = (result) => setState(() {
          _result = result;
          _stage = _Stage.result;
        });
    setState(() {
      _sim = sim;
      _game = SurvivorGame(sim);
      _stage = _Stage.running;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: DefaultTextStyle(
        style: const TextStyle(color: _ink, fontSize: 14),
        child: switch (_stage) {
          _Stage.loadout => _LoadoutView(
              selected: _selected,
              onToggle: (id) => setState(() {
                if (_selected.contains(id)) {
                  if (_selected.length > 1) _selected.remove(id);
                } else {
                  _selected.add(id);
                }
              }),
              onStart: _start,
            ),
          _Stage.running => _RunView(
              sim: _sim!,
              game: _game!,
              onChoose: (id) => setState(() => _sim!.chooseSkill(id)),
            ),
          _Stage.result => _ResultView(
              result: _result!,
              onAgain: () => setState(() => _stage = _Stage.loadout),
            ),
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 持ち出す武器の選択

class _LoadoutView extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onStart;

  const _LoadoutView({
    required this.selected,
    required this.onToggle,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              const Text('ブキヤ・サバイバー',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _accent)),
              const SizedBox(height: 8),
              const Text(
                '店の武器を担いで魔物の森へ。生きて帰れば、使い込んだ武器ほど高く売れる。',
                style: TextStyle(color: _muted, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Text('持ち出す武器',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final w in mockShopStock)
                _WeaponCard(
                  weapon: w,
                  selected: selected.contains(w.id),
                  onTap: () => onToggle(w.id),
                ),
              const SizedBox(height: 16),
              const _RuleBox(),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onStart,
                  child: const Text('森へ出発'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  final CarriedWeapon weapon;
  final bool selected;
  final VoidCallback onTap;

  const _WeaponCard({
    required this.weapon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = switch (weapon.type) {
      CarriedWeaponType.sword => '周囲を回転斬り',
      CarriedWeaponType.bow => '近くの敵を自動で射る',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFF2B3A2F) : _panel,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: selected ? _accent : const Color(0x33EDE6D6),
                  width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? _accent : _muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(weapon.displayName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                          '$style・攻撃力 ×${weapon.damageMultiplier.toStringAsFixed(1)}',
                          style: const TextStyle(color: _muted, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${weapon.basePrice}G',
                    style: const TextStyle(
                        color: _accent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleBox extends StatelessWidget {
  const _RuleBox();

  @override
  Widget build(BuildContext context) {
    const rules = [
      '画面をドラッグ（PC は WASD / 矢印キー）で移動。攻撃は自動',
      '1:30・3:00・4:30 に帰還ゲートが25秒だけ開く。入れば生還',
      '5:00 を過ぎると魔物の大群。ゲートは開きっぱなしになる',
      '倒れると素材は半分しか持ち帰れず、武器の耐久も大きく減る',
      '武器で倒した数が熟練度になり、売値が最大 +50% 上がる',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('・', style: TextStyle(color: _accent)),
                  Expanded(
                      child: Text(r,
                          style: const TextStyle(
                              fontSize: 13, color: _muted, height: 1.5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ラン中

class _RunView extends StatefulWidget {
  final RunSimulation sim;
  final SurvivorGame game;
  final ValueChanged<SkillId> onChoose;

  const _RunView(
      {required this.sim, required this.game, required this.onChoose});

  @override
  State<_RunView> createState() => _RunViewState();
}

class _RunViewState extends State<_RunView> {
  Offset? _stickOrigin;
  Offset? _stickNow;
  bool _paused = false;
  late final Timer _hudTimer;

  static const double _stickRadius = 50;

  @override
  void initState() {
    super.initState();
    // HUD は 10fps で十分
    _hudTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _hudTimer.cancel();
    super.dispose();
  }

  void _updateStick(Offset now) {
    final o = _stickOrigin;
    if (o == null) return;
    var d = now - o;
    if (d.distance > _stickRadius) d = d / d.distance * _stickRadius;
    _stickNow = o + d;
    widget.game.stickX = d.dx / _stickRadius;
    widget.game.stickY = d.dy / _stickRadius;
  }

  void _releaseStick() {
    _stickOrigin = null;
    _stickNow = null;
    widget.game.stickX = 0;
    widget.game.stickY = 0;
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      widget.game.pauseEngine();
    } else {
      widget.game.resumeEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sim = widget.sim;
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => setState(() {
            _stickOrigin = d.localPosition;
            _updateStick(d.localPosition);
          }),
          onPanUpdate: (d) => setState(() => _updateStick(d.localPosition)),
          onPanEnd: (_) => setState(_releaseStick),
          onPanCancel: () => setState(_releaseStick),
          child: GameWidget(game: widget.game),
        ),
        if (_stickOrigin != null)
          IgnorePointer(
            child: CustomPaint(
              painter: _StickPainter(_stickOrigin!, _stickNow!, _stickRadius),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _Hud(sim: sim, paused: _paused, onPause: _togglePause),
          ),
        ),
        if (sim.phase == RunPhase.levelUp)
          _LevelUpOverlay(sim: sim, onChoose: widget.onChoose),
        if (_paused)
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              color: const Color(0xAA000000),
              alignment: Alignment.center,
              child: const Text('一時停止中（タップで再開）',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

class _StickPainter extends CustomPainter {
  final Offset origin;
  final Offset now;
  final double radius;

  _StickPainter(this.origin, this.now, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(origin, radius, Paint()..color = const Color(0x33FFFFFF));
    canvas.drawCircle(
        origin,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x66FFFFFF));
    canvas.drawCircle(now, 20, Paint()..color = const Color(0x99FFFFFF));
  }

  @override
  bool shouldRepaint(_StickPainter old) =>
      old.now != now || old.origin != origin;
}

String _clock(double seconds) {
  final s = seconds.floor();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class _Hud extends StatelessWidget {
  final RunSimulation sim;
  final bool paused;
  final VoidCallback onPause;

  const _Hud({required this.sim, required this.paused, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final gate = sim.gate;
    final matCount = sim.materials.values.fold(0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bar(
                    value: sim.hp / sim.maxHp,
                    color: const Color(0xFFE5484D),
                    label: 'HP ${sim.hp.ceil()} / ${sim.maxHp.round()}',
                  ),
                  const SizedBox(height: 4),
                  _Bar(
                    value: sim.xp / sim.xpToNext,
                    color: const Color(0xFF5EC8FF),
                    label: 'Lv ${sim.level}',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  sim.horde ? '大群襲来' : _clock(sim.timeLeft),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: sim.horde ? const Color(0xFFE5484D) : _ink,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
                Text('撃破 ${sim.totalKills}・素材 $matCount',
                    style: const TextStyle(
                        fontSize: 12, shadows: [Shadow(blurRadius: 4)])),
              ],
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<bool>(
              valueListenable: SurvivorAudio.muted,
              builder: (context, muted, _) => IconButton(
                onPressed: () => SurvivorAudio.muted.value = !muted,
                icon: Icon(muted ? Icons.volume_off : Icons.volume_up,
                    color: _ink),
                tooltip: muted ? '音を出す' : '消音',
              ),
            ),
            IconButton(
              onPressed: onPause,
              icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: _ink),
              tooltip: '一時停止',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (gate != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCC12303D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gateBlue),
              ),
              child: Text(
                gate.closesAt == null
                    ? '帰還ゲートが開いている！矢印の方へ'
                    : '帰還ゲート出現！あと ${(gate.closesAt! - sim.time).ceil()} 秒',
                style: const TextStyle(
                    color: _gateBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;

  const _Bar({required this.value, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: const Color(0xAA000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Center(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 3)])),
          ),
        ],
      ),
    );
  }
}

class _LevelUpOverlay extends StatelessWidget {
  final RunSimulation sim;
  final ValueChanged<SkillId> onChoose;

  const _LevelUpOverlay({required this.sim, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xB3000000),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('レベルアップ！ Lv ${sim.level}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _accent)),
            const SizedBox(height: 12),
            for (final id in sim.currentOffer)
              _SkillCard(sim: sim, id: id, onTap: () => onChoose(id)),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final RunSimulation sim;
  final SkillId id;
  final VoidCallback onTap;

  const _SkillCard({required this.sim, required this.id, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final def = skillDefs[id]!;
    final evolution = id == SkillId.giantSlayer;
    final current = sim.skills.level(id);
    final levelText = id == SkillId.potion
        ? ''
        : evolution
            ? '進化'
            : 'Lv $current → ${current + 1}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: evolution ? const Color(0xFF4A3B12) : _panel,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: evolution ? _accent : const Color(0x33EDE6D6),
                  width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(def.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: evolution ? _accent : _ink)),
                    ),
                    Text(levelText,
                        style: const TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(def.description,
                    style: const TextStyle(color: _muted, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 結果

class _ResultView extends StatelessWidget {
  final RunResult result;
  final VoidCallback onAgain;

  const _ResultView({required this.result, required this.onAgain});

  @override
  Widget build(BuildContext context) {
    final kept = result.materialsKept;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              Text(
                result.returned ? '生還！' : '力尽きた…',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: result.returned ? _gateBlue : const Color(0xFFE5484D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_clock(result.survivedSeconds)} 生存・Lv ${result.level}・撃破 ${result.totalKills}',
                style: const TextStyle(color: _muted),
              ),
              const SizedBox(height: 20),
              const Text('武器の熟練度と売値',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final w in result.weapons) _WeaponOutcomeRow(outcome: w),
              const SizedBox(height: 16),
              Text(
                result.returned ? '持ち帰った素材' : '持ち帰った素材（倒れたので半分）',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: result.materialsFound.isEmpty
                    ? const Text('なし', style: TextStyle(color: _muted))
                    : Column(
                        children: [
                          for (final m in MaterialKind.values)
                            if ((result.materialsFound[m] ?? 0) > 0)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(m.label)),
                                    if (!result.returned)
                                      Text('${result.materialsFound[m]} → ',
                                          style: const TextStyle(
                                              color: _muted,
                                              decoration:
                                                  TextDecoration.lineThrough)),
                                    Text('${kept[m]} 個',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: onAgain,
                  child: const Text('店に戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeaponOutcomeRow extends StatelessWidget {
  final WeaponOutcome outcome;

  const _WeaponOutcomeRow({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final bonus = ((outcome.priceMultiplier - 1) * 100).round();
    final prof = min(outcome.kills, proficiencyCapKills) / proficiencyCapKills;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(outcome.weapon.displayName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Text('${outcome.weapon.basePrice}G → ',
                  style: const TextStyle(color: _muted)),
              Text('${outcome.priceAfter}G',
                  style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: prof,
              minHeight: 6,
              backgroundColor: const Color(0xFF2E3740),
              color: _accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '撃破 ${outcome.kills}（売値 +$bonus%）・耐久 ${outcome.weapon.durability} → ${outcome.durabilityAfter}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
