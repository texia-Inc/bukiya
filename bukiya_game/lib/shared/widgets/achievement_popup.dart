import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/tutorial.dart';
import '../../core/services/tutorial_service.dart';
import '../../shared/themes/app_theme.dart';

/// 実績達成時のポップアップウィジェット
class AchievementPopup extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementPopup({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();

  /// 実績ポップアップを表示
  static void show(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AchievementPopup(achievement: achievement),
    );
  }
}

class _AchievementPopupState extends State<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _confettiController.forward();

    // 自動で閉じる
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 背景エフェクト
                    _buildConfettiBackground(),
                    
                    // メインコンテンツ
                    _buildContent(context),
                    
                    const SizedBox(height: 20),
                    
                    // ボタン
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _dismiss,
                            child: const Text('閉じる'),
                          ),
                        ),
                        if (widget.achievement.rewardGold > 0 ||
                            widget.achievement.rewardExp > 0)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _claimReward(context);
                                _dismiss();
                              },
                              icon: const Icon(Icons.redeem),
                              label: const Text('報酬を受け取る'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfettiBackground() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return SizedBox(
          height: 100,
          child: Stack(
            children: List.generate(10, (index) {
              final offset = Offset(
                (index * 40.0) % 300,
                _confettiController.value * 100 + (index * 10.0) % 50,
              );
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Transform.rotate(
                  angle: _confettiController.value * 6.28 * (index + 1),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: [
                        AppTheme.primaryColor,
                        AppTheme.accentColor,
                        AppTheme.successColor,
                        Colors.yellow,
                      ][index % 4],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // トロフィーアイコン
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.accentColor,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.emoji_events,
            size: 40,
            color: AppTheme.accentColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 実績達成テキスト
        Text(
          '実績達成！',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 実績タイトル
        Text(
          widget.achievement.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // 実績説明
        Text(
          widget.achievement.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        // 報酬表示
        if (widget.achievement.rewardGold > 0 ||
            widget.achievement.rewardExp > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '報酬',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.achievement.rewardGold > 0) ...[
                      Icon(
                        Icons.monetization_on,
                        color: AppTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.achievement.rewardGold}G',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (widget.achievement.rewardGold > 0 &&
                        widget.achievement.rewardExp > 0)
                      const SizedBox(width: 16),
                    if (widget.achievement.rewardExp > 0) ...[
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.achievement.rewardExp} EXP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _claimReward(BuildContext context) {
    // ここで実際に報酬を付与する処理を実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '報酬を受け取りました！ '
          '${widget.achievement.rewardGold > 0 ? '${widget.achievement.rewardGold}G ' : ''}'
          '${widget.achievement.rewardExp > 0 ? '${widget.achievement.rewardExp}EXP' : ''}',
        ),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}