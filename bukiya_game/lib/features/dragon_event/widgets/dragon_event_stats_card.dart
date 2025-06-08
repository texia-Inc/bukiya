import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';

class DragonEventStatsCard extends StatelessWidget {
  final DragonEvent event;
  final DragonEventStats? eventStats;
  final VoidCallback onLoadStats;

  const DragonEventStatsCard({
    Key? key,
    required this.event,
    this.eventStats,
    required this.onLoadStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Event Statistics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onLoadStats,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (eventStats == null) ...[
              _buildLoadingOrEmpty(theme),
            ] else ...[
              // Event Summary
              _buildEventSummary(theme),
              
              const SizedBox(height: 20),
              
              // MVP Section
              if (eventStats!.mvpPlayerName != null) ...[
                _buildMvpSection(theme),
                const SizedBox(height: 20),
              ],
              
              // Leaderboard
              _buildLeaderboard(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOrEmpty(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Load Event Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the refresh button to load detailed statistics and leaderboard',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onLoadStats,
            icon: const Icon(Icons.analytics),
            label: const Text('Load Stats'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEventSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: eventStats!.isVictory
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: eventStats!.isVictory
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                eventStats!.isVictory ? Icons.celebration : Icons.warning,
                color: eventStats!.isVictory ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                eventStats!.isVictory ? 'VICTORY!' : 'DEFEAT',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: eventStats!.isVictory ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                'Participants',
                '${eventStats!.totalParticipants}',
                Icons.people,
                Colors.blue,
              ),
              _buildSummaryItem(
                'Total Damage',
                '${eventStats!.totalDamageDealt}',
                Icons.flash_on,
                Colors.orange,
              ),
              _buildSummaryItem(
                'Dragon HP',
                '${event.dragonCurrentHp}',
                Icons.favorite,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMvpSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber[700],
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MVP (Most Valuable Player)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  eventStats!.mvpPlayerName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                Text(
                  'Dealt the most damage to the dragon',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage Leaderboard',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        if (eventStats!.topParticipants.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No participants data available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ] else ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: eventStats!.topParticipants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final participant = eventStats!.topParticipants[index];
              return _buildLeaderboardItem(participant, theme);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLeaderboardItem(DragonLeaderboardEntry participant, ThemeData theme) {
    Color rankColor;
    IconData rankIcon;
    
    switch (participant.rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankIcon = Icons.workspace_premium;
        break;
      case 3:
        rankColor = Colors.brown;
        rankIcon = Icons.workspace_premium;
        break;
      default:
        rankColor = Colors.grey[600]!;
        rankIcon = Icons.person;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: participant.rank <= 3 
            ? rankColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: participant.rank <= 3
            ? Border.all(color: rankColor.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              rankIcon,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.playerName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rank #${participant.rank}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Damage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${participant.damage.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
              Text(
                'Damage',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}