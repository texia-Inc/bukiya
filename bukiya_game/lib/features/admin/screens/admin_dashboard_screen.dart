import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_header.dart';
import 'weapon_management_screen.dart';
import 'material_management_screen.dart';
import 'monster_management_screen.dart';
import 'system_settings_screen.dart';
import 'action_logs_screen.dart';

/// 管理者ダッシュボード画面
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  
  final List<AdminMenuItem> _menuItems = [
    AdminMenuItem(
      index: 0,
      title: 'ダッシュボード',
      icon: Icons.dashboard,
      widget: const AdminOverviewWidget(),
    ),
    AdminMenuItem(
      index: 1,
      title: '武器管理',
      icon: Icons.sports_martial_arts,
      widget: const WeaponManagementScreen(),
    ),
    AdminMenuItem(
      index: 2,
      title: '素材管理',
      icon: Icons.category,
      widget: const MaterialManagementScreen(),
    ),
    AdminMenuItem(
      index: 3,
      title: 'モンスター管理',
      icon: Icons.pets,
      widget: const MonsterManagementScreen(),
    ),
    AdminMenuItem(
      index: 4,
      title: 'システム設定',
      icon: Icons.settings,
      widget: const SystemSettingsScreen(),
    ),
    AdminMenuItem(
      index: 5,
      title: 'アクションログ',
      icon: Icons.history,
      widget: const ActionLogsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        if (!adminProvider.isAdminLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/admin/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              // サイドバー
              AdminSidebar(
                menuItems: _menuItems,
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                onLogout: () async {
                  await adminProvider.adminLogout();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/admin/login');
                  }
                },
              ),
              
              // メインコンテンツ
              Expanded(
                child: Column(
                  children: [
                    // ヘッダー
                    AdminHeader(
                      title: _menuItems[_selectedIndex].title,
                      admin: adminProvider.currentAdmin!,
                    ),
                    
                    // コンテンツエリア
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: AppTheme.backgroundColor,
                        child: _menuItems[_selectedIndex].widget,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// メニューアイテム
class AdminMenuItem {
  final int index;
  final String title;
  final IconData icon;
  final Widget widget;

  AdminMenuItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.widget,
  });
}

/// 管理ダッシュボード概要ウィジェット
class AdminOverviewWidget extends StatelessWidget {
  const AdminOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 統計カード
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: '登録武器数',
                      value: adminProvider.weapons.length.toString(),
                      icon: Icons.sports_martial_arts,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: '登録素材数',
                      value: adminProvider.materials.length.toString(),
                      icon: Icons.category,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: '登録モンスター数',
                      value: adminProvider.monsters.length.toString(),
                      icon: Icons.pets,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'アクションログ',
                      value: adminProvider.actionLogs.length.toString(),
                      icon: Icons.history,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // 最近のアクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最近のアクション',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (adminProvider.actionLogs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('アクションログがありません'),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: adminProvider.actionLogs.take(5).length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final log = adminProvider.actionLogs[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: log.operationColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getActionIcon(log.operation),
                                  color: log.operationColor,
                                  size: 20,
                                ),
                              ),
                              title: Text('${log.operationDisplayText}: ${log.targetType}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('管理者: ${log.adminUsername}'),
                                  Text(
                                    '${log.timestamp.toString().substring(0, 19)}',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: AppTheme.textSecondary,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getActionIcon(operation) {
    switch (operation.toString()) {
      case 'CrudOperation.create':
        return Icons.add;
      case 'CrudOperation.update':
        return Icons.edit;
      case 'CrudOperation.delete':
        return Icons.delete;
      case 'CrudOperation.read':
        return Icons.visibility;
      default:
        return Icons.info;
    }
  }
}

/// 統計カードウィジェット
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}