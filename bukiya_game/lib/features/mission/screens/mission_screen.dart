import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/mission_card.dart';
import '../widgets/mission_summary_card.dart';
import '../../../shared/themes/app_theme.dart';

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
    
    // ミッションデータを読み込み
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.today),
              text: 'デイリー',
            ),
            Tab(
              icon: Icon(Icons.calendar_view_week),
              text: 'ウィークリー',
            ),
            Tab(
              icon: Icon(Icons.emoji_events),
              text: 'アチーブメント',
            ),
          ],
        ),
      ),
      body: Consumer<MissionProvider>(
        builder: (context, missionProvider, child) {
          if (missionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (missionProvider.error != null) {
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
                    'エラーが発生しました',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    missionProvider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => missionProvider.fetchAllMissions(),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ミッション概要カード
              Container(
                margin: const EdgeInsets.all(16),
                child: _buildOverallSummary(missionProvider),
              ),
              
              // ミッション一覧
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // デイリーミッション
                    _buildMissionList(
                      missionProvider.dailyMissions,
                      'デイリーミッションはありません',
                    ),
                    
                    // ウィークリーミッション
                    _buildMissionList(
                      missionProvider.weeklyMissions,
                      'ウィークリーミッションはありません',
                    ),
                    
                    // アチーブメント
                    _buildMissionList(
                      missionProvider.achievements,
                      'アチーブメントはありません',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallSummary(MissionProvider missionProvider) {
    final totalClaimable = missionProvider.claimableRewardsCount;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ミッション概要',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '進捗状況と受取可能報酬',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalClaimable > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalClaimable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'デイリー',
                    '${missionProvider.completedDailyCount}/${missionProvider.dailyMissions.length}',
                    Icons.today,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'ウィークリー',
                    '${missionProvider.completedWeeklyCount}/${missionProvider.weeklyMissions.length}',
                    Icons.calendar_view_week,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'アチーブメント',
                    '${missionProvider.completedAchievementCount}/${missionProvider.achievements.length}',
                    Icons.emoji_events,
                  ),
                ),
              ],
            ),
            if (totalClaimable > 0) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _claimAllRewards(missionProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '全ての報酬を受け取る ($totalClaimable個)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionList(List<dynamic> missions, String emptyMessage) {
    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MissionProvider>().fetchAllMissions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MissionCard(
              mission: mission,
            ),
          );
        },
      ),
    );
  }

  void _claimAllRewards(MissionProvider missionProvider) async {
    try {
      final claimedCount = await missionProvider.claimAllRewards();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$claimedCount個の報酬を受け取りました！'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報酬の受け取りに失敗しました'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _claimReward(dynamic mission) async {
    try {
      await context.read<MissionProvider>().claimReward(mission.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報酬を受け取りました！'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('報酬の受け取りに失敗しました'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
