import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/admin.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/weapon_form_dialog.dart';

/// 武器管理画面
class WeaponManagementScreen extends StatefulWidget {
  const WeaponManagementScreen({Key? key}) : super(key: key);

  @override
  State<WeaponManagementScreen> createState() => _WeaponManagementScreenState();
}

class _WeaponManagementScreenState extends State<WeaponManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadWeapons();
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
                      hintText: '武器名で検索...',
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
                
                // アクションボタン
                if (adminProvider.hasPermission(AdminPermission.weaponCreate))
                  ElevatedButton.icon(
                    onPressed: () => _showCreateWeaponDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('武器追加'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                
                // バルクアクション
                if (adminProvider.hasSelectedWeapons && 
                    adminProvider.hasPermission(AdminPermission.weaponDelete))
                  ElevatedButton.icon(
                    onPressed: () => _showBulkDeleteDialog(),
                    icon: const Icon(Icons.delete),
                    label: Text('選択削除 (${adminProvider.selectedWeaponIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                
                // リフレッシュボタン
                IconButton(
                  onPressed: () => adminProvider.loadWeapons(),
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
                    : adminProvider.weapons.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_martial_arts, 
                                     size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('武器が見つかりません'),
                              ],
                            ),
                          )
                        : AdminDataTable(
                            columns: _getTableColumns(),
                            rows: _buildTableRows(adminProvider),
                            selectedIds: adminProvider.selectedWeaponIds.map((id) => id.toString()).toSet(),
                            onSelectAll: adminProvider.toggleAllWeaponsSelection,
                            onSelectRow: (idString) => adminProvider.toggleWeaponSelection(int.parse(idString)),
                            pagination: adminProvider.weaponPagination,
                            onPageChanged: (page) => _changePage(page),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<AdminTableColumn> _getTableColumns() {
    return [
      const AdminTableColumn(
        key: 'name',
        label: '武器名',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'type',
        label: '種類',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'attack',
        label: '攻撃力',
        type: AdminColumnType.number,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'rarity',
        label: 'レアリティ',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'price',
        label: '価格',
        type: AdminColumnType.number,
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
    return adminProvider.weapons.map((weapon) {
      return {
        'id': weapon.id,
        'name': weapon.name,
        'type': weapon.weaponType,
        'attack': weapon.attack,
        'rarity': weapon.rarity,
        'price': '${weapon.price}G',
        'actions': Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (adminProvider.hasPermission(AdminPermission.weaponEdit))
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditWeaponDialog(weapon),
                tooltip: '編集',
              ),
            if (adminProvider.hasPermission(AdminPermission.weaponDelete))
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _showDeleteWeaponDialog(weapon),
                tooltip: '削除',
              ),
          ],
        ),
      };
    }).toList();
  }

  void _performSearch(String query) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.weaponFilter.copyWith(
      searchQuery: query.isEmpty ? null : query,
      page: 1,
    );
    adminProvider.updateWeaponFilter(filter);
  }

  void _changePage(int page) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.weaponFilter.copyWith(page: page);
    adminProvider.updateWeaponFilter(filter);
  }

  void _showCreateWeaponDialog() {
    showDialog(
      context: context,
      builder: (context) => WeaponFormDialog(
        onSubmit: (weaponData) async {
          final adminProvider = context.read<AdminProvider>();
          final success = await adminProvider.createWeapon(weaponData);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('武器を作成しました')),
            );
          }
        },
      ),
    );
  }

  void _showEditWeaponDialog(weapon) {
    showDialog(
      context: context,
      builder: (context) => WeaponFormDialog(
        weapon: weapon,
        onSubmit: (weaponData) async {
          final adminProvider = context.read<AdminProvider>();
          final success = await adminProvider.updateWeapon(weapon.id, weaponData);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('武器を更新しました')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteWeaponDialog(weapon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('武器削除'),
        content: Text('「${weapon.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.deleteWeapon(weapon.id);
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('武器を削除しました')),
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
        content: Text('選択された${adminProvider.selectedWeaponIds.length}個の武器を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteSelectedWeapons();
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('選択された武器を削除しました')),
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