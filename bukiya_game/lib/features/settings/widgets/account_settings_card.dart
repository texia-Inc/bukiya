import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アカウント情報表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.primaryColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アカウント情報',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (authProvider.isAuthenticated) ...[
                      _buildInfoRow('ユーザーID', authProvider.currentPlayer?.id.toString() ?? 'Unknown'),
                      _buildInfoRow('ユーザー名', authProvider.currentPlayer?.username ?? 'Unknown'),
                      _buildInfoRow('登録日', _formatDate(authProvider.currentPlayer?.createdAt)),
                    ] else ...[
                      Text(
                        'ログインしていません',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // アカウント操作ボタン
              if (authProvider.isAuthenticated) ...[
                // データ同期ボタン
                _buildActionButton(
                  context,
                  title: '[データ同期]',
                  subtitle: 'サーバーとのデータ同期を実行',
                  icon: Icons.sync,
                  color: AppTheme.primaryColor,
                  onTap: () => _syncData(context),
                ),

                const SizedBox(height: 8),

                // パスワード変更ボタン
                _buildActionButton(
                  context,
                  title: '[パスワード変更]',
                  subtitle: 'アカウントのパスワードを変更',
                  icon: Icons.lock_reset,
                  color: AppTheme.accentColor,
                  onTap: () => _changePassword(context),
                ),

                const SizedBox(height: 8),

                // ログアウトボタン
                _buildActionButton(
                  context,
                  title: '[ログアウト]',
                  subtitle: 'アカウントからログアウト',
                  icon: Icons.logout,
                  color: AppTheme.errorColor,
                  onTap: () => _logout(context),
                ),
              ] else ...[
                // ログインボタン
                _buildActionButton(
                  context,
                  title: '[ログイン]',
                  subtitle: 'アカウントにログイン',
                  icon: Icons.login,
                  color: AppTheme.successColor,
                  onTap: () => _login(context),
                ),
              ],

              const SizedBox(height: 8),

              // 注意書き
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.accentColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ログインするとクラウドにデータが保存され、複数デバイスで同期できます',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          color: color.withValues(alpha: 0.1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _syncData(BuildContext context) {
    // TODO: データ同期処理の実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('データ同期機能は準備中です'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _changePassword(BuildContext context) {
    // TODO: パスワード変更画面への遷移
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('パスワード変更機能は準備中です'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildConfirmDialog(
        context,
        title: 'ログアウト確認',
        message: 'ログアウトしますか？\n未保存のデータは失われる可能性があります。',
        confirmText: '[ログアウト]',
        confirmColor: AppTheme.errorColor,
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<AuthProvider>().logout();
        },
      ),
    );
  }

  void _login(BuildContext context) {
    // TODO: ログイン画面への遷移
    Navigator.of(context).pushNamed('/login');
  }

  Widget _buildConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: confirmColor, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border.all(color: confirmColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '=== $title ===',
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                      ),
                      child: Text(
                        '[キャンセル]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: confirmColor, width: 1),
                        color: confirmColor.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        confirmText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: confirmColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}