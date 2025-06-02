import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer.dart';

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
    final urgencyColor = _getUrgencyColor(request?.urgency ?? 1);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: urgencyColor.withOpacity(0.3),
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
                urgencyColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー行
                Row(
                  children: [
                    // アバター
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        adventurer.professionIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // 基本情報
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                adventurer.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Lv.${adventurer.level}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _getProfessionName(adventurer.profession),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTrustColor(adventurer.trustLevel),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  adventurer.trustLevelName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 残り時間
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
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
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // 要求情報
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: urgencyColor,
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
                          '${_getWeaponTypeName(request.weaponType)}を探しています',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 要求詳細
                  Row(
                    children: [
                      Expanded(
                        child: _buildRequirementItem(
                          Icons.flash_on,
                          '攻撃力',
                          '${request.minAttack}+',
                          AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRequirementItem(
                          Icons.monetization_on,
                          '予算',
                          '${request.maxBudget}G',
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // 説明
                  Text(
                    request.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                if (onAction != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.handshake, size: 18),
                      label: const Text('取引する'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
