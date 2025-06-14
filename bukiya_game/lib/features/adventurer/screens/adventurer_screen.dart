import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/models/adventurer_new.dart';
import '../../../core/models/material_targeting.dart';
import '../providers/adventurer_provider.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../widgets/adventurer_card.dart';
import '../widgets/quest_progress_card.dart';
import '../widgets/adventurer_detail_dialog.dart';
import '../widgets/weapon_selection_dialog.dart';
import '../widgets/quest_dispatch_dialog.dart';
import '../widgets/buyback_dialog.dart';
import '../widgets/bulk_buyback_dialog.dart';
import '../widgets/bulk_buyback_result_dialog.dart';
import '../widgets/gem_spawn_confirmation_dialog.dart';
import '../../character/screens/character_screen.dart';
import '../../auth/providers/auth_provider.dart';

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
    debugPrint('=== 冒険中タブの表示 ===');
    debugPrint('isLoading: ${provider.isLoading}');
    debugPrint('onQuestAdventurers数: ${provider.onQuestAdventurers.length}');
    for (var adv in provider.onQuestAdventurers) {
      debugPrint('- ${adv.name} (${adv.status})');
    }
    debugPrint('======================');
    
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
      child: Column(
        children: [
          // 一括買取ボタン
          if (provider.pendingBuybacks.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => _showBulkBuybackDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.successColor,
                      width: 1,
                    ),
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '一括買取',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          // 買取リスト
          Expanded(
            child: provider.pendingBuybacks.isEmpty
                ? _buildEmptyState(
                    Icons.shopping_bag_outlined,
                    '現在、買取案件はありません',
                    '冒険者が帰還するまでお待ちください',
                  )
                : _buildBuybackList(provider.pendingBuybacks),
          ),
        ],
      ),
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
    // 武器販売ダイアログを開く前に冒険者の情報をログ出力
    debugPrint('=== 武器販売ダイアログ開始 ===');
    debugPrint('選択された冒険者: ${adventurer.name}');
    debugPrint('冒険者ID: ${adventurer.id}');
    debugPrint('ステータス: ${adventurer.status}');
    debugPrint('プレイヤーID: ${adventurer.playerId}');
    debugPrint('=============================');
    
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
        questAreaDropInfo: provider.questAreaDropInfo,
        onDispatch: (questAreaId) => _handleQuestDispatch(adventurer.id, questAreaId),
        onDispatchWithTargeting: (questAreaId, targetRequest) => 
            _handleQuestDispatchWithTargeting(adventurer.id, questAreaId, targetRequest),
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

  void _showBulkBuybackDialog() {
    final authProvider = context.read<AuthProvider>();
    final playerGold = authProvider.currentPlayer?.gold ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => BulkBuybackDialog(
        playerGold: playerGold,
        onSuccess: () => _handleBulkBuybackSuccess(),
      ),
    );
  }

  void _handleBulkBuybackSuccess() {
    // データを再読み込みして画面を更新
    final adventurerProvider = context.read<AdventurerProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // プレイヤー情報とアドベンチャー情報を更新
    authProvider.refreshPlayerData();
    adventurerProvider.loadAdventurerData();
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
        
        // クエスト派遣された場合は、自動的に「冒険中」タブに切り替える
        if (result.questDispatched) {
          _tabController.animateTo(1); // 1番目のタブ（冒険中）に切り替え
        }
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
      // Dialog is already closed by QuestDispatchDialog before calling this callback
      _showSuccessMessage('冒険者を派遣しました！');
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '派遣に失敗しました');
    }
  }

  Future<void> _handleQuestDispatchWithTargeting(
    String adventurerId, 
    int questAreaId, 
    MaterialTargetRequest? targetRequest
  ) async {
    final provider = context.read<AdventurerProvider>();
    final success = await provider.dispatchAdventurerWithTargeting(
      adventurerId: adventurerId,
      questAreaId: questAreaId,
      targetRequest: targetRequest,
    );
    
    if (success && mounted) {
      String message = '冒険者を派遣しました！';
      if (targetRequest != null && targetRequest.targetMaterialId != null) {
        message = '素材ターゲティング派遣が完了しました！ (${targetRequest.levelInfo.name})';
      }
      _showSuccessMessage(message);
    } else if (mounted) {
      _showErrorMessage(provider.errorMessage ?? '素材ターゲティング派遣に失敗しました');
    }
  }

  Future<void> _handleBuyback(String questResultId, List<String> itemIds) async {
    final provider = context.read<AdventurerProvider>();
    final success = await provider.buybackItems(questResultId, itemIds);
    
    if (success && mounted) {
      Navigator.of(context).pop(); // ダイアログを閉じる
      _showSuccessMessage('アイテムを買い取りました！');
    } else if (mounted) {
      // エラーダイアログで詳細な情報を表示
      _showDetailedErrorDialog(
        'アイテム買取エラー', 
        provider.errorMessage ?? '買取に失敗しました'
      );
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

  void _showDetailedErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
            if (message.contains('ゴールドが不足'))
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // インベントリ画面に移動して武器売却を促す
                  DefaultTabController.of(context)?.animateTo(0); // 訪問者タブに移動
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('武器を売る'),
              ),
          ],
        );
      },
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
    final authProvider = context.watch<AuthProvider>();
    final currentPlayer = authProvider.currentPlayer;
    final playerGems = currentPlayer?.gems ?? 0;
    const gemCost = 100; // ジェムスポーンのコスト

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
          
          // 通常の呼び出しボタン
          GestureDetector(
            onTap: provider.isLoading ? null : () async {
              await provider.manualSpawnVisitors();
              
              // Provider側でエラーハンドリングを行っているため、
              // エラーメッセージの有無をチェックして表示
              if (provider.errorMessage != null) {
                _showErrorMessage(provider.errorMessage!);
              } else {
                _showSuccessMessage('新しい冒険者を呼び出しました');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: provider.isLoading ? AppTheme.textSecondary : AppTheme.primaryColor,
                  width: 1,
                ),
                color: provider.isLoading 
                    ? AppTheme.textSecondary.withValues(alpha: 0.1)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_call,
                    color: provider.isLoading ? AppTheme.textSecondary : AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '冒険者を呼び出す',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: provider.isLoading ? AppTheme.textSecondary : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // ジェムスポーンボタン
          GestureDetector(
            onTap: provider.isLoading ? null : () async {
              // ジェム確認ダイアログを表示
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => GemSpawnConfirmationDialog(
                  playerGems: playerGems,
                  gemCost: gemCost,
                ),
              );
              
              if (confirmed == true) {
                final success = await provider.spawnVisitorsWithGems();
                
                if (success) {
                  _showSuccessMessage('💎 ジェムで冒険者を召喚しました！');
                } else if (provider.errorMessage != null) {
                  _showErrorMessage(provider.errorMessage!);
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: provider.isLoading ? AppTheme.textSecondary : AppTheme.rareColor,
                  width: 1,
                ),
                color: provider.isLoading 
                    ? AppTheme.textSecondary.withValues(alpha: 0.1)
                    : AppTheme.rareColor.withValues(alpha: 0.1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond,
                    color: provider.isLoading ? AppTheme.textSecondary : AppTheme.rareColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ジェムで即座に召喚 (${gemCost}💎)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: provider.isLoading ? AppTheme.textSecondary : AppTheme.rareColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // プレイヤーのジェム表示
          if (currentPlayer != null)
            Text(
              '所持ジェム: ${playerGems} 💎',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // テスト用：即座スポーンボタン（デバッグ用）
          if (kDebugMode)
            GestureDetector(
              onTap: provider.isLoading ? null : () async {
                try {
                  final authProvider = context.read<AuthProvider>();
                  final response = await authProvider.apiService.dio.post('/api/v1/adventurers/test-spawn-immediate');
                  if (response.statusCode == 200) {
                    await provider.loadAdventurerData();
                    _showSuccessMessage('🔧 テスト用：訪問者を即座にスポーンしました');
                  }
                } catch (e) {
                  _showErrorMessage('テストスポーンエラー: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: provider.isLoading ? AppTheme.textSecondary : Colors.orange,
                    width: 1,
                  ),
                  color: provider.isLoading 
                      ? AppTheme.textSecondary.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bug_report,
                      color: provider.isLoading ? AppTheme.textSecondary : Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '🔧 即座スポーン (テスト)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: provider.isLoading ? AppTheme.textSecondary : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterTab() {
    // 一時的にCharacterScreenを無効化（APIエンドポイント未実装のため）
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '固有キャラ機能は開発中です',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'この機能は将来のアップデートで実装予定です',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
