import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/crafting.dart';
import 'package:bukiya_game/features/crafting/providers/crafting_provider.dart';
import 'package:bukiya_game/features/crafting/widgets/recipe_card.dart';
import 'package:bukiya_game/features/crafting/widgets/crafting_filter_bar.dart';
import 'package:bukiya_game/features/crafting/widgets/crafting_result_dialog.dart';
import 'package:bukiya_game/shared/themes/app_theme.dart';

class CraftingScreen extends StatefulWidget {
  const CraftingScreen({super.key});

  @override
  State<CraftingScreen> createState() => _CraftingScreenState();
}

class _CraftingScreenState extends State<CraftingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _sortBy = 'name';
  String? _filterWeaponType;
  String? _filterRarity;
  bool _showCraftableOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 初回データ取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CraftingProvider>().fetchAllRecipes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          '武器錬成',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          Consumer<CraftingProvider>(
            builder: (context, provider, child) {
              if (provider.craftableRecipesCount > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.build_circle, color: Colors.white),
                      onPressed: () => _showCraftableRecipes(provider),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.craftableRecipesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<CraftingProvider>().refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 20),
                  SizedBox(width: 4),
                  Text('全レシピ'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 4),
                  Text('合成可能'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<CraftingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRecipeList(provider.recipes, provider),
              _buildRecipeList(provider.availableRecipes, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(List<CraftingRecipe> recipes, CraftingProvider provider) {
    // フィルタリングと検索
    List<CraftingRecipe> filteredRecipes = provider.filterRecipes(
      weaponType: _filterWeaponType,
      rarity: _filterRarity,
      craftableOnly: _showCraftableOnly,
    );

    if (_searchQuery.isNotEmpty) {
      filteredRecipes = provider.searchRecipes(_searchQuery);
    }

    // ソート
    filteredRecipes = provider.sortRecipes(filteredRecipes, _sortBy);

    if (filteredRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'レシピが見つかりません',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: Column(
        children: [
          // フィルターバー
          CraftingFilterBar(
            searchQuery: _searchQuery,
            sortBy: _sortBy,
            filterWeaponType: _filterWeaponType,
            filterRarity: _filterRarity,
            showCraftableOnly: _showCraftableOnly,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onSortChanged: (sortBy) {
              setState(() {
                _sortBy = sortBy;
              });
            },
            onWeaponTypeChanged: (weaponType) {
              setState(() {
                _filterWeaponType = weaponType;
              });
            },
            onRarityChanged: (rarity) {
              setState(() {
                _filterRarity = rarity;
              });
            },
            onCraftableOnlyChanged: (craftableOnly) {
              setState(() {
                _showCraftableOnly = craftableOnly;
              });
            },
          ),
          
          // レシピリスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecipeCard(
                    recipe: recipe,
                    playerMaterials: provider.playerMaterials,
                    onCraft: () => _craftWeapon(recipe, provider),
                    isCrafting: provider.isCrafting,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCraftableRecipes(CraftingProvider provider) {
    setState(() {
      _tabController.index = 1;
      _showCraftableOnly = true;
    });
  }

  Future<void> _craftWeapon(CraftingRecipe recipe, CraftingProvider provider) async {
    // 合成確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${recipe.name}を合成'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('武器: ${recipe.weapon.name}'),
            Text('コスト: ${recipe.goldCostFormatted}G'),
            Text('成功率: ${recipe.successRatePercentage}%'),
            const SizedBox(height: 8),
            const Text('必要素材:'),
            ...recipe.materials.map((material) => Text(
              '• ${material.material.name} x${material.quantity}',
            )),
            const SizedBox(height: 8),
            const Text(
              '合成を実行しますか？',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('合成する'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.craftWeapon(recipe.id);
      
      if (mounted && provider.lastCraftingResult != null) {
        // 結果ダイアログを表示
        await showDialog(
          context: context,
          builder: (context) => CraftingResultDialog(
            result: provider.lastCraftingResult!,
          ),
        );
        
        // 結果をクリア
        provider.clearLastCraftingResult();
      }
    }
  }
}
