import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/idle_system.dart';
import '../providers/idle_provider.dart';

class IdleIncomeCard extends StatelessWidget {
  const IdleIncomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IdleProvider>(
      builder: (context, idleProvider, child) {
        final idleSystem = idleProvider.idleSystem;
        
        if (idleSystem == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '放置収益システム',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 現在の収益率
                _buildIncomeRateSection(context, idleSystem),
                const SizedBox(height: 12),
                
                // 待機中の収益
                _buildPendingIncomeSection(context, idleProvider),
                const SizedBox(height: 12),
                
                // レベル情報
                _buildLevelSection(context, idleSystem),
                const SizedBox(height: 16),
                
                // 収益回収ボタン
                _buildCollectButton(context, idleProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeRateSection(BuildContext context, IdleSystem idleSystem) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '収益率',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                idleSystem.efficiencyDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '倍率',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '×${idleSystem.multiplier.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingIncomeSection(BuildContext context, IdleProvider idleProvider) {
    final pendingIncome = idleProvider.currentPendingIncome;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '待機中の収益',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${pendingIncome}G',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.trending_up,
            color: AppTheme.successColor,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSection(BuildContext context, IdleSystem idleSystem) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'レベル ${idleSystem.currentLevel}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'アップグレード数: ${idleSystem.upgradeCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Lv.${idleSystem.currentLevel}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectButton(BuildContext context, IdleProvider idleProvider) {
    final pendingIncome = idleProvider.currentPendingIncome;
    final isLoading = idleProvider.isLoading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: pendingIncome > 0 && !isLoading
            ? () => _collectIncome(context, idleProvider)
            : null,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.download),
        label: Text(
          pendingIncome > 0
              ? '${pendingIncome}G を回収'
              : '回収可能な収益なし',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: pendingIncome > 0
              ? AppTheme.successColor
              : AppTheme.surfaceColor,
          foregroundColor: pendingIncome > 0
              ? Colors.white
              : AppTheme.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _collectIncome(BuildContext context, IdleProvider idleProvider) async {
    final result = await idleProvider.collectIncome();
    
    if (result != null && context.mounted) {
      _showCollectionResult(context, result);
    } else if (idleProvider.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(idleProvider.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showCollectionResult(BuildContext context, IdleCollectionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('収益回収完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.offlineTime.inSeconds > 0) ...[
              Text('オフライン時間: ${result.offlineTimeDisplay}'),
              const SizedBox(height: 8),
            ],
            Text('獲得ゴールド: ${result.goldEarned}G'),
            if (result.experienceGained > 0) ...[
              const SizedBox(height: 4),
              Text('獲得経験値: ${result.experienceGained}'),
            ],
            if (result.leveledUp) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'レベルアップ！ Lv.${result.newLevel}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
