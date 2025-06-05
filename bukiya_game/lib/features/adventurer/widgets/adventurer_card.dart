import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';

class AdventurerCard extends StatelessWidget {
  final Adventurer adventurer;
  final VoidCallback onTap;
  final VoidCallback? onAction;

  const AdventurerCard({
    super.key,
    required this.adventurer,
    required this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final request = adventurer.currentRequest;
    final professionColor = _getProfessionColor(adventurer.profession);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー行
              Row(
                children: [
                  // アバター
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: professionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: professionColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        adventurer.professionIcon,
                        style: TextStyle(
                          fontSize: 20,
                          color: professionColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 基本情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adventurer.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_getProfessionName(adventurer.profession)} • Lv.${adventurer.level}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 残り時間と信頼度
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTrustColor(adventurer.trustLevel),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          adventurer.trustLevelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${adventurer.remainingVisitMinutes}分',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: adventurer.remainingVisitMinutes <= 10
                              ? AppTheme.errorColor
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (request != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(request.urgency),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              request.urgencyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getWeaponTypeName(request.weaponType)}を探している',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '攻撃力${request.minAttack}+ • 予算${request.maxBudget}G',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (onAction != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        width: 60,
                        height: 32,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.successColor,
                            width: 1,
                          ),
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.handshake,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProfessionColor(String profession) {
    switch (profession.toLowerCase()) {
      case 'warrior':
        return AppTheme.primaryColor;
      case 'archer':
        return AppTheme.accentColor;
      case 'mage':
        return Colors.purple;
      case 'rogue':
      case 'thief':
        return Colors.orange;
      case 'paladin':
        return Colors.blue;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getUrgencyColor(int urgency) {
    switch (urgency) {
      case 5:
        return AppTheme.errorColor;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 2:
        return AppTheme.successColor;
      case 1:
        return Colors.blue;
      default:
        return Colors.amber;
    }
  }

  Color _getTrustColor(int trustLevel) {
    if (trustLevel >= 80) return AppTheme.successColor;
    if (trustLevel >= 60) return Colors.blue;
    if (trustLevel >= 40) return Colors.amber;
    if (trustLevel >= 20) return Colors.orange;
    return AppTheme.errorColor;
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