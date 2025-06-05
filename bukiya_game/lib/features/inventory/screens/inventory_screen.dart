import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../providers/inventory_provider.dart';
import '../widgets/inventory_stats_card.dart';
import '../widgets/weapon_inventory_tab.dart';
import '../widgets/material_inventory_tab.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('=== インベントリ ==='),
            backgroundColor: AppTheme.backgroundColor,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
          ),
          body: Container(
            color: AppTheme.backgroundColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー情報
                  _buildRetroHeader(inventoryProvider),
                  const SizedBox(height: 4),
                  
                  // タブメニュー
                  _buildRetroTabs(inventoryProvider),
                  const SizedBox(height: 4),
                  
                  // メインコンテンツ
                  _buildRetroContent(inventoryProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // レトロ風UIメソッド
  Widget _buildRetroHeader(InventoryProvider inventoryProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '--- インベントリ管理 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                '武器: ${inventoryProvider.playerWeapons.length}個',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '素材: ${inventoryProvider.playerMaterials.length}個',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRetroTabs(InventoryProvider inventoryProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: _tabController.index == 0 
                    ? Border.all(color: AppTheme.primaryColor, width: 1)
                    : null,
                ),
                child: Text(
                  '[1] 武器 (${inventoryProvider.playerWeapons.length})',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _tabController.index == 0 
                      ? AppTheme.primaryColor 
                      : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: _tabController.index == 1 
                    ? Border.all(color: AppTheme.primaryColor, width: 1)
                    : null,
                ),
                child: Text(
                  '[2] 素材 (${inventoryProvider.playerMaterials.length})',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _tabController.index == 1 
                      ? AppTheme.primaryColor 
                      : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroContent(InventoryProvider inventoryProvider) {
    if (inventoryProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Text(
          'インベントリを読み込み中...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabController.index == 0 ? '--- 武器一覧 ---' : '--- 素材一覧 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_tabController.index == 0)
            _buildRetroWeaponList(inventoryProvider)
          else
            _buildRetroMaterialList(inventoryProvider),
        ],
      ),
    );
  }

  Widget _buildRetroWeaponList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.playerWeapons.isEmpty) {
      return Text(
        '武器がありません',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      );
    }

    return Column(
      children: inventoryProvider.playerWeapons.take(10).map((weapon) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  weapon.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ATK:${weapon.totalAttack}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  weapon.weaponMaster.rarity,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getRarityColor(weapon.weaponMaster.rarity),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '[詳細]',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRetroMaterialList(InventoryProvider inventoryProvider) {
    if (inventoryProvider.playerMaterials.isEmpty) {
      return Text(
        '素材がありません',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      );
    }

    return Column(
      children: inventoryProvider.playerMaterials.take(10).map((material) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  material.material.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'x${material.quantity}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  material.material.rarity,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getRarityColor(material.material.rarity),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '[使用]',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
