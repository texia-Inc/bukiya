import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/tutorial/providers/tutorial_provider.dart';
import '../../shared/themes/app_theme.dart';

/// クイックスタートカード - 新規プレイヤー向けの即座に実行可能なアクション
class QuickStartCard extends StatelessWidget {
  final VoidCallback? onActionTap;

  const QuickStartCard({
    super.key,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        // 経験者には表示しない
        if (!tutorialProvider.isNewPlayer) {
          return const SizedBox.shrink();
        }

        final guideState = tutorialProvider.guideState;
        final recommendedActions = tutorialProvider.recommendedActions;

        if (recommendedActions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.05),
                  AppTheme.accentColor.withOpacity(0.05),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.rocket_launch,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'クイックスタート',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '始めやすいアクションから試してみましょう',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // アクションリスト
                ...recommendedActions.take(3).map((action) => 
                  _buildActionButton(context, action, guideState)
                ),

                // 進捗表示
                if (guideState.totalActionsCompleted > 0) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(context, guideState),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, String action, guideState) {
    IconData icon;
    Color color;
    VoidCallback? onTap;

    // アクションに応じてアイコンと色を設定
    switch (action) {
      case 'ショップタブを開く':
        icon = Icons.store;
        color = AppTheme.primaryColor;
        onTap = () => _navigateToTab(context, 1);
        break;
      case '武器を購入する':
        icon = Icons.shopping_cart;
        color = AppTheme.accentColor;
        onTap = () => _navigateToTab(context, 1);
        break;
      case '冒険者に武器を販売する':
        icon = Icons.sell;
        color = AppTheme.successColor;
        onTap = () => _navigateToTab(context, 3);
        break;
      case '合成タブを確認する':
        icon = Icons.build;
        color = Colors.orange;
        onTap = () => _navigateToTab(context, 5);
        break;
      case '武器を作成する':
        icon = Icons.construction;
        color = Colors.deepOrange;
        onTap = () => _navigateToTab(context, 5);
        break;
      case '冒険者タブを確認する':
        icon = Icons.people;
        color = Colors.blue;
        onTap = () => _navigateToTab(context, 3);
        break;
      default:
        icon = Icons.check_circle_outline;
        color = AppTheme.textSecondary;
        onTap = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    action,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, guideState) {
    final progress = (guideState.totalActionsCompleted / 10).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '初心者ガイドの進捗',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${guideState.totalActionsCompleted}/10',
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
        const SizedBox(height: 4),
        if (progress >= 1.0)
          Text(
            '🎉 初心者ガイド完了！武器屋経営を楽しみましょう',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  void _navigateToTab(BuildContext context, int tabIndex) {
    // ダッシュボードの親ウィジェットにタブ変更を通知
    // 実際の実装では、コールバックやProvider経由でタブを変更
    onActionTap?.call();
    
    // ユーザーへのフィードバック
    final tabNames = {
      1: 'ショップ',
      3: '冒険者',
      5: '合成',
    };
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tabNames[tabIndex]}タブを確認してみましょう！'),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }
}