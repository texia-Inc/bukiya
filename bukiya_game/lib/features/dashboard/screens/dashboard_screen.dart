import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/player_info_card.dart';
import '../widgets/game_stats_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/offline_income_dialog.dart';
import '../../shop/screens/shop_screen.dart';

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
    
    // オフライン収益をチェック
    await _checkOfflineIncome();
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
        return _buildInventoryTab();
      case 3:
        return _buildCraftingTab();
      default:
        return _buildDashboardTab(player, dashboardProvider);
    }
  }

  Widget _buildDashboardTab(player, DashboardProvider dashboardProvider) {
    return RefreshIndicator(
      onRefresh: () => dashboardProvider.loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // プレイヤー情報カード
            PlayerInfoCard(player: player),
            const SizedBox(height: 16),
            
            // ゲーム統計カード
            GameStatsCard(
              statistics: dashboardProvider.statistics,
            ),
            const SizedBox(height: 16),
            
            // クイックアクションカード
            QuickActionsCard(
              onShopTap: () => _setCurrentIndex(1),
              onInventoryTap: () => _setCurrentIndex(2),
              onCraftingTap: () => _setCurrentIndex(3),
              onCollectIncome: () => _collectOfflineIncome(),
            ),
            const SizedBox(height: 16),
            
            // 最近の活動
            _buildRecentActivity(dashboardProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    // ショップ画面を直接表示
    return const ShopScreen();
  }

  Widget _buildInventoryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'インベントリ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '所持している武器・素材を確認できます',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '実装予定',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftingTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          Text(
            '武器合成',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '素材を使って新しい武器を作成できます',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '実装予定',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: _setCurrentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'ダッシュボード',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'ショップ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'インベントリ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: '合成',
        ),
      ],
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
}
