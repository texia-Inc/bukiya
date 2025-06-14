import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/services/bulk_buyback_api_service.dart';
import '../../../core/services/api_service.dart';
import 'bulk_buyback_result_dialog.dart';

class BulkBuybackDialog extends StatefulWidget {
  final int playerGold;
  final VoidCallback onSuccess;

  const BulkBuybackDialog({
    super.key,
    required this.playerGold,
    required this.onSuccess,
  });

  @override
  State<BulkBuybackDialog> createState() => _BulkBuybackDialogState();
}

class _BulkBuybackDialogState extends State<BulkBuybackDialog> {
  bool _isLoading = true;
  bool _isExecuting = false;
  Map<String, dynamic>? _summary;
  String? _error;
  int? _customMaxGold;
  final TextEditingController _maxGoldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBuybackSummary();
  }

  @override
  void dispose() {
    _maxGoldController.dispose();
    super.dispose();
  }

  Future<void> _loadBuybackSummary() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiService = ApiService();
      final bulkBuybackService = BulkBuybackApiService(apiService.dio);
      final summary = await bulkBuybackService.getBuybackSummary();

      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _executeBulkBuyback() async {
    try {
      setState(() {
        _isExecuting = true;
        _error = null;
      });

      final apiService = ApiService();
      final bulkBuybackService = BulkBuybackApiService(apiService.dio);
      
      final result = await bulkBuybackService.executeBulkBuyback(
        maxGold: _customMaxGold,
      );

      if (result['success'] == true) {
        // 成功時はダイアログを閉じて結果を表示
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSuccess();
          _showBuybackResultDialog(result);
        }
      } else {
        setState(() {
          _error = result['message'] ?? '一括買取に失敗しました';
          _isExecuting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isExecuting = false;
      });
    }
  }

  void _showBuybackResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => BulkBuybackResultDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '一括買取',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Text('買取可能アイテムを確認中...'),
            ] else if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'エラーが発生しました',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loadBuybackSummary,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 1,
                    ),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '再試行',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else if (_summary != null) ...[
              _buildSummaryInfo(),
              const SizedBox(height: 16),
              _buildMaxGoldInput(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryInfo() {
    final summary = _summary!;
    final totalItems = summary['total_items'] as int;
    final totalCost = summary['total_cost'] as int;
    final affordableItems = summary['affordable_items'] as int;
    final affordableCost = summary['affordable_cost'] as int;
    final efficiency = summary['efficiency_percentage'] as double;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '買取概要',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('買取可能アイテム'),
              Text(
                '$totalItems個',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('総費用'),
              Text(
                '${totalCost}G',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('予算内購入可能'),
              Text(
                '$affordableItems個',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: affordableItems > 0 ? AppTheme.successColor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('予算内費用'),
              Text(
                '${affordableCost}G',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: affordableCost > 0 ? AppTheme.successColor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('所持ゴールド'),
              Text(
                '${widget.playerGold}G',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          if (efficiency > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '購入効率: ${efficiency.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaxGoldInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用上限金額設定（オプション）',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '空欄の場合は全所持金を使用します',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _maxGoldController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '例: 1000',
              suffixText: 'G',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _customMaxGold = value.isEmpty ? null : int.tryParse(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final summary = _summary!;
    final affordableItems = summary['affordable_items'] as int;
    final canExecute = affordableItems > 0 && !_isExecuting;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isExecuting ? null : () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isExecuting ? AppTheme.textSecondary : AppTheme.primaryColor,
                  width: 1,
                ),
                color: _isExecuting 
                    ? AppTheme.textSecondary.withValues(alpha: 0.1)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
              ),
              child: Text(
                'キャンセル',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isExecuting ? AppTheme.textSecondary : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: canExecute ? _executeBulkBuyback : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: canExecute ? AppTheme.successColor : AppTheme.textSecondary,
                  width: 1,
                ),
                color: canExecute 
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.textSecondary.withValues(alpha: 0.1),
              ),
              child: _isExecuting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '実行中...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      canExecute
                          ? '一括買取実行'
                          : '買取可能なアイテムなし',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: canExecute ? AppTheme.successColor : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}