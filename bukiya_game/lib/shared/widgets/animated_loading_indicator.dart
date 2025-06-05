import 'package:flutter/material.dart';
import 'dart:math' as math;

// ゲーム風のローディングインジケーター
class GameLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  
  const GameLoadingIndicator({
    Key? key,
    this.size = 50,
    this.color,
  }) : super(key: key);
  
  @override
  State<GameLoadingIndicator> createState() => _GameLoadingIndicatorState();
}

class _GameLoadingIndicatorState extends State<GameLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late List<Animation<double>> _scaleAnimations;
  
  @override
  void initState() {
    super.initState();
    
    // 回転アニメーション
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    
    // スケールアニメーション（4つの武器アイコン用）
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    _scaleAnimations = List.generate(4, (index) {
      final delay = index * 0.25;
      return Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Interval(
          delay,
          delay + 0.5,
          curve: Curves.easeInOut,
        ),
      ));
    });
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(4, (index) {
                final angle = (index * math.pi / 2);
                final iconOffset = Offset(
                  math.cos(angle) * widget.size * 0.3,
                  math.sin(angle) * widget.size * 0.3,
                );
                
                return Transform.translate(
                  offset: iconOffset,
                  child: Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: Icon(
                      _getWeaponIcon(index),
                      size: widget.size * 0.3,
                      color: color.withValues(
                        alpha: 0.6 + (_scaleAnimations[index].value - 0.8) * 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
  
  IconData _getWeaponIcon(int index) {
    const icons = [
      Icons.sports_martial_arts, // Sword
      Icons.construction, // Axe
      Icons.auto_fix_high, // Staff
      Icons.sports_golf, // Bow
    ];
    return icons[index % icons.length];
  }
}

// RPG風のプログレスバー
class RPGProgressBar extends StatefulWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double height;
  
  const RPGProgressBar({
    Key? key,
    required this.progress,
    this.label,
    this.color,
    this.height = 24,
  }) : super(key: key);
  
  @override
  State<RPGProgressBar> createState() => _RPGProgressBarState();
}

class _RPGProgressBarState extends State<RPGProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(_shimmerController);
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(color: color, width: 2),
        color: color.withValues(alpha: 0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2 - 2),
        child: Stack(
          children: [
            // 進捗バー
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: widget.height,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widget.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
            
            // シマーエフェクト
            if (widget.progress > 0 && widget.progress < 1)
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: ClipRect(
                      child: Transform.translate(
                        offset: Offset(_shimmerAnimation.value * 200, 0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            // ラベル
            if (widget.label != null)
              Center(
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.height * 0.5,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 武器エンチャント風のローディング
class EnchantmentLoadingIndicator extends StatefulWidget {
  final double size;
  
  const EnchantmentLoadingIndicator({
    Key? key,
    this.size = 100,
  }) : super(key: key);
  
  @override
  State<EnchantmentLoadingIndicator> createState() => _EnchantmentLoadingIndicatorState();
}

class _EnchantmentLoadingIndicatorState extends State<EnchantmentLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 外側の円
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              // 回転する魔法陣
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: Size(widget.size * 0.8, widget.size * 0.8),
                  painter: MagicCirclePainter(),
                ),
              ),
              
              // 中央の武器アイコン
              Icon(
                Icons.auto_fix_high,
                size: widget.size * 0.3,
                color: Colors.purple,
              ),
            ],
          );
        },
      ),
    );
  }
}

// 魔法陣ペインター
class MagicCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // 外側の円
    canvas.drawCircle(center, size.width / 2, paint);
    
    // 内側の円
    canvas.drawCircle(center, size.width / 3, paint);
    
    // 星形
    final path = Path();
    const points = 6;
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = i.isEven ? size.width / 2 : size.width / 3;
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}