import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/features/dragon_event/providers/dragon_event_provider.dart';
import 'package:bukiya_game/features/dragon_event/widgets/dragon_battle_display.dart';
import 'package:bukiya_game/features/dragon_event/widgets/dragon_participation_card.dart';
import 'package:bukiya_game/features/dragon_event/widgets/dragon_event_stats_card.dart';
import 'package:bukiya_game/features/dragon_event/widgets/dragon_battle_logs.dart';
import 'package:bukiya_game/features/dragon_event/widgets/dragon_rewards_dialog.dart';
import 'package:bukiya_game/shared/widgets/loading_screen.dart';

class DragonEventScreen extends StatefulWidget {
  const DragonEventScreen({Key? key}) : super(key: key);

  @override
  State<DragonEventScreen> createState() => _DragonEventScreenState();
}

class _DragonEventScreenState extends State<DragonEventScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DragonEventProvider>().loadCurrentEvent();
    });
    
    // Set up periodic refresh
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshData(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshData() {
    context.read<DragonEventProvider>().refresh();
  }

  Future<void> _onRefresh() async {
    await context.read<DragonEventProvider>().refresh();
  }

  void _showRewardsDialog() {
    final provider = context.read<DragonEventProvider>();
    if (provider.lastRewards != null) {
      showDialog(
        context: context,
        builder: (context) => DragonRewardsDialog(
          rewards: provider.lastRewards!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dragon Raid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.whatshot), text: 'Battle'),
            Tab(icon: Icon(Icons.people), text: 'Participate'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Stats'),
          ],
        ),
      ),
      body: Consumer<DragonEventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentEvent == null) {
            return const LoadingScreen(message: 'Loading dragon event...');
          }

          if (provider.error != null) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading dragon event',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          if (provider.currentEvent == null) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Dragon Event',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dragon events happen weekly.\nCheck back later!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Battle Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dragon Battle Display
                      DragonBattleDisplay(
                        event: provider.currentEvent!,
                        battleState: provider.battleState,
                      ),
                      const SizedBox(height: 16),
                      
                      // Battle Logs
                      DragonBattleLogs(
                        battleLogs: provider.getRecentBattleMessages(limit: 10),
                        isLoading: provider.isBattleLoading,
                      ),
                      
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
              
              // Participation Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DragonParticipationCard(
                        event: provider.currentEvent!,
                        isParticipating: provider.isPlayerParticipating,
                        isJoining: provider.isJoining,
                        canClaim: provider.canClaimRewards,
                        isClaimingRewards: provider.isClaimingRewards,
                        onJoin: (adventurerInstanceId) async {
                          final success = await provider.joinEvent(
                            provider.currentEvent!.id,
                            adventurerInstanceId,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Successfully joined the dragon raid!'),
                              ),
                            );
                          }
                        },
                        onClaimRewards: () async {
                          final success = await provider.claimRewards(
                            provider.currentEvent!.id,
                          );
                          if (success) {
                            _showRewardsDialog();
                          }
                        },
                      ),
                      
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
              
              // Stats Tab
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DragonEventStatsCard(
                        event: provider.currentEvent!,
                        eventStats: provider.eventStats,
                        onLoadStats: () {
                          provider.loadEventStats(provider.currentEvent!.id);
                        },
                      ),
                      
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      
      // Floating Action Button for quick actions
      floatingActionButton: Consumer<DragonEventProvider>(
        builder: (context, provider, child) {
          if (provider.currentEvent == null || !provider.hasActiveEvent) {
            return const SizedBox.shrink();
          }
          
          if (provider.isPlayerParticipating && provider.canClaimRewards) {
            return FloatingActionButton.extended(
              onPressed: provider.isClaimingRewards ? null : () async {
                final success = await provider.claimRewards(
                  provider.currentEvent!.id,
                );
                if (success) {
                  _showRewardsDialog();
                }
              },
              icon: provider.isClaimingRewards 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.card_giftcard),
              label: Text(provider.isClaimingRewards ? 'Claiming...' : 'Claim Rewards'),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}