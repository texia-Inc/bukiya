import 'package:flutter/material.dart';

import '../domain/loadout.dart';
import '../domain/profile.dart';
import '../domain/shop.dart';
import '../domain/run_result.dart';
import '../domain/stage.dart';
import 'menu_painters.dart';

// ホーム画面の配色：明るいオレンジの背景に、黒い縁取りの太いパネル
const _bgTop = Color(0xFFFFA53A);
const _bgBottom = Color(0xFFF5781F);
const _ink = Color(0xFF1E1A16);
const _panel = Color(0xFF2E3340);
const _panelLight = Color(0xFF3D4352);
const _yellow = Color(0xFFFFD23F);
const _cream = Color(0xFFFFF4DC);
const _muted = Color(0xFFB9BECB);

enum HomeTab { shop, gear, battle }

/// ホーム画面（店・装備・戦闘の3タブ）
class HomeView extends StatefulWidget {
  final SurvivorProfile profile;
  final VoidCallback onStart;

  /// 記録（選んだ武器やステージ）が変わったときに保存させる
  final VoidCallback onChanged;

  const HomeView({
    super.key,
    required this.profile,
    required this.onStart,
    required this.onChanged,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  HomeTab _tab = HomeTab.battle;
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  SurvivorProfile get _p => widget.profile;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _change(VoidCallback f) {
    setState(f);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _TopBar(profile: _p),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: switch (_tab) {
                    HomeTab.battle => _BattleTab(
                        profile: _p,
                        anim: _anim,
                        onStage: (s) => _change(() => _p.selectedStage = s.id),
                        onGear: () => setState(() => _tab = HomeTab.gear),
                        onStart: widget.onStart,
                      ),
                    HomeTab.gear => _GearTab(
                        profile: _p,
                        onToggle: (w) => _change(() => _p.toggleWeapon(w.uid)),
                        onEnchant: (w) {
                          _change(() => _p.enchant(w));
                          _toast('${w.name} を +${w.enchantLevel} に強化した');
                        },
                        onRepair: (w) {
                          _change(() => _p.repair(w));
                          _toast('${w.displayName} を修理した');
                        },
                      ),
                    HomeTab.shop => _ShopTab(
                        profile: _p,
                        onSell: (w) async {
                          final ok = await _confirm(
                              '${w.displayName} を ${w.sellPrice}G で売りますか？');
                          if (!ok) return;
                          final price = w.sellPrice;
                          _change(() => _p.sell(w));
                          _toast('${w.displayName} を ${price}G で売った');
                        },
                        onCraft: (r) {
                          OwnedWeapon? made;
                          _change(() => made = _p.craft(r));
                          if (made != null) _toast('${made!.name} を鍛えた');
                        },
                      ),
                  },
                ),
              ),
            ),
            _BottomNav(
              tab: _tab,
              onTab: (t) => setState(() => _tab = t),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w800)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        // 下のタブに重ならないよう持ち上げる
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
      ));
  }

  Future<bool> _confirm(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _Chunky(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _cream,
                      fontWeight: FontWeight.w800,
                      fontSize: 15)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _SmallButton(
                      label: 'やめる',
                      color: _panelLight,
                      textColor: _cream,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SmallButton(
                      label: '売る',
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return ok ?? false;
  }
}

// ---------------------------------------------------------------------------
// 共通の部品

/// 黒い縁取りの文字（タイトルなど）
class OutlinedText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double stroke;

  const OutlinedText(this.text,
      {super.key,
      required this.size,
      this.color = Colors.white,
      this.stroke = 5});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = stroke
                  ..strokeJoin = StrokeJoin.round
                  ..color = _ink)),
        Text(text,
            style: TextStyle(
                fontSize: size, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

/// 黒い縁取りと下に影のある、ゲームらしいパネル
class _Chunky extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  const _Chunky({
    required this.child,
    this.color = _panel,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ink, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _Icon extends StatelessWidget {
  final CustomPainter painter;
  final double size;

  const _Icon(this.painter, {this.size = 26});

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: painter));
}

const _rules = [
  '画面をドラッグ（PC は WASD / 矢印キー）で移動。攻撃は自動',
  '1:30・3:00・4:30 に帰還ゲートが25秒だけ開く。入れば生還',
  '2:00 と 4:00 にボスが出る。倒すと宝箱（魔核とレベルアップ2回分）',
  '5:00 を過ぎると魔物の大群。ゲートは開きっぱなしになる',
  '倒れると素材は半分しか持ち帰れない',
  '武器で倒した数が熟練度になり、売値が最大 +50% 上がる',
  '武器は出撃で耐久が減る（生還 -10・倒れると -40）。0 になったら店で修理',
  '店で武器を売ってお金を稼ぎ、素材とお金で新しい武器を鍛えたり強化したりできる',
];

void showRulesDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: _Chunky(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OutlinedText('遊び方', size: 22),
            const SizedBox(height: 10),
            for (final r in _rules)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('・', style: TextStyle(color: _yellow)),
                    Expanded(
                        child: Text(r,
                            style: const TextStyle(
                                color: _cream, fontSize: 13, height: 1.5))),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる',
                    style:
                        TextStyle(color: _yellow, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// 上のバー

class _TopBar extends StatelessWidget {
  final SurvivorProfile profile;

  const _TopBar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(bottom: BorderSide(color: _ink, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF7B955),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _ink, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(painter: ShopkeeperFacePainter()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('武器屋の店主',
                    style: TextStyle(
                        color: _cream,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
                Text('出撃 ${profile.runs} 回',
                    style: const TextStyle(color: _muted, fontSize: 11)),
              ],
            ),
          ),
          _Pill(
            icon: _Icon(CoinPainter(), size: 20),
            value: '${profile.gold}',
          ),
          const SizedBox(width: 6),
          _Pill(
            icon: _Icon(MaterialIconPainter(MaterialKind.bossCore), size: 20),
            value: '${profile.materials[MaterialKind.bossCore] ?? 0}',
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () => showRulesDialog(context),
            icon: const Icon(Icons.help_outline_rounded, color: _cream),
            tooltip: '遊び方',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget icon;
  final String value;

  const _Pill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
      decoration: BoxDecoration(
        color: const Color(0xFF14161C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 戦闘タブ：ステージを選んで出発

String formatDuration(double seconds) {
  final s = seconds.floor();
  return '${s ~/ 60}分${(s % 60).toString().padLeft(2, '0')}秒';
}

class _BattleTab extends StatelessWidget {
  final SurvivorProfile profile;
  final Animation<double> anim;
  final ValueChanged<StageDef> onStage;
  final VoidCallback onGear;
  final VoidCallback onStart;

  const _BattleTab({
    required this.profile,
    required this.anim,
    required this.onStage,
    required this.onGear,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final stage = profile.stage;
    final i = allStages.indexOf(stage);
    final locked = !profile.isUnlocked(stage);
    final best = profile.bestSeconds[stage.id];
    return LayoutBuilder(builder: (context, c) {
      final artHeight = (c.maxHeight * 0.42).clamp(160.0, 320.0);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Spacer(),
            OutlinedText('${stage.number}.${stage.name}', size: 30),
            const SizedBox(height: 4),
            OutlinedText(
              best == null ? 'まだ挑戦していない' : '最長生存時間：${formatDuration(best)}',
              size: 15,
              stroke: 4,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: artHeight,
              child: Row(
                children: [
                  _ArrowButton(
                    left: true,
                    enabled: i > 0,
                    onTap: () => onStage(allStages[i - 1]),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: anim,
                          builder: (context, _) => CustomPaint(
                            size: Size.infinite,
                            painter: StageArtPainter(stage, anim.value * 6,
                                locked: locked),
                          ),
                        ),
                        if (locked)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock, color: _cream, size: 40),
                              const SizedBox(height: 4),
                              OutlinedText(
                                '${allStages[i - 1].name}で3分生き残るか\nボスを倒すと解放',
                                size: 13,
                                stroke: 3,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  _ArrowButton(
                    left: false,
                    enabled: i < allStages.length - 1,
                    onTap: () => onStage(allStages[i + 1]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(stage.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
            const Spacer(),
            GestureDetector(
              onTap: onGear,
              child: _Chunky(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    const Text('持ち出す武器',
                        style: TextStyle(color: _muted, fontSize: 12)),
                    const SizedBox(width: 8),
                    for (final w in profile.loadout) ...[
                      _Icon(WeaponIconPainter(w.type), size: 24),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(w.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: _cream,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Icon(Icons.chevron_right, color: _muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _StartButton(
              enabled: !locked && profile.loadout.isNotEmpty,
              label: locked
                  ? '未解放'
                  : profile.loadout.isEmpty
                      ? '使える武器がない'
                      : 'スタート',
              onTap: onStart,
            ),
            const SizedBox(height: 14),
          ],
        ),
      );
    });
  }
}

class _ArrowButton extends StatelessWidget {
  final bool left;
  final bool enabled;
  final VoidCallback onTap;

  const _ArrowButton(
      {required this.left, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.25,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 36,
          height: 52,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _ink, width: 3),
          ),
          child: Icon(left ? Icons.chevron_left : Icons.chevron_right,
              color: _cream, size: 30),
        ),
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  const _StartButton(
      {required this.enabled, required this.label, required this.onTap});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down && widget.enabled;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: 72,
        width: double.infinity,
        transform: Matrix4.translationValues(0, pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.enabled ? _yellow : const Color(0xFF8E8E8E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _ink, width: 4),
          boxShadow: [
            if (!pressed)
              const BoxShadow(color: Color(0xFF8A4A0E), offset: Offset(0, 6)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(widget.label,
            style: TextStyle(
                color: _ink,
                fontSize: widget.label.length > 5 ? 22 : 30,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 装備タブ：持ち出す武器を選び、強化・修理する

class _SmallButton extends StatelessWidget {
  final String label;
  final String? sub;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;

  const _SmallButton({
    required this.label,
    this.sub,
    this.onTap,
    this.color = _yellow,
    this.textColor = _ink,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFF5A5E68),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _ink, width: 2.5),
          boxShadow: enabled
              ? const [
                  BoxShadow(color: Color(0x66000000), offset: Offset(0, 3))
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: enabled ? textColor : const Color(0xFFB0B3BA),
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
            if (sub != null)
              Text(sub!,
                  style: TextStyle(
                      color: enabled
                          ? textColor.withValues(alpha: 0.75)
                          : const Color(0xFF9A9DA4),
                      fontWeight: FontWeight.w700,
                      fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

/// 必要な素材とお金を「アイコン 持っている数/要る数」で並べる
class _CostRow extends StatelessWidget {
  final SurvivorProfile profile;
  final int gold;
  final Map<MaterialKind, int> materials;

  const _CostRow(
      {required this.profile, required this.gold, required this.materials});

  @override
  Widget build(BuildContext context) {
    Widget item(Widget icon, int have, int need) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 2),
              Text('$have/$need',
                  style: TextStyle(
                      color: have >= need ? _cream : const Color(0xFFFF8A8A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ],
          ),
        );
    return Wrap(
      runSpacing: 4,
      children: [
        for (final e in materials.entries)
          item(_Icon(MaterialIconPainter(e.key), size: 18), profile.have(e.key),
              e.value),
        item(_Icon(CoinPainter(), size: 18), profile.gold, gold),
      ],
    );
  }
}

class _GearTab extends StatelessWidget {
  final SurvivorProfile profile;
  final ValueChanged<OwnedWeapon> onToggle;
  final ValueChanged<OwnedWeapon> onEnchant;
  final ValueChanged<OwnedWeapon> onRepair;

  const _GearTab({
    required this.profile,
    required this.onToggle,
    required this.onEnchant,
    required this.onRepair,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const OutlinedText('装備', size: 26),
        const SizedBox(height: 4),
        const Text('タップで持ち出す武器を2本まで選ぶ。魔石とお金で強化、耐久が減ったら修理。',
            style: TextStyle(
                color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 12),
        for (final w in profile.weapons)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _GearCard(
              profile: profile,
              weapon: w,
              selected: profile.selectedWeapons.contains(w.uid),
              onTap: () => onToggle(w),
              onEnchant: () => onEnchant(w),
              onRepair: () => onRepair(w),
            ),
          ),
      ],
    );
  }
}

class _GearCard extends StatelessWidget {
  final SurvivorProfile profile;
  final OwnedWeapon weapon;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEnchant;
  final VoidCallback onRepair;

  const _GearCard({
    required this.profile,
    required this.weapon,
    required this.selected,
    required this.onTap,
    required this.onEnchant,
    required this.onRepair,
  });

  @override
  Widget build(BuildContext context) {
    final w = weapon;
    final prof = (w.kills / proficiencyCapKills).clamp(0.0, 1.0);
    final maxed = w.enchantLevel >= maxEnchantLevel;
    final cost = maxed ? null : enchantCost(w);
    return _Chunky(
      color: w.broken
          ? const Color(0xFF4A2F33)
          : selected
              ? const Color(0xFF3A4A3A)
              : _panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: selected ? _yellow : _panelLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _ink, width: 3),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: CustomPaint(painter: WeaponIconPainter(w.type)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(w.displayName,
                                style: const TextStyle(
                                    color: _cream,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16)),
                          ),
                          Text('${w.sellPrice} G',
                              style: const TextStyle(
                                  color: _yellow, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      Text(
                          w.broken ? '壊れている（修理するまで持ち出せない）' : w.type.attackStyle,
                          style: TextStyle(
                              color:
                                  w.broken ? const Color(0xFFFF8A8A) : _muted,
                              fontSize: 11)),
                      const SizedBox(height: 6),
                      _MiniBar(
                          label: '熟練度 ${w.kills}/$proficiencyCapKills',
                          value: prof,
                          color: _yellow),
                      const SizedBox(height: 3),
                      _MiniBar(
                          label: '耐久 ${w.durability}/100',
                          value: w.durability / 100,
                          color: w.durability > 30
                              ? const Color(0xFF6BD17A)
                              : const Color(0xFFE5484D)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? _yellow : _muted,
                    size: 28),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: maxed
                    ? const Text('強化は最大',
                        style: TextStyle(color: _muted, fontSize: 12))
                    : _CostRow(
                        profile: profile,
                        gold: cost!.gold,
                        materials: cost.materials),
              ),
              _SmallButton(
                label: '強化',
                sub: maxed ? null : '+${w.enchantLevel + 1}',
                onTap: profile.canEnchant(w) ? onEnchant : null,
              ),
              if (w.durability < 100) ...[
                const SizedBox(width: 6),
                _SmallButton(
                  label: '修理',
                  sub: '${repairCost(w)}G',
                  color: const Color(0xFF8BE9FF),
                  onTap: profile.canRepair(w) ? onRepair : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniBar(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF1B1E26),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 104,
          child:
              Text(label, style: const TextStyle(color: _muted, fontSize: 10)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 店タブ：武器を売る・鍛冶・素材の倉庫

class _ShopTab extends StatelessWidget {
  final SurvivorProfile profile;
  final ValueChanged<OwnedWeapon> onSell;
  final ValueChanged<Recipe> onCraft;

  const _ShopTab({
    required this.profile,
    required this.onSell,
    required this.onCraft,
  });

  @override
  Widget build(BuildContext context) {
    final full = profile.weapons.length >= maxOwnedWeapons;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const OutlinedText('武器を売る', size: 24),
        const SizedBox(height: 4),
        const Text('使い込んだ武器ほど高く売れる。耐久が減ると値が下がる。',
            style: TextStyle(
                color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 10),
        for (final w in profile.weapons)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Chunky(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                children: [
                  _Icon(WeaponIconPainter(w.type), size: 34),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.displayName,
                            style: const TextStyle(
                                color: _cream,
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                        Text('熟練度 ${w.kills}・耐久 ${w.durability}',
                            style:
                                const TextStyle(color: _muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  _SmallButton(
                    label: '売る',
                    sub: '${w.sellPrice}G',
                    onTap: profile.canSell(w) ? () => onSell(w) : null,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        const OutlinedText('鍛冶', size: 24),
        const SizedBox(height: 4),
        Text(
            full
                ? '倉庫がいっぱい（$maxOwnedWeapons本まで）。武器を売ると鍛えられる。'
                : '持ち帰った素材とお金で新しい武器を鍛える。',
            style: const TextStyle(
                color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 10),
        for (final r in recipes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Chunky(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(
                children: [
                  _Icon(WeaponIconPainter(r.type), size: 34),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(weaponNames[r.type]!,
                            style: const TextStyle(
                                color: _cream,
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                        const SizedBox(height: 3),
                        _CostRow(
                            profile: profile,
                            gold: r.gold,
                            materials: r.materials),
                      ],
                    ),
                  ),
                  _SmallButton(
                    label: '鍛える',
                    onTap: profile.canCraft(r) ? () => onCraft(r) : null,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        const OutlinedText('倉庫', size: 24),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (final m in MaterialKind.values)
              _Chunky(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Icon(MaterialIconPainter(m), size: 34),
                    const SizedBox(height: 4),
                    Text(m.label,
                        style: const TextStyle(color: _muted, fontSize: 11)),
                    Text('${profile.have(m)}',
                        style: const TextStyle(
                            color: _cream,
                            fontWeight: FontWeight.w900,
                            fontSize: 18)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 下のタブ

class _BottomNav extends StatelessWidget {
  final HomeTab tab;
  final ValueChanged<HomeTab> onTab;

  const _BottomNav({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    const items = [
      (HomeTab.shop, Icons.storefront_rounded, '店'),
      (HomeTab.gear, Icons.shield_rounded, '装備'),
      (HomeTab.battle, Icons.local_fire_department_rounded, '戦闘'),
    ];
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(top: BorderSide(color: _ink, width: 3)),
      ),
      child: Row(
        children: [
          for (final (t, icon, label) in items)
            Expanded(
              flex: t == tab ? 3 : 2,
              child: GestureDetector(
                onTap: () => onTab(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: t == tab ? _yellow : _panel,
                    border: const Border(
                        left: BorderSide(color: _ink, width: 1.5),
                        right: BorderSide(color: _ink, width: 1.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon,
                          color: t == tab ? _ink : _muted,
                          size: t == tab ? 32 : 26),
                      Text(label,
                          style: TextStyle(
                              color: t == tab ? _ink : _muted,
                              fontWeight: FontWeight.w900,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
