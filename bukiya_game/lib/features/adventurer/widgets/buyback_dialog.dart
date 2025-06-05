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
      child: Padding(
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
            const SizedBox(height: 8),
            Text(
              '総額: ${questResult.totalBuybackPrice}G',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
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
                    onTap: () => onBuyback(questResult.drops.map((d) => d.id).toList()),
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
}
