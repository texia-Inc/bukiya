import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/crafting.dart';

class CraftingResultDialog extends StatefulWidget {
  final CraftingResult result;

  const CraftingResultDialog({
    super.key,
    required this.result,
  });

  @override
  State<CraftingResultDialog> createState() => _CraftingResultDialogState();
}

class _CraftingResultDialogState extends State<CraftingResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _iconController;
  late AnimationController _detailsController;
  late AnimationController _shakeController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<double> _detailsAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.bounceOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.result.success ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _detailsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _startAnimation();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _iconController.dispose();
    _detailsController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    _mainController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _iconController.forward();
    
    if (!widget.result.success) {
      await Future.delayed(const Duration(milliseconds: 100));
      _shakeController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 400));
    _detailsController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final shakeOffset = widget.result.success ? 0.0 : 
                  10.0 * _shakeAnimation.value * (0.5 - (_shakeAnimation.value % 1.0).abs());
              
              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: widget.result.success
                              ? [const Color(0xFF4CAF50), const Color(0xFF388E3C)]
                              : [const Color(0xFFE53935), const Color(0xFFC62828)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // アニメーション付きアイコンとタイトル
                          AnimatedBuilder(
                            animation: _iconController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _iconScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _iconRotationAnimation.value * 0.5,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      boxShadow: widget.result.success && _iconScaleAnimation.value > 0.8
                                          ? [
                                              BoxShadow(
                                                color: Colors.white.withValues(alpha: 0.5),
                                                blurRadius: 20,
                                                spreadRadius: 5,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Icon(
                                      widget.result.success ? Icons.check_circle : Icons.cancel,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
            
                          const SizedBox(height: 16),
                          
                          // アニメーション付きタイトル
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(_mainController),
                              child: Text(
                                widget.result.success ? '合成成功！' : '合成失敗...',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // アニメーション付きメッセージ
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(_mainController),
                              child: Text(
                                widget.result.message,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // アニメーション付き結果詳細
                          AnimatedBuilder(
                            animation: _detailsController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _detailsAnimation.value,
                                child: Opacity(
                                  opacity: _detailsAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '合成結果',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 12),
                                        
                                        // 武器作成結果
                                        if (widget.result.weaponCreated) ...[
                                          _buildResultRow(
                                            Icons.build_circle,
                                            '武器作成',
                                            '成功',
                                            Colors.lightGreen,
                                          ),
                                        ] else ...[
                                          _buildResultRow(
                                            Icons.build_circle,
                                            '武器作成',
                                            '失敗',
                                            Colors.redAccent,
                                          ),
                                        ],
                                        
                                        // ゴールド消費
                                        _buildResultRow(
                                          Icons.monetization_on,
                                          'ゴールド消費',
                                          '${_formatNumber(widget.result.goldSpent)}G',
                                          Colors.yellow,
                                        ),
                                        
                                        // 消費素材
                                        if (widget.result.materialsConsumed.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            '消費素材',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...widget.result.materialsConsumed.map((material) =>
                                            _buildMaterialRow(material),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // アニメーション付き閉じるボタン
                          FadeTransition(
                            opacity: _detailsAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(_detailsController),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: widget.result.success ? Colors.green : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    '閉じる',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(ConsumedMaterial material) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Icon(
              Icons.category,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              material.materialName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            'x${material.quantity}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
