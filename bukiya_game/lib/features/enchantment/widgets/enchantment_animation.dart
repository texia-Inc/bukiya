import 'package:flutter/material.dart';
import 'dart:math' as math;

// エンチャント実行中のアニメーション
class EnchantmentProcessAnimation extends StatefulWidget {
  final Widget child;
  final bool isProcessing;
  final VoidCallback? onComplete;
  
  const EnchantmentProcessAnimation({
    Key? key,
    required this.child,
    required this.isProcessing,
    this.onComplete,
  }) : super(key: key);
  
  @override
  State<EnchantmentProcessAnimation> createState() => _EnchantmentProcessAnimationState();
}

class _EnchantmentProcessAnimationState extends State<EnchantmentProcessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    if (widget.isProcessing) {
      _startAnimation();
    }
  }
  
  @override
  void didUpdateWidget(EnchantmentProcessAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isProcessing && !oldWidget.isProcessing) {
      _startAnimation();
    } else if (!widget.isProcessing && oldWidget.isProcessing) {
      _stopAnimation();
    }
  }
  
  void _startAnimation() {
    _glowController.repeat(reverse: true);
    _particleController.repeat();
  }
  
  void _stopAnimation() {
    _glowController.stop();
    _particleController.stop();
    widget.onComplete?.call();
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isProcessing) {
      return widget.child;
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // グロー効果
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: _glowAnimation.value * 0.6),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
              child: widget.child,
            );
          },
        ),
        
        // パーティクルエフェクト
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: EnchantmentParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// エンチャントパーティクルペインター
class EnchantmentParticlePainter extends CustomPainter {
  final double progress;
  
  EnchantmentParticlePainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // シード固定で同じパターンに
    
    for (int i = 0; i < 20; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = size.height + 20;
      
      final currentY = startY - (progress * (size.height + 40));
      final waveX = math.sin(progress * math.pi * 4 + i) * 20;
      
      final opacity = (1 - progress) * 0.8;
      paint.color = Colors.purple.withValues(alpha: opacity);
      
      canvas.drawCircle(
        Offset(startX + waveX, currentY),
        3 + random.nextDouble() * 2,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// エンチャント成功アニメーション
class EnchantmentSuccessAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  
  const EnchantmentSuccessAnimation({
    Key? key,
    required this.onComplete,
  }) : super(key: key);
  
  @override
  State<EnchantmentSuccessAnimation> createState() => _EnchantmentSuccessAnimationState();
}

class _EnchantmentSuccessAnimationState extends State<EnchantmentSuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _shineController;
  late List<_Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particles = List.generate(30, (index) {
      final angle = (index / 30) * 2 * math.pi;
      return _Particle(
        angle: angle,
        speed: 100 + math.Random().nextDouble() * 200,
        size: 2 + math.Random().nextDouble() * 4,
        color: [Colors.yellow, Colors.orange, Colors.white][index % 3],
      );
    });
    
    _explosionController.forward();
    _shineController.forward();
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete();
    });
  }
  
  @override
  void dispose() {
    _explosionController.dispose();
    _shineController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 中央の光
            AnimatedBuilder(
              animation: _shineController,
              builder: (context, child) {
                final scale = _shineController.value * 3;
                final opacity = (1 - _shineController.value) * 0.8;
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: opacity),
                          Colors.yellow.withValues(alpha: opacity * 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // パーティクル爆発
            AnimatedBuilder(
              animation: _explosionController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ExplosionPainter(
                    particles: _particles,
                    progress: _explosionController.value,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// パーティクルデータ
class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  
  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

// 爆発ペインター
class _ExplosionPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  
  _ExplosionPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;
      
      final opacity = (1 - progress) * 0.8;
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1 - progress * 0.5),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// エンチャント失敗アニメーション
class EnchantmentFailureAnimation extends StatefulWidget {
  final bool weaponDestroyed;
  final VoidCallback onComplete;
  
  const EnchantmentFailureAnimation({
    Key? key,
    required this.weaponDestroyed,
    required this.onComplete,
  }) : super(key: key);
  
  @override
  State<EnchantmentFailureAnimation> createState() => _EnchantmentFailureAnimationState();
}

class _EnchantmentFailureAnimationState extends State<EnchantmentFailureAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _fadeController;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _shakeController.forward();
    if (widget.weaponDestroyed) {
      _fadeController.forward();
    }
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      widget.onComplete();
    });
  }
  
  @override
  void dispose() {
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 赤いフラッシュ
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.red.withValues(
                    alpha: (1 - _shakeAnimation.value) * 0.3,
                  ),
                );
              },
            ),
            
            // 破壊エフェクト
            if (widget.weaponDestroyed)
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: _ShatterPainter(
                      progress: _fadeController.value,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// 破片ペインター
class _ShatterPainter extends CustomPainter {
  final double progress;
  
  _ShatterPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = progress * 100;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance + progress * 50;
      
      final rotation = progress * math.pi * 2;
      final opacity = 1 - progress;
      
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      
      final path = Path()
        ..moveTo(-10, -10)
        ..lineTo(10, -5)
        ..lineTo(5, 10)
        ..lineTo(-5, 5)
        ..close();
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}