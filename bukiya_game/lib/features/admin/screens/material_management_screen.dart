import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/admin.dart';
import '../../../core/models/crafting.dart' as crafting;
import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_data_table.dart';
import '../widgets/material_form_dialog.dart';

/// 素材管理画面
class MaterialManagementScreen extends StatefulWidget {
  const MaterialManagementScreen({Key? key}) : super(key: key);

  @override
  State<MaterialManagementScreen> createState() => _MaterialManagementScreenState();
}

class _MaterialManagementScreenState extends State<MaterialManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadMaterials();
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
                      hintText: '素材名で検索...',
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
                if (adminProvider.hasPermission(AdminPermission.materialCreate))
                  ElevatedButton.icon(
                    onPressed: () => _showCreateMaterialDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('素材追加'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                
                // バルクアクション
                if (adminProvider.hasSelectedMaterials && 
                    adminProvider.hasPermission(AdminPermission.materialDelete))
                  ElevatedButton.icon(
                    onPressed: () => _showBulkDeleteDialog(),
                    icon: const Icon(Icons.delete),
                    label: Text('選択削除 (${adminProvider.selectedMaterialIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                
                // リフレッシュボタン
                IconButton(
                  onPressed: () => adminProvider.loadMaterials(),
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
                    : adminProvider.materials.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.category, 
                                     size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('素材が見つかりません'),
                              ],
                            ),
                          )
                        : AdminDataTable(
                            columns: _getTableColumns(),
                            rows: _buildTableRows(adminProvider),
                            selectedIds: adminProvider.selectedMaterialIds.map((id) => id.toString()).toSet(),
                            onSelectAll: adminProvider.toggleAllMaterialsSelection,
                            onSelectRow: (idString) => adminProvider.toggleMaterialSelection(int.parse(idString)),
                            pagination: adminProvider.materialPagination,
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
        label: '素材名',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'type',
        label: '種類',
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'rarity',
        label: 'レアリティ',
        type: AdminColumnType.enum_,
        sortable: true,
      ),
      const AdminTableColumn(
        key: 'price',
        label: '売却価格',
        type: AdminColumnType.number,
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
    return adminProvider.materials.map((material) {
      return {
        'id': material.id.toString(),
        'name': material.name,
        'type': _getMaterialTypeDisplayName(material),
        'rarity': material.rarity,
        'price': '${material.sellPrice}G',
        'active': material.isActive,
        'actions': Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (adminProvider.hasPermission(AdminPermission.materialEdit))
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditMaterialDialog(material),
                tooltip: '編集',
              ),
            if (adminProvider.hasPermission(AdminPermission.materialDelete))
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _showDeleteMaterialDialog(material),
                tooltip: '削除',
              ),
          ],
        ),
      };
    }).toList();
  }

  String _getMaterialTypeDisplayName(crafting.Material material) {
    // 素材の説明から種類を推測（実際の実装では material_type フィールドがあれば使用）
    if (material.description.contains('鉱石')) return '鉱石';
    if (material.description.contains('木')) return '木材';
    if (material.description.contains('布')) return '布';
    if (material.description.contains('革')) return '革';
    if (material.description.contains('水晶')) return '水晶';
    return 'その他';
  }

  void _performSearch(String query) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.materialFilter.copyWith(
      searchQuery: query.isEmpty ? null : query,
      page: 1,
    );
    adminProvider.updateMaterialFilter(filter);
  }

  void _changePage(int page) {
    final adminProvider = context.read<AdminProvider>();
    final filter = adminProvider.materialFilter.copyWith(page: page);
    adminProvider.updateMaterialFilter(filter);
  }

  void _showCreateMaterialDialog() {
    showDialog(
      context: context,
      builder: (context) => MaterialFormDialog(
        onSubmit: (materialData) async {
          final adminProvider = context.read<AdminProvider>();
          final success = await adminProvider.createMaterial(materialData);
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('素材を作成しました')),
            );
          }
        },
      ),
    );
  }

  void _showEditMaterialDialog(crafting.Material material) {
    showDialog(
      context: context,
      builder: (context) => MaterialFormDialog(
        material: material,
        onSubmit: (materialData) async {
          final adminProvider = context.read<AdminProvider>();
          final success = await adminProvider.updateMaterial(
            material.id.toString(), 
            materialData
          );
          if (success && mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('素材を更新しました')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteMaterialDialog(crafting.Material material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('素材削除'),
        content: Text('「${material.name}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              final success = await adminProvider.deleteMaterial(material.id.toString());
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('素材を削除しました')),
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
        content: Text('選択された${adminProvider.selectedMaterialIds.length}個の素材を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteSelectedMaterials();
              if (success && mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('選択された素材を削除しました')),
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