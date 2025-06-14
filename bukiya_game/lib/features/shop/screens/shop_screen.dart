import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/weapon.dart';
import '../../../core/models/player.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/weapon_card.dart';
import '../widgets/weapon_detail_dialog.dart';
import '../widgets/shop_filter_bar.dart';
import '../widgets/procurement_confirmation_dialog.dart';
import '../../inventory/providers/inventory_provider.dart';

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
      _refreshPlayerData();
    });
  }
  
  Future<void> _refreshPlayerData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final freshPlayer = await authProvider.apiService.getPlayerProfile();
      await authProvider.updatePlayer(freshPlayer);
      debugPrint('Player data refreshed on shop screen: Gold = ${freshPlayer.gold}');
    } catch (e) {
      debugPrint('Failed to refresh player data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadShopData() async {
    final authProvider = context.read<AuthProvider>();
    final shopProvider = context.read<ShopProvider>();
    final player = authProvider.currentPlayer;
    
    await shopProvider.loadWeapons(player: player);
    if (player != null) {
      shopProvider.updatePlayer(player);
    }
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
            shopProvider.updateFilters(filters);
          },
        ),
        
        // 武器一覧
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadShopData,
            child: shopProvider.weapons.isEmpty
                ? _buildEmptyState('仕入れ可能な武器がありません')
                : _buildWeaponGrid(shopProvider.weapons, true),
          ),
        ),
      ],
    );
  }

  Widget _buildSellTab(ShopProvider shopProvider) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        if (inventoryProvider.isLoading && inventoryProvider.playerWeapons.isEmpty) {
          return const LoadingScreen(
            message: '武器を読み込み中...',
            showLogo: false,
          );
        }

        final playerWeapons = inventoryProvider.playerWeapons;
        
        if (playerWeapons.isEmpty) {
          return _buildEmptyState('売却できる武器がありません');
        }

        return Column(
          children: [
            // 売却情報ヘッダー
            _buildSellInfoHeader(),
            
            // 武器グリッド（売却モード）
            Expanded(
              child: _buildWeaponGrid(
                playerWeapons.map((pw) => pw.weaponMaster).toList(),
                false, // 売却モード
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSellInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.accentColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- 売却情報 ---',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 売却価格は仕入れ価格の70%です\n'
            '• 売却後の武器は回復できません\n'
            '• レア度の高い武器ほど高値で売れます',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
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
                      ? () => _handleProcurement(weapons[index])
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
        onPurchase: isPurchaseMode ? () {
          // まず詳細ダイアログを閉じてから仕入れ処理を開始
          Navigator.of(context).pop();
          _handleProcurement(weapon);
        } : null,
        onSell: !isPurchaseMode ? () {
          Navigator.of(context).pop();
          _handleSell(weapon);
        } : null,
      ),
    );
  }

  Future<void> _handleProcurement(Weapon weapon) async {
    final authProvider = context.read<AuthProvider>();
    final player = authProvider.currentPlayer;
    
    if (player == null) return;

    // 最新のプレイヤー情報を取得してデバッグ
    debugPrint('Purchase Debug (cached): Player Gold: ${player.gold}, Weapon Price: ${weapon.price}, Weapon: ${weapon.name}');
    
    // バックエンドから最新のプレイヤー情報を取得
    Player currentPlayer = player;
    try {
      final freshPlayer = await authProvider.apiService.getPlayerProfile();
      debugPrint('Purchase Debug (fresh from API): Current Gold: ${freshPlayer.gold}');
      
      if (freshPlayer.gold != player.gold) {
        debugPrint('⚠️ WARNING: Cached gold (${player.gold}) differs from API gold (${freshPlayer.gold})');
        // 最新の情報でプレイヤーデータを更新
        await authProvider.updatePlayer(freshPlayer);
        currentPlayer = freshPlayer;
        
        // 強制的に画面を更新
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch fresh player data: $e');
    }

    // 最新の残高でチェック
    if (currentPlayer.gold < weapon.price) {
      _showErrorMessage('ゴールドが不足しています (所持: ${currentPlayer.gold}G, 必要: ${weapon.price}G)');
      return;
    }

    // ショップレベルチェック
    if (currentPlayer.shopLevel < weapon.requiredLevel) {
      _showErrorMessage('ショップレベルが足りません（必要レベル: ${weapon.requiredLevel}）');
      return;
    }

    // 仕入れ確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ProcurementConfirmationDialog(
        weapon: weapon,
        playerGold: currentPlayer.gold,
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final shopProvider = context.read<ShopProvider>();
        final success = await shopProvider.procureWeapon(weapon.id.toString());
        
        if (success && mounted) {
          // 仕入れ成功メッセージを表示
          _showSuccessMessage('${weapon.name}を仕入れました！');
          
          // 仕入れ成功後にプレイヤー情報を更新
          try {
            final updatedPlayer = await authProvider.apiService.getPlayerProfile();
            await authProvider.updatePlayer(updatedPlayer);
            debugPrint('Player gold updated after procurement: ${updatedPlayer.gold}');
          } catch (e) {
            debugPrint('Failed to update player data after procurement: $e');
          }
          
          // 少し待ってからダイアログを閉じる
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.canPop(context)) {
            Navigator.of(context).pop(true);
          }
        } else if (mounted) {
          _showErrorMessage(shopProvider.errorMessage ?? '仕入れに失敗しました');
        }
      } catch (e) {
        debugPrint('Procurement error: $e');
        if (mounted) {
          _showErrorMessage('仕入れ中にエラーが発生しました');
        }
      }
    }
  }

  Future<void> _handleSell(Weapon weapon) async {
    final inventoryProvider = context.read<InventoryProvider>();
    
    // 売却価格を計算（仕入れ価格の70%）
    final sellPrice = (weapon.price * 0.7).round();
    
    // 売却確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildSellConfirmationDialog(weapon, sellPrice),
    );
    
    if (confirmed == true) {
      try {
        // インベントリプロバイダーの売却メソッドを呼び出し
        final success = await inventoryProvider.sellWeapon(weapon.id.toString());
        
        if (success) {
          Navigator.of(context).pop(); // 詳細ダイアログを閉じる
          _showSuccessMessage('${weapon.name}を${sellPrice}ゴールドで売却しました！');
        } else {
          _showErrorMessage(inventoryProvider.errorMessage ?? '売却に失敗しました');
        }
      } catch (e) {
        _showErrorMessage('売却中にエラーが発生しました: $e');
      }
    }
  }

  Widget _buildSellConfirmationDialog(Weapon weapon, int sellPrice) {
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: AppTheme.accentColor, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border.all(color: AppTheme.accentColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '=== 売却確認 ===',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            
            // 武器情報
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '--- 売却武器情報 ---',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('武器名', weapon.name),
                  _buildInfoRow('タイプ', weapon.weaponType),
                  _buildInfoRow('レアリティ', weapon.rarity),
                  _buildInfoRow('攻撃力', '${weapon.attack}'),
                  _buildInfoRow('仕入れ価格', '${weapon.price}G'),
                  _buildInfoRow('売却価格', '${sellPrice}G'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '⚠️ 注意: 売却後の武器は回復できません',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ボタン
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                      ),
                      child: Text(
                        '[キャンセル]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accentColor, width: 1),
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        '[売却する]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
                  '[1] 仕入れ',
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
              '仕入れ可能な武器がありません',
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
                onTap: () => _handleProcurement(weapon),
                child: Text(
                  '[仕入れ]',
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
