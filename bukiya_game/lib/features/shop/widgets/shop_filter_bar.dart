import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';

class ShopFilterBar extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const ShopFilterBar({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<ShopFilterBar> createState() => _ShopFilterBarState();
}

class _ShopFilterBarState extends State<ShopFilterBar> {
  String _selectedWeaponType = 'all';
  String _selectedRarity = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;

  final List<String> _weaponTypes = [
    'all',
    'sword',
    'axe',
    'bow',
    'staff',
    'dagger',
    'hammer',
  ];

  final List<String> _rarities = [
    'all',
    'common',
    'uncommon',
    'rare',
    'epic',
    'legendary',
  ];

  final List<String> _sortOptions = [
    'name',
    'price',
    'attack',
    'rarity',
    'level',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // フィルター行
          Row(
            children: [
              // 武器タイプフィルター
              Expanded(
                child: _buildFilterDropdown(
                  '武器タイプ',
                  _selectedWeaponType,
                  _weaponTypes,
                  (value) {
                    setState(() {
                      _selectedWeaponType = value!;
                    });
                    _notifyFilterChange();
                  },
                  _getWeaponTypeDisplayName,
                ),
              ),
              const SizedBox(width: 12),
              
              // レアリティフィルター
              Expanded(
                child: _buildFilterDropdown(
                  'レアリティ',
                  _selectedRarity,
                  _rarities,
                  (value) {
                    setState(() {
                      _selectedRarity = value!;
                    });
                    _notifyFilterChange();
                  },
                  _getRarityDisplayName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ソート行
          Row(
            children: [
              // ソート基準
              Expanded(
                child: _buildFilterDropdown(
                  'ソート',
                  _sortBy,
                  _sortOptions,
                  (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _notifyFilterChange();
                  },
                  _getSortDisplayName,
                ),
              ),
              const SizedBox(width: 12),
              
              // ソート順序
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                    _notifyFilterChange();
                  },
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: AppTheme.primaryColor,
                  ),
                  tooltip: _sortAscending ? '昇順' : '降順',
                ),
              ),
              
              // リセットボタン
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('リセット'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    String Function(String) getDisplayName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    getDisplayName(option),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getWeaponTypeDisplayName(String type) {
    switch (type) {
      case 'all':
        return 'すべて';
      case 'sword':
        return '剣';
      case 'axe':
        return '斧';
      case 'bow':
        return '弓';
      case 'staff':
        return '杖';
      case 'dagger':
        return '短剣';
      case 'hammer':
        return 'ハンマー';
      default:
        return type;
    }
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity) {
      case 'all':
        return 'すべて';
      case 'common':
        return 'コモン';
      case 'uncommon':
        return 'アンコモン';
      case 'rare':
        return 'レア';
      case 'epic':
        return 'エピック';
      case 'legendary':
        return 'レジェンダリー';
      default:
        return rarity;
    }
  }

  String _getSortDisplayName(String sort) {
    switch (sort) {
      case 'name':
        return '名前';
      case 'price':
        return '価格';
      case 'attack':
        return '攻撃力';
      case 'rarity':
        return 'レアリティ';
      case 'level':
        return '必要レベル';
      default:
        return sort;
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedWeaponType = 'all';
      _selectedRarity = 'all';
      _sortBy = 'name';
      _sortAscending = true;
    });
    _notifyFilterChange();
  }

  void _notifyFilterChange() {
    widget.onFilterChanged({
      'weaponType': _selectedWeaponType,
      'rarity': _selectedRarity,
      'sortBy': _sortBy,
      'sortAscending': _sortAscending,
    });
  }
}
