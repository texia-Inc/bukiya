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
    _tabController.addListener(() {
      setState(() {});
    });
    
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
        title: const Text('=== 武器錬成 ==='),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
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
          return Container(
            color: AppTheme.backgroundColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー情報
                  _buildRetroHeader(provider),
                  const SizedBox(height: 4),
                  
                  // タブメニュー
                  _buildRetroTabs(provider),
                  const SizedBox(height: 4),
                  
                  // メインコンテンツ
                  _buildRetroContent(provider),
                ],
              ),
            ),
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
      
      if (mounted) {
        if (success && provider.lastCraftingResult != null) {
          // 成功時：結果ダイアログを表示
          await showDialog(
            context: context,
            builder: (context) => CraftingResultDialog(
              result: provider.lastCraftingResult!,
            ),
          );
          
          // 結果をクリア
          provider.clearLastCraftingResult();
        } else if (provider.errorMessage != null) {
          // エラー時：分かりやすいスナックバーを表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          
          // エラーメッセージをクリア
          provider.clearError();
        }
      }
    }
  }

  // レトロ風UIメソッド
  Widget _buildRetroHeader(CraftingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '--- 武器錬成工房 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                '合成可能: ${provider.craftableRecipesCount}件',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '総レシピ: ${provider.recipes.length}件',
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

  Widget _buildRetroTabs(CraftingProvider provider) {
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
                  '[1] 全レシピ',
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
                  '[2] 合成可能',
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

  Widget _buildRetroContent(CraftingProvider provider) {
    if (provider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Text(
          'レシピデータを読み込み中...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '--- エラー ---',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => provider.refresh(),
              child: Text(
                '[再試行]',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final recipes = _tabController.index == 0 
      ? provider.recipes 
      : provider.availableRecipes.where((recipe) => recipe.isCraftable).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- レシピ一覧 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (recipes.isEmpty)
            Text(
              'レシピがありません',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            _buildRetroRecipeList(recipes, provider),
        ],
      ),
    );
  }

  Widget _buildRetroRecipeList(List<CraftingRecipe> recipes, CraftingProvider provider) {
    return Column(
      children: recipes.take(10).map((recipe) => _buildRetroRecipeItem(recipe, provider)).toList(),
    );
  }

  Widget _buildRetroRecipeItem(CraftingRecipe recipe, CraftingProvider provider) {
    final isAvailableTab = _tabController.index == 1;
    final canCraft = recipe.isCraftable;
    
    return GestureDetector(
      onTap: () => _craftWeapon(recipe, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                recipe.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${recipe.successRatePercentage}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${recipe.goldCost}G',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            // 合成可能タブでのみ可用性表示
            if (isAvailableTab)
              Expanded(
                flex: 1,
                child: Text(
                  '[合成]',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
