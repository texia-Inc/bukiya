import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';

class BuybackAlertCard extends StatelessWidget {
  final List<QuestResult> urgentBuybacks;
  final VoidCallback onTap;

  const BuybackAlertCard({
    super.key,
    required this.urgentBuybacks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mostUrgent = urgentBuybacks.first;
    final totalValue = urgentBuybacks.fold<int>(
      0, 
      (sum, result) => sum + result.totalBuybackPrice,
    );
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.errorColor,
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
                  AppTheme.errorColor.withValues(alpha: 0.1),
                  AppTheme.errorColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // アラートアイコン
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // アラート情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '緊急買取案件',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${urgentBuybacks.length}件',
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
                        Text(
                          '最短期限: ${mostUrgent.remainingBuybackMinutes}分',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '総額: ${totalValue}G',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 矢印アイコン
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
