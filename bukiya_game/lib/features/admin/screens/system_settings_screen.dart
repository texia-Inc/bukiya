import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/admin.dart';
import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';

/// システム設定画面
class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadSystemSettings();
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
                  'システム設定の権限がありません',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }

        if (adminProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (adminProvider.systemSettings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.settings,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text('システム設定が見つかりません'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => adminProvider.loadSystemSettings(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('再読み込み'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'システム設定',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => adminProvider.loadSystemSettings(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'リフレッシュ',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 設定リスト
            Expanded(
              child: ListView(
                children: [
                  // グループごとに設定を表示
                  _buildSettingGroup(
                    'ゲーム設定',
                    Icons.videogame_asset,
                    adminProvider.systemSettings
                        .where((s) => s.group == 'game')
                        .toList(),
                    adminProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingGroup(
                    'ショップ設定',
                    Icons.store,
                    adminProvider.systemSettings
                        .where((s) => s.group == 'shop')
                        .toList(),
                    adminProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingGroup(
                    'バトル設定',
                    Icons.sports_kabaddi,
                    adminProvider.systemSettings
                        .where((s) => s.group == 'battle')
                        .toList(),
                    adminProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingGroup(
                    'メンテナンス設定',
                    Icons.build,
                    adminProvider.systemSettings
                        .where((s) => s.group == 'maintenance')
                        .toList(),
                    adminProvider,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingGroup(
    String title,
    IconData icon,
    List<SystemSetting> settings,
    AdminProvider adminProvider,
  ) {
    if (settings.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...settings.map((setting) => _buildSettingItem(setting, adminProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(SystemSetting setting, AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  setting.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (setting.description != null)
                  Text(
                    setting.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSettingControl(setting, adminProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingControl(SystemSetting setting, AdminProvider adminProvider) {
    switch (setting.type) {
      case AdminFieldType.checkbox:
        return Switch(
          value: setting.value ?? setting.defaultValue ?? false,
          onChanged: (value) => _updateSetting(setting.key, value, adminProvider),
        );
        
      case AdminFieldType.number:
        return TextFormField(
          initialValue: (setting.value ?? setting.defaultValue ?? 0).toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixText: setting.unit,
          ),
          onFieldSubmitted: (value) {
            final numValue = int.tryParse(value);
            if (numValue != null) {
              _updateSetting(setting.key, numValue, adminProvider);
            }
          },
        );
        
      case AdminFieldType.text:
        return TextFormField(
          initialValue: setting.value ?? setting.defaultValue ?? '',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onFieldSubmitted: (value) => _updateSetting(setting.key, value, adminProvider),
        );
        
      case AdminFieldType.dropdown:
        final options = setting.options ?? [];
        final currentValue = setting.value ?? setting.defaultValue;
        
        return DropdownButtonFormField<String>(
          value: currentValue?.toString(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option.toString(),
              child: Text(option.toString()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              // 数値の場合は変換
              final numValue = int.tryParse(value);
              _updateSetting(setting.key, numValue ?? value, adminProvider);
            }
          },
        );
        
      default:
        return ElevatedButton.icon(
          onPressed: () => _showJsonEditor(setting, adminProvider),
          icon: const Icon(Icons.code),
          label: const Text('JSON編集'),
        );
    }
  }

  Future<void> _updateSetting(String key, dynamic value, AdminProvider adminProvider) async {
    final success = await adminProvider.updateSystemSetting(key, value);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('設定を更新しました: $key'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('設定の更新に失敗しました: ${adminProvider.errorMessage}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showJsonEditor(SystemSetting setting, AdminProvider adminProvider) {
    final controller = TextEditingController(
      text: setting.value?.toString() ?? setting.defaultValue?.toString() ?? '{}',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('JSON編集: ${setting.label}'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'JSON形式で入力してください',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                // JSON検証（実際にはパースしてオブジェクトとして保存）
                final jsonStr = controller.text;
                _updateSetting(setting.key, jsonStr, adminProvider);
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('無効なJSON形式です: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}