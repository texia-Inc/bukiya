import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';

class AdventurerDetailDialog extends StatelessWidget {
  final Adventurer adventurer;
  final VoidCallback? onSellWeapon;
  final VoidCallback? onDispatchQuest;

  const AdventurerDetailDialog({
    super.key,
    required this.adventurer,
    this.onSellWeapon,
    this.onDispatchQuest,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    adventurer.professionIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adventurer.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Lv.${adventurer.level} ${_getProfessionName(adventurer.profession)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 詳細情報
            _buildInfoRow('信頼度', adventurer.trustLevelName),
            _buildInfoRow('予算', '${adventurer.budget}G'),
            _buildInfoRow('好みの武器', _getWeaponTypeName(adventurer.preferredWeaponType)),
            
            const SizedBox(height: 24),
            
            // アクションボタン
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                      ),
                      child: Text(
                        '[閉じる]',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onSellWeapon != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onSellWeapon!();
                      },
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
                          '[取引する]',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getProfessionName(String profession) {
    switch (profession.toLowerCase()) {
      case 'warrior':
        return '戦士';
      case 'archer':
        return '弓使い';
      case 'mage':
        return '魔法使い';
      case 'rogue':
        return '盗賊';
      case 'paladin':
        return '聖騎士';
      default:
        return profession;
    }
  }

  String _getWeaponTypeName(String weaponType) {
    switch (weaponType.toLowerCase()) {
      case 'sword':
        return '剣';
      case 'bow':
        return '弓';
      case 'staff':
        return '杖';
      case 'dagger':
        return '短剣';
      case 'axe':
        return '斧';
      case 'hammer':
        return 'ハンマー';
      default:
        return weaponType;
    }
  }
}
