import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/enchantment.dart';
import '../services/enchantment_failure_service.dart';

/// 強化されたエンチャント結果ダイアログ
/// 
/// 失敗時の詳細な補償情報と同情システムを表示します
class EnhancedResultDialog extends StatelessWidget {
  final EnchantmentResponse result;
  final EnchantmentFailureResult? failureResult;

  const EnhancedResultDialog({
    super.key,
    required this.result,
    this.failureResult,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: _getResultColor(), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border.all(color: _getResultColor(), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildMainResult(),
            if (failureResult != null && failureResult!.hasCompensation) ...[
              const SizedBox(height: 16),
              _buildCompensationSection(),
            ],
            if (failureResult?.nextSuccessRateBonus != null && failureResult!.nextSuccessRateBonus > 0) ...[
              const SizedBox(height: 16),
              _buildPitySection(),
            ],
            const SizedBox(height: 24),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getResultIcon(),
          color: _getResultColor(),
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getResultTitle(),
            style: TextStyle(
              color: _getResultColor(),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getResultColor().withValues(alpha: 0.1),
        border: Border.all(color: _getResultColor(), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- エンチャント結果 ---',
            style: TextStyle(
              color: _getResultColor(),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          _buildResultStats(),
        ],
      ),
    );
  }

  Widget _buildResultStats() {
    return Column(
      children: [
        _buildStatRow('レベル', '${result.beforeLevel} → ${result.afterLevel}'),
        _buildStatRow('消費ゴールド', '${result.cost}G'),
        _buildStatRow('成功率', '${(result.successRate * 100).toStringAsFixed(1)}%'),
        if (failureResult?.protectionUsed == true)
          _buildStatRow('保護アイテム', '使用済み', color: AppTheme.successColor),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompensationSection() {
    if (failureResult == null || !failureResult!.hasCompensation) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.successColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: AppTheme.successColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '--- 補償アイテム ---',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // ゴールド補償
          if (failureResult!.goldCompensation > 0)
            _buildCompensationItem(
              icon: Icons.monetization_on,
              label: 'ゴールド',
              value: '${failureResult!.goldCompensation}G',
              color: AppTheme.accentColor,
            ),
          
          // 素材補償
          if (failureResult!.materialCompensation.isNotEmpty)
            ...failureResult!.materialCompensation.map((material) =>
              _buildCompensationItem(
                icon: Icons.inventory,
                label: material.materialName,
                value: 'x${material.quantity}',
                color: _getMaterialRarityColor(material.rarity),
              ),
            ).toList(),
          
          // 同情ポイント
          if (failureResult!.pityPointsGained > 0)
            _buildCompensationItem(
              icon: Icons.favorite,
              label: '同情ポイント',
              value: '+${failureResult!.pityPointsGained}',
              color: AppTheme.rareColor,
            ),
        ],
      ),
    );
  }

  Widget _buildCompensationItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitySection() {
    if (failureResult == null || failureResult!.nextSuccessRateBonus <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.rareColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.rareColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: AppTheme.rareColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '--- 次回ボーナス ---',
                style: TextStyle(
                  color: AppTheme.rareColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '失敗に対する救済措置として、次回の同じエンチャントの成功率が${(failureResult!.nextSuccessRateBonus * 100).toStringAsFixed(1)}%アップします！',
            style: TextStyle(
              color: AppTheme.rareColor,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor, width: 1),
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
          ),
          child: Text(
            '[了解]',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  IconData _getResultIcon() {
    switch (result.result) {
      case EnchantmentResult.success:
        return Icons.check_circle;
      case EnchantmentResult.failure:
        return failureResult?.protectionUsed == true ? Icons.shield : Icons.error;
      case EnchantmentResult.destroy:
        return failureResult?.protectionUsed == true ? Icons.shield : Icons.dangerous;
    }
  }

  Color _getResultColor() {
    if (failureResult?.protectionUsed == true) {
      return AppTheme.successColor;
    }
    
    switch (result.result) {
      case EnchantmentResult.success:
        return AppTheme.successColor;
      case EnchantmentResult.failure:
        return AppTheme.accentColor;
      case EnchantmentResult.destroy:
        return AppTheme.errorColor;
    }
  }

  String _getResultTitle() {
    if (failureResult?.protectionUsed == true) {
      return '=== 保護成功 ===';
    }
    
    switch (result.result) {
      case EnchantmentResult.success:
        return '=== エンチャント成功！ ===';
      case EnchantmentResult.failure:
        return '=== エンチャント失敗 ===';
      case EnchantmentResult.destroy:
        return '=== 武器破壊 ===';
    }
  }

  Color _getMaterialRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return AppTheme.textSecondary;
      case 'uncommon':
        return AppTheme.successColor;
      case 'rare':
        return AppTheme.accentColor;
      case 'epic':
        return AppTheme.rareColor;
      case 'legendary':
        return AppTheme.legendaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  /// ダイアログを表示
  static Future<void> show(
    BuildContext context,
    EnchantmentResponse result, {
    EnchantmentFailureResult? failureResult,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedResultDialog(
        result: result,
        failureResult: failureResult,
      ),
    );
  }
}