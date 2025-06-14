import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/tutorial.dart';
import '../providers/tutorial_provider.dart';
import 'tutorial_overlay.dart';

/// チュートリアル機能付きのラッパーウィジェット
class TutorialWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  final List<TutorialStepType> availableSteps;
  final Map<String, GlobalKey>? predefinedKeys;
  
  const TutorialWrapper({
    Key? key,
    required this.child,
    required this.screenName,
    required this.availableSteps,
    this.predefinedKeys,
  }) : super(key: key);
  
  @override
  State<TutorialWrapper> createState() => _TutorialWrapperState();
}

class _TutorialWrapperState extends State<TutorialWrapper> {
  late Map<String, GlobalKey> _widgetKeys;
  
  @override
  void initState() {
    super.initState();
    _widgetKeys = widget.predefinedKeys ?? {};
    
    // コンテキストを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tutorialProvider = context.read<TutorialProvider>();
      final tutorialContext = TutorialContext(
        screenName: widget.screenName,
        widgetKeys: _widgetKeys,
        availableSteps: widget.availableSteps,
      );
      tutorialProvider.setContext(tutorialContext);
      
      // 自動開始チェック
      tutorialProvider.autoStartStepForScreen(widget.screenName);
    });
  }
  
  @override
  void dispose() {
    // コンテキストをクリア
    final tutorialProvider = context.read<TutorialProvider>();
    tutorialProvider.clearContext();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TutorialOverlay(
      child: widget.child,
    );
  }
  
  /// ウィジェットキーを動的に追加
  void addWidgetKey(String key, GlobalKey widgetKey) {
    _widgetKeys[key] = widgetKey;
  }
  
  /// ウィジェットキーを取得
  GlobalKey? getWidgetKey(String key) {
    return _widgetKeys[key];
  }
}

/// チュートリアル付きのタブビュー
class TutorialTabView extends StatefulWidget {
  final List<Widget> children;
  final List<Widget> tabs;
  final TabController? controller;
  final Map<int, String> tabKeys; // タブインデックス -> チュートリアルキーのマッピング
  
  const TutorialTabView({
    Key? key,
    required this.children,
    required this.tabs,
    required this.tabKeys,
    this.controller,
  }) : super(key: key);
  
  @override
  State<TutorialTabView> createState() => _TutorialTabViewState();
}

class _TutorialTabViewState extends State<TutorialTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, GlobalKey> _tabKeys = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = widget.controller ?? TabController(
      length: widget.children.length,
      vsync: this,
    );
    
    // タブキーを作成
    widget.tabKeys.forEach((index, key) {
      _tabKeys[key] = GlobalKey();
    });
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _tabController.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final tutorialKey = widget.tabKeys[index];
              
              if (tutorialKey != null && _tabKeys.containsKey(tutorialKey)) {
                return Container(
                  key: _tabKeys[tutorialKey],
                  child: tab,
                );
              }
              return tab;
            }).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
  
  /// タブキーを取得
  Map<String, GlobalKey> get tabKeys => _tabKeys;
}

/// チュートリアル開始ダイアログ
class TutorialStartDialog extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSkip;
  
  const TutorialStartDialog({
    Key? key,
    required this.onStart,
    required this.onSkip,
  }) : super(key: key);
  
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStart,
    required VoidCallback onSkip,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialStartDialog(
        onStart: onStart,
        onSkip: onSkip,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコン
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // タイトル
            Text(
              'チュートリアル',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 説明
            Text(
              '武器屋ゲームの基本的な操作方法を学びませんか？\n'
              'チュートリアルでは以下のことを学べます：\n\n'
              '• 武器の仕入れと販売\n'
              '• 冒険者との取引\n'
              '• 武器の作成と強化\n'
              '• 放置システムの活用',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // ボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('スキップ'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('開始'),
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

/// チュートリアル完了ダイアログ
class TutorialCompleteDialog extends StatelessWidget {
  final VoidCallback onClose;
  
  const TutorialCompleteDialog({
    Key? key,
    required this.onClose,
  }) : super(key: key);
  
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onClose,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialCompleteDialog(
        onClose: onClose,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 成功アイコン
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // タイトル
            Text(
              'チュートリアル完了！',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            
            // 説明
            Text(
              'おめでとうございます！\n'
              '武器屋ゲームの基本操作をマスターしました。\n\n'
              'これで立派な武器屋店主として\n'
              '冒険者たちにサービスを提供できます！',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ゲームを始める'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// チュートリアル設定ダイアログ
class TutorialSettingsDialog extends StatefulWidget {
  final TutorialConfig config;
  final Function(TutorialConfig) onConfigChanged;
  
  const TutorialSettingsDialog({
    Key? key,
    required this.config,
    required this.onConfigChanged,
  }) : super(key: key);
  
  static Future<void> show(
    BuildContext context, {
    required TutorialConfig config,
    required Function(TutorialConfig) onConfigChanged,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => TutorialSettingsDialog(
        config: config,
        onConfigChanged: onConfigChanged,
      ),
    );
  }
  
  @override
  State<TutorialSettingsDialog> createState() => _TutorialSettingsDialogState();
}

class _TutorialSettingsDialogState extends State<TutorialSettingsDialog> {
  late TutorialConfig _config;
  
  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'チュートリアル設定',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // チュートリアル有効/無効
            SwitchListTile(
              title: const Text('チュートリアルを有効にする'),
              value: _config.isEnabled,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(isEnabled: value);
                });
              },
            ),
            
            // アニメーション有効/無効
            SwitchListTile(
              title: const Text('アニメーションを表示'),
              value: _config.showAnimations,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(showAnimations: value);
                });
              },
            ),
            
            // スキップ許可
            SwitchListTile(
              title: const Text('スキップを許可'),
              value: _config.allowSkip,
              onChanged: (value) {
                setState(() {
                  _config = _config.copyWith(allowSkip: value);
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfigChanged(_config);
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}