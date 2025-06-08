import 'package:flutter/material.dart';

class DragonBattleLogs extends StatefulWidget {
  final List<String> battleLogs;
  final bool isLoading;

  const DragonBattleLogs({
    Key? key,
    required this.battleLogs,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<DragonBattleLogs> createState() => _DragonBattleLogsState();
}

class _DragonBattleLogsState extends State<DragonBattleLogs>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DragonBattleLogs oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Scroll to bottom when new logs are added
    if (widget.battleLogs.length > oldWidget.battleLogs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getLogColor(String message) {
    if (message.contains('Critical damage')) {
      return Colors.red;
    } else if (message.contains('Special damage')) {
      return Colors.purple;
    } else if (message.contains('roared') || message.contains('trembled') || message.contains('swirled')) {
      return Colors.orange;
    } else if (message.contains('struggled') || message.contains('reduced')) {
      return Colors.grey;
    }
    return Colors.blue;
  }

  IconData _getLogIcon(String message) {
    if (message.contains('Critical damage')) {
      return Icons.flash_on;
    } else if (message.contains('Special damage')) {
      return Icons.auto_awesome;
    } else if (message.contains('roared') || message.contains('trembled') || message.contains('swirled')) {
      return Icons.warning;
    } else if (message.contains('struggled') || message.contains('reduced')) {
      return Icons.shield;
    }
    return Icons.sports_martial_arts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Battle Log',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (widget.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Battle Logs
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: widget.battleLogs.isEmpty
                ? _buildEmptyState(theme)
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: widget.battleLogs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final message = widget.battleLogs[index];
                        final color = _getLogColor(message);
                        final icon = _getLogIcon(message);
                        
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: Opacity(
                                opacity: value,
                                child: _buildLogItem(message, color, icon, theme),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String message, Color color, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 3,
            color: color,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No battle activity yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Battle logs will appear here when the fight begins',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}