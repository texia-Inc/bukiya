import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/mission.dart';
import 'package:bukiya_game/features/mission/providers/mission_provider.dart';
import 'package:bukiya_game/features/mission/widgets/mission_card.dart';
import 'package:bukiya_game/features/mission/widgets/mission_summary_card.dart';
import 'package:bukiya_game/shared/themes/app_theme.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 初回データ取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissionProvider>().fetchAllMissions();
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
        title: const Text(
          'ミッション',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          Consumer<MissionProvider>(
            builder: (context, provider, child) {
              if (provider.hasClaimableRewards) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.card_giftcard, color: Colors.white),
                      onPressed: () => _showClaimAllDialog(context, provider),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${provider.claimableRewardsCount}',
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
              context.read<MissionProvider>().refresh();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.today, size: 20),
                  const SizedBox(width: 4),
                  const Text('デイリー'),
                  Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      final count = provider.dailyMissions
                          .where((m) => m.canClaimReward)
                          .length;
                      if (count > 0) {
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_view_week, size: 20),
                  const SizedBox(width: 4),
                  const Text('ウィークリー'),
                  Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      final count = provider.weeklyMissions
                          .where((m) => m.canClaimReward)
                          .length;
                      if (count > 0) {
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 20),
                  const SizedBox(width: 4),
                  const Text('実績'),
                  Consumer<MissionProvider>(
                    builder: (context, provider, child) {
                      final count = provider.achievements
                          .where((m) => m.canClaimReward)
                          .length;
                      if (count > 0) {
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<MissionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMissionList(
                provider.dailyMissions,
                MissionType.daily,
                provider,
              ),
              _buildMissionList(
                provider.weeklyMissions,
                MissionType.weekly,
                provider,
              ),
              _buildMissionList(
                provider.achievements,
                MissionType.achievement,
                provider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionList(
    List<Mission> missions,
    MissionType type,
    MissionProvider provider,
  ) {
    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(type),
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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // サマリーカード
          MissionSummaryCard(
            type: type,
            missions: missions,
          ),
          const SizedBox(height: 16),
          
          // ミッションリスト
          ...missions.map((mission) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionCard(
              mission: mission,
              onClaimReward: () => _claimReward(mission, provider),
            ),
          )),
        ],
      ),
    );
  }

  IconData _getTypeIcon(MissionType type) {
    switch (type) {
      case MissionType.daily:
        return Icons.today;
      case MissionType.weekly:
        return Icons.calendar_view_week;
      case MissionType.achievement:
        return Icons.emoji_events;
    }
  }

  String _getEmptyMessage(MissionType type) {
    switch (type) {
      case MissionType.daily:
        return 'デイリーミッションはありません';
      case MissionType.weekly:
        return 'ウィークリーミッションはありません';
      case MissionType.achievement:
        return 'アチーブメントはありません';
    }
  }

  Future<void> _claimReward(Mission mission, MissionProvider provider) async {
    final success = await provider.claimReward(mission.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('報酬を受け取りました: ${mission.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('報酬の受取に失敗しました'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showClaimAllDialog(
    BuildContext context,
    MissionProvider provider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('一括受取'),
        content: Text(
          '受取可能な報酬 ${provider.claimableRewardsCount} 個をすべて受け取りますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('受け取る'),
          ),
        ],
      ),
    );

    if (result == true) {
      final claimedCount = await provider.claimAllRewards();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$claimedCount 個の報酬を受け取りました'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
