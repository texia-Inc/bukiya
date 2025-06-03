import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/mission.dart';

class MissionSummaryCard extends StatelessWidget {
  final MissionType type;
  final List<Mission> missions;

  const MissionSummaryCard({
    super.key,
    required this.type,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = missions.where((m) => m.isCompleted).length;
    final claimableCount = missions.where((m) => m.canClaimReward).length;
    final totalRewardGold = missions
        .where((m) => m.canClaimReward)
        .fold<int>(0, (sum, m) => sum + m.rewardGold);
    final totalRewardExp = missions
        .where((m) => m.canClaimReward)
        .fold<int>(0, (sum, m) => sum + m.rewardExp);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _getGradient(),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(
                  _getTypeIcon(),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getSubtitle(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (claimableCount > 0)
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
                      '$claimableCount',
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
            
            // 進捗情報
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '完了',
                    '$completedCount/${missions.length}',
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '受取可能',
                    '$claimableCount',
                    Icons.card_giftcard,
                  ),
                ),
              ],
            ),
            
            if (claimableCount > 0) ...[
              const SizedBox(height: 16),
              
              // 受取可能報酬
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '受取可能報酬',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (totalRewardGold > 0) ...[
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${totalRewardGold.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                              (Match m) => '${m[1]},'
                            )}G',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        if (totalRewardGold > 0 && totalRewardExp > 0)
                          const SizedBox(width: 16),
                        if (totalRewardExp > 0) ...[
                          const Icon(
                            Icons.star,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${totalRewardExp}EXP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // 次回リセット時間（デイリー・ウィークリーのみ）
            if (type != MissionType.achievement && missions.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildResetInfo(),
            ],
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (type) {
      case MissionType.daily:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MissionType.weekly:
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case MissionType.achievement:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case MissionType.daily:
        return Icons.today;
      case MissionType.weekly:
        return Icons.calendar_view_week;
      case MissionType.achievement:
        return Icons.emoji_events;
    }
  }

  String _getSubtitle() {
    switch (type) {
      case MissionType.daily:
        return '毎日更新されるミッション';
      case MissionType.weekly:
        return '毎週更新されるミッション';
      case MissionType.achievement:
        return '永続的な実績';
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
            fontSize: 18,
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

  Widget _buildResetInfo() {
    final now = DateTime.now();
    DateTime nextReset;
    String resetLabel;

    if (type == MissionType.daily) {
      nextReset = DateTime(now.year, now.month, now.day + 1);
      resetLabel = 'デイリーリセット';
    } else {
      // ウィークリー（月曜日リセット）
      final daysUntilMonday = (8 - now.weekday) % 7;
      nextReset = DateTime(now.year, now.month, now.day + daysUntilMonday);
      if (daysUntilMonday == 0) {
        nextReset = nextReset.add(const Duration(days: 7));
      }
      resetLabel = 'ウィークリーリセット';
    }

    final timeUntilReset = nextReset.difference(now);
    
    return Row(
      children: [
        const Icon(
          Icons.schedule,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$resetLabel: ${_formatDuration(timeUntilReset)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}日${duration.inHours % 24}時間後';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}時間${duration.inMinutes % 60}分後';
    } else {
      return '${duration.inMinutes}分後';
    }
  }
}
