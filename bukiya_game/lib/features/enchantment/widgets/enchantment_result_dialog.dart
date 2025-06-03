import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/enchantment.dart';

class EnchantmentResultDialog extends StatelessWidget {
  final EnchantmentResponse result;

  const EnchantmentResultDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getResultIcon(),
            color: _getResultColor(),
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            _getResultTitle(),
            style: TextStyle(
              color: _getResultColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildResultDetails(context),
          if (result.materialsUsed != null) ...[
            const SizedBox(height: 16),
            _buildMaterialsUsed(context),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildResultDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getResultColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getResultColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'エンチャントレベル',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${result.beforeLevel} → ${result.afterLevel}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '消費ゴールド',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${result.cost}G',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '成功率',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(result.successRate * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsUsed(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用した素材',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '素材情報を表示',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  IconData _getResultIcon() {
    switch (result.result) {
      case EnchantmentResult.success:
        return Icons.check_circle;
      case EnchantmentResult.failure:
        return Icons.error;
      case EnchantmentResult.destroy:
        return Icons.dangerous;
    }
  }

  Color _getResultColor() {
    switch (result.result) {
      case EnchantmentResult.success:
        return Colors.green;
      case EnchantmentResult.failure:
        return Colors.orange;
      case EnchantmentResult.destroy:
        return Colors.red;
    }
  }

  String _getResultTitle() {
    switch (result.result) {
      case EnchantmentResult.success:
        return 'エンチャント成功！';
      case EnchantmentResult.failure:
        return 'エンチャント失敗';
      case EnchantmentResult.destroy:
        return '武器が破壊されました';
    }
  }
}
