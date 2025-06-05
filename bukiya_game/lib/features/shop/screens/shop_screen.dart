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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('=== 武器ショップ ==='),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          return Container(
            color: AppTheme.backgroundColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー情報
                  _buildRetroHeader(),
                  const SizedBox(height: 4),
                  
                  // メニュータブ
                  _buildRetroTabs(),
                  const SizedBox(height: 4),
                  
                  // メインコンテンツ
                  _buildRetroContent(shopProvider),
                ],
              ),
            ),
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

  // レトロ風UIメソッド
  Widget _buildRetroHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final player = authProvider.currentPlayer;
        if (player == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '--- 武器ショップ ---',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'ゴールド: ${player.gold}G',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'ジェム: ${player.gems}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.rareColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRetroTabs() {
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
                  '[1] 購入',
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
                  '[2] 売却',
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

  Widget _buildRetroContent(ShopProvider shopProvider) {
    if (shopProvider.isLoading && shopProvider.weapons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Text(
          '武器データを読み込み中...',
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
            '--- 武器一覧 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (shopProvider.weapons.isEmpty)
            Text(
              '購入可能な武器がありません',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            _buildRetroWeaponList(shopProvider.weapons),
        ],
      ),
    );
  }

  Widget _buildRetroWeaponList(List<Weapon> weapons) {
    return Column(
      children: weapons.map((weapon) => _buildRetroWeaponItem(weapon)).toList(),
    );
  }

  Widget _buildRetroWeaponItem(Weapon weapon) {
    return GestureDetector(
      onTap: () => _showWeaponDetail(weapon, true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                weapon.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'ATK:${weapon.attack}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${weapon.price}G',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentColor,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => _handlePurchase(weapon),
                child: Text(
                  '[購入]',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
