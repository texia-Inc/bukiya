import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/audio_settings_card.dart';
import '../widgets/display_settings_card.dart';
import '../widgets/game_settings_card.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/privacy_settings_card.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../../tutorial/widgets/tutorial_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  Widget _buildTutorialSettings(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorialProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              // チュートリアル状態
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      tutorialProvider.isCompleted 
                        ? Icons.check_circle 
                        : Icons.play_circle_outline,
                      color: tutorialProvider.isCompleted 
                        ? AppTheme.successColor 
                        : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutorialProvider.isCompleted 
                              ? 'チュートリアル完了'
                              : 'チュートリアル未完了',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (!tutorialProvider.isCompleted)
                            Text(
                              '基本操作を学びましょう',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                height: 1,
                color: AppTheme.borderColor,
              ),
              
              // チュートリアル開始ボタン
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (tutorialProvider.isCompleted) {
                        // リセット確認ダイアログ
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('チュートリアルをリセット'),
                            content: const Text(
                              'チュートリアルの進行状況をリセットして、'
                              '最初からやり直しますか？',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('キャンセル'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('リセット'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await tutorialProvider.resetProgress();
                          tutorialProvider.startTutorial();
                        }
                      } else {
                        tutorialProvider.startTutorial();
                      }
                    },
                    icon: Icon(
                      tutorialProvider.isCompleted 
                        ? Icons.refresh 
                        : Icons.play_arrow,
                    ),
                    label: Text(
                      tutorialProvider.isCompleted 
                        ? 'チュートリアルをやり直す' 
                        : 'チュートリアルを開始',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              
              // チュートリアル設定
              if (tutorialProvider.isEnabled)
                Container(
                  height: 1,
                  color: AppTheme.borderColor,
                ),
              if (tutorialProvider.isEnabled)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'チュートリアルを有効にする',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                      const Spacer(),
                      Switch(
                        value: tutorialProvider.isEnabled,
                        onChanged: (value) async {
                          if (value) {
                            // チュートリアルを有効にする
                            await tutorialProvider.updateConfig(
                              tutorialProvider.config.copyWith(isEnabled: true)
                            );
                          } else {
                            // チュートリアルを無効にする
                            await tutorialProvider.disableTutorial();
                          }
                        },
                        activeColor: AppTheme.primaryColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // レトロスタイルのヘッダー
              SliverAppBar(
                backgroundColor: AppTheme.backgroundColor,
                elevation: 0,
                pinned: true,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            border: Border.all(color: AppTheme.primaryColor),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '=== SYSTEM CONFIG ===',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
              ),

              // 設定セクション
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // エラーメッセージ表示
                    if (settingsProvider.errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          border: Border.all(color: AppTheme.errorColor, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                settingsProvider.errorMessage!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 音声設定
                    SettingsSection(
                      title: 'AUDIO CONFIG',
                      icon: Icons.volume_up,
                      child: AudioSettingsCard(),
                    ),
                    const SizedBox(height: 16),

                    // 表示設定
                    SettingsSection(
                      title: 'DISPLAY CONFIG',
                      icon: Icons.display_settings,
                      child: DisplaySettingsCard(),
                    ),
                    const SizedBox(height: 16),

                    // ゲーム設定
                    SettingsSection(
                      title: 'GAME CONFIG',
                      icon: Icons.gamepad,
                      child: GameSettingsCard(),
                    ),
                    const SizedBox(height: 16),

                    // チュートリアル設定
                    SettingsSection(
                      title: 'TUTORIAL CONFIG',
                      icon: Icons.school,
                      child: _buildTutorialSettings(context),
                    ),
                    const SizedBox(height: 16),

                    // アカウント設定
                    SettingsSection(
                      title: 'ACCOUNT CONFIG',
                      icon: Icons.account_circle,
                      child: AccountSettingsCard(),
                    ),
                    const SizedBox(height: 16),

                    // プライバシー設定
                    SettingsSection(
                      title: 'PRIVACY CONFIG',
                      icon: Icons.privacy_tip,
                      child: PrivacySettingsCard(),
                    ),
                    const SizedBox(height: 16),

                    // リセットボタン
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        border: Border.all(color: AppTheme.errorColor, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '--- DANGER ZONE ---',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () => _showResetConfirmation(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.errorColor, width: 1),
                                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                                ),
                                child: Text(
                                  '[RESET TO DEFAULT]',
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
                    ),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
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
                '=== CONFIRMATION ===',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'すべての設定をデフォルトにリセットしますか？\nこの操作は元に戻せません。',
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
                      onTap: () async {
                        Navigator.of(context).pop();
                        await context.read<SettingsProvider>().resetToDefault();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.errorColor, width: 1),
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          '[リセット]',
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
}