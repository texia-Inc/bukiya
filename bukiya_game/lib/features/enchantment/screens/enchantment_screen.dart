import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/enchantment.dart';
import 'package:bukiya_game/core/models/weapon.dart';
import 'package:bukiya_game/features/enchantment/providers/enchantment_provider.dart';
import 'package:bukiya_game/features/enchantment/widgets/weapon_selection_card.dart';
import 'package:bukiya_game/features/enchantment/widgets/enchantment_type_selection_card.dart';
import 'package:bukiya_game/features/enchantment/widgets/material_selection_card.dart';
import 'package:bukiya_game/features/enchantment/widgets/enchantment_preview_card.dart';
import 'package:bukiya_game/features/enchantment/widgets/enchantment_result_dialog.dart';
import 'package:bukiya_game/shared/widgets/loading_screen.dart';

class EnchantmentScreen extends StatefulWidget {
  const EnchantmentScreen({super.key});

  @override
  State<EnchantmentScreen> createState() => _EnchantmentScreenState();
}

class _EnchantmentScreenState extends State<EnchantmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnchantmentProvider>().loadEnchantmentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('エンチャント'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showEnchantmentHistory(context),
            tooltip: 'エンチャント履歴',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showEnchantmentInfo(context),
            tooltip: 'エンチャント情報',
          ),
        ],
      ),
      body: Consumer<EnchantmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingScreen();
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadEnchantmentData();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // エンチャント統計カード
                if (provider.stats != null) _buildStatsCard(provider.stats!),
                const SizedBox(height: 16),

                // 武器選択カード
                const WeaponSelectionCard(),
                const SizedBox(height: 16),

                // エンチャントタイプ選択カード
                if (provider.selectedWeapon != null) ...[
                  const EnchantmentTypeSelectionCard(),
                  const SizedBox(height: 16),
                ],

                // 素材選択カード
                if (provider.selectedEnchantmentType != null) ...[
                  const MaterialSelectionCard(),
                  const SizedBox(height: 16),
                ],

                // エンチャントプレビューカード
                if (provider.selectedWeapon != null && 
                    provider.selectedEnchantmentType != null) ...[
                  const EnchantmentPreviewCard(),
                  const SizedBox(height: 24),
                ],

                // エンチャント実行ボタン
                if (provider.canEnchant()) _buildEnchantButton(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(EnchantmentStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'エンチャント統計',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '総回数',
                    stats.totalEnchantments.toString(),
                    Icons.auto_fix_high,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '成功率',
                    '${(stats.successRate * 100).toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '平均レベル',
                    stats.averageLevel.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '総コスト',
                    '${stats.totalCost}G',
                    Icons.monetization_on,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildEnchantButton(EnchantmentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'エンチャント実行',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.calculateEnchantmentCost()}G',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '成功率: ${(provider.calculateSuccessRate() * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isEnchanting ? null : () => _performEnchantment(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: provider.isEnchanting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'エンチャント開始',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performEnchantment(EnchantmentProvider provider) async {
    final success = await provider.performEnchantment();
    
    if (success && provider.lastEnchantmentResult != null) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EnchantmentResultDialog(
            result: provider.lastEnchantmentResult!,
          ),
        );
        provider.clearLastResult();
      }
    }
  }

  void _showEnchantmentHistory(BuildContext context) {
    Navigator.of(context).pushNamed('/enchantment/history');
  }

  void _showEnchantmentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エンチャントについて'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'エンチャントシステム',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 武器に特殊効果を付与できます'),
              Text('• レベルが上がるほど効果が強くなります'),
              Text('• 失敗すると武器が破壊される可能性があります'),
              SizedBox(height: 12),
              Text(
                'エンチャント素材',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 素材を使用すると成功率が上がります'),
              Text('• 保護アイテムで破壊を防げます'),
              Text('• 素材の効果タイプが一致すると効果的です'),
            ],
          ),
        ),
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
