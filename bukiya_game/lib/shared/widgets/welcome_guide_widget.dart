import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/tutorial/providers/tutorial_provider.dart';
import '../../shared/themes/app_theme.dart';

/// 新規プレイヤー向けのウェルカムガイドウィジェット
class WelcomeGuideWidget extends StatelessWidget {
  const WelcomeGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        if (!tutorialProvider.isNewPlayer) return const SizedBox.shrink();

        final guideState = tutorialProvider.guideState;
        final currentObjective = tutorialProvider.currentObjective;
        final recommendedActions = tutorialProvider.recommendedActions;

        return Card(
          margin: const EdgeInsets.all(8),
          elevation: 6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        guideState.isFirstTimeUser 
                            ? 'ようこそ武器屋へ！' 
                            : '今日の目標',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    if (!guideState.isFirstTimeUser)
                      IconButton(
                        onPressed: () => _dismissGuide(context, tutorialProvider),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // 現在の目標
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: AppTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentObjective,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 推奨アクション
                if (recommendedActions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '推奨アクション:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recommendedActions.take(3).map((action) => 
                    _buildActionItem(context, action)
                  ),
                ],

                // 進捗表示
                if (guideState.totalActionsCompleted > 0) ...[
                  const SizedBox(height: 16),
                  _buildProgressIndicator(context, guideState),
                ],

                // アクションボタン
                if (guideState.isFirstTimeUser) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _startGuidedTour(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ガイドを開始'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem(BuildContext context, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.successColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, guideState) {
    final totalMilestones = 10; // 基本的なマイルストーン数
    final progress = (guideState.totalActionsCompleted / totalMilestones).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '進捗',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${guideState.totalActionsCompleted}/$totalMilestones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
        ),
      ],
    );
  }

  void _startGuidedTour(BuildContext context) {
    // ガイドツアーを開始 - ショップタブに移動
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ショップタブを確認してみましょう！'),
        backgroundColor: AppTheme.primaryColor,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  void _dismissGuide(BuildContext context, TutorialProvider tutorialProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ガイドを非表示'),
        content: const Text('新規プレイヤーガイドを非表示にしますか？\n後で設定から再表示できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              tutorialProvider.updateGuideState(
                tutorialProvider.guideState.copyWith(
                  hasCompletedTutorial: true,
                ),
              );
            },
            child: const Text('非表示にする'),
          ),
        ],
      ),
    );
  }
}