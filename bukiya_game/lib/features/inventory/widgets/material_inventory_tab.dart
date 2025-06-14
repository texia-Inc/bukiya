import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/inventory.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/inventory_provider.dart';
import 'material_inventory_card.dart';
import 'inventory_filter_bar.dart';

class MaterialInventoryTab extends StatelessWidget {
  const MaterialInventoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Column(
          children: [
            // フィルターバー
            InventoryFilterBar(
              searchQuery: inventoryProvider.materialSearchQuery,
              sortBy: inventoryProvider.materialSortBy,
              filterRarity: inventoryProvider.materialFilterRarity,
              onSearchChanged: inventoryProvider.setMaterialSearchQuery,
              onSortChanged: inventoryProvider.setMaterialSort,
              onRarityChanged: inventoryProvider.setMaterialRarityFilter,
              onClearFilters: inventoryProvider.clearMaterialFilters,
              isWeapon: false,
            ),
            
            // 素材リスト
            Expanded(
              child: _buildMaterialList(inventoryProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMaterialList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.isMaterialsLoading) {
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
              onPressed: () => inventoryProvider.loadPlayerMaterials(),
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    final materials = inventoryProvider.playerMaterials;

    if (materials.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              '素材がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ミッションをクリアするか、\n錬成で素材を入手してください',
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
      onRefresh: () => inventoryProvider.loadPlayerMaterials(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return MaterialInventoryCard(
            material: material,
            onSell: (quantity) => _showSellConfirmation(
              context,
              material,
              quantity,
              inventoryProvider,
            ),
          );
        },
      ),
    );
  }

  void _showSellConfirmation(
    BuildContext context,
    InventoryPlayerMaterial material,
    int quantity,
    InventoryProvider inventoryProvider,
  ) {
    final totalPrice = material.sellPrice * quantity;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('素材売却'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${material.material.name}を${quantity}個売却しますか？'),
            const SizedBox(height: 8),
            Text(
              '単価: ${material.sellPrice.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}G',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '合計: ${totalPrice.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}G',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '残り数量: ${material.quantity - quantity}個',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※売却した素材は元に戻せません',
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
              final result = await inventoryProvider.sellMaterial(
                material.materialId.toString(),
                quantity,
              );
              if (result != null && context.mounted) {
                _showSellResult(context, result, material.material.name);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('売却'),
          ),
        ],
      ),
    );
  }

  void _showSellResult(
    BuildContext context,
    MaterialSellResult result,
    String materialName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '売却完了',
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 8),
            Text('獲得ゴールド: ${result.goldEarned}G'),
            if (result.newQuantity > 0)
              Text('残り数量: ${result.newQuantity}個')
            else
              Text('$materialNameをすべて売却しました'),
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
