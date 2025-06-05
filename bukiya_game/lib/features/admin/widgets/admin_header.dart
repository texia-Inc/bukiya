import 'package:flutter/material.dart';

import '../../../core/models/admin.dart';
import '../../../shared/themes/app_theme.dart';

/// 管理画面ヘッダー
class AdminHeader extends StatelessWidget {
  final String title;
  final AdminAccount admin;

  const AdminHeader({
    Key? key,
    required this.title,
    required this.admin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // タイトル
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // 管理者情報
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  admin.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin.username,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getRoleDisplayName(admin.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return 'スーパー管理者';
      case AdminRole.gameAdmin:
        return 'ゲーム管理者';
      case AdminRole.moderator:
        return 'モデレーター';
    }
  }
}