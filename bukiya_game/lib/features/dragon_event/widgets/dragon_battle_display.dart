import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';

class DragonBattleDisplay extends StatefulWidget {
  final DragonEvent event;
  final DragonBattleState? battleState;

  const DragonBattleDisplay({
    Key? key,
    required this.event,
    this.battleState,
  }) : super(key: key);

  @override
  State<DragonBattleDisplay> createState() => _DragonBattleDisplayState();
}

class _DragonBattleDisplayState extends State<DragonBattleDisplay>
    with TickerProviderStateMixin {
  late AnimationController _dragonAnimationController;
  late AnimationController _hpBarAnimationController;
  late Animation<double> _dragonShakeAnimation;
  late Animation<double> _hpBarAnimation;

  @override
  void initState() {
    super.initState();
    
    _dragonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _hpBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _dragonShakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _dragonAnimationController,
      curve: Curves.elasticInOut,
    ));
    
    _hpBarAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _hpBarAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _hpBarAnimationController.forward();
  }

  @override
  void didUpdateWidget(DragonBattleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger dragon shake animation when HP changes
    if (oldWidget.battleState?.dragonCurrentHp != widget.battleState?.dragonCurrentHp) {
      _dragonAnimationController.forward().then((_) {
        _dragonAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _dragonAnimationController.dispose();
    _hpBarAnimationController.dispose();
    super.dispose();
  }

  double get _hpPercentage {
    if (widget.battleState != null) {
      return widget.battleState!.hpPercentage / 100;
    }
    return widget.event.hpPercentage;
  }

  int get _currentHp {
    return widget.battleState?.dragonCurrentHp ?? widget.event.dragonCurrentHp;
  }

  int get _maxHp {
    return widget.battleState?.dragonMaxHp ?? widget.event.dragonMaxHp;
  }

  String get _timeRemaining {
    if (widget.battleState != null) {
      return widget.battleState!.timeRemainingText;
    } else {
      final remaining = widget.event.timeRemaining;
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getHpBarColor() {
    if (_hpPercentage > 0.6) return Colors.green;
    if (_hpPercentage > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Event Title
            Text(
              widget.event.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Event Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: widget.event.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.event.isActive ? 'ACTIVE' : widget.event.status.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Dragon Image with Animation
            AnimatedBuilder(
              animation: _dragonShakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_dragonShakeAnimation.value, 0),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _hpPercentage <= 0 ? Colors.grey : Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.whatshot,
                      size: 60,
                      color: _hpPercentage <= 0 ? Colors.white54 : Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Dragon HP Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dragon HP',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentHp.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} / ${_maxHp.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedBuilder(
                    animation: _hpBarAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _hpPercentage * _hpBarAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(_getHpBarColor()),
                        borderRadius: BorderRadius.circular(10),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Center(
                  child: Text(
                    '${(_hpPercentage * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getHpBarColor(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Battle Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'Time Left',
                  _timeRemaining,
                  Icons.timer,
                  theme.colorScheme.primary,
                ),
                _buildStatColumn(
                  'Participants',
                  '${widget.battleState?.participantCount ?? widget.event.participants.length}',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatColumn(
                  'Total Damage',
                  '${widget.battleState?.totalDamageDealt ?? (_maxHp - _currentHp)}',
                  Icons.flash_on,
                  Colors.orange,
                ),
              ],
            ),
            
            // Victory/Defeat Status
            if (!widget.event.isActive && widget.event.isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.event.isVictory ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.event.isVictory ? Icons.celebration : Icons.warning,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.event.isVictory ? 'VICTORY!' : 'DEFEAT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
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
}