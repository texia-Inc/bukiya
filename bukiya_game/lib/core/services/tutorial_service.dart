import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/tutorial.dart';
import '../constants/app_constants.dart';

/// 統合チュートリアル・実績・ガイドサービス
/// 
/// 新規プレイヤーのオンボーディング、実績システム、ガイダンスを提供します
class TutorialService extends ChangeNotifier {
  static const String _progressKey = 'tutorial_progress';
  static const String _configKey = 'tutorial_config';
  static const String _guideStateKey = 'player_guide_state';
  static const String _achievementKey = 'player_achievements';
  
  // シングルトンインスタンス
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();
  
  TutorialProgress? _currentProgress;
  TutorialConfig _config = const TutorialConfig();
  PlayerGuideState _guideState = PlayerGuideState.initial();
  List<Achievement> _achievements = [];
  bool _isLoading = false;

  // Getters
  PlayerGuideState get guideState => _guideState;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  
  List<Achievement> get completedAchievements => 
      _achievements.where((a) => a.isCompleted).toList();
  
  List<Achievement> get pendingAchievements => 
      _achievements.where((a) => !a.isCompleted && !a.isHidden).toList();
  
  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadProgress();
      await _loadConfig();
      await _loadGuideState();
      await _loadAchievements();
      await _initializeDefaultAchievements();
    } catch (e) {
      debugPrint('Tutorial service initialization error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
  
  /// プログレス読み込み
  Future<void> _loadProgress() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get(_progressKey);
      
      if (data != null) {
        _currentProgress = TutorialProgress.fromJson(Map<String, dynamic>.from(data));
      } else {
        // 初回起動時は新規プログレスを作成
        _currentProgress = TutorialProgress.initial();
        await _saveProgress();
      }
    } catch (e) {
      debugPrint('チュートリアルプログレス読み込みエラー: $e');
      _currentProgress = TutorialProgress.initial();
    }
  }
  
  /// 設定読み込み
  Future<void> _loadConfig() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get(_configKey);
      
      if (data != null) {
        _config = TutorialConfig.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      debugPrint('チュートリアル設定読み込みエラー: $e');
    }
  }
  
  /// プログレス保存
  Future<void> _saveProgress() async {
    if (_currentProgress == null) return;
    
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_progressKey, _currentProgress!.toJson());
    } catch (e) {
      debugPrint('チュートリアルプログレス保存エラー: $e');
    }
  }
  
  /// 設定保存
  Future<void> _saveConfig() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_configKey, _config.toJson());
    } catch (e) {
      debugPrint('チュートリアル設定保存エラー: $e');
    }
  }

  /// ガイド状態の読み込み
  Future<void> _loadGuideState() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get(_guideStateKey);
      
      if (data != null) {
        _guideState = PlayerGuideState.fromJson(Map<String, dynamic>.from(data));
      } else {
        _guideState = PlayerGuideState.initial();
        await _saveGuideState();
      }
    } catch (e) {
      debugPrint('Failed to load guide state: $e');
      _guideState = PlayerGuideState.initial();
    }
  }

  /// ガイド状態の保存
  Future<void> _saveGuideState() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_guideStateKey, _guideState.toJson());
    } catch (e) {
      debugPrint('Failed to save guide state: $e');
    }
  }

  /// 実績の読み込み
  Future<void> _loadAchievements() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get(_achievementKey);
      
      if (data != null) {
        final achievementsList = List<Map<String, dynamic>>.from(data);
        _achievements = achievementsList
            .map((a) => Achievement.fromJson(a))
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to load achievements: $e');
      _achievements = [];
    }
  }

  /// 実績の保存
  Future<void> _saveAchievements() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_achievementKey, _achievements.map((a) => a.toJson()).toList());
    } catch (e) {
      debugPrint('Failed to save achievements: $e');
    }
  }

  /// デフォルト実績の初期化
  Future<void> _initializeDefaultAchievements() async {
    final defaultAchievements = _createDefaultAchievements();
    
    for (final defaultAchievement in defaultAchievements) {
      final existingIndex = _achievements.indexWhere(
        (a) => a.id == defaultAchievement.id
      );
      
      if (existingIndex == -1) {
        _achievements.add(defaultAchievement);
      }
    }
    
    await _saveAchievements();
  }

  /// デフォルト実績の作成
  List<Achievement> _createDefaultAchievements() {
    return [
      // 初回アクション系
      Achievement(
        id: 'first_login',
        title: 'ようこそ武器屋へ！',
        description: '初めてゲームにログインしました',
        category: 'beginner',
        iconName: 'login',
        rewardGold: 100,
        rewardExp: 50,
      ),
      Achievement(
        id: 'first_shop_visit',
        title: '初回来店',
        description: 'ショップを初めて見学しました',
        category: 'beginner',
        iconName: 'store',
        rewardGold: 50,
        rewardExp: 25,
      ),
      Achievement(
        id: 'first_weapon_procure',
        title: '初めての仕入れ',
        description: '初めて武器を仕入れしました',
        category: 'trading',
        iconName: 'shopping_cart',
        rewardGold: 200,
        rewardExp: 100,
      ),
      Achievement(
        id: 'first_weapon_sale',
        title: '初回販売',
        description: '初めて武器を販売しました',
        category: 'trading',
        iconName: 'sell',
        rewardGold: 300,
        rewardExp: 150,
      ),
      Achievement(
        id: 'first_craft',
        title: '初心者クラフター',
        description: '初めて武器を作成しました',
        category: 'crafting',
        iconName: 'build',
        rewardGold: 250,
        rewardExp: 200,
      ),
      
      // 数量達成系
      Achievement(
        id: 'sales_5',
        title: '商売上手',
        description: '武器を5本販売しました',
        category: 'trading',
        iconName: 'trending_up',
        rewardGold: 500,
        rewardExp: 250,
        maxProgress: 5,
      ),
      Achievement(
        id: 'gold_1000',
        title: '小金持ち',
        description: '1000ゴールドを貯めました',
        category: 'wealth',
        iconName: 'attach_money',
        rewardGold: 200,
        rewardExp: 100,
      ),
      Achievement(
        id: 'level_5',
        title: 'ショップ拡張',
        description: 'ショップレベル5に到達しました',
        category: 'progression',
        iconName: 'store',
        rewardGold: 1000,
        rewardExp: 500,
      ),

      // 探索系
      Achievement(
        id: 'all_tabs_visited',
        title: '探検家',
        description: 'すべての機能を一度は見学しました',
        category: 'exploration',
        iconName: 'explore',
        rewardGold: 300,
        rewardExp: 150,
      ),
    ];
  }
  
  /// 現在の進行状況を取得
  TutorialProgress? get currentProgress => _currentProgress;
  
  /// 設定を取得
  TutorialConfig get config => _config;
  
  /// チュートリアルが有効かどうか
  bool get isEnabled => _config.isEnabled;
  
  /// チュートリアルが完了しているかどうか
  bool get isCompleted => _currentProgress?.isCompleted ?? false;
  
  /// 現在のステップを取得
  TutorialStepType? get currentStep => _currentProgress?.currentStep;
  
  /// 特定のステップが完了しているかどうか
  bool isStepCompleted(TutorialStepType step) {
    return _currentProgress?.completedSteps.contains(step) ?? false;
  }
  
  /// チュートリアル開始
  Future<void> startTutorial() async {
    _currentProgress = TutorialProgress.initial();
    await _saveProgress();
  }
  
  /// チュートリアル再開
  Future<void> restartTutorial() async {
    _currentProgress = TutorialProgress.initial();
    await _saveProgress();
  }
  
  /// ステップ完了
  Future<void> completeStep(TutorialStepType step) async {
    if (_currentProgress == null) return;
    
    final updatedSteps = List<TutorialStepType>.from(_currentProgress!.completedSteps);
    if (!updatedSteps.contains(step)) {
      updatedSteps.add(step);
    }
    
    // 次のステップを計算
    final nextStep = _getNextStep(step);
    final isCompleted = nextStep == null;
    
    _currentProgress = _currentProgress!.copyWith(
      completedSteps: updatedSteps,
      currentStep: nextStep,
      isCompleted: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );
    
    await _saveProgress();
  }
  
  /// チュートリアルスキップ
  Future<void> skipTutorial() async {
    _currentProgress = _currentProgress?.copyWith(
      isCompleted: true,
      isSkipped: true,
      completedAt: DateTime.now(),
      currentStep: null,
    ) ?? TutorialProgress(
      isCompleted: true,
      completedSteps: [],
      isSkipped: true,
      completedAt: DateTime.now(),
    );
    
    await _saveProgress();
  }
  
  /// 設定更新
  Future<void> updateConfig(TutorialConfig newConfig) async {
    _config = newConfig;
    await _saveConfig();
  }
  
  /// チュートリアル無効化
  Future<void> disableTutorial() async {
    await updateConfig(_config.copyWith(isEnabled: false));
  }
  
  /// 次のステップを取得
  TutorialStepType? _getNextStep(TutorialStepType currentStep) {
    final stepOrder = [
      TutorialStepType.welcome,
      TutorialStepType.shopBasics,
      TutorialStepType.weaponProcure,
      TutorialStepType.adventurerIntro,
      TutorialStepType.weaponSale,
      TutorialStepType.inventoryManage,
      TutorialStepType.craftingBasics,
      TutorialStepType.enchantmentIntro,
      TutorialStepType.idleSystemIntro,
      TutorialStepType.missionSystem,
      TutorialStepType.tutorialComplete,
    ];
    
    final currentIndex = stepOrder.indexOf(currentStep);
    if (currentIndex == -1 || currentIndex >= stepOrder.length - 1) {
      return null;
    }
    
    return stepOrder[currentIndex + 1];
  }
  
  /// チュートリアルステップ定義を取得
  static List<TutorialStep> getAllSteps() {
    return [
      // ウェルカム
      const TutorialStep(
        type: TutorialStepType.welcome,
        title: '武器屋へようこそ！',
        description: 'あなたは武器屋の店主となり、冒険者たちに武器を作って販売する仕事をします。\n'
                    'まずは基本的な操作を覚えていきましょう！',
        buttonText: 'はじめる',
        autoAdvanceDelay: Duration(seconds: 3),
      ),
      
      // ショップ基本操作
      const TutorialStep(
        type: TutorialStepType.shopBasics,
        title: 'ショップ画面',
        description: 'ここでは武器の仕入れと販売ができます。\n'
                    '最初は武器を仕入れして在庫を増やしましょう。',
        targetWidgetKey: 'shop_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/shop',
      ),
      
      // 武器仕入れ
      const TutorialStep(
        type: TutorialStepType.weaponProcure,
        title: '武器を仕入れしよう',
        description: '武器カードをタップして仕入れできます。\n'
                    '右下の買い物カゴボタンを押してみましょう！',
        targetWidgetKey: 'weapon_procure_button',
        highlightShape: TutorialHighlightShape.rectangle,
      ),
      
      // 冒険者システム紹介
      const TutorialStep(
        type: TutorialStepType.adventurerIntro,
        title: '冒険者たちがやってきた！',
        description: '冒険者があなたの店を訪れます。\n'
                    '彼らに武器を販売して利益を得ましょう。',
        targetWidgetKey: 'adventurer_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/adventurer',
      ),
      
      // 武器販売
      const TutorialStep(
        type: TutorialStepType.weaponSale,
        title: '武器を販売しよう',
        description: '冒険者が欲しがっている武器を販売できます。\n'
                    '価格を設定して取引を成立させましょう！',
        targetWidgetKey: 'weapon_sale_button',
        highlightShape: TutorialHighlightShape.rectangle,
      ),
      
      // インベントリ管理
      const TutorialStep(
        type: TutorialStepType.inventoryManage,
        title: 'インベントリで在庫管理',
        description: 'インベントリでは所持している武器や素材を確認できます。\n'
                    '在庫を把握して効率的に商売を進めましょう。',
        targetWidgetKey: 'inventory_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/inventory',
      ),
      
      // クラフティング基本
      const TutorialStep(
        type: TutorialStepType.craftingBasics,
        title: '武器を作成しよう',
        description: '素材を組み合わせて新しい武器を作成できます。\n'
                    'より強力な武器を作って高く売りましょう！',
        targetWidgetKey: 'crafting_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/crafting',
      ),
      
      // エンチャント紹介
      const TutorialStep(
        type: TutorialStepType.enchantmentIntro,
        title: '武器を強化しよう',
        description: 'エンチャントで武器を強化できます。\n'
                    '強化された武器はより高い価格で販売できます！',
        targetWidgetKey: 'enchantment_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/enchantment',
      ),
      
      // 放置システム紹介
      const TutorialStep(
        type: TutorialStepType.idleSystemIntro,
        title: '放置収益システム',
        description: 'ゲームを閉じていても自動で収益が発生します。\n'
                    'アップグレードして効率を上げましょう！',
        targetWidgetKey: 'idle_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/idle',
      ),
      
      // ミッションシステム
      const TutorialStep(
        type: TutorialStepType.missionSystem,
        title: 'ミッションに挑戦',
        description: 'ミッションを完了すると報酬がもらえます。\n'
                    '目標を達成してゲームを進めましょう！',
        targetWidgetKey: 'mission_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/mission',
      ),
      
      // チュートリアル完了
      const TutorialStep(
        type: TutorialStepType.tutorialComplete,
        title: 'チュートリアル完了！',
        description: 'おめでとうございます！\n'
                    '基本操作を覚えました。さあ、立派な武器屋店主を目指しましょう！',
        buttonText: '完了',
        isSkippable: false,
      ),
    ];
  }
  
  /// 特定のステップ定義を取得
  static TutorialStep? getStepDefinition(TutorialStepType type) {
    return getAllSteps().where((step) => step.type == type).firstOrNull;
  }
  
  /// 実績を更新/進捗
  Future<void> updateAchievementProgress(String achievementId, {int increment = 1}) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    if (achievement.isCompleted) return;

    final newProgress = (achievement.progress + increment).clamp(0, achievement.maxProgress);
    final isNowCompleted = newProgress >= achievement.maxProgress;

    _achievements[index] = achievement.copyWith(
      progress: newProgress,
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );

    if (isNowCompleted) {
      debugPrint('Achievement completed: ${achievement.title}');
      _onAchievementCompleted(_achievements[index]);
    }

    await _saveAchievements();
    notifyListeners();
  }

  /// 実績完了時の処理
  void _onAchievementCompleted(Achievement achievement) {
    debugPrint('🎉 Achievement unlocked: ${achievement.title}');
    debugPrint('Reward: ${achievement.rewardGold} gold, ${achievement.rewardExp} exp');
  }

  /// ガイド状態の更新
  Future<void> updateGuideState(PlayerGuideState newState) async {
    _guideState = newState;
    await _saveGuideState();
    notifyListeners();
  }

  /// 特定のアクションを記録
  Future<void> recordAction(String action) async {
    var newState = _guideState.copyWith(
      totalActionsCompleted: _guideState.totalActionsCompleted + 1,
    );

    // アクション固有の状態更新
    switch (action) {
      case 'shop_visit':
        newState = newState.copyWith(hasSeenShop: true);
        await updateAchievementProgress('first_shop_visit');
        break;
      case 'weapon_procure':
        await updateAchievementProgress('first_weapon_procure');
        break;
      case 'weapon_sale':
        newState = newState.copyWith(hasCompletedFirstSale: true);
        await updateAchievementProgress('first_weapon_sale');
        await updateAchievementProgress('sales_5');
        break;
      case 'weapon_craft':
        newState = newState.copyWith(hasCompletedFirstCraft: true);
        await updateAchievementProgress('first_craft');
        break;
      case 'adventurer_visit':
        newState = newState.copyWith(hasSeenAdventurer: true);
        break;
      case 'crafting_visit':
        newState = newState.copyWith(hasSeenCrafting: true);
        break;
    }

    await updateGuideState(newState);
  }

  /// 現在の目標を取得
  String getCurrentObjective() {
    if (_guideState.isFirstTimeUser) {
      return 'ようこそ武器屋へ！まずはショップタブを見てみましょう';
    }
    
    if (!_guideState.hasSeenShop) {
      return 'ショップで武器を確認してみましょう';
    }
    
    if (!_guideState.hasCompletedFirstSale) {
      return '武器を仕入れして冒険者に販売してみましょう';
    }
    
    if (!_guideState.hasSeenCrafting) {
      return '合成タブで武器作成を試してみましょう';
    }
    
    if (!_guideState.hasCompletedFirstCraft) {
      return '素材を集めて武器を作成してみましょう';
    }
    
    if (_guideState.totalActionsCompleted < 10) {
      return 'いろいろな機能を試して、経験を積みましょう';
    }
    
    return '自由に武器屋経営を楽しみましょう！';
  }

  /// 次のステップの推奨アクション
  List<String> getRecommendedActions() {
    final actions = <String>[];
    
    if (!_guideState.hasSeenShop) {
      actions.add('ショップタブを開く');
    }
    
    if (_guideState.hasSeenShop && !_guideState.hasCompletedFirstSale) {
      actions.add('武器を仕入れる');
      actions.add('冒険者に武器を販売する');
    }
    
    if (!_guideState.hasSeenCrafting) {
      actions.add('合成タブを確認する');
    }
    
    if (_guideState.hasSeenCrafting && !_guideState.hasCompletedFirstCraft) {
      actions.add('武器を作成する');
    }
    
    if (!_guideState.hasSeenAdventurer) {
      actions.add('冒険者タブを確認する');
    }

    // 経験者向けの推奨アクション
    if (_guideState.totalActionsCompleted >= 5) {
      actions.add('ショップレベルを上げる');
      actions.add('高レア武器を作成する');
      actions.add('エンチャントを試す');
    }
    
    return actions;
  }

  /// セッション開始時の処理
  Future<void> onSessionStart() async {
    final newState = _guideState.copyWith(
      sessionCount: _guideState.sessionCount + 1,
      lastPlayedAt: DateTime.now(),
    );
    
    await updateGuideState(newState);
    
    // 初回ログイン実績
    if (newState.sessionCount == 1) {
      await updateAchievementProgress('first_login');
    }
  }

  /// 新規プレイヤーかどうか
  bool isNewPlayer() => _guideState.isNewPlayer;
  
  /// チュートリアル完了かどうか
  bool isTutorialCompleted() => _guideState.hasCompletedTutorial;

  /// 進行状況のリセット（デバッグ用）
  Future<void> resetProgress() async {
    final box = await Hive.openBox(AppConstants.gameDataKey);
    await box.delete(_progressKey);
    _currentProgress = null;
    await _loadProgress();
  }

  /// デバッグ用：ガイド状態リセット
  Future<void> resetGuideState() async {
    if (kDebugMode) {
      _guideState = PlayerGuideState.initial();
      await _saveGuideState();
      notifyListeners();
    }
  }

  /// デバッグ用：実績リセット
  Future<void> resetAchievements() async {
    if (kDebugMode) {
      _achievements.clear();
      await _saveAchievements();
      await _initializeDefaultAchievements();
      notifyListeners();
    }
  }
}