import 'dart:async';
import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../domain/run_result.dart';
import '../domain/run_simulation.dart';
import '../domain/skills.dart';
import '../data/profile_store.dart';
import '../domain/profile.dart';
import '../domain/shop.dart';
import '../game/run_fx.dart';
import '../game/sfx_backend.dart';
import '../game/survivor_audio.dart';
import '../game/survivor_game.dart';
import 'home_view.dart';

const _bg = Color(0xFF14181D);
const _panel = Color(0xFF1F262E);
const _ink = Color(0xFFEDE6D6);
const _muted = Color(0xFF9AA39D);
const _accent = Color(0xFFF2C230);
const _gateBlue = Color(0xFF8BE9FF);

enum _Stage { loading, home, running, result }

/// ブキヤ・サバイバーの画面。ホーム（店・装備・戦闘）→ ラン → 結果
class SurvivorScreen extends StatefulWidget {
  const SurvivorScreen({super.key});

  @override
  State<SurvivorScreen> createState() => _SurvivorScreenState();
}

class _SurvivorScreenState extends State<SurvivorScreen> {
  _Stage _stage = _Stage.loading;
  final ProfileStore _store = ProfileStore();
  late SurvivorProfile _profile;
  RunSimulation? _sim;
  SurvivorGame? _game;
  RunResult? _result;

  @override
  void initState() {
    super.initState();
    _store.load().then((p) {
      if (!mounted) return;
      setState(() {
        _profile = p;
        _stage = _Stage.home;
      });
    });
  }

  void _start() {
    // 出発ボタンのタップをきっかけに音を出せるようにする（iPhone の制限）
    SfxBackend.unlock();
    final stage = _profile.stage;
    final sim = RunSimulation(
        loadout: _profile.loadout, config: RunConfig(stage: stage));
    sim.onLevelUp = (_) => setState(() {});
    sim.onEnd = (result) {
      _profile.applyResult(result, stage);
      _store.save(_profile);
      setState(() {
        _result = result;
        _stage = _Stage.result;
      });
    };
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
          _Stage.loading => const Center(child: CircularProgressIndicator()),
          _Stage.home => HomeView(
              profile: _profile,
              onStart: _start,
              onChanged: () => _store.save(_profile),
            ),
          _Stage.running => _RunView(
              sim: _sim!,
              game: _game!,
              onChoose: (id) => setState(() => _sim!.chooseSkill(id)),
            ),
          _Stage.result => _ResultView(
              result: _result!,
              profile: _profile,
              onAgain: () => setState(() => _stage = _Stage.home),
            ),
        },
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
  /// スティックの (起点, 現在位置)。指の動きのたびに画面全体を作り直さないよう、
  /// setState ではなくこの通知でスティックの絵だけを描き直す
  final ValueNotifier<(Offset, Offset)?> _stick = ValueNotifier(null);
  bool _paused = false;

  static const double _stickRadius = 50;

  @override
  void dispose() {
    _stick.dispose();
    super.dispose();
  }

  void _updateStick(Offset origin, Offset now) {
    var d = now - origin;
    if (d.distance > _stickRadius) d = d / d.distance * _stickRadius;
    _stick.value = (origin, origin + d);
    widget.game.stickX = d.dx / _stickRadius;
    widget.game.stickY = d.dy / _stickRadius;
  }

