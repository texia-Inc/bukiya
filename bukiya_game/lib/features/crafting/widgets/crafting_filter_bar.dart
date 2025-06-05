import 'package:flutter/material.dart';

class CraftingFilterBar extends StatelessWidget {
  final String searchQuery;
  final String sortBy;
  final String? filterWeaponType;
  final String? filterRarity;
  final bool showCraftableOnly;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String?> onWeaponTypeChanged;
  final ValueChanged<String?> onRarityChanged;
  final ValueChanged<bool> onCraftableOnlyChanged;

  const CraftingFilterBar({
    super.key,
    required this.searchQuery,
    required this.sortBy,
    this.filterWeaponType,
    this.filterRarity,
    required this.showCraftableOnly,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onWeaponTypeChanged,
    required this.onRarityChanged,
    required this.onCraftableOnlyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
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
              hintText: 'レシピを検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // フィルターとソート
          Row(
            children: [
              // ソート
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sortBy,
                  decoration: InputDecoration(
                    labelText: 'ソート',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('名前順')),
                    DropdownMenuItem(value: 'level', child: Text('レベル順')),
                    DropdownMenuItem(value: 'cost', child: Text('コスト順')),
                    DropdownMenuItem(value: 'success_rate', child: Text('成功率順')),
                    DropdownMenuItem(value: 'craftable', child: Text('合成可能順')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onSortChanged(value);
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 武器タイプフィルター
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: filterWeaponType,
                  decoration: InputDecoration(
                    labelText: '武器タイプ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全て')),
                    DropdownMenuItem(value: 'sword', child: Text('剣')),
                    DropdownMenuItem(value: 'bow', child: Text('弓')),
                    DropdownMenuItem(value: 'staff', child: Text('杖')),
                    DropdownMenuItem(value: 'dagger', child: Text('短剣')),
                  ],
                  onChanged: onWeaponTypeChanged,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // レアリティフィルター
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: filterRarity,
                  decoration: InputDecoration(
                    labelText: 'レアリティ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('全て')),
                    DropdownMenuItem(value: 'common', child: Text('コモン')),
                    DropdownMenuItem(value: 'uncommon', child: Text('アンコモン')),
                    DropdownMenuItem(value: 'rare', child: Text('レア')),
                    DropdownMenuItem(value: 'epic', child: Text('エピック')),
                    DropdownMenuItem(value: 'legendary', child: Text('レジェンダリー')),
                  ],
                  onChanged: onRarityChanged,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 合成可能のみ表示チェックボックス
          Row(
            children: [
              Checkbox(
                value: showCraftableOnly,
                onChanged: (value) {
                  onCraftableOnlyChanged(value ?? false);
                },
              ),
              const Text('合成可能なレシピのみ表示'),
              const Spacer(),
              
              // フィルタークリアボタン
              TextButton.icon(
                onPressed: () {
                  onSearchChanged('');
                  onSortChanged('name');
                  onWeaponTypeChanged(null);
                  onRarityChanged(null);
                  onCraftableOnlyChanged(false);
                },
                icon: const Icon(Icons.clear),
                label: const Text('クリア'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
