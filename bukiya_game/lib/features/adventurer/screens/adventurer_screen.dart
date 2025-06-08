import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/models/adventurer_new.dart';
import '../providers/adventurer_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../widgets/adventurer_card.dart';
import '../widgets/quest_progress_card.dart';
import '../widgets/adventurer_detail_dialog.dart';
import '../widgets/weapon_selection_dialog.dart';
import '../widgets/quest_dispatch_dialog.dart';
import '../widgets/buyback_dialog.dart';
import '../../character/screens/character_screen.dart';

class AdventurerScreen extends StatefulWidget {
  const AdventurerScreen({super.key});

  @override
  State<AdventurerScreen> createState() => _AdventurerScreenState();
}

class _AdventurerScreenState extends State<AdventurerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdventurerData();
      final adventurerProvider = context.read<AdventurerProvider>();
      adventurerProvider.startAutoUpdate();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    final adventurerProvider = context.read<AdventurerProvider>();
    adventurerProvider.stopAutoUpdate();
    super.dispose();
  }

  Future<void> _loadAdventurerData() async {
    final adventurerProvider = context.read<AdventurerProvider>();
    await adventurerProvider.loadAdventurerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('冒険者ギルド'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadAdventurerData(),
          ),
        ],
      ),
      body: Consumer<AdventurerProvider>(
        builder: (context, adventurerProvider, child) {
          return Column(
            children: [
              // 統計情報
              _buildStatsHeader(adventurerProvider),
              
              // タブバー
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: '訪問者 (${adventurerProvider.visitingAdventurers.length})',
                    icon: const Icon(Icons.people),
                  ),
                  Tab(
                    text: '冒険中 (${adventurerProvider.onQuestAdventurers.length})',
                    icon: const Icon(Icons.explore),
                  ),
                  Tab(
                    text: '買取 (${adventurerProvider.pendingBuybacks.length})',
                    icon: const Icon(Icons.shopping_bag),
                  ),
                  const Tab(
                    text: '固有キャラ',
                    icon: Icon(Icons.star),
                  ),
                ],
              ),
              
              // タブコンテンツ
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVisitorsTab(adventurerProvider),
                    _buildOnQuestTab(adventurerProvider),
                    _buildBuybackTab(adventurerProvider),
                    _buildCharacterTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVisitorsTab(AdventurerProvider provider) {
    if (provider.isLoading && provider.visitingAdventurers.isEmpty) {
      return const LoadingScreen(
        message: '冒険者を読み込み中...',
        showLogo: false,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAdventurerData(),
      child: provider.visitingAdventurers.isEmpty
          ? _buildEmptyStateWithSpawn(provider)
          : _buildAdventurerList(provider.visitingAdventurers, true),
    );
  }

  Widget _buildOnQuestTab(AdventurerProvider provider) {
    if (provider.isLoading && provider.onQuestAdventurers.isEmpty) {
      return const LoadingScreen(
        message: '冒険状況を読み込み中...',
        showLogo: false,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAdventurerData(),
      child: provider.onQuestAdventurers.isEmpty
          ? _buildEmptyState(
              Icons.explore_off,
              '現在、冒険中の冒険者はいません',
              '冒険者を派遣して素材を集めましょう',
            )
          : _buildQuestProgressList(provider.onQuestAdventurers),
    );
  }

  Widget _buildBuybackTab(AdventurerProvider provider) {
    if (provider.isLoading && provider.pendingBuybacks.isEmpty) {
      return const LoadingScreen(
        message: '買取案件を読み込み中...',
        showLogo: false,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadAdventurerData(),
      child: provider.pendingBuybacks.isEmpty
          ? _buildEmptyState(
              Icons.shopping_bag_outlined,
              '現在、買取案件はありません',
              '冒険者が帰還するまでお待ちください',
            )
          : _buildBuybackList(provider.pendingBuybacks),
    );
  }

  Widget _buildAdventurerList(List<Adventurer> adventurers, bool isVisiting) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adventurers.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AdventurerCard(
                    adventurer: adventurers[index],
                    onTap: () => _showAdventurerDetail(adventurers[index]),
                    onAction: isVisiting
                        ? () => _showWeaponSaleDialog(adventurers[index])
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestProgressList(List<Adventurer> adventurers) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adventurers.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuestProgressCard(
                    adventurer: adventurers[index],
                    onTap: () => _showAdventurerDetail(adventurers[index]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuybackList(List<QuestResult> results) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _showBuybackDialog(result),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.inventory,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${result.questAreaName}からの帰還',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'アイテム数: ${result.drops.length}個',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '買取価格: ${result.totalBuybackPrice}G',
                                    style: TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: result.remainingBuybackMinutes <= 10
                                        ? AppTheme.errorColor.withValues(alpha: 0.1)
                                        : AppTheme.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '期限: ${result.remainingBuybackMinutes}分',
                                    style: TextStyle(
                                      color: result.remainingBuybackMinutes <= 10
                                          ? AppTheme.errorColor
                                          : AppTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAdventurerDetail(Adventurer adventurer) {
    showDialog(
      context: context,
      builder: (context) => AdventurerDetailDialog(
        adventurer: adventurer,
        onSellWeapon: adventurer.adventurerStatus == AdventurerStatus.visiting
            ? () => _showWeaponSaleDialog(adventurer)
            : null,
        onDispatchQuest: adventurer.adventurerStatus == AdventurerStatus.visiting
            ? () => _showQuestDispatchDialog(adventurer)
            : null,
      ),
    );
  }

  void _showWeaponSaleDialog(Adventurer adventurer) {
    showDialog(
      context: context,
      builder: (context) => WeaponSelectionDialog(
        adventurer: adventurer,
        onSale: (weaponId, price) => _handleWeaponSale(adventurer.id, weaponId, price),
      ),
    );
  }

  void _showQuestDispatchDialog(Adventurer adventurer) {
    final provider = context.read<AdventurerProvider>();
    showDialog(
      context: context,
      builder: (context) => QuestDispatchDialog(
        adventurer: adventurer,
        questAreas: provider.questAreas,
        onDispatch: (questAreaId) => _handleQuestDispatch(adventurer.id, questAreaId),
      ),
    );
  }

  void _showBuybackDialog(QuestResult result) {
    showDialog(
      context: context,
      builder: (context) => BuybackDialog(
        questResult: result,
        onBuyback: (itemIds) => _handleBuyback(result.id, itemIds),
        onReject: () => _handleBuybackReject(result.id),
      ),
    );
  }

  Future<void> _handleWeaponSale(String adventurerId, String weaponId, int price) async {
    final provider = context.read<AdventurerProvider>();
    
    try {
      final result = await provider.sellWeaponToAdventurer(adventurerId, weaponId, price);
      
      if (result.success && mounted) {
        // 詳細な成功メッセージを表示
        String successMessage = '武器を販売しました！\n';
        successMessage += '獲得ゴールド: ${result.goldEarned}G';
        
        if (result.trustGained != null && result.trustGained! > 0) {
          successMessage += '\n信頼度 +${result.trustGained}';
        }
        
        if (result.questDispatched && result.questAreaName != null) {
          successMessage += '\n✅ ${result.questAreaName}へクエスト派遣';
          if (result.questDurationMinutes != null) {
            successMessage += '（${result.questDurationMinutes}分）';
          }
        }
        
        if (result.saleReason != null) {
          successMessage += '\n${result.saleReason}';
        }
        
        _showSuccessMessage(successMessage);
      } else if (mounted) {
        // 詳細な失敗理由を表示
        _showErrorMessage(result.message.isNotEmpty ? result.message : '販売に失敗しました');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('予期しないエラーが発生しました: $e');
      }
    }
  }

  Future<void> _handleQuestDispatch(String adventurerId, String questAreaId) async {
    final provider = context.read<AdventurerProvider>();
    final success = await provider.sendAdventurerOnQuest(adventurerId, questAreaId);
    
    if (success && mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      _showSuccessMessage('冒険者を派遣しました！');
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '派遣に失敗しました');
    }
  }

  Future<void> _handleBuyback(String questResultId, List<String> itemIds) async {
    final provider = context.read<AdventurerProvider>();
    final success = await provider.buybackItems(questResultId, itemIds);
    
    if (success && mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      _showSuccessMessage('アイテムを買い取りました！');
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '買取に失敗しました');
    }
  }

  Future<void> _handleBuybackReject(String questResultId) async {
    final provider = context.read<AdventurerProvider>();
    final success = await provider.rejectBuyback(questResultId);
    
    if (success && mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      _showSuccessMessage('買取を拒否しました');
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '拒否に失敗しました');
    }
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

  Widget _buildStatsHeader(AdventurerProvider adventurerProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '--- 冒険者ギルド ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                '訪問者: ${adventurerProvider.visitingAdventurers.length}人',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '冒険中: ${adventurerProvider.onQuestAdventurers.length}人',
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

  Widget _buildEmptyStateWithSpawn(AdventurerProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '現在、訪問中の冒険者はいません',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '冒険者が自動で来店するか、手動で呼び出してください',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () async {
              try {
                await provider.manualSpawnVisitors();
                _showSuccessMessage('新しい冒険者を呼び出しました');
              } catch (e) {
                _showErrorMessage('冒険者の呼び出しに失敗しました');
              }
            },
            icon: const Icon(Icons.add_call),
            label: const Text('冒険者を呼び出す'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterTab() {
    return const CharacterScreen();
  }

}
