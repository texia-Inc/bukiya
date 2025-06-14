import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/admin.dart';
import '../../../core/models/monster.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/monster_form_dialog.dart';

/// モンスター管理画面
class MonsterManagementScreen extends StatefulWidget {
  const MonsterManagementScreen({Key? key}) : super(key: key);

  @override
  State<MonsterManagementScreen> createState() => _MonsterManagementScreenState();
}

class _MonsterManagementScreenState extends State<MonsterManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedHabitat;
  String? _selectedRarity;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadMonsters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダーツールバー
            Row(
              children: [
                // 検索ボックス
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'モンスター名で検索...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.1),
                    ),
                    onSubmitted: (value) => _performSearch(value),
                  ),
                ),
                const SizedBox(width: 16),
                
                // フィルター
                _buildFilterDropdown(
                  'ヒント',
                  _selectedHabitat,
                  MonsterHabitat.allHabitats.map(
                    (h) => DropdownMenuItem(
                      value: h,
                      child: Text(MonsterHabitat.getDisplayName(h)),
                    ),
                  ).toList(),
                  (value) => setState(() => _selectedHabitat = value),
                ),
                const SizedBox(width: 8),
                
                _buildFilterDropdown(
                  'レアリティ',
                  _selectedRarity,
                  ['common', 'uncommon', 'rare', 'epic', 'legendary', 'mythic']
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(_getRarityDisplayName(r)),
                          ))
                      .toList(),
                  (value) => setState(() => _selectedRarity = value),
                ),
                const SizedBox(width: 16),
                
                // アクションボタン
                ElevatedButton.icon(
                  onPressed: () {
                    print('モンスター追加ボタンがクリックされました'); // デバッグログ
                    print('権限チェック: ${adminProvider.hasPermission(AdminPermission.weaponCreate)}'); // デバッグログ
                    _showCreateMonsterDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('モンスター追加'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                
                // バルクアクション
                if (adminProvider.hasSelectedMonsters && 
                    adminProvider.hasPermission(AdminPermission.weaponDelete))
                  ElevatedButton.icon(
                    onPressed: () => _showBulkDeleteDialog(),
                    icon: const Icon(Icons.delete),
                    label: Text('選択削除 (${adminProvider.selectedMonsterIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                
                // リフレッシュボタン
                IconButton(
                  onPressed: () => adminProvider.loadMonsters(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'リフレッシュ',
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // データテーブル
            Expanded(
              child: Card(
                child: adminProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : adminProvider.monsters.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets, 
                                     size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('モンスターが見つかりません'),
                              ],
                            ),
                          )
                        : AdminDataTable(
                            columns: _getTableColumns(),
                            rows: _buildTableRows(adminProvider),
                            selectedIds: adminProvider.selectedMonsterIds.map((id) => id.toString()).toSet(),
                            onSelectAll: adminProvider.toggleAllMonstersSelection,
                            onSelectRow: (idString) => adminProvider.toggleMonsterSelection(int.parse(idString)),
                            pagination: adminProvider.monsterPagination,
                            onPageChanged: (page) => _changePage(page),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>(
    String hint,
    T? value,
    List<DropdownMenuItem<T>> items,
    Function(T?) onChanged,
  ) {
    return SizedBox(
      width: 120,
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem(value: null, child: Text('すべて')),
          ...items,
        ],
        onChanged: onChanged,
      ),
    );
  }

  List<AdminTableColumn> _getTableColumns() {
    return [
      const AdminTableColumn(
        key: 'name',
        label: 'モンスター名',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'type',
        label: 'タイプ',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'level',
        label: 'レベル',
        type: AdminColumnType.number,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'rarity',
        label: 'レアリティ',
        type: AdminColumnType.enum_,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'habitat',
        label: '生息地',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'combat_power',
        label: '戦闘力',
        type: AdminColumnType.number,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'boss',
        label: 'ボス',
        type: AdminColumnType.boolean,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'active',
        label: '状態',
        type: AdminColumnType.boolean,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'actions',
        label: 'アクション',
        type: AdminColumnType.action,
        sortable: false,
      ),
    ];
  }

  List<Map<String, dynamic>> _buildTableRows(AdminProvider adminProvider) {
    return adminProvider.monsters.map((monster) {
      return {
        'id': monster.id,
        'name': monster.name,
        'type': MonsterType.getDisplayName(monster.monsterType),
        'level': monster.level,
        'rarity': monster.rarity,
        'habitat': MonsterHabitat.getDisplayName(monster.habitat),
        'combat_power': monster.combatPower,
        'boss': monster.isBoss,
        'active': monster.isActive,
        'actions': Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 18),
              onPressed: () => _showMonsterDetails(monster),
              tooltip: '詳細',
            ),
            if (adminProvider.hasPermission(AdminPermission.weaponEdit))
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditMonsterDialog(monster),
                tooltip: '編集',
              ),
            if (adminProvider.hasPermission(AdminPermission.weaponDelete))
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _showDeleteMonsterDialog(monster),
                tooltip: '削除',
              ),
          ],
        ),
      };
    }).toList();
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity) {
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
      case 'mythic':
        return 'ミシック';
      default:
        return rarity;
    }
  }

  void _performSearch(String query) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.monsterFilter.copyWith(
      searchQuery: query.isEmpty ? null : query,
      page: 1,
    );
    adminProvider.updateMonsterFilter(filter);
  }

  void _changePage(int page) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.monsterFilter.copyWith(page: page);
    adminProvider.updateMonsterFilter(filter);
  }

  void _showCreateMonsterDialog() {
    print('_showCreateMonsterDialog called'); // デバッグログ
    showDialog(
      context: context,
      builder: (context) {
        print('MonsterFormDialog builder called'); // デバッグログ
        return MonsterFormDialog(
          onSubmit: (monsterData) async {
            print('MonsterFormDialog onSubmit called with data: $monsterData'); // デバッグログ
            final adminProvider = context.read<AdminProvider>();
            final success = await adminProvider.createMonster(monsterData);
            if (success && mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('モンスターを作成しました')),
              );
            }
          },
        );
      },
    );
  }

  void _showEditMonsterDialog(Monster monster) {
    showDialog(
      context: context,
      builder: (context) => MonsterFormDialog(
        monster: monster,
        onSubmit: (monsterData) async {
          final adminProvider = context.read<AdminProvider>();
          final success = await adminProvider.updateMonster(monster.id.toString(), monsterData);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('モンスターを更新しました')),
            );
          }
        },
      ),
    );
  }

  void _showMonsterDetails(Monster monster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(monster.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('説明: ${monster.description}'),
              Text('タイプ: ${MonsterType.getDisplayName(monster.monsterType)}'),
              Text('レベル: ${monster.level}'),
              Text('レアリティ: ${_getRarityDisplayName(monster.rarity)}'),
              Text('HP: ${monster.hp}'),
              Text('攻撃力: ${monster.attack}'),
              Text('防御力: ${monster.defense}'),
              Text('速度: ${monster.speed}'),
              Text('戦闘力: ${monster.combatPower}'),
              Text('経験値報酬: ${monster.expReward}'),
              Text('ゴールド報酬: ${monster.goldReward}'),
              Text('生息地: ${MonsterHabitat.getDisplayName(monster.habitat)}'),
              Text('ボス: ${monster.isBoss ? 'はい' : 'いいえ'}'),
              if (monster.skills.isNotEmpty)
                Text('スキル: ${monster.skills.join(', ')}'),
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

  void _showDeleteMonsterDialog(Monster monster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('モンスター削除'),
        content: Text('「${monster.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.deleteMonster(monster.id.toString());
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('モンスターを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog() {
    final adminProvider = context.read<AdminProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('一括削除'),
        content: Text('選択された${adminProvider.selectedMonsterIds.length}体のモンスターを削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteSelectedMonsters();
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('選択されたモンスターを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}