import 'package:flutter/material.dart';

import '../../../core/models/admin.dart';
import '../../../shared/themes/app_theme.dart';

/// 管理画面用データテーブル
class AdminDataTable extends StatelessWidget {
  final List<AdminTableColumn> columns;
  final List<Map<String, dynamic>> rows;
  final Set<String> selectedIds;
  final VoidCallback? onSelectAll;
  final Function(String)? onSelectRow;
  final PaginationInfo? pagination;
  final Function(int)? onPageChanged;

  const AdminDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.selectedIds = const {},
    this.onSelectAll,
    this.onSelectRow,
    this.pagination,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // テーブル
        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              showCheckboxColumn: onSelectRow != null,
              columns: _buildColumns(),
              rows: _buildRows(),
              headingRowHeight: 56,
              dataRowHeight: 56,
              columnSpacing: 24,
            ),
          ),
        ),
        
        // ページネーション
        if (pagination != null && onPageChanged != null)
          _buildPagination(),
      ],
    );
  }

  List<DataColumn> _buildColumns() {
    final List<DataColumn> dataColumns = [];
    
    // 全選択チェックボックス
    if (onSelectAll != null) {
      dataColumns.add(
        DataColumn(
          label: Checkbox(
            value: selectedIds.isNotEmpty && selectedIds.length == rows.length,
            tristate: true,
            onChanged: (_) => onSelectAll?.call(),
          ),
        ),
      );
    }
    
    // 通常のカラム
    dataColumns.addAll(
      columns.map((column) => DataColumn(
        label: Text(
          column.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        numeric: column.type == AdminColumnType.number,
      )),
    );
    
    return dataColumns;
  }

  List<DataRow> _buildRows() {
    return rows.map((row) {
      final id = row['id'] as String;
      final isSelected = selectedIds.contains(id);
      
      return DataRow(
        selected: isSelected,
        onSelectChanged: onSelectRow != null 
            ? (_) => onSelectRow!(id)
            : null,
        cells: columns.map((column) {
          final value = row[column.key];
          
          if (column.type == AdminColumnType.action && value is Widget) {
            return DataCell(value);
          }
          
          return DataCell(
            _buildCellContent(column, value),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildCellContent(AdminTableColumn column, dynamic value) {
    if (value == null) return const Text('-');
    
    switch (column.type) {
      case AdminColumnType.text:
        return Text(value.toString());
        
      case AdminColumnType.number:
        return Text(
          value.toString(),
          style: const TextStyle(fontFamily: 'monospace'),
        );
        
      case AdminColumnType.date:
        if (value is DateTime) {
          return Text(
            '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}',
          );
        }
        return Text(value.toString());
        
      case AdminColumnType.boolean:
        return Icon(
          value == true ? Icons.check_circle : Icons.cancel,
          color: value == true ? Colors.green : Colors.red,
          size: 20,
        );
        
      case AdminColumnType.enum_:
        return Chip(
          label: Text(
            value.toString(),
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: _getChipColor(value.toString()),
        );
        
      case AdminColumnType.image:
        return value.toString().isNotEmpty
            ? CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(value.toString()),
              )
            : const CircleAvatar(
                radius: 16,
                child: Icon(Icons.image, size: 16),
              );
              
      case AdminColumnType.action:
        return value is Widget ? value : const SizedBox.shrink();
        
      default:
        return Text(value.toString());
    }
  }

  Color _getChipColor(String value) {
    switch (value.toLowerCase()) {
      case 'common':
        return Colors.grey.withValues(alpha: 0.3);
      case 'uncommon':
        return Colors.green.withValues(alpha: 0.3);
      case 'rare':
        return Colors.blue.withValues(alpha: 0.3);
      case 'epic':
        return Colors.purple.withValues(alpha: 0.3);
      case 'legendary':
        return Colors.orange.withValues(alpha: 0.3);
      case 'active':
        return Colors.green.withValues(alpha: 0.3);
      case 'inactive':
        return Colors.red.withValues(alpha: 0.3);
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  Widget _buildPagination() {
    if (pagination == null || onPageChanged == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${pagination!.totalItems}件中 ${_getItemRange()}件を表示',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          
          const Spacer(),
          
          // ページネーションボタン
          Row(
            children: [
              IconButton(
                onPressed: pagination!.hasPrevious 
                    ? () => onPageChanged!(pagination!.currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              
              ...List.generate(
                _getDisplayPages().length,
                (index) {
                  final page = _getDisplayPages()[index];
                  final isCurrentPage = page == pagination!.currentPage;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: page == -1
                        ? const Text('...', style: TextStyle(fontSize: 16))
                        : TextButton(
                            onPressed: isCurrentPage 
                                ? null 
                                : () => onPageChanged!(page),
                            style: TextButton.styleFrom(
                              backgroundColor: isCurrentPage 
                                  ? AppTheme.primaryColor
                                  : null,
                              foregroundColor: isCurrentPage 
                                  ? Colors.white
                                  : null,
                              minimumSize: const Size(40, 40),
                            ),
                            child: Text(page.toString()),
                          ),
                  );
                },
              ),
              
              IconButton(
                onPressed: pagination!.hasNext 
                    ? () => onPageChanged!(pagination!.currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getItemRange() {
    final start = (pagination!.currentPage - 1) * pagination!.itemsPerPage + 1;
    final end = (start + pagination!.itemsPerPage - 1)
        .clamp(start, pagination!.totalItems);
    return '$start-$end';
  }

  List<int> _getDisplayPages() {
    final current = pagination!.currentPage;
    final total = pagination!.totalPages;
    
    if (total <= 7) {
      return List.generate(total, (i) => i + 1);
    }
    
    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total];
    }
    
    if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    }
    
    return [1, -1, current - 1, current, current + 1, -1, total];
  }
}