  void _releaseStick() {
    _stick.value = null;
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
          onPanStart: (d) {
            SfxBackend.unlock();
            _updateStick(d.localPosition, d.localPosition);
          },
          onPanUpdate: (d) {
            final s = _stick.value;
            if (s != null) _updateStick(s.$1, d.localPosition);
          },
          onPanEnd: (_) => _releaseStick(),
          onPanCancel: _releaseStick,
          child: GameWidget(game: widget.game),
        ),
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _StickPainter(_stick, _stickRadius),
              size: Size.infinite,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _HudTicker(
              sim: sim,
              fx: widget.game.fx,
              builder: () => _Hud(
                  sim: sim,
                  fx: widget.game.fx,
                  paused: _paused,
                  onPause: _togglePause),
            ),
          ),
        ),
        if (SurvivorGame.showPerf)
          Positioned(
            left: 12,
            bottom: 12,
            child: IgnorePointer(
              child: _HudTicker(
                sim: sim,
                fx: widget.game.fx,
                alwaysRebuild: true,
                builder: () => Container(
                  padding: const EdgeInsets.all(6),
                  color: const Color(0xAA000000),
                  child: Text(widget.game.perf.toString(),
                      style: const TextStyle(
                          fontSize: 11, fontFamily: 'monospace', color: _ink)),
                ),
              ),
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

/// HUD だけを 0.1 秒ごとに作り直す。表示する値が変わっていなければ作り直さない
class _HudTicker extends StatefulWidget {
  final RunSimulation sim;
  final RunFx fx;
  final Widget Function() builder;
  final bool alwaysRebuild;

  const _HudTicker({
    required this.sim,
    required this.fx,
    required this.builder,
    this.alwaysRebuild = false,
  });

  @override
  State<_HudTicker> createState() => _HudTickerState();
}

class _HudTickerState extends State<_HudTicker> {
  late final Timer _timer;
  Object? _last;

  /// 画面に出る値の組。これが同じなら作り直す必要がない
  Object _snapshot() {
    final s = widget.sim;
    final g = s.gate;
    return (
      s.hp.ceil(),
      s.maxHp.round(),
      s.level,
      (s.xp / s.xpToNext * 50).floor(),
      s.horde ? -1 : s.timeLeft.floor(),
      s.totalKills,
      s.materials.values.fold(0, (a, b) => a + b),
      g == null
          ? null
          : (g.closesAt == null ? -1 : (g.closesAt! - s.time).ceil()),
      s.boss == null ? null : (s.boss!.hp / s.boss!.maxHp * 100).ceil(),
      widget.fx.bossWarning > 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      if (widget.alwaysRebuild) {
        setState(() {});
        return;
      }
      final snap = _snapshot();
      if (snap != _last) setState(() => _last = snap);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(child: widget.builder());
}

class _StickPainter extends CustomPainter {
  final ValueNotifier<(Offset, Offset)?> stick;
  final double radius;

  _StickPainter(this.stick, this.radius) : super(repaint: stick);

  @override
  void paint(Canvas canvas, Size size) {
    final s = stick.value;
    if (s == null) return;
    final (origin, now) = s;
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
  bool shouldRepaint(_StickPainter old) => old.stick != stick;
}

String _clock(double seconds) {
  final s = seconds.floor();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

class _Hud extends StatelessWidget {
  final RunSimulation sim;
  final RunFx fx;
  final bool paused;
  final VoidCallback onPause;

  const _Hud({
    required this.sim,
    required this.fx,
    required this.paused,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final gate = sim.gate;
    final boss = sim.boss;
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
                    shadows: const [Shadow(offset: Offset(1, 1))],
                  ),
                ),
                Text('撃破 ${sim.totalKills}・素材 $matCount',
                    style: const TextStyle(
                        fontSize: 12, shadows: [Shadow(offset: Offset(1, 1))])),
              ],
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<bool>(
              valueListenable: SurvivorAudio.muted,
              builder: (context, muted, _) => IconButton(
                onPressed: () {
                  SfxBackend.unlock();
                  SurvivorAudio.muted.value = !muted;
                },
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
        if (boss != null) ...[
          _BossBar(boss: boss),
          const SizedBox(height: 6),
        ],
        if (fx.bossWarning > 0 && boss != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCC3D1214),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5484D)),
              ),
              child: Text('ボス出現！ ${_bossName(boss.kind)}',
                  style: const TextStyle(
                      color: Color(0xFFFF8A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
          ),
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

String _bossName(EnemyKind kind) => switch (kind) {
      EnemyKind.ogre => 'オーガ',
      EnemyKind.kingSlime => 'キングスライム',
      _ => '',
    };

class _BossBar extends StatelessWidget {
  final Enemy boss;

  const _BossBar({required this.boss});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_bossName(boss.kind),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8A8A),
                shadows: [Shadow(offset: Offset(1, 1))])),
        const SizedBox(height: 2),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xAA000000),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFF1A1A1A)),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (boss.hp / boss.maxHp).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5484D),
                borderRadius: BorderRadius.circular(5),
              ),
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
                    shadows: [Shadow(offset: Offset(1, 1))])),
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
  final SurvivorProfile profile;
  final VoidCallback onAgain;

  const _ResultView(
      {required this.result, required this.profile, required this.onAgain});

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
              for (final w in result.weapons)
                _WeaponOutcomeRow(
                    outcome: w, owned: profile.weapon(w.weapon.id)),
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

  /// 記録に反映したあとの武器（累計の熟練度と今の売値を出す）
  final OwnedWeapon? owned;

  const _WeaponOutcomeRow({required this.outcome, required this.owned});

  @override
  Widget build(BuildContext context) {
    final total = owned?.kills ?? outcome.kills;
    final prof = min(total, proficiencyCapKills) / proficiencyCapKills;
    final bonus = ((proficiencyMultiplier(total) - 1) * 100).round();
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
              if (owned != null) ...[
                const Text('売値 ', style: TextStyle(color: _muted)),
                Text('${owned!.sellPrice}G',
                    style: const TextStyle(
                        color: _accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
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
            '撃破 +${outcome.kills}（熟練度 $total・売値 +$bonus%）・耐久 ${outcome.weapon.durability} → ${outcome.durabilityAfter}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          if (outcome.durabilityAfter <= 0)
            const Text('壊れた！店で修理するまで持ち出せない',
                style: TextStyle(color: Color(0xFFFF8A8A), fontSize: 12)),
        ],
      ),
    );
  }
}
