import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/weapon.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/weapon_card.dart';
import '../widgets/weapon_detail_dialog.dart';
import '../widgets/shop_filter_bar.dart';
import '../widgets/purchase_confirmation_dialog.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShopData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    final shopProvider = context.read<ShopProvider>();
    await shopProvider.loadWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('武器ショップ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: '購入',
            ),
            Tab(
              icon: Icon(Icons.sell),
              text: '売却',
            ),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final player = authProvider.currentPlayer;
              if (player == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppTheme.secondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.gold.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.diamond,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.gems.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // 購入タブ
              _buildPurchaseTab(shopProvider),
              // 売却タブ
              _buildSellTab(shopProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPurchaseTab(ShopProvider shopProvider) {
    if (shopProvider.isLoading && shopProvider.weapons.isEmpty) {
      return const LoadingScreen(
        message: '武器を読み込み中...',
        showLogo: false,
      );
    }

    return Column(
      children: [
        // フィルターバー
        ShopFilterBar(
          onFilterChanged: (filters) {
            // TODO: フィルター機能実装
          },
        ),
        
        // 武器一覧
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => shopProvider.loadWeapons(),
            child: shopProvider.weapons.isEmpty
                ? _buildEmptyState('購入可能な武器がありません')
                : _buildWeaponGrid(shopProvider.weapons, true),
          ),
        ),
      ],
    );
  }

  Widget _buildSellTab(ShopProvider shopProvider) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // TODO: プレイヤー武器一覧の実装
        return _buildEmptyState('売却機能は実装予定です');
      },
    );
  }

  Widget _buildWeaponGrid(List<Weapon> weapons, bool isPurchaseMode) {
    return AnimationLimiter(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: weapons.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: WeaponCard(
                  weapon: weapons[index],
                  isPurchaseMode: isPurchaseMode,
                  onTap: () => _showWeaponDetail(weapons[index], isPurchaseMode),
                  onAction: isPurchaseMode
                      ? () => _handlePurchase(weapons[index])
                      : () => _handleSell(weapons[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showWeaponDetail(Weapon weapon, bool isPurchaseMode) {
    showDialog(
      context: context,
      builder: (context) => WeaponDetailDialog(
        weapon: weapon,
        isPurchaseMode: isPurchaseMode,
        onPurchase: isPurchaseMode ? () => _handlePurchase(weapon) : null,
        onSell: !isPurchaseMode ? () => _handleSell(weapon) : null,
      ),
    );
  }

  Future<void> _handlePurchase(Weapon weapon) async {
    final authProvider = context.read<AuthProvider>();
    final player = authProvider.currentPlayer;
    
    if (player == null) return;

    // 残高チェック
    if (player.gold < weapon.price) {
      _showErrorMessage('ゴールドが不足しています');
      return;
    }

    // レベルチェック
    if (player.level < weapon.requiredLevel) {
      _showErrorMessage('レベルが足りません（必要レベル: ${weapon.requiredLevel}）');
      return;
    }

    // 購入確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => PurchaseConfirmationDialog(
        weapon: weapon,
        playerGold: player.gold,
      ),
    );

    if (confirmed == true && mounted) {
      final shopProvider = context.read<ShopProvider>();
      final success = await shopProvider.purchaseWeapon(weapon.id);
      
      if (success && mounted) {
        // プレイヤー情報を更新
        await authProvider.checkAuthStatus();
        
        _showSuccessMessage('${weapon.name}を購入しました！');
        Navigator.of(context).pop(); // ダイアログを閉じる
      } else if (mounted) {
        _showErrorMessage(shopProvider.errorMessage ?? '購入に失敗しました');
      }
    }
  }

  Future<void> _handleSell(Weapon weapon) async {
    // TODO: 売却機能の実装
    _showErrorMessage('売却機能は実装予定です');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
