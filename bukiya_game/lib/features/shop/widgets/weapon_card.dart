import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/weapon.dart';
import '../../../core/constants/app_constants.dart';

class WeaponCard extends StatelessWidget {
  final Weapon weapon;
  final bool isPurchaseMode;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const WeaponCard({
    super.key,
    required this.weapon,
    required this.isPurchaseMode,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = AppTheme.getRarityColor(weapon.rarity);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: rarityColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                rarityColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 武器アイコンとレアリティ
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rarityColor.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        _getWeaponIcon(weapon.weaponType),
                        color: rarityColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        weapon.rarity,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // 武器名
                Text(
                  weapon.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // 攻撃力
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weapon.attack.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // 必要レベル
                if (weapon.requiredLevel > 1) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppTheme.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lv.${weapon.requiredLevel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  const SizedBox(height: 16),
                ],
                
                const Spacer(),
                
                // 価格とボタン
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: AppTheme.secondaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                weapon.price.toString(),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPurchaseMode 
                              ? AppTheme.primaryColor 
                              : AppTheme.successColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Icon(
                          isPurchaseMode ? Icons.shopping_cart : Icons.sell,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
