import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';

class BulkBuybackResultDialog extends StatelessWidget {
  final Map<String, dynamic> result;

  const BulkBuybackResultDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final items = (result['items_purchased'] as List<dynamic>?) ?? [];
    final totalItems = result['total_items'] as int? ?? 0;
    final totalCost = result['total_cost'] as int? ?? 0;
    final goldRemaining = result['gold_remaining'] as int? ?? 0;
    final expGained = result['exp_gained'] as int? ?? 0;
    final shopLevel = result['shop_level'] as int? ?? 1;
    final shopLevelUp = result['shop_level_up'] as Map<String, dynamic>?;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_checkout,
                  color: AppTheme.successColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '一括買取完了',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 概要情報
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('購入アイテム数'),
                      Text(
                        '${totalItems}個',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('総費用'),
                      Text(
                        '${totalCost}G',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('残りゴールド'),
                      Text(
                        '${goldRemaining}G',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  if (expGained > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('獲得経験値'),
                        Text(
                          '+${expGained} EXP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (shopLevelUp != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shopLevelUp['message'] ?? 'レベルアップしました！',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              // 購入アイテム詳細
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '購入アイテム詳細',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index] as Map<String, dynamic>;
                            return _buildPurchasedItem(context, item, index == items.length - 1);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('確認'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchasedItem(BuildContext context, Map<String, dynamic> item, bool isLast) {
    final itemType = item['item_type'] as String? ?? '';
    final itemName = item['item_name'] as String? ?? '';
    final quantity = item['quantity'] as int? ?? 1;
    final price = item['price'] as int? ?? 0;
    final questAreaName = item['quest_area_name'] as String? ?? '';
    final adventurerName = item['adventurer_name'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: isLast 
            ? null 
            : Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          // アイテムアイコン
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getItemTypeColor(itemType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getItemTypeColor(itemType).withOpacity(0.3),
              ),
            ),
            child: Icon(
              _getItemTypeIcon(itemType),
              size: 22,
              color: _getItemTypeColor(itemType),
            ),
          ),
          const SizedBox(width: 12),
          
          // アイテム情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quantity > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    '×$quantity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        questAreaName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        adventurerName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 価格
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${price}G',
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
}