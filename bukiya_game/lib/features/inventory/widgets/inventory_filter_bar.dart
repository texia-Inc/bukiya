import 'package:flutter/material.dart';
import '../../../shared/themes/app_theme.dart';

class InventoryFilterBar extends StatelessWidget {
  final String searchQuery;
  final String sortBy;
  final String? filterRarity;
  final Function(String) onSearchChanged;
  final Function(String) onSortChanged;
  final Function(String?) onRarityChanged;
  final VoidCallback onClearFilters;
  final bool isWeapon;

  const InventoryFilterBar({
    super.key,
    required this.searchQuery,
    required this.sortBy,
    required this.filterRarity,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onRarityChanged,
    required this.onClearFilters,
    required this.isWeapon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 検索バー
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: isWeapon ? '武器名で検索...' : '素材名で検索...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // フィルター・ソート行
          Row(
            children: [
              // ソートドロップダウン
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: sortBy,
                      isExpanded: true,
                      icon: const Icon(Icons.sort, size: 20),
                      onChanged: (value) {
                        if (value != null) onSortChanged(value);
                      },
                      items: _getSortOptions().map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Row(
                            children: [
                              Icon(
                                option['icon'] as IconData,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                option['label'] as String,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // レアリティフィルター
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: filterRarity,
                      isExpanded: true,
                      hint: const Row(
                        children: [
                          Icon(Icons.filter_list, size: 16),
                          SizedBox(width: 8),
                          Text('レアリティ', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      onChanged: onRarityChanged,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.clear, size: 16),
                              SizedBox(width: 8),
                              Text('すべて', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        ..._getRarityOptions().map((rarity) {
                          return DropdownMenuItem<String>(
                            value: rarity['value'],
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: rarity['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rarity['label'] as String,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // クリアボタン
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.refresh),
                  color: AppTheme.primaryColor,
                  tooltip: 'フィルターをクリア',
                ),
              ),
            ],
          ),
          
          // アクティブフィルター表示
          if (searchQuery.isNotEmpty || filterRarity != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (searchQuery.isNotEmpty)
                          _buildFilterChip(
                            '検索: "$searchQuery"',
                            () => onSearchChanged(''),
                          ),
                        if (filterRarity != null)
                          _buildFilterChip(
                            'レアリティ: ${_getRarityDisplayName(filterRarity!)}',
                            () => onRarityChanged(null),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSortOptions() {
    if (isWeapon) {
      return [
        {'value': 'name', 'label': '名前順', 'icon': Icons.sort_by_alpha},
        {'value': 'attack', 'label': '攻撃力順', 'icon': Icons.flash_on},
        {'value': 'enchant_level', 'label': 'エンチャント順', 'icon': Icons.auto_awesome},
        {'value': 'sell_price', 'label': '売却価格順', 'icon': Icons.monetization_on},
        {'value': 'rarity', 'label': 'レアリティ順', 'icon': Icons.star},
        {'value': 'created_at', 'label': '作成日順', 'icon': Icons.calendar_today},
      ];
    } else {
      return [
        {'value': 'name', 'label': '名前順', 'icon': Icons.sort_by_alpha},
        {'value': 'quantity', 'label': '数量順', 'icon': Icons.numbers},
        {'value': 'total_value', 'label': '総価値順', 'icon': Icons.monetization_on},
        {'value': 'unit_price', 'label': '単価順', 'icon': Icons.attach_money},
        {'value': 'rarity', 'label': 'レアリティ順', 'icon': Icons.star},
      ];
    }
  }

  List<Map<String, dynamic>> _getRarityOptions() {
    return [
      {'value': 'common', 'label': 'コモン', 'color': const Color(0xFF9E9E9E)},
      {'value': 'uncommon', 'label': 'アンコモン', 'color': const Color(0xFF4CAF50)},
      {'value': 'rare', 'label': 'レア', 'color': const Color(0xFF2196F3)},
      {'value': 'epic', 'label': 'エピック', 'color': const Color(0xFF9C27B0)},
      {'value': 'legendary', 'label': 'レジェンダリー', 'color': const Color(0xFFFF9800)},
    ];
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity.toLowerCase()) {
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
}
