import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/idle_system.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/idle_provider.dart';

class IdleUpgradesCard extends StatelessWidget {
  const IdleUpgradesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<IdleProvider, AuthProvider>(
      builder: (context, idleProvider, authProvider, child) {
        final upgrades = idleProvider.availableUpgrades;
        final playerGold = authProvider.currentPlayer?.gold ?? 0;
        
        if (upgrades.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('利用可能なアップグレードがありません'),
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
                      Icons.upgrade,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'アップグレード',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // アップグレードリスト
                ...upgrades.map((upgrade) => _buildUpgradeItem(
                  context,
                  upgrade,
                  playerGold,
                  idleProvider,
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpgradeItem(
    BuildContext context,
    IdleUpgrade upgrade,
    int playerGold,
    IdleProvider idleProvider,
  ) {
    final canAfford = upgrade.canUpgrade(playerGold);
    final isMaxLevel = upgrade.isMaxLevel;
    final paybackTime = idleProvider.calculatePaybackTime(upgrade.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: canAfford && !isMaxLevel
              ? AppTheme.primaryColor
              : AppTheme.surfaceColor,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isMaxLevel
            ? AppTheme.surfaceColor.withValues(alpha: 0.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー行
          Row(
            children: [
              // アイコン
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getUpgradeIcon(upgrade.iconName),
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // 名前とレベル
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lv.${upgrade.level}/${upgrade.maxLevel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // レベル表示
              if (!isMaxLevel)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? AppTheme.successColor
                        : AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Lv.${upgrade.level + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'MAX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 説明
          Text(
            upgrade.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          
          // 効果と統計
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrade.effectDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (paybackTime > 0 && !isMaxLevel) ...[
                      const SizedBox(height: 4),
                      Text(
                        '回収時間: ${_formatPaybackTime(paybackTime)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 購入ボタン
              if (!isMaxLevel)
                ElevatedButton(
                  onPressed: canAfford && !idleProvider.isLoading
                      ? () => _purchaseUpgrade(context, upgrade, idleProvider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? AppTheme.primaryColor
                        : AppTheme.surfaceColor,
                    foregroundColor: canAfford
                        ? Colors.white
                        : AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: idleProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('${upgrade.nextLevelCost}G'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getUpgradeIcon(String iconName) {
    switch (iconName) {
      case 'speed':
        return Icons.speed;
      case 'efficiency':
        return Icons.trending_up;
      case 'automation':
        return Icons.smart_toy;
      case 'multiplier':
        return Icons.close;
      case 'capacity':
        return Icons.storage;
      case 'quality':
        return Icons.star;
      default:
        return Icons.upgrade;
    }
  }

  String _formatPaybackTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}秒';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}分';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}時間${minutes}分';
    } else {
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      return '${days}日${hours}時間';
    }
  }

  Future<void> _purchaseUpgrade(
    BuildContext context,
    IdleUpgrade upgrade,
    IdleProvider idleProvider,
  ) async {
    final result = await idleProvider.purchaseUpgrade(upgrade.id);
    
    if (result != null && context.mounted) {
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${upgrade.name} をアップグレードしました！'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else if (idleProvider.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(idleProvider.errorMessage!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
