import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onClose;

  const AnimatedSuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle,
    this.iconColor = Colors.green,
    this.onClose,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle,
    Color iconColor = Colors.green,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimatedSuccessDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  State<AnimatedSuccessDialog> createState() => _AnimatedSuccessDialogState();
}

class _AnimatedSuccessDialogState extends State<AnimatedSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // スケールアニメーション
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // 回転アニメーション
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutBack,
    ));

    // パーティクルアニメーション
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    // アニメーション開始
    _scaleController.forward();
    _rotationController.forward();

    // 自動的に閉じる
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onClose?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.iconColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコンとパーティクル
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // パーティクルエフェクト
                  AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(120, 120),
                        painter: ParticlePainter(
                          progress: _particleAnimation.value,
                          color: widget.iconColor,
                        ),
                      );
                    },
                  ),
                  // メインアイコン
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
                    builder: (context, child) => Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(_scaleAnimation.value)
                        ..rotateZ(_rotationAnimation.value),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.iconColor,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // タイトル
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // メッセージ
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey[600],
              ),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// パーティクルペインター
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  ParticlePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * (1 - progress))
      ..style = PaintingStyle.fill;

    // 8方向にパーティクルを描画
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (progress * math.pi / 8);
      final distance = progress * 50;
      
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      final particleSize = 4 * (1 - progress);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// エラー用のアニメーションダイアログ
class AnimatedErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onClose;

  const AnimatedErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.onClose,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AnimatedErrorDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  State<AnimatedErrorDialog> createState() => _AnimatedErrorDialogState();
}

class _AnimatedErrorDialogState extends State<AnimatedErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _shakeController.forward();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      '閉じる',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}