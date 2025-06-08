import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';

class BuybackDialog extends StatelessWidget {
  final QuestResult questResult;
  final Function(List<String> itemIds) onBuyback;
  final VoidCallback onReject;

  const BuybackDialog({
    super.key,
    required this.questResult,
    required this.onBuyback,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '買取案件',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${questResult.questArea}からの帰還品',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // アイテム詳細表示
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                      ),
                    ),
                    child: Text(
                      '獲得アイテム一覧',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: _buildRewardsList(questResult),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 総額表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                border: Border.all(color: AppTheme.secondaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '買取総額',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${questResult.totalBuybackPrice}G',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                      ),
                      child: Text(
                        '[拒否]',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onBuyback(questResult.rewards.where((r) => !r.isBought).map((r) => r.id).toList()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.successColor,
                          width: 1,
                        ),
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        '[買取する]',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsList(QuestResult questResult) {
    final availableRewards = questResult.rewards.where((r) => !r.isBought).toList();
    
    if (availableRewards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              '買取可能なアイテムがありません',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: availableRewards.length,
      itemBuilder: (context, index) {
        final reward = availableRewards[index];
        return _buildRewardItem(context, reward);
      },
    );
  }

  Widget _buildRewardItem(BuildContext context, QuestReward reward) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryColor.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // アイテムアイコン
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getItemTypeColor(reward.itemType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getItemTypeColor(reward.itemType).withOpacity(0.3),
              ),
            ),
            child: Icon(
              _getItemTypeIcon(reward.itemType),
              size: 18,
              color: _getItemTypeColor(reward.itemType),
            ),
          ),
          const SizedBox(width: 12),
          
          // アイテム情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemDisplayName(reward.itemType, reward.itemId),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (reward.quantity > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    '×${reward.quantity}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 買取価格
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${reward.buybackPrice ?? 0}G',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemTypeColor(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'material':
      case 'iron':
      case 'wood':
      case 'stone':
        return const Color(0xFF8D6E63); // ブラウン
      case 'gem':
      case 'crystal':
        return const Color(0xFF9C27B0); // パープル
      case 'gold':
      case 'coin':
        return const Color(0xFFFFB300); // ゴールド
      case 'potion':
      case 'herb':
        return const Color(0xFF4CAF50); // グリーン
      case 'weapon':
      case 'equipment':
        return const Color(0xFF2196F3); // ブルー
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getItemTypeIcon(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'material':
      case 'iron':
      case 'wood':
      case 'stone':
        return Icons.inventory_2;
      case 'gem':
      case 'crystal':
        return Icons.diamond;
      case 'gold':
      case 'coin':
        return Icons.paid;
      case 'potion':
      case 'herb':
        return Icons.local_pharmacy;
      case 'weapon':
      case 'equipment':
        return Icons.sports_martial_arts;
      default:
        return Icons.help_outline;
    }
  }

  String _getItemDisplayName(String itemType, String itemId) {
    // アイテムIDから表示名を生成
    // 実際の実装では、アイテムマスターデータから名前を取得する
    switch (itemType.toLowerCase()) {
      case 'material':
        return _getMaterialName(itemId);
      case 'gem':
        return _getGemName(itemId);
      case 'potion':
        return _getPotionName(itemId);
      default:
        return '${itemType} #$itemId';
    }
  }

  String _getMaterialName(String itemId) {
    switch (itemId) {
      case '1':
        return '鉄鉱石';
      case '2':
        return '銅鉱石';
      case '3':
        return '銀鉱石';
      case '4':
        return '金鉱石';
      case '5':
        return '硬い木材';
      case '6':
        return '魔法の木材';
      case '7':
        return '石材';
      case '8':
        return '魔石';
      default:
        return '素材 #$itemId';
    }
  }

  String _getGemName(String itemId) {
    switch (itemId) {
      case '1':
        return 'ルビー';
      case '2':
        return 'サファイア';
      case '3':
        return 'エメラルド';
      case '4':
        return 'ダイヤモンド';
      default:
        return '宝石 #$itemId';
    }
  }

  String _getPotionName(String itemId) {
    switch (itemId) {
      case '1':
        return '体力回復薬';
      case '2':
        return '魔力回復薬';
      case '3':
        return '万能薬';
      default:
        return 'ポーション #$itemId';
    }
  }
}
