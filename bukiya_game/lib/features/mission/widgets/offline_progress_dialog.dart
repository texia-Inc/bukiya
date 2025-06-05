import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/services/mission_auto_progress_service.dart';

/// オフライン進捗表示ダイアログ
/// 
/// プレイヤーがアプリを再開した際に、オフライン期間中の進捗を表示します
class OfflineProgressDialog extends StatelessWidget {
  final OfflineProgressResult progressResult;
  final VoidCallback? onClose;

  const OfflineProgressDialog({
    super.key,
    required this.progressResult,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: AppTheme.accentColor, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border.all(color: AppTheme.accentColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            _buildHeader(),
            const SizedBox(height: 16),
            
            // オフライン時間表示
            _buildOfflineTimeInfo(),
            const SizedBox(height: 16),
            
            // 推定アクション表示
            if (progressResult.estimatedActions.isNotEmpty)
              _buildEstimatedActions(),
            
            const SizedBox(height: 16),
            
            // 収益表示
            _buildEarningsInfo(),
            const SizedBox(height: 24),
            
            // 閉じるボタン
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: AppTheme.accentColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '=== おかえりなさい！ ===',
          style: TextStyle(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- オフライン時間 ---',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressResult.offlineTimeDisplay,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'の間、ショップが自動運営されていました',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.successColor, width: 1),
        color: AppTheme.successColor.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- 自動実行されたアクション ---',
            style: TextStyle(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          ...progressResult.estimatedActions.entries.map((entry) {
            return _buildActionRow(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionRow(String actionType, int count) {
    final actionName = _getActionDisplayName(actionType);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _getActionIcon(actionType),
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$actionName:',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            '$count回',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accentColor, width: 1),
        color: AppTheme.accentColor.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- 獲得報酬 ---',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: 16,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'ゴールド: ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '${progressResult.goldEarned}G',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '経験値: ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '${progressResult.expGained}EXP',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          onClose?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor, width: 1),
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          child: Text(
            '[了解]',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  String _getActionDisplayName(String actionType) {
    switch (actionType) {
      case 'craft_weapon':
        return '武器作成';
      case 'sell_weapon':
        return '武器販売';
      case 'collect_material':
        return '素材収集';
      case 'dispatch_adventurer':
        return '冒険者派遣';
      case 'earn_gold':
        return 'ゴールド獲得';
      case 'upgrade_shop':
        return 'ショップ強化';
      case 'enchant_weapon':
        return '武器強化';
      case 'complete_quest':
        return 'クエスト完了';
      case 'buy_item':
        return 'アイテム購入';
      default:
        return actionType;
    }
  }

  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'craft_weapon':
        return Icons.build;
      case 'sell_weapon':
        return Icons.sell;
      case 'collect_material':
        return Icons.inventory;
      case 'dispatch_adventurer':
        return Icons.send;
      case 'earn_gold':
        return Icons.monetization_on;
      case 'upgrade_shop':
        return Icons.upgrade;
      case 'enchant_weapon':
        return Icons.auto_fix_high;
      case 'complete_quest':
        return Icons.task_alt;
      case 'buy_item':
        return Icons.shopping_cart;
      default:
        return Icons.pets;
    }
  }

  /// ダイアログを表示
  static Future<void> show(
    BuildContext context,
    OfflineProgressResult progressResult, {
    VoidCallback? onClose,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfflineProgressDialog(
        progressResult: progressResult,
        onClose: onClose,
      ),
    );
  }
}