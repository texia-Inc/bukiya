import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../shared/widgets/badge_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../mission/providers/mission_provider.dart';
import '../../enchantment/providers/enchantment_provider.dart';
import '../../crafting/providers/crafting_provider.dart';
import '../widgets/player_info_card.dart';
import '../widgets/game_stats_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/offline_income_dialog.dart';
import '../../shop/screens/shop_screen.dart';
import '../../mission/screens/mission_screen.dart';
import '../../crafting/screens/crafting_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../adventurer/screens/adventurer_screen.dart';
import '../../idle/widgets/idle_income_card.dart';
import '../../enchantment/screens/enchantment_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final dashboardProvider = context.read<DashboardProvider>();
    await dashboardProvider.loadDashboardData();
    
    // オフライン収益をチェック（一時的に無効化）
    // await _checkOfflineIncome();
  }

  Future<void> _checkOfflineIncome() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final offlineIncome = await dashboardProvider.getOfflineIncome();
    
    if (offlineIncome > 0 && mounted) {
      _showOfflineIncomeDialog(offlineIncome);
    }
  }

  void _showOfflineIncomeDialog(int income) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfflineIncomeDialog(
        income: income,
        onCollect: () async {
          final dashboardProvider = context.read<DashboardProvider>();
          await dashboardProvider.collectOfflineIncome();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, authProvider, dashboardProvider, child) {
        final player = authProvider.currentPlayer;
        
        if (player == null) {
          return const LoadingScreen(message: 'プレイヤー情報を読み込み中...');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${player.username}の武器屋'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => dashboardProvider.loadDashboardData(),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      _navigateToSettings();
                      break;
                    case 'logout':
                      _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('設定'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('ログアウト'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: dashboardProvider.isLoading,
            loadingMessage: 'データを更新中...',
            child: _buildBody(player, dashboardProvider),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBody(player, DashboardProvider dashboardProvider) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab(player, dashboardProvider);
      case 1:
        return _buildShopTab();
      case 2:
        return const MissionScreen();
      case 3:
        return _buildAdventurerTab();
      case 4:
        return _buildInventoryTab();
      case 5:
        return _buildCraftingTab();
      case 6:
        return _buildEnchantmentTab();
      case 7:
        return const SettingsScreen();
      default:
        return _buildDashboardTab(player, dashboardProvider);
    }
  }

  Widget _buildDashboardTab(player, DashboardProvider dashboardProvider) {
    return RefreshIndicator(
      onRefresh: () => dashboardProvider.loadDashboardData(),
      child: Container(
        color: AppTheme.backgroundColor,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // レトロなヘッダー（横幅めいっぱい）
              _buildRetroHeader(player),
              const SizedBox(height: 4),
              
              // メイン情報エリア（横並び）
              _buildMainInfoArea(player, dashboardProvider),
              const SizedBox(height: 4),
              
              // メニューエリア（横並び）
              _buildRetroMenu(),
              const SizedBox(height: 4),
              
              // 統計情報（1行表示）
              _buildRetroStats(dashboardProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    // ショップ画面を直接表示
    return const ShopScreen();
  }

  Widget _buildAdventurerTab() {
    // 冒険者画面を直接表示
    return const AdventurerScreen();
  }

  Widget _buildInventoryTab() {
    // インベントリ画面を直接表示
    return InventoryScreen(key: ValueKey(_currentIndex));
  }

  Widget _buildCraftingTab() {
    // 錬成画面を直接表示
    return const CraftingScreen();
  }

  Widget _buildEnchantmentTab() {
    // エンチャント画面を直接表示
    return const EnchantmentScreen();
  }

  Widget _buildRecentActivity(DashboardProvider dashboardProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '最近の活動',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '最近の活動はありません',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer3<MissionProvider, EnchantmentProvider, CraftingProvider>(
      builder: (context, missionProvider, enchantmentProvider, craftingProvider, child) {
        // バッジカウントを計算
        final claimableMissions = missionProvider.claimableRewardsCount;
        final availableRecipes = craftingProvider.availableRecipes.length;
        final enchantableWeapons = enchantmentProvider.selectedWeapon != null ? 1 : 0;
        
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _setCurrentIndex,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'ショップ',
            ),
            BadgedBottomNavigationBarItem(
              icon: const Icon(Icons.assignment),
              label: 'ミッション',
              badgeCount: claimableMissions,
              showBadge: claimableMissions > 0,
              animated: true,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: '冒険者',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'インベントリ',
            ),
            BadgedBottomNavigationBarItem(
              icon: const Icon(Icons.build),
              label: '合成',
              badgeCount: availableRecipes,
              showBadge: availableRecipes > 0,
              badgeColor: Colors.green,
              animated: true,
            ),
            BadgedBottomNavigationBarItem(
              icon: const Icon(Icons.auto_fix_high),
              label: 'エンチャント',
              badgeCount: enchantableWeapons,
              showBadge: enchantableWeapons > 0,
              badgeColor: Colors.purple,
              animated: true,
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        );
      },
    );
  }

  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSettings() {
    // TODO: 設定画面への遷移
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('設定画面は実装予定です'),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.logoutSuccessMessage),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _collectOfflineIncome() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final income = await dashboardProvider.getOfflineIncome();
    
    if (income > 0) {
      _showOfflineIncomeDialog(income);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('オフライン収益はありません'),
        ),
      );
    }
  }

  // レトロ風UIメソッド
  Widget _buildRetroHeader(player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '=== 武器屋経営システム ===',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'プレイヤー: ${player.username}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'ショップLv: ${player.shopLevel} (EXP: ${player.experience})',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroPlayerInfo(player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- プレイヤー情報 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ゴールド: ${player.gold}G',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentColor,
            ),
          ),
          Text(
            'ジェム: ${player.gems}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.rareColor,
            ),
          ),
          Text(
            'ショップレベル: ${player.shopLevel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '評判: ${player.reputation}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- メインメニュー ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // メニューを横並びで表示
          Wrap(
            spacing: 20,
            runSpacing: 4,
            children: [
              _buildMenuOption('[1] ショップ管理', () => _setCurrentIndex(1)),
              _buildMenuOption('[2] 武器錬成', () => _setCurrentIndex(5)),
              _buildMenuOption('[3] 冒険者対応', () => _setCurrentIndex(3)),
              _buildMenuOption('[4] ミッション確認', () => _setCurrentIndex(2)),
              _buildMenuOption('[5] インベントリ', () => _setCurrentIndex(4)),
              _buildMenuOption('[6] エンチャント', () => _setCurrentIndex(6)),
              _buildMenuOption('[7] オフライン収益', () => _collectOfflineIncome()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  // メイン情報エリア（横並び）
  Widget _buildMainInfoArea(player, DashboardProvider dashboardProvider) {
    return Row(
      children: [
        // プレイヤー情報（左側）
        Expanded(
          flex: 1,
          child: _buildRetroPlayerInfo(player),
        ),
        const SizedBox(width: 4),
        // 追加情報（右側）
        Expanded(
          flex: 1,
          child: _buildQuickInfo(player),
        ),
      ],
    );
  }

  // クイック情報
  Widget _buildQuickInfo(player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '--- クイック情報 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'プレイ時間: 計算中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '武器作成数: 計算中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            '総収益: 計算中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroStats(DashboardProvider dashboardProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '--- システム情報 --- ステータス: オンライン',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.successColor,
            ),
          ),
          Text(
            '最終更新: ${DateTime.now().toString().substring(11, 19)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            'v1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
