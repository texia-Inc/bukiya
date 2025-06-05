import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import 'settings_toggle.dart';

class PrivacySettingsCard extends StatelessWidget {
  const PrivacySettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.settings;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分析データ送信設定
              SettingsToggle(
                title: '使用データ分析',
                subtitle: 'アプリ使用状況の匿名データ送信',
                value: settings.analytics,
                onChanged: (value) => settingsProvider.updateAnalytics(value),
              ),

              const SizedBox(height: 16),

              // クラッシュレポート送信設定
              SettingsToggle(
                title: 'クラッシュレポート',
                subtitle: 'アプリのクラッシュ情報送信',
                value: settings.crashReporting,
                onChanged: (value) => settingsProvider.updateCrashReporting(value),
              ),

              const SizedBox(height: 16),

              // プライバシーポリシーリンク
              GestureDetector(
                onTap: () => _showPrivacyPolicy(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 1),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '[プライバシーポリシーを確認]',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // データ削除ボタン
              GestureDetector(
                onTap: () => _showDataDeletionDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.errorColor, width: 1),
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[すべてのデータを削除]',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'ローカルデータとアカウントデータを完全削除',
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.errorColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // プライバシー説明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.accentColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'プライバシーについて',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 収集されるデータは匿名化され、アプリ改善にのみ使用されます\n'
                      '• 個人を特定できる情報は一切収集しません\n'
                      '• いつでも設定を変更できます',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 11,
                        fontFamily: 'monospace',
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

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '=== PRIVACY POLICY ===',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'ブキヤゲームは、お客様のプライバシーを尊重します。\n\n'
                    '収集する情報:\n'
                    '• ゲームプレイデータ（レベル、実績等）\n'
                    '• アプリの使用状況（匿名）\n'
                    '• クラッシュレポート（匿名）\n\n'
                    '情報の使用目的:\n'
                    '• ゲーム体験の向上\n'
                    '• バグ修正とパフォーマンス改善\n'
                    '• 新機能の開発\n\n'
                    '第三者への提供:\n'
                    '• 個人情報は第三者に提供しません\n'
                    '• 統計データのみ匿名で分析されます\n\n'
                    'お客様の権利:\n'
                    '• いつでもデータ収集を停止できます\n'
                    '• アカウント削除により全データを削除できます',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 1),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '[閉じる]',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDataDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.errorColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '=== DATA DELETION ===',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '⚠️ 警告: この操作は元に戻せません\n\n'
                '削除されるデータ:\n'
                '• すべてのゲーム進捗\n'
                '• アカウント情報\n'
                '• 設定データ\n'
                '• ローカル保存データ\n\n'
                '本当にすべてのデータを削除しますか？',
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
                      onTap: () {
                        Navigator.of(context).pop();
                        _deleteAllData(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.errorColor, width: 1),
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          '[削除実行]',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.errorColor,
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
      ),
    );
  }

  void _deleteAllData(BuildContext context) {
    // TODO: 実際のデータ削除処理の実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('データ削除機能は準備中です'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}