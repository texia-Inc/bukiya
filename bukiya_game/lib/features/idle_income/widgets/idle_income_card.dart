import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/idle_income_provider.dart';

/// 放置収入表示カード
class IdleIncomeCard extends StatefulWidget {
  const IdleIncomeCard({super.key});

  @override
  State<IdleIncomeCard> createState() => _IdleIncomeCardState();
}

class _IdleIncomeCardState extends State<IdleIncomeCard> {
  @override
  void initState() {
    super.initState();
    // カード表示時に放置収入状況を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IdleIncomeProvider>().loadIdleIncomeStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IdleIncomeProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.secondaryColor.withOpacity(0.1),
                  AppTheme.accentColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 16),
                _buildIncomeDisplay(context, provider),
                const SizedBox(height: 16),
                _buildProgressBar(context, provider),
                const SizedBox(height: 16),
                _buildActionButton(context, provider),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  _buildErrorMessage(context, provider.error!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, IdleIncomeProvider provider) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.savings,
            color: AppTheme.secondaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '店舗経営収入',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${provider.currentIncomePerMinute.toStringAsFixed(1)}G/分',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (provider.isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildIncomeDisplay(BuildContext context, IdleIncomeProvider provider) {
    final hasIncome = provider.availableIncome > 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasIncome 
            ? AppTheme.successColor.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasIncome 
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '回収可能',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.availableIncome}G',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasIncome ? AppTheme.successColor : AppTheme.textPrimary,
            ),
          ),
          if (provider.elapsedMinutes > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${provider.elapsedMinutes}分経過',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, IdleIncomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '蓄積進捗',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${provider.progressPercentage}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: provider.progressRatio,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            provider.progressRatio >= 1.0 
                ? AppTheme.successColor 
                : AppTheme.accentColor,
          ),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          provider.progressRatio >= 1.0 
              ? '最大蓄積に到達'
              : '最大まで: ${provider.remainingTimeDisplay}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IdleIncomeProvider provider) {
    final hasIncome = provider.availableIncome > 0;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: hasIncome && !provider.isLoading
            ? () => _collectIncome(context, provider)
            : null,
        icon: Icon(
          hasIncome ? Icons.download : Icons.hourglass_empty,
          size: 20,
        ),
        label: Text(
          hasIncome 
              ? '${provider.availableIncome}G 回収'
              : '収入待機中',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasIncome 
              ? AppTheme.successColor 
              : AppTheme.surfaceColor,
          foregroundColor: hasIncome 
              ? Colors.white 
              : AppTheme.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _collectIncome(BuildContext context, IdleIncomeProvider provider) async {
    final success = await provider.collectIdleIncome();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${provider.availableIncome}ゴールドを回収しました！'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}