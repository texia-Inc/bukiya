import 'package:flutter/material.dart';

import '../../../core/models/tutorial.dart';
import '../../../core/services/tutorial_service.dart';

/// チュートリアル状態管理プロバイダー
class TutorialProvider extends ChangeNotifier {
  final TutorialService _tutorialService = TutorialService();
  
  // 状態
  TutorialProgress? _progress;
  TutorialConfig _config = const TutorialConfig();
  bool _isInitialized = false;
  bool _isShowingTutorial = false;
  TutorialStep? _currentStepDefinition;
  TutorialContext? _currentContext;
  
  // ゲッター
  TutorialProgress? get progress => _progress;
  TutorialConfig get config => _config;
  bool get isInitialized => _isInitialized;
  bool get isShowingTutorial => _isShowingTutorial;
  TutorialStep? get currentStepDefinition => _currentStepDefinition;
  TutorialContext? get currentContext => _currentContext;
  
  // チュートリアル状態
  bool get isEnabled => _config.isEnabled;
  bool get isCompleted => _progress?.isCompleted ?? false;
  bool get canSkip => _config.allowSkip;
  TutorialStepType? get currentStep => _progress?.currentStep;
  
  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _tutorialService.initialize();
      _progress = _tutorialService.currentProgress;
      _config = _tutorialService.config;
      _isInitialized = true;
      
      // 現在のステップ定義を読み込み
      if (_progress?.currentStep != null) {
        _currentStepDefinition = TutorialService.getStepDefinition(_progress!.currentStep!);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('チュートリアルプロバイダー初期化エラー: $e');
    }
  }
  
  /// チュートリアル開始
  Future<void> startTutorial() async {
    await _tutorialService.startTutorial();
    await _reloadProgress();
    
    _isShowingTutorial = true;
    notifyListeners();
  }
  
  /// チュートリアル再開
  Future<void> restartTutorial() async {
    await _tutorialService.restartTutorial();
    await _reloadProgress();
    
    _isShowingTutorial = true;
    notifyListeners();
  }
  
  /// ステップ完了
  Future<void> completeCurrentStep() async {
    if (_progress?.currentStep == null) return;
    
    await _tutorialService.completeStep(_progress!.currentStep!);
    await _reloadProgress();
    
    // チュートリアル完了チェック
    if (_progress?.isCompleted ?? false) {
      _isShowingTutorial = false;
    }
    
    notifyListeners();
  }
  
  /// 特定のステップ完了
  Future<void> completeStep(TutorialStepType step) async {
    await _tutorialService.completeStep(step);
    await _reloadProgress();
    notifyListeners();
  }
  
  /// チュートリアルスキップ
  Future<void> skipTutorial() async {
    await _tutorialService.skipTutorial();
    await _reloadProgress();
    
    _isShowingTutorial = false;
    notifyListeners();
  }
  
  /// チュートリアル表示開始
  void showTutorial() {
    if (!isEnabled || isCompleted) return;
    
    _isShowingTutorial = true;
    notifyListeners();
  }
  
  /// チュートリアル表示終了
  void hideTutorial() {
    _isShowingTutorial = false;
    notifyListeners();
  }
  
  /// 現在のステップが表示可能かチェック
  bool canShowCurrentStep() {
    return _isShowingTutorial && 
           _currentStepDefinition != null && 
           _currentContext != null &&
           !isCompleted;
  }
  
  /// 特定のステップが完了しているかチェック
  bool isStepCompleted(TutorialStepType step) {
    return _tutorialService.isStepCompleted(step);
  }
  
  /// 設定更新
  Future<void> updateConfig(TutorialConfig newConfig) async {
    await _tutorialService.updateConfig(newConfig);
    _config = newConfig;
    notifyListeners();
  }
  
  /// チュートリアル無効化
  Future<void> disableTutorial() async {
    await _tutorialService.disableTutorial();
    _config = _config.copyWith(isEnabled: false);
    _isShowingTutorial = false;
    notifyListeners();
  }
  
  /// コンテキスト設定（画面遷移時に呼び出し）
  void setContext(TutorialContext context) {
    _currentContext = context;
    
    // 現在のステップがこの画面で実行可能かチェック
    if (_progress?.currentStep != null && 
        context.hasStep(_progress!.currentStep!)) {
      _currentStepDefinition = TutorialService.getStepDefinition(_progress!.currentStep!);
    }
    
    notifyListeners();
  }
  
  /// コンテキストクリア
  void clearContext() {
    _currentContext = null;
    notifyListeners();
  }
  
  /// 特定の画面のステップを自動開始
  void autoStartStepForScreen(String screenName) {
    if (!_isShowingTutorial || _progress?.currentStep == null) return;
    
    final currentStepDef = _currentStepDefinition;
    if (currentStepDef?.route != null && 
        currentStepDef!.route!.contains(screenName)) {
      // このステップは現在の画面で実行可能
      notifyListeners();
    }
  }
  
  /// 次のステップに進む
  Future<void> nextStep() async {
    await completeCurrentStep();
    
    // 必要に応じて画面遷移
    final nextStepDef = _currentStepDefinition;
    if (nextStepDef?.route != null) {
      // プロバイダーは直接ナビゲーションしない
      // 呼び出し側が遷移を処理する
    }
  }
  
  /// ターゲットウィジェットのキーを取得
  GlobalKey? getTargetKey() {
    if (_currentStepDefinition?.targetWidgetKey == null || _currentContext == null) {
      return null;
    }
    
    return _currentContext!.getKey(_currentStepDefinition!.targetWidgetKey!);
  }
  
  /// 進行状況を再読み込み
  Future<void> _reloadProgress() async {
    _progress = _tutorialService.currentProgress;
    _config = _tutorialService.config;
    
    // 現在のステップ定義を更新
    if (_progress?.currentStep != null) {
      _currentStepDefinition = TutorialService.getStepDefinition(_progress!.currentStep!);
    } else {
      _currentStepDefinition = null;
    }
  }
  
  /// 進行状況リセット（デバッグ用）
  Future<void> resetProgress() async {
    await _tutorialService.resetProgress();
    await _reloadProgress();
    _isShowingTutorial = false;
    notifyListeners();
  }
  
  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'isShowingTutorial': _isShowingTutorial,
      'currentStep': _progress?.currentStep?.name,
      'isCompleted': _progress?.isCompleted,
      'completedSteps': _progress?.completedSteps.map((e) => e.name).toList(),
      'hasContext': _currentContext != null,
      'contextScreen': _currentContext?.screenName,
      'hasTargetKey': getTargetKey() != null,
    };
  }
}