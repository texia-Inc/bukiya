import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import 'settings_toggle.dart';
import 'settings_slider.dart';

class AudioSettingsCard extends StatelessWidget {
  const AudioSettingsCard({super.key});

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
              // 効果音設定
              SettingsToggle(
                title: '効果音',
                subtitle: 'ゲーム内の効果音のオン/オフ',
                value: settings.soundEnabled,
                onChanged: (value) => settingsProvider.updateSoundEnabled(value),
              ),
              
              // 効果音音量（効果音が有効な場合のみ表示）
              if (settings.soundEnabled) ...[
                const SizedBox(height: 8),
                SettingsSlider(
                  title: '効果音音量',
                  subtitle: '効果音の音量調整',
                  value: settings.soundVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) => settingsProvider.updateSoundVolume(value),
                  valueFormatter: (value) => '${(value * 100).round()}%',
                ),
              ],

              const SizedBox(height: 16),
              
              // 音楽設定
              SettingsToggle(
                title: 'BGM',
                subtitle: 'バックグラウンドミュージックのオン/オフ',
                value: settings.musicEnabled,
                onChanged: (value) => settingsProvider.updateMusicEnabled(value),
              ),
              
              // 音楽音量（音楽が有効な場合のみ表示）
              if (settings.musicEnabled) ...[
                const SizedBox(height: 8),
                SettingsSlider(
                  title: 'BGM音量',
                  subtitle: 'バックグラウンドミュージックの音量調整',
                  value: settings.musicVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) => settingsProvider.updateMusicVolume(value),
                  valueFormatter: (value) => '${(value * 100).round()}%',
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
                        '音声設定は次回アプリ起動時に反映されます',
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