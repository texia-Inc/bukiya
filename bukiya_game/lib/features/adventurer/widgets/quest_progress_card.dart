import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';

class QuestProgressCard extends StatefulWidget {
  final Adventurer adventurer;
  final VoidCallback onTap;

  const QuestProgressCard({
    super.key,
    required this.adventurer,
    required this.onTap,
  });

  @override
  State<QuestProgressCard> createState() => _QuestProgressCardState();
}

class _QuestProgressCardState extends State<QuestProgressCard> {
  @override
  Widget build(BuildContext context) {
    final questProgress = widget.adventurer.currentQuest;
    
    // クエスト情報がない場合は基本的な表示
    if (questProgress == null) {
      return _buildBasicCard(context);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分（冒険者情報）
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      widget.adventurer.professionIcon,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.adventurer.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${questProgress.questArea.name} • ${questProgress.remainingTimeText}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(questProgress),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 進捗バー
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '進捗',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        questProgress.progressText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: questProgress.isCompleted ? Colors.green : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: questProgress.progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      questProgress.isCompleted ? Colors.green : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // モンスター情報
              if (questProgress.monsterFighting != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getMonsterIcon(questProgress.monsterFighting!.monsterType),
                        color: AppTheme.warningColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${questProgress.monsterFighting!.name} (Lv.${questProgress.monsterFighting!.level})',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningColor,
                              ),
                            ),
                            if (questProgress.monsterFighting!.elementDisplayName.isNotEmpty)
                              Text(
                                '${questProgress.monsterFighting!.typeDisplayName} • ${questProgress.monsterFighting!.elementDisplayName}属性',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // 使用武器情報（簡略化）
              Row(
                children: [
                  Icon(
                    _getWeaponIcon(questProgress.weaponUsed.weaponType),
                    color: AppTheme.textSecondary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      questProgress.weaponUsed.fullDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '攻撃力 ${questProgress.weaponUsed.attack}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  widget.adventurer.professionIcon,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.adventurer.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '冒険中...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.explore, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(QuestProgress questProgress) {
    Color chipColor;
    String statusText;
    
    if (questProgress.isCompleted) {
      chipColor = Colors.green;
      statusText = '完了';
    } else {
      chipColor = AppTheme.primaryColor;
      statusText = '冒険中';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getQuestAreaColor(String colorCode) {
    try {
      return Color(int.parse(colorCode.replaceFirst('#', '0xff')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  IconData _getAreaIcon(String areaType) {
    switch (areaType.toLowerCase()) {
      case 'forest':
      case 'dark_forest':
        return Icons.forest;
      case 'cave':
        return Icons.terrain;
      case 'mountain':
        return Icons.landscape;
      case 'desert':
        return Icons.wb_sunny;
      case 'plain':
        return Icons.grass;
      case 'swamp':
        return Icons.water;
      case 'valley':
        return Icons.panorama_horizontal;
      default:
        return Icons.explore;
    }
  }

  IconData _getWeaponIcon(String weaponType) {
    switch (weaponType.toLowerCase()) {
      case 'sword':
        return Icons.sports_martial_arts;
      case 'bow':
        return Icons.sports_cricket;
      case 'staff':
        return Icons.auto_fix_high;
      case 'dagger':
        return Icons.content_cut;
      case 'hammer':
        return Icons.construction;
      default:
        return Icons.hardware;
    }
  }

  IconData _getMonsterIcon(String monsterType) {
    switch (monsterType.toLowerCase()) {
      case 'beast':
        return Icons.pets;
      case 'humanoid':
        return Icons.person;
      case 'undead':
        return Icons.dangerous;
      case 'elemental':
        return Icons.flash_on;
      case 'dragon':
        return Icons.whatshot;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'flying':
        return Icons.flight;
      default:
        return Icons.bug_report;
    }
  }
}
