import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/mission.dart';
import 'package:bukiya_game/shared/themes/app_theme.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onClaimReward;

  const MissionCard({
    super.key,
    required this.mission,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: _getGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Row(
                children: [
                  Icon(
                    _getTypeIcon(),
                    color: _getTypeColor(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mission.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 説明文
              Text(
                mission.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 進捗バー
              _buildProgressBar(),
              
              const SizedBox(height: 8),
              
              // 進捗テキスト
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${mission.targetTypeDisplayName}: ${mission.currentProgress}/${mission.targetCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  if (mission.timeRemaining != null)
                    Text(
                      _formatTimeRemaining(mission.timeRemaining!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 報酬とボタン
              Row(
                children: [
                  Expanded(
                    child: _buildRewardInfo(),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (mission.missionType) {
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
    switch (mission.missionType) {
      case MissionType.daily:
        return Icons.today;
      case MissionType.weekly:
        return Icons.calendar_view_week;
      case MissionType.achievement:
        return Icons.emoji_events;
    }
  }

  Color _getTypeColor() {
    return Colors.white;
  }

  Widget _buildStatusChip() {
    if (mission.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '受取済み',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (mission.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '完了',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (mission.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '期限切れ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: mission.progressPercentage,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            mission.isCompleted ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '報酬',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (mission.rewardGold > 0) ...[
              const Icon(
                Icons.monetization_on,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                '${mission.rewardGold.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                  (Match m) => '${m[1]},'
                )}G',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (mission.rewardGold > 0 && mission.rewardExp > 0)
              const SizedBox(width: 12),
            if (mission.rewardExp > 0) ...[
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                '${mission.rewardExp}EXP',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (mission.isClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '受取済み',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (mission.canClaimReward) {
      return ElevatedButton(
        onPressed: onClaimReward,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          '受け取る',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (mission.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '期限切れ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${(mission.progressPercentage * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '残り${duration.inDays}日';
    } else if (duration.inHours > 0) {
      return '残り${duration.inHours}時間';
    } else if (duration.inMinutes > 0) {
      return '残り${duration.inMinutes}分';
    } else {
      return '残り${duration.inSeconds}秒';
    }
  }
}
