import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/admin.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';

/// アクションログ画面
class ActionLogsScreen extends StatefulWidget {
  const ActionLogsScreen({Key? key}) : super(key: key);

  @override
  State<ActionLogsScreen> createState() => _ActionLogsScreenState();
}

class _ActionLogsScreenState extends State<ActionLogsScreen> {
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
  String? _filterAdminId;
  String? _filterTargetType;
  CrudOperation? _filterOperation;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadActionLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (!adminProvider.hasPermission(AdminPermission.systemConfig)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'アクションログの閲覧権限がありません',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダーとフィルター
            _buildHeader(adminProvider),
            const SizedBox(height: 16),
            
            // ログテーブル
            Expanded(
              child: Card(
                child: adminProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildLogsTable(adminProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AdminProvider adminProvider) {
    return Row(
      children: [
        const Icon(
          Icons.history,
          color: AppTheme.primaryColor,
          size: 32,
        ),
        const SizedBox(width: 12),
        Text(
          'アクションログ',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // フィルターボタン
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'フィルター',
          onSelected: (value) => _showFilterDialog(adminProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'filter',
              child: Row(
                children: [
                  Icon(Icons.filter_alt),
                  SizedBox(width: 8),
                  Text('フィルター設定'),
                ],
              ),
            ),
          ],
        ),
        
        // 日付範囲選択
        IconButton(
          onPressed: () => _selectDateRange(adminProvider),
          icon: const Icon(Icons.date_range),
          tooltip: '日付範囲',
        ),
        
        // リフレッシュボタン
        IconButton(
          onPressed: () => adminProvider.loadActionLogs(),
          icon: const Icon(Icons.refresh),
          tooltip: 'リフレッシュ',
        ),
      ],
    );
  }

  Widget _buildLogsTable(AdminProvider adminProvider) {
    final logs = _filterLogs(adminProvider.actionLogs);

    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('アクションログがありません'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('日時')),
          DataColumn(label: Text('管理者')),
          DataColumn(label: Text('操作')),
          DataColumn(label: Text('対象')),
          DataColumn(label: Text('詳細')),
          DataColumn(label: Text('IPアドレス')),
        ],
        rows: logs.map((log) => _buildLogRow(log)).toList(),
      ),
    );
  }

  DataRow _buildLogRow(AdminActionLog log) {
    return DataRow(
      cells: [
        DataCell(Text(
          _formatDate(log.timestamp),
          style: const TextStyle(fontSize: 12),
        )),
        DataCell(Text(log.adminUsername)),
        DataCell(
          Chip(
            label: Text(
              _getOperationLabel(log.operation),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            backgroundColor: _getOperationColor(log.operation),
          ),
        ),
        DataCell(Text('${log.targetType} #${log.targetId}')),
        DataCell(
          InkWell(
            onTap: () => _showLogDetails(log),
            child: Text(
              log.notes ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        DataCell(Text(log.ipAddress ?? '-')),
      ],
    );
  }

  List<AdminActionLog> _filterLogs(List<AdminActionLog> logs) {
    return logs.where((log) {
      // 管理者フィルター
      if (_filterAdminId != null && log.adminId != _filterAdminId) {
        return false;
      }
      
      // ターゲットタイプフィルター
      if (_filterTargetType != null && log.targetType != _filterTargetType) {
        return false;
      }
      
      // 操作フィルター
      if (_filterOperation != null && log.operation != _filterOperation) {
        return false;
      }
      
      // 日付範囲フィルター
      if (_dateRange != null) {
        if (log.timestamp.isBefore(_dateRange!.start) ||
            log.timestamp.isAfter(_dateRange!.end)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  String _getOperationLabel(CrudOperation operation) {
    switch (operation) {
      case CrudOperation.create:
        return '作成';
      case CrudOperation.read:
        return '閲覧';
      case CrudOperation.update:
        return '更新';
      case CrudOperation.delete:
        return '削除';
    }
  }

  Color _getOperationColor(CrudOperation operation) {
    switch (operation) {
      case CrudOperation.create:
        return Colors.green;
      case CrudOperation.read:
        return Colors.blue;
      case CrudOperation.update:
        return Colors.orange;
      case CrudOperation.delete:
        return Colors.red;
    }
  }

  void _showFilterDialog(AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フィルター設定'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 管理者フィルター
              DropdownButtonFormField<String>(
                value: _filterAdminId,
                decoration: const InputDecoration(
                  labelText: '管理者',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('すべて'),
                  ),
                  // 実際にはログから管理者リストを取得
                  DropdownMenuItem(
                    value: adminProvider.currentAdmin?.id,
                    child: Text(adminProvider.currentAdmin?.username ?? ''),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterAdminId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // ターゲットタイプフィルター
              DropdownButtonFormField<String>(
                value: _filterTargetType,
                decoration: const InputDecoration(
                  labelText: '対象タイプ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('すべて')),
                  DropdownMenuItem(value: 'weapon', child: Text('武器')),
                  DropdownMenuItem(value: 'material', child: Text('素材')),
                  DropdownMenuItem(value: 'system_setting', child: Text('システム設定')),
                  DropdownMenuItem(value: 'admin', child: Text('管理者')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterTargetType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // 操作フィルター
              DropdownButtonFormField<CrudOperation?>(
                value: _filterOperation,
                decoration: const InputDecoration(
                  labelText: '操作',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('すべて')),
                  DropdownMenuItem(value: CrudOperation.create, child: Text('作成')),
                  DropdownMenuItem(value: CrudOperation.read, child: Text('閲覧')),
                  DropdownMenuItem(value: CrudOperation.update, child: Text('更新')),
                  DropdownMenuItem(value: CrudOperation.delete, child: Text('削除')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterOperation = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterAdminId = null;
                _filterTargetType = null;
                _filterOperation = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('クリア'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(AdminProvider adminProvider) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showLogDetails(AdminActionLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ログ詳細 #${log.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('日時', _formatDate(log.timestamp)),
              _buildDetailRow('管理者', log.adminUsername),
              _buildDetailRow('操作', _getOperationLabel(log.operation)),
              _buildDetailRow('対象', '${log.targetType} #${log.targetId}'),
              if (log.notes != null)
                _buildDetailRow('詳細', log.notes!),
              if (log.oldData != null)
                _buildDetailRow('変更前データ', _formatJson(log.oldData!)),
              if (log.newData != null)
                _buildDetailRow('変更後データ', _formatJson(log.newData!)),
              if (log.ipAddress != null)
                _buildDetailRow('IPアドレス', log.ipAddress!),
              if (log.userAgent != null)
                _buildDetailRow('User Agent', log.userAgent!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      // 簡易的なJSON表示
      return json.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    } catch (e) {
      return json.toString();
    }
  }
}