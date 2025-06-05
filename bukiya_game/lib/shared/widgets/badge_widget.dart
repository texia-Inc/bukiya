import 'package:flutter/material.dart';

/// 右上に赤丸バッジを表示するウィジェット
class BadgeWidget extends StatelessWidget {
  final Widget child;
  final int? count;
  final bool showBadge;
  final Color badgeColor;
  final Color textColor;
  final double badgeSize;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final Offset? offset;

  const BadgeWidget({
    super.key,
    required this.child,
    this.count,
    this.showBadge = true,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.badgeSize = 20.0,
    this.fontSize = 12.0,
    this.padding,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge || (count != null && count! <= 0)) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: offset?.dx ?? -8,
          top: offset?.dy ?? -8,
          child: Container(
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            padding: padding ?? 
                (count != null 
                    ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                    : EdgeInsets.zero),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: count == null ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: count != null ? BorderRadius.circular(10) : null,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: count != null
                ? Center(
                    child: Text(
                      count! > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SizedBox(
                    width: badgeSize,
                    height: badgeSize,
                  ),
          ),
        ),
      ],
    );
  }
}

/// アニメーション付きのバッジウィジェット
class AnimatedBadgeWidget extends StatefulWidget {
  final Widget child;
  final int? count;
  final bool showBadge;
  final Color badgeColor;
  final Color textColor;
  final double badgeSize;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final Offset? offset;
  final Duration animationDuration;

  const AnimatedBadgeWidget({
    super.key,
    required this.child,
    this.count,
    this.showBadge = true,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.badgeSize = 20.0,
    this.fontSize = 12.0,
    this.padding,
    this.offset,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedBadgeWidget> createState() => _AnimatedBadgeWidgetState();
}

class _AnimatedBadgeWidgetState extends State<AnimatedBadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showBadge && (widget.count == null || widget.count! > 0)) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBadgeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // カウントが変更された場合のアニメーション
    if (widget.count != oldWidget.count) {
      if (widget.showBadge && (widget.count == null || widget.count! > 0)) {
        _animationController.forward();
        // パルスアニメーション
        _animationController.repeat(reverse: true);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _animationController.stop();
            _animationController.forward();
          }
        });
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.showBadge && (widget.count == null || widget.count! > 0))
          Positioned(
            right: widget.offset?.dx ?? -8,
            top: widget.offset?.dy ?? -8,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: widget.badgeSize,
                      minHeight: widget.badgeSize,
                    ),
                    padding: widget.padding ?? 
                        (widget.count != null 
                            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                            : EdgeInsets.zero),
                    decoration: BoxDecoration(
                      color: widget.badgeColor,
                      shape: widget.count == null ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: widget.count != null ? BorderRadius.circular(10) : null,
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: widget.badgeColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: widget.count != null
                        ? Center(
                            child: Text(
                              widget.count! > 99 ? '99+' : widget.count.toString(),
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : SizedBox(
                            width: widget.badgeSize,
                            height: widget.badgeSize,
                          ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// バッジ付きアイコンボタン
class BadgedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final int? badgeCount;
  final bool showBadge;
  final Color? iconColor;
  final double iconSize;
  final Color badgeColor;
  final String? tooltip;
  final bool animated;

  const BadgedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.badgeCount,
    this.showBadge = true,
    this.iconColor,
    this.iconSize = 24.0,
    this.badgeColor = Colors.red,
    this.tooltip,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconButton = IconButton(
      icon: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );

    if (animated) {
      return AnimatedBadgeWidget(
        count: badgeCount,
        showBadge: showBadge,
        badgeColor: badgeColor,
        child: iconButton,
      );
    } else {
      return BadgeWidget(
        count: badgeCount,
        showBadge: showBadge,
        badgeColor: badgeColor,
        child: iconButton,
      );
    }
  }
}

/// バッジ付きボトムナビゲーションバーアイテム用ヘルパー
class BadgedBottomNavigationBarItem extends BottomNavigationBarItem {
  BadgedBottomNavigationBarItem({
    required Widget icon,
    required String label,
    Widget? activeIcon,
    int? badgeCount,
    bool showBadge = true,
    Color badgeColor = Colors.red,
    bool animated = false,
    String? tooltip,
  }) : super(
          icon: animated
              ? AnimatedBadgeWidget(
                  count: badgeCount,
                  showBadge: showBadge,
                  badgeColor: badgeColor,
                  child: icon,
                )
              : BadgeWidget(
                  count: badgeCount,
                  showBadge: showBadge,
                  badgeColor: badgeColor,
                  child: icon,
                ),
          activeIcon: activeIcon != null
              ? (animated
                  ? AnimatedBadgeWidget(
                      count: badgeCount,
                      showBadge: showBadge,
                      badgeColor: badgeColor,
                      child: activeIcon,
                    )
                  : BadgeWidget(
                      count: badgeCount,
                      showBadge: showBadge,
                      badgeColor: badgeColor,
                      child: activeIcon,
                    ))
              : null,
          label: label,
          tooltip: tooltip,
        );
}

/// バッジの色を定義する列挙型
enum BadgeType {
  notification(Colors.red),
  success(Colors.green),
  warning(Colors.orange),
  info(Colors.blue),
  error(Colors.red);

  const BadgeType(this.color);
  final Color color;
}

/// 異なるタイプのバッジを簡単に作成するためのヘルパークラス
class BadgeHelper {
  static Widget notification({
    required Widget child,
    int? count,
    bool showBadge = true,
    bool animated = true,
  }) {
    return animated
        ? AnimatedBadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.notification.color,
            child: child,
          )
        : BadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.notification.color,
            child: child,
          );
  }

  static Widget success({
    required Widget child,
    int? count,
    bool showBadge = true,
    bool animated = true,
  }) {
    return animated
        ? AnimatedBadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.success.color,
            child: child,
          )
        : BadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.success.color,
            child: child,
          );
  }

  static Widget warning({
    required Widget child,
    int? count,
    bool showBadge = true,
    bool animated = true,
  }) {
    return animated
        ? AnimatedBadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.warning.color,
            child: child,
          )
        : BadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.warning.color,
            child: child,
          );
  }

  static Widget info({
    required Widget child,
    int? count,
    bool showBadge = true,
    bool animated = true,
  }) {
    return animated
        ? AnimatedBadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.info.color,
            child: child,
          )
        : BadgeWidget(
            count: count,
            showBadge: showBadge,
            badgeColor: BadgeType.info.color,
            child: child,
          );
  }
}