import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';

class OfflineIncomeDialog extends StatelessWidget {
  final int income;
  final VoidCallback onCollect;

  const OfflineIncomeDialog({
    super.key,
    required this.income,
    required this.onCollect,
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
            // アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.monetization_on,
                size: 40,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // タイトル
            Text(
              'おかえりなさい！',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // メッセージ
            Text(
              'あなたが離れている間に\n武器屋が収益を上げました！',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 収益表示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppTheme.secondaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+$income',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ゴールド',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCollect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '収益を回収する',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
