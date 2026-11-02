part of 'home_view.dart';

// ---------------------------------------------------------------------------
// 戦闘タブのメニュー：ギフト・パトロール・チャプター宝箱・ミッション

/// 丸い札のメニューボタン。受け取れるものがあると赤い「!」が付く
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool badge;
  final String? sub;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.badge,
    required this.onTap,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _ink, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x55000000), offset: Offset(0, 3)),
                  ],
                ),
                child:
                    Icon(icon, color: Colors.white, size: 32, shadows: const [
                  Shadow(color: _ink, offset: Offset(1.5, 1.5)),
                ]),
              ),
              if (badge)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5484D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text('!',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            height: 1.1)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          OutlinedText(label, size: 12, stroke: 3),
          if (sub != null) OutlinedText(sub!, size: 10, stroke: 3),
        ],
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  final SurvivorProfile profile;
  final VoidCallback onChanged;

  const _MenuRow({required this.profile, required this.onChanged});

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  late final Timer _timer;

  SurvivorProfile get _p => widget.profile;

  @override
  void initState() {
    super.initState();
    // パトロールの貯まり具合を表示し直す
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _open(Widget Function(VoidCallback changed) dialog) async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => dialog(() {
          setDialog(() {});
          widget.onChanged();
        }),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minutes = _p.patrolMinutes(now);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MenuButton(
          icon: Icons.card_giftcard_rounded,
          label: 'ギフト',
          color: const Color(0xFFE5484D),
          badge: _p.canClaimGift(now),
          onTap: () => _open((c) => _GiftDialog(profile: _p, onChanged: c)),
        ),
        _MenuButton(
          icon: Icons.storefront_rounded,
          label: 'パトロール',
          sub: _patrolTime(minutes),
          color: const Color(0xFF3F8FD6),
          badge: minutes >= 60,
          onTap: () => _open((c) => _PatrolDialog(profile: _p, onChanged: c)),
        ),
        _MenuButton(
          icon: Icons.inventory_2_rounded,
          label: '宝箱',
          color: const Color(0xFF3E9A5A),
          badge: _p.hasClaimableChest(),
          onTap: () => _open((c) => _ChestDialog(profile: _p, onChanged: c)),
        ),
        _MenuButton(
          icon: Icons.assignment_rounded,
          label: 'ミッション',
          color: const Color(0xFF8E5BC9),
          badge: _p.hasClaimableMission(now: now),
          onTap: () => _open((c) => _MissionDialog(profile: _p, onChanged: c)),
        ),
      ],
    );
  }
}

String _patrolTime(int minutes) =>
    minutes >= 60 ? '${minutes ~/ 60}時間${minutes % 60}分' : '$minutes分';

/// メニューのダイアログの枠
class _MenuDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _MenuDialog({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: _Chunky(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: OutlinedText(title, size: 22)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: _cream),
                    tooltip: '閉じる',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// もらえるもの（お金と素材）を並べる
class _RewardRow extends StatelessWidget {
  final Reward reward;
  final double size;

  const _RewardRow(this.reward, {this.size = 18});

  @override
  Widget build(BuildContext context) {
    Widget item(Widget icon, int n) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 3),
              Text('$n',
                  style: TextStyle(
                      color: _cream,
                      fontWeight: FontWeight.w900,
                      fontSize: size * 0.75)),
            ],
          ),
        );
    return Wrap(
      runSpacing: 4,
      children: [
        if (reward.gold > 0)
          item(_Icon(CoinPainter(), size: size), reward.gold),
        for (final e in reward.materials.entries)
          if (e.value > 0)
            item(_Icon(MaterialIconPainter(e.key), size: size), e.value),
      ],
    );
  }
}

class _GiftDialog extends StatelessWidget {
  final SurvivorProfile profile;
  final VoidCallback onChanged;

