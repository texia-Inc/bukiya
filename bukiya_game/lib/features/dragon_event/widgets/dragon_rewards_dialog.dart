import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';

class DragonRewardsDialog extends StatefulWidget {
  final DragonRewardsResponse rewards;

  const DragonRewardsDialog({
    Key? key,
    required this.rewards,
  }) : super(key: key);

  @override
  State<DragonRewardsDialog> createState() => _DragonRewardsDialogState();
}

class _DragonRewardsDialogState extends State<DragonRewardsDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: theme.dialogBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Trophy Icon
                    Transform.rotate(
                      angle: _rotationAnimation.value * 0.1,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.rewards.isMvp ? Colors.amber : Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.rewards.isMvp 
                                  ? Colors.amber.withOpacity(0.4)
                                  : Colors.blue.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.rewards.isMvp ? Icons.emoji_events : Icons.card_giftcard,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.rewards.isMvp ? 'MVP REWARDS!' : 'Rewards Claimed!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.rewards.isMvp ? Colors.amber[800] : theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.rewards.isMvp) ...[
                      const SizedBox(height: 8),
                      Text(
                        'You dealt the most damage!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Rank Information
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rank #${widget.rewards.rank} • ${widget.rewards.totalDamage} Damage',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rewards Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildRewardRow(
                            'Participation Reward',
                            widget.rewards.participationReward,
                            Icons.monetization_on,
                          ),
                          if (widget.rewards.victoryBonus > 0) ...[
                            const SizedBox(height: 8),
                            _buildRewardRow(
                              'Victory Bonus',
                              widget.rewards.victoryBonus,
                              Icons.celebration,
                            ),
                          ],
                          if (widget.rewards.mvpBonus > 0) ...[
                            const SizedBox(height: 8),
                            _buildRewardRow(
                              'MVP Bonus',
                              widget.rewards.mvpBonus,
                              Icons.emoji_events,
                              isSpecial: true,
                            ),
                          ],
                          const Divider(height: 20),
                          _buildRewardRow(
                            'Total Gold',
                            widget.rewards.totalReward,
                            Icons.account_balance_wallet,
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check),
                        label: const Text('Awesome!'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: widget.rewards.isMvp ? Colors.amber : null,
                          foregroundColor: widget.rewards.isMvp ? Colors.white : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardRow(
    String label,
    int amount,
    IconData icon, {
    bool isSpecial = false,
    bool isTotal = false,
  }) {
    Color color = Colors.green;
    if (isSpecial) color = Colors.amber;
    if (isTotal) color = Colors.blue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? color : null,
              ),
            ),
          ],
        ),
        Text(
          '+${amount.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )} G',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}