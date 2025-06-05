import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import 'settings_toggle.dart';
import 'settings_dropdown.dart';

class DisplaySettingsCard extends StatelessWidget {
  const DisplaySettingsCard({super.key});

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
              // テーマ設定
              SettingsDropdown<String>(
                title: 'テーマ',
                subtitle: 'アプリの外観テーマを選択',
                value: settings.theme,
                options: const {
                  'retro': 'レトロ',
                  'modern': 'モダン',
                  'dark': 'ダーク',
                },
                onChanged: (value) => settingsProvider.updateTheme(value),
              ),

              const SizedBox(height: 16),

              // 言語設定
              SettingsDropdown<String>(
                title: '言語',
                subtitle: 'アプリの表示言語を選択',
                value: settings.language,
                options: SettingsProvider.availableLanguages,
                onChanged: (value) => settingsProvider.updateLanguage(value),
              ),

              const SizedBox(height: 16),

              // アニメーション設定
              SettingsToggle(
                title: 'アニメーション',
                subtitle: 'UI要素のアニメーション効果',
                value: settings.animations,
                onChanged: (value) => settingsProvider.updateAnimations(value),
              ),

              const SizedBox(height: 16),

              // 通知設定
              SettingsToggle(
                title: '通知',
                subtitle: 'アプリ内通知の表示',
                value: settings.notifications,
                onChanged: (value) => settingsProvider.updateNotifications(value),
              ),

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
                        'テーマと言語の変更は次回アプリ起動時に反映されます',
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
}