  const _GiftDialog({required this.profile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final can = profile.canClaimGift(now);
    return _MenuDialog(
      title: '毎日のギフト',
      children: [
        const Text('1日に1回、店にお客さんから差し入れが届く。解放したステージが多いほど豪華になる',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        Center(child: _RewardRow(profile.giftFor(now), size: 28)),
        const SizedBox(height: 14),
        _SmallButton(
          label: can ? '受け取る' : 'また明日',
          onTap: can
              ? () {
                  profile.claimGift(now);
                  onChanged();
                }
              : null,
        ),
      ],
    );
  }
}

class _PatrolDialog extends StatelessWidget {
  final SurvivorProfile profile;
  final VoidCallback onChanged;

  const _PatrolDialog({required this.profile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final minutes = profile.patrolMinutes(now);
    final pending = profile.patrolPending(now);
    final perHour =
        (patrolGoldPerMinute(profile.unlockedStageCount) * 60).round();
    return _MenuDialog(
      title: 'パトロール',
      children: [
        Text(
            '留守の間も、見習いが店のまわりを見回ってお金と素材を集めてくる。'
            '最大${patrolCap.inHours}時間分まで貯まる',
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.5)),
        const SizedBox(height: 10),
        _Chunky(
          color: _panelLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '見回り時間：${_patrolTime(minutes)}'
                  '${minutes >= patrolCap.inMinutes ? '（満タン）' : ''}',
                  style: const TextStyle(
                      color: _cream, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: minutes / patrolCap.inMinutes,
                  minHeight: 8,
                  color: _yellow,
                  backgroundColor: const Color(0xFF14161C),
                ),
              ),
              const SizedBox(height: 8),
              const Text('集まったもの',
                  style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 4),
              pending.isEmpty
                  ? const Text('まだ何もない',
                      style: TextStyle(color: _cream, fontSize: 13))
                  : _RewardRow(pending, size: 24),
              const SizedBox(height: 6),
              Text(
                  '1時間あたり ${perHour}G・素材${60 ~/ patrolMinutesPerMaterial}個'
                  '（ステージを解放すると増える）',
                  style: const TextStyle(color: _muted, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SmallButton(
          label: '受け取る',
          onTap: pending.isEmpty
              ? null
              : () {
                  profile.claimPatrol(now);
                  onChanged();
                },
        ),
      ],
    );
  }
}

class _ChestDialog extends StatelessWidget {
  final SurvivorProfile profile;
  final VoidCallback onChanged;

  const _ChestDialog({required this.profile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _MenuDialog(
      title: 'チャプター宝箱',
      children: [
        const Text('ステージで1分・3分・5分生き残ると、宝箱を1回ずつ開けられる',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final s in allStages)
                  if (profile.isUnlocked(s))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _Chunky(
                        color: _panelLight,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s.number}. ${s.name}',
                                style: const TextStyle(
                                    color: _cream,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                for (final c in chapterChests)
                                  Expanded(child: _chest(context, s, c)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chest(BuildContext context, StageDef s, ChapterChest c) {
    final claimed = profile.chestClaimed(s, c);
    final can = profile.canClaimChest(s, c);
    final label = '${c.seconds ~/ 60}分';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Icon(
            claimed ? Icons.check_circle_rounded : Icons.inventory_2_rounded,
            color: claimed
                ? const Color(0xFF6BE08A)
                : can
                    ? _yellow
                    : const Color(0xFF6A6E78),
            size: 30,
          ),
          _RewardRow(c.reward(s), size: 13),
          const SizedBox(height: 4),
          _SmallButton(
            label: claimed ? '済み' : label,
            onTap: can
                ? () {
                    profile.claimChest(s, c);
                    onChanged();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _MissionDialog extends StatefulWidget {
  final SurvivorProfile profile;
  final VoidCallback onChanged;

  const _MissionDialog({required this.profile, required this.onChanged});

  @override
  State<_MissionDialog> createState() => _MissionDialogState();
}

class _MissionDialogState extends State<_MissionDialog> {
  bool _daily = true;

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final now = DateTime.now();
    final list = _daily ? dailyMissions : achievements;
    Widget tab(String label, bool daily) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _SmallButton(
              label: label,
              color: _daily == daily ? _yellow : _panelLight,
              textColor: _daily == daily ? _ink : _cream,
              onTap: () => setState(() => _daily = daily),
            ),
          ),
        );
    return _MenuDialog(
      title: 'ミッション',
      children: [
        Row(children: [tab('毎日', true), tab('実績', false)]),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final m in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _missionCard(p, m, now),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _missionCard(SurvivorProfile p, MissionDef m, DateTime now) {
    final progress = p.missionProgress(m, now: now);
    final claimed = p.missionClaimed(m, now: now);
    final can = p.canClaimMission(m, now: now);
    return _Chunky(
      color: claimed ? const Color(0xFF2A2E38) : _panelLight,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title,
                    style: TextStyle(
                        color: claimed ? _muted : _cream,
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / m.goal,
                          minHeight: 7,
                          color: const Color(0xFF6BE08A),
                          backgroundColor: const Color(0xFF14161C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('$progress/${m.goal}',
                        style: const TextStyle(color: _muted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                _RewardRow(m.reward, size: 15),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SmallButton(
            label: claimed ? '済み' : '受け取る',
            onTap: can
                ? () {
                    p.claimMission(m, now: now);
                    widget.onChanged();
                    setState(() {});
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 才能タブ：お金で上げる、ずっと残る強化

class _TalentTab extends StatelessWidget {
  final SurvivorProfile profile;
  final ValueChanged<TalentId> onUpgrade;

  const _TalentTab({required this.profile, required this.onUpgrade});

  static const Map<TalentId, (IconData, Color)> _looks = {
    TalentId.vitality: (Icons.favorite_rounded, Color(0xFFE5484D)),
    TalentId.power: (Icons.fitness_center_rounded, Color(0xFFE0883A)),
    TalentId.swiftness: (Icons.directions_run_rounded, Color(0xFF3F8FD6)),
    TalentId.insight: (Icons.auto_stories_rounded, Color(0xFF8E5BC9)),
    TalentId.magnet: (Icons.visibility_rounded, Color(0xFF3E9A5A)),
    TalentId.guard: (Icons.shield_rounded, Color(0xFF6E7488)),
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const OutlinedText('才能', size: 26),
        const SizedBox(height: 2),
        const Text('お金で店主を鍛える。上げた才能は、どの出撃でも最初から効く',
            style: TextStyle(
                color: _ink, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 10),
        for (final d in talentDefs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _talentCard(d),
          ),
      ],
    );
  }

  Widget _talentCard(TalentDef d) {
    final lv = profile.talentLevel(d.id);
    final maxed = lv >= d.maxLevel;
    final (icon, color) = _looks[d.id]!;
    return _Chunky(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _ink, width: 2.5),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(d.name,
                        style: const TextStyle(
                            color: _cream,
                            fontWeight: FontWeight.w900,
                            fontSize: 15)),
                    const SizedBox(width: 6),
                    Text('Lv $lv / ${d.maxLevel}',
                        style: const TextStyle(color: _muted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('1レベルごとに ${d.perLevel}',
                    style: const TextStyle(color: _muted, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var i = 0; i < d.maxLevel; i++)
                      Expanded(
                        child: Container(
                          height: 6,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: i < lv ? color : const Color(0xFF14161C),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _SmallButton(
            label: maxed ? 'MAX' : '上げる',
            sub: maxed ? null : '${d.costAt(lv)}G',
            onTap:
                profile.canUpgradeTalent(d.id) ? () => onUpgrade(d.id) : null,
          ),
        ],
      ),
    );
  }
}
