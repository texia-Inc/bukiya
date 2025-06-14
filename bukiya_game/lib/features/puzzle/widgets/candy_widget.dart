import 'package:flutter/material.dart';

import '../models/candy.dart';
import 'particle_effect.dart';

class CandyWidget extends StatefulWidget {
  final Candy candy;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final bool isSwapping;
  final Offset? swapDirection;

  const CandyWidget({
    Key? key,
    required this.candy,
    this.isSelected = false,
    this.onTap,
    this.size = 40.0,
    this.isSwapping = false,
    this.swapDirection,
  }) : super(key: key);

  @override
  State<CandyWidget> createState() => _CandyWidgetState();
}

class _CandyWidgetState extends State<CandyWidget>
    with TickerProviderStateMixin {
  late AnimationController _disappearController;
  late AnimationController _swapController;
  late AnimationController _fallController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _swapAnimation;
  late Animation<Offset> _fallAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 消去アニメーション
    _disappearController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // スワップアニメーション
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    // 落下アニメーション
    _fallController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // パルスアニメーション（選択時）
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _disappearController,
      curve: Curves.easeInBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _disappearController,
      curve: const Interval(0.5, 1.0),
    ));

    _swapAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOut,
    ));

    _fallAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fallController,
      curve: Curves.bounceOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));
  }

  @override
  void didUpdateWidget(CandyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // マッチしたキャンディの消去アニメーション
    if (widget.candy.isMatched && !oldWidget.candy.isMatched) {
      _playDisappearAnimation();
    }
    
    // スワップアニメーション
    if (widget.isSwapping && !oldWidget.isSwapping && widget.swapDirection != null) {
      _playSwapAnimation(widget.swapDirection!);
    }
    
    // 落下アニメーション
    if (widget.candy.isFalling && !oldWidget.candy.isFalling) {
      _playFallAnimation();
    }
    
    // 選択時のパルスアニメーション
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _playDisappearAnimation() async {
    await _disappearController.forward();
    _disappearController.reset();
  }

  void _playSwapAnimation(Offset direction) async {
    _swapAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOut,
    ));
    
    await _swapController.forward();
    _swapController.reset();
  }

  void _playFallAnimation() async {
    await _fallController.forward();
    _fallController.reset();
  }

  @override
  void dispose() {
    _disappearController.dispose();
    _swapController.dispose();
    _fallController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParticleEffect(
      showEffect: widget.candy.isMatched,
      particleColor: _getParticleColor(),
      child: GestureDetector(
        onTap: () {
          debugPrint('CandyWidget タップ検出: ${widget.candy.type}');
          widget.onTap?.call();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _disappearController,
            _swapController,
            _fallController,
            _pulseController,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: _swapAnimation.value * widget.size + _fallAnimation.value * widget.size,
              child: Transform.scale(
                scale: widget.candy.isMatched 
                    ? _scaleAnimation.value 
                    : (widget.isSelected ? _pulseAnimation.value : 1.0),
                child: Opacity(
                  opacity: widget.candy.isMatched ? _opacityAnimation.value : 1.0,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.isSelected 
                          ? Colors.yellow.withOpacity(0.3 + 0.2 * _pulseAnimation.value) 
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected ? Colors.orange : Colors.grey.shade300,
                        width: widget.isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.5 * _pulseAnimation.value),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        widget.candy.emoji,
                        style: TextStyle(
                          fontSize: widget.size * 0.6,
                          shadows: widget.candy.isMatched
                              ? [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Color _getParticleColor() {
    switch (widget.candy.type) {
      case CandyType.red:
        return Colors.red;
      case CandyType.blue:
        return Colors.blue;
      case CandyType.green:
        return Colors.green;
      case CandyType.yellow:
        return Colors.yellow;
      case CandyType.purple:
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}