import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// 取引結果のフィードバックを表示するウィジェット
class TransactionFeedback {
  /// 成功フィードバックを表示
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    int? goldChange,
    int? expGained,
    String? itemReceived,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TransactionFeedbackWidget(
        title: title,
        message: message,
        isSuccess: true,
        goldChange: goldChange,
        expGained: expGained,
        itemReceived: itemReceived,
        onTap: onTap,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // 自動で削除
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 失敗フィードバックを表示
  static void showError(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TransactionFeedbackWidget(
        title: title,
        message: message,
        isSuccess: false,
        onTap: onTap,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // 自動で削除
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 利益/損失フィードバックを表示
  static void showProfitLoss(
    BuildContext context, {
    required String action,
    required int amount,
    required int profit,
    String? itemName,
  }) {
    final isProfit = profit > 0;
    final profitText = isProfit 
        ? '+${profit}G 利益' 
        : '${profit}G 損失';
    
    showSuccess(
      context,
      title: action,
      message: itemName != null ? '$itemName を ${amount}Gで$action' : '',
      goldChange: profit,
    );
  }
}

class _TransactionFeedbackWidget extends StatefulWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final int? goldChange;
  final int? expGained;
  final String? itemReceived;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _TransactionFeedbackWidget({
    required this.title,
    required this.message,
    required this.isSuccess,
    this.goldChange,
    this.expGained,
    this.itemReceived,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TransactionFeedbackWidget> createState() => _TransactionFeedbackWidgetState();
}

class _TransactionFeedbackWidgetState extends State<_TransactionFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {
                widget.onTap?.call();
                widget.onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isSuccess 
                      ? AppTheme.successColor.withOpacity(0.9)
                      : AppTheme.errorColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    Row(
                      children: [
                        Icon(
                          widget.isSuccess ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onDismiss,
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ],
                    ),

                    if (widget.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],

                    // 報酬表示
                    if (widget.goldChange != null || 
                        widget.expGained != null || 
                        widget.itemReceived != null) ...[
                      const SizedBox(height: 8),
                      _buildRewards(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewards() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        if (widget.goldChange != null)
          _buildRewardItem(
            icon: Icons.monetization_on,
            text: '${widget.goldChange! >= 0 ? '+' : ''}${widget.goldChange}G',
            color: widget.goldChange! >= 0 ? Colors.yellow : Colors.red.shade300,
          ),
        if (widget.expGained != null)
          _buildRewardItem(
            icon: Icons.star,
            text: '+${widget.expGained} EXP',
            color: Colors.orange.shade300,
          ),
        if (widget.itemReceived != null)
          _buildRewardItem(
            icon: Icons.redeem,
            text: widget.itemReceived!,
            color: Colors.blue.shade300,
          ),
      ],
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}