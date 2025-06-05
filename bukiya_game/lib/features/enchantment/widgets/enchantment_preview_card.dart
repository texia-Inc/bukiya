import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/features/enchantment/providers/enchantment_provider.dart';
import 'package:bukiya_game/core/models/enchantment.dart';

class EnchantmentPreviewCard extends StatelessWidget {
  const EnchantmentPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'エンチャントプレビュー',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<EnchantmentProvider>(
              builder: (context, provider, child) {
                if (provider.selectedWeapon == null) {
                  return _buildNoWeaponSelected(context);
                }

                if (provider.selectedEnchantmentType == null) {
                  return _buildNoEnchantmentTypeSelected(context);
                }

                return _buildEnchantmentPreview(context, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWeaponSelected(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text('武器を選択してください'),
        ],
      ),
    );
  }

  Widget _buildNoEnchantmentTypeSelected(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text('エンチャントタイプを選択してください'),
        ],
      ),
    );
  }

  Widget _buildEnchantmentPreview(BuildContext context, EnchantmentProvider provider) {
    final weapon = provider.selectedWeapon!;
    final enchantmentType = provider.selectedEnchantmentType!;
    final currentLevel = provider.getCurrentEnchantmentLevel(enchantmentType.id);
    final nextLevel = currentLevel + 1;
    final successRate = provider.calculateSuccessRate();
    final cost = provider.calculateEnchantmentCost();
    final materialBonus = provider.calculateMaterialBonus();

    return Column(
      children: [
        _buildWeaponInfo(context, weapon),
        const SizedBox(height: 16),
        _buildEnchantmentInfo(context, enchantmentType, currentLevel, nextLevel),
        const SizedBox(height: 16),
        _buildCostAndSuccess(context, cost, successRate, materialBonus),
        const SizedBox(height: 16),
        _buildEnchantButton(context, provider),
      ],
    );
  }

  Widget _buildWeaponInfo(BuildContext context, weapon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sports_martial_arts,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weapon.weaponMaster?.name ?? '武器名',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '攻撃力: ${weapon.totalAttack ?? weapon.attack}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnchantmentInfo(BuildContext context, enchantmentType, int currentLevel, int nextLevel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                enchantmentType.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                'レベル: $currentLevel → $nextLevel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '最大: ${enchantmentType.maxLevel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostAndSuccess(BuildContext context, int cost, double successRate, double materialBonus) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'コスト',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${cost}G',
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
                '基本成功率',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(successRate * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getSuccessRateColor(successRate),
                ),
              ),
            ],
          ),
          if (materialBonus > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '素材ボーナス',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '+${(materialBonus * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最終成功率',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${((successRate + materialBonus) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getSuccessRateColor(successRate + materialBonus),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnchantButton(BuildContext context, EnchantmentProvider provider) {
    final canEnchant = provider.canPerformEnchantment();
    final isLoading = provider.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: canEnchant && !isLoading ? () => _performEnchantment(context, provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canEnchant ? Theme.of(context).colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                canEnchant ? 'エンチャント実行' : 'エンチャント不可',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _performEnchantment(BuildContext context, EnchantmentProvider provider) async {
    try {
      await provider.performEnchantment();
      if (context.mounted) {
        // エンチャント結果ダイアログを表示
        final resultData = provider.lastEnchantmentResult;
        if (resultData != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(resultData.result == EnchantmentResult.success ? 'エンチャント成功！' : 'エンチャント失敗'),
              content: Text(resultData.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
