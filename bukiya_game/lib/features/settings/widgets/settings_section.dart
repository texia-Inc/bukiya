import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '--- $title ---',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          
          // セクションコンテンツ
          child,
        ],
      ),
    );
  }
}