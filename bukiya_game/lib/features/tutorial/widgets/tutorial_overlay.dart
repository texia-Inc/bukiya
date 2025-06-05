import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../core/models/tutorial.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/tutorial_provider.dart';

/// チュートリアルオーバーレイウィジェット
class TutorialOverlay extends StatefulWidget {
  final Widget child;
  
  const TutorialOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        final shouldShow = tutorialProvider.canShowCurrentStep();
        
        if (shouldShow) {
          _fadeController.forward();
        } else {
          _fadeController.reverse();
        }
        
        return Stack(
          children: [
            widget.child,
            if (shouldShow)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnimation.value,
                  child: _TutorialOverlayContent(
                    step: tutorialProvider.currentStepDefinition!,
                    targetKey: tutorialProvider.getTargetKey(),
                    pulseAnimation: _pulseAnimation,
                    onNext: () => tutorialProvider.nextStep(),
                    onSkip: () => tutorialProvider.skipTutorial(),
                    canSkip: tutorialProvider.canSkip,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// チュートリアルオーバーレイのコンテンツ
class _TutorialOverlayContent extends StatelessWidget {
  final TutorialStep step;
  final GlobalKey? targetKey;
  final Animation<double> pulseAnimation;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool canSkip;
  
  const _TutorialOverlayContent({
    required this.step,
    required this.targetKey,
    required this.pulseAnimation,
    required this.onNext,
    required this.onSkip,
    required this.canSkip,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 背景オーバーレイ
          _BackgroundOverlay(
            targetKey: targetKey,
            highlightShape: step.highlightShape,
            pulseAnimation: pulseAnimation,
          ),
          
          // 説明ダイアログ
          _TutorialDialog(
            step: step,
            targetKey: targetKey,
            onNext: onNext,
            onSkip: onSkip,
            canSkip: canSkip,
          ),
        ],
      ),
    );
  }
}

/// 背景オーバーレイ（ハイライト効果付き）
class _BackgroundOverlay extends StatelessWidget {
  final GlobalKey? targetKey;
  final TutorialHighlightShape highlightShape;
  final Animation<double> pulseAnimation;
  
  const _BackgroundOverlay({
    required this.targetKey,
    required this.highlightShape,
    required this.pulseAnimation,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _OverlayPainter(
            targetKey: targetKey,
            highlightShape: highlightShape,
            pulseScale: pulseAnimation.value,
          ),
        );
      },
    );
  }
}

/// オーバーレイペインター
class _OverlayPainter extends CustomPainter {
  final GlobalKey? targetKey;
  final TutorialHighlightShape highlightShape;
  final double pulseScale;
  
  _OverlayPainter({
    required this.targetKey,
    required this.highlightShape,
    required this.pulseScale,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8);
    
    // 全体を暗くする
    canvas.drawRect(Offset.zero & size, paint);
    
    // ターゲットがある場合はハイライト
    if (targetKey?.currentContext != null) {
      final targetBox = targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (targetBox != null) {
        final targetPosition = targetBox.localToGlobal(Offset.zero);
        final targetSize = targetBox.size;
        
        // ハイライト領域を描画（切り抜き）
        final highlightPaint = Paint()
          ..color = Colors.transparent
          ..blendMode = BlendMode.clear;
        
        final center = Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height / 2,
        );
        
        switch (highlightShape) {
          case TutorialHighlightShape.circle:
            final radius = (math.max(targetSize.width, targetSize.height) / 2 + 16) * pulseScale;
            canvas.drawCircle(center, radius, highlightPaint);
            
            // パルス効果のリング
            final ringPaint = Paint()
              ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
            canvas.drawCircle(center, radius, ringPaint);
            break;
            
          case TutorialHighlightShape.rectangle:
            final rect = Rect.fromCenter(
              center: center,
              width: (targetSize.width + 32) * pulseScale,
              height: (targetSize.height + 32) * pulseScale,
            );
            canvas.drawRect(rect, highlightPaint);
            
            // パルス効果のボーダー
            final borderPaint = Paint()
              ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
            canvas.drawRect(rect, borderPaint);
            break;
            
          case TutorialHighlightShape.roundedRectangle:
            final rect = RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: center,
                width: (targetSize.width + 32) * pulseScale,
                height: (targetSize.height + 32) * pulseScale,
              ),
              const Radius.circular(12),
            );
            canvas.drawRRect(rect, highlightPaint);
            
            // パルス効果のボーダー
            final borderPaint = Paint()
              ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3;
            canvas.drawRRect(rect, borderPaint);
            break;
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// チュートリアルダイアログ
class _TutorialDialog extends StatelessWidget {
  final TutorialStep step;
  final GlobalKey? targetKey;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool canSkip;
  
  const _TutorialDialog({
    required this.step,
    required this.targetKey,
    required this.onNext,
    required this.onSkip,
    required this.canSkip,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogPosition = _calculateDialogPosition(context, screenSize);
    
    return Positioned(
      left: dialogPosition.dx,
      top: dialogPosition.dy,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: math.min(screenSize.width * 0.8, 320),
          minWidth: 250,
        ),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダー
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          if (canSkip && step.isSkippable)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: onSkip,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 説明テキスト
                      Text(
                        step.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // ボタン
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (canSkip && step.isSkippable) ...[
                            TextButton(
                              onPressed: onSkip,
                              child: const Text('スキップ'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(step.buttonText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// ダイアログの位置を計算
  Offset _calculateDialogPosition(BuildContext context, Size screenSize) {
    // ターゲットがある場合はその位置を考慮
    if (targetKey?.currentContext != null) {
      final targetBox = targetKey!.currentContext!.findRenderObject() as RenderBox?;
      if (targetBox != null) {
        final targetPosition = targetBox.localToGlobal(Offset.zero);
        final targetSize = targetBox.size;
        
        // ターゲットの下に配置を試行
        double dialogY = targetPosition.dy + targetSize.height + 20;
        
        // 画面下部に収まらない場合は上に配置
        if (dialogY + 200 > screenSize.height) {
          dialogY = targetPosition.dy - 200 - 20;
        }
        
        // 左右中央に配置
        double dialogX = targetPosition.dx + targetSize.width / 2 - 160;
        
        // 画面左右の境界をチェック
        dialogX = math.max(20, math.min(dialogX, screenSize.width - 320 - 20));
        
        return Offset(dialogX, math.max(20, dialogY));
      }
    }
    
    // ターゲットがない場合は画面中央
    return Offset(
      (screenSize.width - 320) / 2,
      (screenSize.height - 200) / 2,
    );
  }
}

/// チュートリアル用のキー付きウィジェット
class TutorialKeyWidget extends StatelessWidget {
  final String tutorialKey;
  final Widget child;
  final TutorialProvider? tutorialProvider;
  
  const TutorialKeyWidget({
    Key? key,
    required this.tutorialKey,
    required this.child,
    this.tutorialProvider,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final provider = tutorialProvider ?? context.read<TutorialProvider>();
    final widgetKey = GlobalKey();
    
    // コンテキストにキーを登録
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.currentContext != null) {
        provider.currentContext!.widgetKeys[tutorialKey] = widgetKey;
      }
    });
    
    return Container(
      key: widgetKey,
      child: child,
    );
  }
}