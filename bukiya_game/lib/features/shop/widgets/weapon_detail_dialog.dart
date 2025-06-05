import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/weapon.dart';

class WeaponDetailDialog extends StatelessWidget {
  final Weapon weapon;
  final bool isPurchaseMode;
  final VoidCallback? onPurchase;
  final VoidCallback? onSell;

  const WeaponDetailDialog({
    super.key,
    required this.weapon,
    required this.isPurchaseMode,
    this.onPurchase,
    this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppTheme.getRarityColor(weapon.rarity);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rarityColor.withValues(alpha: 0.1),
                    rarityColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: rarityColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getWeaponIcon(weapon.weaponType),
                      color: rarityColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            weapon.rarity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // コンテンツ
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 説明
                    if (weapon.description.isNotEmpty) ...[
                      Text(
                        '説明',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weapon.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // ステータス
                    Text(
                      'ステータス',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildStatRow(
                      context,
                      Icons.flash_on,
                      '攻撃力',
                      weapon.attack.toString(),
                      AppTheme.accentColor,
                    ),
                    const SizedBox(height: 8),
                    
                    _buildStatRow(
                      context,
                      Icons.category,
                      '武器タイプ',
                      weapon.weaponType,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    
                    _buildStatRow(
                      context,
                      Icons.star,
                      '必要レベル',
                      weapon.requiredLevel.toString(),
                      AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    
                    // 価格
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isPurchaseMode ? '価格' : '売却価格',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: AppTheme.secondaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPurchaseMode 
                                    ? weapon.price.toString()
                                    : (weapon.price * 0.7).round().toString(),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ボタン
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('閉じる'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isPurchaseMode ? onPurchase : onSell,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPurchaseMode 
                            ? AppTheme.primaryColor 
                            : AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPurchaseMode ? Icons.shopping_cart : Icons.sell,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPurchaseMode ? '購入する' : '売却する',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getWeaponIcon(String weaponType) {
    switch (weaponType.toLowerCase()) {
      case 'sword':
        return Icons.sports_martial_arts;
      case 'axe':
        return Icons.construction;
      case 'bow':
        return Icons.sports_golf;
      case 'staff':
        return Icons.auto_fix_high;
      case 'dagger':
        return Icons.content_cut;
      case 'hammer':
        return Icons.build;
      default:
        return Icons.sports_martial_arts;
    }
  }
}
