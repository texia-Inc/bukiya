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
          appBar: AppBar(
            title: const Text('インベントリ'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => inventoryProvider.loadInventory(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.sports_martial_arts),
                  text: '武器 (${inventoryProvider.playerWeapons.length})',
                ),
                Tab(
                  icon: const Icon(Icons.category),
                  text: '素材 (${inventoryProvider.playerMaterials.length})',
                ),
              ],
            ),
          ),
          body: LoadingOverlay(
            isLoading: inventoryProvider.isLoading,
            loadingMessage: 'インベントリを読み込み中...',
            child: Column(
              children: [
                // 統計カード
                if (inventoryProvider.inventoryStats != null)
                  InventoryStatsCard(
                    stats: inventoryProvider.inventoryStats!,
                  ),
                
                // タブビュー
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      WeaponInventoryTab(),
                      MaterialInventoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
