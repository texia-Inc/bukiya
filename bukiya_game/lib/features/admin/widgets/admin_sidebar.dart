import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../screens/admin_dashboard_screen.dart';

/// 管理画面サイドバー
class AdminSidebar extends StatelessWidget {
  final List<AdminMenuItem> menuItems;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    Key? key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  '管理パネル',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bukiya Game',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white24),
          
          // メニューアイテム
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected 
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                        fontWeight: isSelected 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => onItemSelected(index),
                    selected: isSelected,
                  ),
                );
              },
            ),
          ),
          
          const Divider(color: Colors.white24),
          
          // ログアウトボタン
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('ログアウト'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}