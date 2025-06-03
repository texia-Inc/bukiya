import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/inventory.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/inventory_provider.dart';
import 'weapon_inventory_card.dart';
import 'inventory_filter_bar.dart';

class WeaponInventoryTab extends StatelessWidget {
  const WeaponInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Column(
          children: [
            // フィルターバー
            InventoryFilterBar(
              searchQuery: inventoryProvider.weaponSearchQuery,
              sortBy: inventoryProvider.weaponSortBy,
              filterRarity: inventoryProvider.weaponFilterRarity,
              onSearchChanged: inventoryProvider.setWeaponSearchQuery,
              onSortChanged: inventoryProvider.setWeaponSort,
              onRarityChanged: inventoryProvider.setWeaponRarityFilter,
              onClearFilters: inventoryProvider.clearWeaponFilters,
              isWeapon: true,
            ),
            
            // 武器リスト
            Expanded(
              child: _buildWeaponList(inventoryProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeaponList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.isWeaponsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (inventoryProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              inventoryProvider.errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => inventoryProvider.loadPlayerWeapons(),
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    final weapons = inventoryProvider.playerWeapons;

    if (weapons.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_martial_arts,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '武器がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ショップで武器を購入するか、\n錬成で武器を作成してください',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => inventoryProvider.loadPlayerWeapons(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: weapons.length,
        itemBuilder: (context, index) {
          final weapon = weapons[index];
          return WeaponInventoryCard(
            weapon: weapon,
            onSell: () => _showSellConfirmation(context, weapon, inventoryProvider),
            onEnchant: () => _showEnchantConfirmation(context, weapon, inventoryProvider),
          );
        },
      ),
    );
  }

  void _showSellConfirmation(
    BuildContext context,
    PlayerWeapon weapon,
    InventoryProvider inventoryProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('武器売却'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${weapon.displayName}を売却しますか？'),
            const SizedBox(height: 8),
            Text(
              '売却価格: ${weapon.sellPrice.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}G',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※売却した武器は元に戻せません',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await inventoryProvider.sellWeapon(weapon.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${weapon.displayName}を売却しました'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('売却'),
          ),
        ],
      ),
    );
  }

  void _showEnchantConfirmation(
    BuildContext context,
    PlayerWeapon weapon,
    InventoryProvider inventoryProvider,
  ) {
    if (!weapon.canEnchant) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('この武器はエンチャントできません（最大レベル）'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('武器エンチャント'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${weapon.displayName}をエンチャントしますか？'),
            const SizedBox(height: 8),
            Text('現在のレベル: +${weapon.enchantLevel}'),
            Text('次のレベル: +${weapon.enchantLevel + 1}'),
            const SizedBox(height: 8),
            Text(
              'エンチャントコスト: ${weapon.enchantCost.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}G',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '成功率: ${(weapon.enchantSuccessRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: weapon.enchantSuccessRate > 0.5 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※失敗してもゴールドは消費されます',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final result = await inventoryProvider.enchantWeapon(weapon.id);
              if (result != null && context.mounted) {
                _showEnchantResult(context, result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('エンチャント'),
          ),
        ],
      ),
    );
  }

  void _showEnchantResult(BuildContext context, EnchantResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result.success ? 'エンチャント成功！' : 'エンチャント失敗...',
          style: TextStyle(
            color: result.success ? Colors.green : Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 8),
            if (result.success) ...[
              Text('新しいレベル: +${result.newLevel}'),
              Text('新しい攻撃力: ${result.newAttack}'),
            ],
            Text('消費ゴールド: ${result.goldSpent}G'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
