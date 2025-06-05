import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/models/adventurer.dart';
import '../providers/adventurer_provider.dart';
import '../widgets/adventurer_card.dart';
import '../widgets/quest_progress_card.dart';
import '../widgets/buyback_alert_card.dart';
import '../widgets/adventurer_detail_dialog.dart';
import '../widgets/weapon_sale_dialog.dart';
import '../widgets/quest_dispatch_dialog.dart';
import '../widgets/buyback_dialog.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdventurerData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdventurerData() async {
    final adventurerProvider = context.read<AdventurerProvider>();
    await adventurerProvider.loadAdventurerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('=== 冒険者ギルド ==='),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Consumer<AdventurerProvider>(
        builder: (context, adventurerProvider, child) {
          return Container(
            color: AppTheme.backgroundColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ヘッダー情報
                  _buildRetroHeader(adventurerProvider),
                  const SizedBox(height: 4),
                  
                  // タブメニュー
                  _buildRetroTabs(adventurerProvider),
                  const SizedBox(height: 4),
                  
                  // メインコンテンツ
                  _buildRetroContent(adventurerProvider),
                ],
              ),
            ),
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
          ? _buildEmptyState(
              Icons.people_outline,
              '現在、訪問中の冒険者はいません',
              '冒険者が来店するまでお待ちください',
            )
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
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          results[index].questArea[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${results[index].questArea}からの帰還',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('アイテム数: ${results[index].drops.length}'),
                          Text(
                            '買取価格: ${results[index].totalBuybackPrice}G',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '期限: ${results[index].remainingBuybackMinutes}分',
                            style: TextStyle(
                              color: results[index].remainingBuybackMinutes <= 10
                                  ? AppTheme.errorColor
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showBuybackDialog(results[index]),
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
        onSellWeapon: adventurer.status == AdventurerStatus.visiting
            ? () => _showWeaponSaleDialog(adventurer)
            : null,
        onDispatchQuest: adventurer.status == AdventurerStatus.visiting
            ? () => _showQuestDispatchDialog(adventurer)
            : null,
      ),
    );
  }

  void _showWeaponSaleDialog(Adventurer adventurer) {
    showDialog(
      context: context,
      builder: (context) => WeaponSaleDialog(
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
    final success = await provider.sellWeaponToAdventurer(adventurerId, weaponId, price);
    
    if (success && mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      _showSuccessMessage('武器を販売しました！');
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '販売に失敗しました');
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

  Widget _buildRetroHeader(AdventurerProvider adventurerProvider) {
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

  Widget _buildRetroTabs(AdventurerProvider adventurerProvider) {
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
                  '[1] 訪問者 (${adventurerProvider.visitingAdventurers.length})',
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
                  '[2] 冒険中 (${adventurerProvider.onQuestAdventurers.length})',
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
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: _tabController.index == 2 
                    ? Border.all(color: AppTheme.primaryColor, width: 1)
                    : null,
                ),
                child: Text(
                  '[3] 買取 (${adventurerProvider.pendingBuybacks.length})',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _tabController.index == 2 
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

  Widget _buildRetroContent(AdventurerProvider adventurerProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: IndexedStack(
        index: _tabController.index,
        children: [
          _buildVisitorsTab(adventurerProvider),
          _buildOnQuestTab(adventurerProvider),
          _buildBuybackTab(adventurerProvider),
        ],
      ),
    );
  }
}
