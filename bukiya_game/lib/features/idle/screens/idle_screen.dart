import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../providers/idle_provider.dart';
import '../widgets/idle_income_card.dart';
import '../widgets/idle_upgrades_card.dart';

class IdleScreen extends StatefulWidget {
  const IdleScreen({super.key});

  @override
  State<IdleScreen> createState() => _IdleScreenState();
}

class _IdleScreenState extends State<IdleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeIdleSystem();
    });
  }

  Future<void> _initializeIdleSystem() async {
    final idleProvider = context.read<IdleProvider>();
    await idleProvider.loadIdleSystem();
  }

  Future<void> _refreshIdleSystem() async {
    final idleProvider = context.read<IdleProvider>();
    await idleProvider.loadIdleSystem();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('放置システムを更新しました'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('放置システム'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshIdleSystem(),
          ),
        ],
      ),
      body: Consumer<IdleProvider>(
        builder: (context, idleProvider, child) {
          if (idleProvider.idleSystem == null && idleProvider.isLoading) {
            return const LoadingScreen(message: '放置システムを読み込み中...');
          }

          return RefreshIndicator(
            onRefresh: () => idleProvider.loadIdleSystem(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // エラーメッセージ
                  if (idleProvider.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              idleProvider.errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 放置収益カード
                  const IdleIncomeCard(),
                  const SizedBox(height: 16),

                  // アクティブボーナス
                  _buildActiveBonusesCard(idleProvider),
                  const SizedBox(height: 16),

                  // アップグレードカード
                  const IdleUpgradesCard(),
                  const SizedBox(height: 16),

                  // 統計情報
                  _buildStatisticsCard(idleProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveBonusesCard(IdleProvider idleProvider) {
    final activeBonuses = idleProvider.activeBonuses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flash_on,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'アクティブボーナス',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (activeBonuses.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'アクティブなボーナスはありません',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...activeBonuses.map((bonus) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.successColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getBonusIcon(bonus.iconName),
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bonus.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bonus.effectDescription,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bonus.remainingTimeDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(IdleProvider idleProvider) {
    final idleSystem = idleProvider.idleSystem;
    
    if (idleSystem == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '統計情報',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 統計グリッド
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(
                  context,
                  '基本収益',
                  '${idleSystem.baseIncomePerSecond}G/秒',
                  Icons.monetization_on,
                ),
                _buildStatItem(
                  context,
                  '現在倍率',
                  '×${idleSystem.multiplier.toStringAsFixed(1)}',
                  Icons.trending_up,
                ),
                _buildStatItem(
                  context,
                  '現在レベル',
                  'Lv.${idleSystem.currentLevel}',
                  Icons.star,
                ),
                _buildStatItem(
                  context,
                  'アップグレード',
                  '${idleSystem.upgradeCount}個',
                  Icons.upgrade,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getBonusIcon(String iconName) {
    switch (iconName) {
      case 'income':
        return Icons.monetization_on;
      case 'experience':
        return Icons.star;
      case 'crafting':
        return Icons.build;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.flash_on;
    }
  }
}
