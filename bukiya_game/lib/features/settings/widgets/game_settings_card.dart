import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import 'settings_toggle.dart';
import 'settings_slider.dart';

class GameSettingsCard extends StatelessWidget {
  const GameSettingsCard({super.key});

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
              // 自動保存設定
              SettingsToggle(
                title: '自動保存',
                subtitle: 'ゲームデータの自動保存機能',
                value: settings.autoSave,
                onChanged: (value) => settingsProvider.updateAutoSave(value),
              ),

              // 自動保存間隔（自動保存が有効な場合のみ表示）
              if (settings.autoSave) ...[
                const SizedBox(height: 8),
                SettingsSlider(
                  title: '自動保存間隔',
                  subtitle: '自動保存の実行間隔（秒）',
                  value: settings.autoSaveInterval.toDouble(),
                  min: 10.0,
                  max: 300.0,
                  divisions: 29,
                  onChanged: (value) => settingsProvider.updateAutoSaveInterval(value.round()),
                  valueFormatter: (value) => '${value.round()}秒',
                ),
              ],

              const SizedBox(height: 16),

              // オフライン収入設定
              SettingsToggle(
                title: 'オフライン収入',
                subtitle: 'アプリを閉じている間の収入計算',
                value: settings.offlineIncome,
                onChanged: (value) => settingsProvider.updateOfflineIncome(value),
              ),

              const SizedBox(height: 16),

              // 仕入れ確認設定
              SettingsToggle(
                title: '仕入れ確認',
                subtitle: 'アイテム仕入れ時の確認ダイアログ表示',
                value: settings.confirmPurchases,
                onChanged: (value) => settingsProvider.updateConfirmPurchases(value),
              ),

              const SizedBox(height: 8),

              // 説明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  border: Border.all(color: AppTheme.successColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.successColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ゲーム設定の説明',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 自動保存: データの損失を防ぐため推奨\n'
                      '• オフライン収入: アプリ終了時間に応じた収入を計算\n'
                      '• 仕入れ確認: 誤操作防止のための確認ダイアログ',
                      style: TextStyle(
                        color: AppTheme.successColor,
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
}