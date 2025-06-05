import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/badge_widget.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onShopTap;
  final VoidCallback onInventoryTap;
  final VoidCallback onCraftingTap;
  final VoidCallback onCollectIncome;
  final int? craftingBadgeCount;
  final int? incomeBadgeCount;
  final int? inventoryBadgeCount;

  const QuickActionsCard({
    super.key,
    required this.onShopTap,
    required this.onInventoryTap,
    required this.onCraftingTap,
    required this.onCollectIncome,
    this.craftingBadgeCount,
    this.incomeBadgeCount,
    this.inventoryBadgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flash_on,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'クイックアクション',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.store,
                    'ショップ',
                    AppTheme.primaryColor,
                    onShopTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.inventory,
                    'インベントリ',
                    AppTheme.secondaryColor,
                    onInventoryTap,
                    badgeCount: inventoryBadgeCount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.build,
                    '武器合成',
                    AppTheme.accentColor,
                    onCraftingTap,
                    badgeCount: craftingBadgeCount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    Icons.monetization_on,
                    '収益回収',
                    AppTheme.successColor,
                    onCollectIncome,
                    badgeCount: incomeBadgeCount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            AnimatedBadgeWidget(
              count: badgeCount,
              showBadge: badgeCount != null && badgeCount > 0,
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
