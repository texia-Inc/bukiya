import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/tutorial.dart';
import '../constants/app_constants.dart';

/// チュートリアルサービス
/// 
/// チュートリアルの進行状況管理とステップ定義を提供します
class TutorialService {
  static const String _progressKey = 'tutorial_progress';
  static const String _configKey = 'tutorial_config';
  
  // シングルトンインスタンス
  static final TutorialService _instance = TutorialService._internal();
  factory TutorialService() => _instance;
  TutorialService._internal();
  
  TutorialProgress? _currentProgress;
  TutorialConfig _config = const TutorialConfig();
  
  /// 初期化
  Future<void> initialize() async {
    await _loadProgress();
    await _loadConfig();
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
      TutorialStepType.weaponPurchase,
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
        description: 'ここでは武器の購入と販売ができます。\n'
                    '最初は武器を購入して在庫を増やしましょう。',
        targetWidgetKey: 'shop_tab',
        highlightShape: TutorialHighlightShape.circle,
        route: '/shop',
      ),
      
      // 武器購入
      const TutorialStep(
        type: TutorialStepType.weaponPurchase,
        title: '武器を購入しよう',
        description: '武器カードをタップして購入できます。\n'
                    '右下の買い物カゴボタンを押してみましょう！',
        targetWidgetKey: 'weapon_purchase_button',
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
  
  /// 進行状況のリセット（デバッグ用）
  Future<void> resetProgress() async {
    final box = await Hive.openBox(AppConstants.gameDataKey);
    await box.delete(_progressKey);
    _currentProgress = null;
    await _loadProgress();
  }
}