import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/mission_provider.dart';

/// セッション統計表示カード
/// 
/// 現在のセッション中に実行されたアクションの統計を表示します
class SessionStatsCard extends StatelessWidget {
  const SessionStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MissionProvider>(
      builder: (context, missionProvider, child) {
        final sessionStats = missionProvider.sessionStats;
        
        if (sessionStats.isEmpty) {
          return _buildEmptyState();
        }
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildStatsList(sessionStats),
              const SizedBox(height: 12),
              _buildResetButton(context, missionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.query_stats,
            size: 48,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'セッション開始',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'アクションを実行するとここに統計が表示されます',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.analytics,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '--- セッション統計 ---',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const Spacer(),
        Icon(
          Icons.trending_up,
          color: AppTheme.successColor,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildStatsList(Map<String, int> sessionStats) {
    final totalActions = sessionStats.values.fold(0, (sum, count) => sum + count);
    
    return Column(
      children: [
        // 合計アクション数
        _buildTotalRow(totalActions),
        const SizedBox(height: 8),
        
        // 個別アクション統計
        ...sessionStats.entries.map((entry) {
          return _buildStatRow(entry.key, entry.value, totalActions);
        }).toList(),
      ],
    );
  }

  Widget _buildTotalRow(int totalActions) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.successColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.summarize,
            size: 16,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Text(
            '合計アクション',
            style: TextStyle(
              color: AppTheme.successColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Text(
            '$totalActions回',
            style: TextStyle(
              color: AppTheme.successColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String actionType, int count, int totalActions) {
    final percentage = totalActions > 0 ? (count / totalActions * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            _getActionIcon(actionType),
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getActionDisplayName(actionType),
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            '$count回',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($percentage%)',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, MissionProvider missionProvider) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () async {
          await missionProvider.resetSessionStats();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            '[統計リセット]',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
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
      case 'login':
        return 'ログイン';
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
      case 'login':
        return Icons.login;
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
}