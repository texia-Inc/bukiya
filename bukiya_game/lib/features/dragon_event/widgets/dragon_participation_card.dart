import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';
// import 'package:bukiya_game/core/models/adventurer_new.dart' show AdventurerInstance;
import 'package:bukiya_game/features/dragon_event/widgets/adventurer_selection_dialog.dart';

class DragonParticipationCard extends StatelessWidget {
  final DragonEvent event;
  final bool isParticipating;
  final bool isJoining;
  final bool canClaim;
  final bool isClaimingRewards;
  final Function(int) onJoin;
  final VoidCallback onClaimRewards;

  const DragonParticipationCard({
    Key? key,
    required this.event,
    required this.isParticipating,
    required this.isJoining,
    required this.canClaim,
    required this.isClaimingRewards,
    required this.onJoin,
    required this.onClaimRewards,
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
                  Icons.people,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Participation',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Event Description
            if (event.description != null) ...[
              Text(
                event.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Rewards Information
            _buildRewardsSection(theme),
            
            const SizedBox(height: 20),
            
            // Participation Status
            if (isParticipating) ...[
              _buildParticipatingStatus(theme),
            ] else if (event.isActive) ...[
              _buildJoinSection(context, theme),
            ] else ...[
              _buildEventEndedSection(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Rewards',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRewardItem(
            'Participation',
            '${event.participationRewardGold} Gold',
            'Just for joining the battle',
            Icons.monetization_on,
          ),
          const SizedBox(height: 8),
          _buildRewardItem(
            'Victory Bonus',
            '${event.victoryBonusGold} Gold',
            'If the dragon is defeated',
            Icons.celebration,
          ),
          const SizedBox(height: 8),
          _buildRewardItem(
            'MVP Bonus',
            '${event.mvpBonusGold} Gold',
            'For dealing the most damage',
            Icons.emoji_events,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String title, String amount, String description, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.amber[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipatingStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'You are participating!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your adventurer is fighting bravely against the dragon. '
            'Stay tuned for battle updates and rewards!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.green[700],
            ),
          ),
          
          if (canClaim) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isClaimingRewards ? null : onClaimRewards,
                icon: isClaimingRewards
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.card_giftcard),
                label: Text(isClaimingRewards ? 'Claiming...' : 'Claim Rewards'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJoinSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'How to Join',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Select one of your adventurers to send into battle\n'
                '• Your adventurer will automatically fight the dragon\n'
                '• Higher level adventurers deal more damage\n'
                '• Better weapons increase your damage output',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isJoining ? null : () => _showAdventurerSelection(context),
            icon: isJoining
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(isJoining ? 'Joining...' : 'Send Adventurer to Battle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventEndedSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Event Ended',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This dragon event has ended. Check back later for the next event!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdventurerSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AdventurerSelectionDialog(
        onAdventurerSelected: onJoin,
      ),
    );
  }
}