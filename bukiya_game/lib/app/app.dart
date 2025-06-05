import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/mission/providers/mission_provider.dart';
import '../features/mission/widgets/offline_progress_dialog.dart';
import '../features/tutorial/providers/tutorial_provider.dart';
import '../shared/widgets/loading_screen.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _hasShownOfflineProgress = false;

  @override
  void initState() {
    super.initState();
    // アプリ起動時に認証状態をチェック
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AuthProvider>().checkAuthStatus();
      // チュートリアルプロバイダーを初期化
      await context.read<TutorialProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('AppWrapper状態: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}, currentPlayer=${authProvider.currentPlayer?.username}');
        
        // 認証状態チェック中
        if (authProvider.isLoading) {
          debugPrint('ローディング画面を表示中...');
          return const LoadingScreen();
        }

        // 認証済み
        if (authProvider.isAuthenticated) {
          debugPrint('認証済み - ダッシュボードに遷移');
          return Consumer<MissionProvider>(
            builder: (context, missionProvider, child) {
              // オフライン進捗ダイアログを表示
              if (!_hasShownOfflineProgress && 
                  missionProvider.hasCheckedOfflineProgress &&
                  missionProvider.lastOfflineProgress != null &&
                  missionProvider.lastOfflineProgress!.offlineTime.inMinutes >= 5) {
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showOfflineProgressDialog(missionProvider.lastOfflineProgress!);
                });
              }
              
              return const DashboardScreen();
            },
          );
        }

        // 未認証
        debugPrint('未認証 - ログイン画面を表示');
        return const LoginScreen();
      },
    );
  }

  void _showOfflineProgressDialog(offlineProgress) {
    if (!_hasShownOfflineProgress && mounted) {
      _hasShownOfflineProgress = true;
      OfflineProgressDialog.show(
        context,
        offlineProgress,
        onClose: () {
          // ダイアログが閉じられた後の処理
          final missionProvider = context.read<MissionProvider>();
          missionProvider.resetOfflineProgressCheck();
        },
      );
    }
  }
}
