import 'package:flutter/material.dart';

/// チュートリアルステップの定義
enum TutorialStepType {
  welcome,           // ウェルカム
  shopBasics,        // ショップ基本操作
  weaponProcure,    // 武器仕入れ
  adventurerIntro,   // 冒険者システム紹介
  weaponSale,        // 武器販売
  inventoryManage,   // インベントリ管理
  craftingBasics,    // クラフティング基本
  enchantmentIntro,  // エンチャント紹介
  idleSystemIntro,   // 放置システム紹介
  missionSystem,     // ミッションシステム
  tutorialComplete,  // チュートリアル完了
}

/// チュートリアルステップ
class TutorialStep {
  final TutorialStepType type;
  final String title;
  final String description;
  final String? targetWidgetKey; // ハイライト対象のwidget key
  final Offset? targetPosition;  // ハイライト位置（keyがない場合）
  final TutorialHighlightShape highlightShape;
  final String buttonText;
  final bool isSkippable;
  final Duration? autoAdvanceDelay; // 自動進行の遅延
  final String? route; // 必要に応じて画面遷移

  const TutorialStep({
    required this.type,
    required this.title,
    required this.description,
    this.targetWidgetKey,
    this.targetPosition,
    this.highlightShape = TutorialHighlightShape.circle,
    this.buttonText = '次へ',
    this.isSkippable = true,
    this.autoAdvanceDelay,
    this.route,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'title': title,
    'description': description,
    'target_widget_key': targetWidgetKey,
    'target_position': targetPosition != null ? {
      'dx': targetPosition!.dx,
      'dy': targetPosition!.dy,
    } : null,
    'highlight_shape': highlightShape.name,
    'button_text': buttonText,
    'is_skippable': isSkippable,
    'auto_advance_delay': autoAdvanceDelay?.inMilliseconds,
    'route': route,
  };

  factory TutorialStep.fromJson(Map<String, dynamic> json) => TutorialStep(
    type: TutorialStepType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'],
    description: json['description'],
    targetWidgetKey: json['target_widget_key'],
    targetPosition: json['target_position'] != null 
        ? Offset(json['target_position']['dx'], json['target_position']['dy'])
        : null,
    highlightShape: TutorialHighlightShape.values.firstWhere(
      (e) => e.name == json['highlight_shape'],
      orElse: () => TutorialHighlightShape.circle,
    ),
    buttonText: json['button_text'] ?? '次へ',
    isSkippable: json['is_skippable'] ?? true,
    autoAdvanceDelay: json['auto_advance_delay'] != null 
        ? Duration(milliseconds: json['auto_advance_delay'])
        : null,
    route: json['route'],
  );
}

/// ハイライト形状
enum TutorialHighlightShape {
  circle,    // 円形
  rectangle, // 矩形
  roundedRectangle, // 角丸矩形
}

/// チュートリアル進行状況
class TutorialProgress {
  final bool isCompleted;
  final TutorialStepType? currentStep;
  final List<TutorialStepType> completedSteps;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final bool isSkipped;

  const TutorialProgress({
    required this.isCompleted,
    this.currentStep,
    required this.completedSteps,
    this.startedAt,
    this.completedAt,
    this.isSkipped = false,
  });

  TutorialProgress copyWith({
    bool? isCompleted,
    TutorialStepType? currentStep,
    List<TutorialStepType>? completedSteps,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isSkipped,
  }) {
    return TutorialProgress(
      isCompleted: isCompleted ?? this.isCompleted,
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_completed': isCompleted,
    'current_step': currentStep?.name,
    'completed_steps': completedSteps.map((e) => e.name).toList(),
    'started_at': startedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'is_skipped': isSkipped,
  };

  factory TutorialProgress.fromJson(Map<String, dynamic> json) => TutorialProgress(
    isCompleted: json['is_completed'] ?? false,
    currentStep: json['current_step'] != null 
        ? TutorialStepType.values.firstWhere((e) => e.name == json['current_step'])
        : null,
    completedSteps: (json['completed_steps'] as List<dynamic>?)
        ?.map((e) => TutorialStepType.values.firstWhere((step) => step.name == e))
        .toList() ?? [],
    startedAt: json['started_at'] != null 
        ? DateTime.parse(json['started_at'])
        : null,
    completedAt: json['completed_at'] != null 
        ? DateTime.parse(json['completed_at'])
        : null,
    isSkipped: json['is_skipped'] ?? false,
  );

  // デフォルトの新規プログレス
  static TutorialProgress initial() => TutorialProgress(
    isCompleted: false,
    currentStep: TutorialStepType.welcome,
    completedSteps: [],
    startedAt: DateTime.now(),
  );
}

/// チュートリアル設定
class TutorialConfig {
  final bool isEnabled;
  final bool showAnimations;
  final bool allowSkip;
  final Duration defaultStepDuration;
  final double overlayOpacity;

  const TutorialConfig({
    this.isEnabled = true,
    this.showAnimations = true,
    this.allowSkip = true,
    this.defaultStepDuration = const Duration(seconds: 5),
    this.overlayOpacity = 0.8,
  });

  TutorialConfig copyWith({
    bool? isEnabled,
    bool? showAnimations,
    bool? allowSkip,
    Duration? defaultStepDuration,
    double? overlayOpacity,
  }) {
    return TutorialConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      showAnimations: showAnimations ?? this.showAnimations,
      allowSkip: allowSkip ?? this.allowSkip,
      defaultStepDuration: defaultStepDuration ?? this.defaultStepDuration,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_enabled': isEnabled,
    'show_animations': showAnimations,
    'allow_skip': allowSkip,
    'default_step_duration': defaultStepDuration.inMilliseconds,
    'overlay_opacity': overlayOpacity,
  };

  factory TutorialConfig.fromJson(Map<String, dynamic> json) => TutorialConfig(
    isEnabled: json['is_enabled'] ?? true,
    showAnimations: json['show_animations'] ?? true,
    allowSkip: json['allow_skip'] ?? true,
    defaultStepDuration: Duration(
      milliseconds: json['default_step_duration'] ?? 5000,
    ),
    overlayOpacity: json['overlay_opacity']?.toDouble() ?? 0.8,
  );
}

/// 特定の画面でのチュートリアルコンテキスト
class TutorialContext {
  final String screenName;
  final Map<String, GlobalKey> widgetKeys;
  final List<TutorialStepType> availableSteps;
  
  TutorialContext({
    required this.screenName,
    required this.widgetKeys,
    required this.availableSteps,
  });
  
  GlobalKey? getKey(String keyName) => widgetKeys[keyName];
  
  bool hasStep(TutorialStepType step) => availableSteps.contains(step);
}

/// 実績システム
class Achievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final String iconName;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardGold;
  final int rewardExp;
  final String? rewardItem;
  final int progress;
  final int maxProgress;
  final bool isHidden; // 隠し実績
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    this.isCompleted = false,
    this.completedAt,
    this.rewardGold = 0,
    this.rewardExp = 0,
    this.rewardItem,
    this.progress = 0,
    this.maxProgress = 1,
    this.isHidden = false,
  });
  
  double get progressPercentage {
    if (maxProgress == 0) return 0.0;
    return (progress / maxProgress).clamp(0.0, 1.0);
  }
  
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? iconName,
    bool? isCompleted,
    DateTime? completedAt,
    int? rewardGold,
    int? rewardExp,
    String? rewardItem,
    int? progress,
    int? maxProgress,
    bool? isHidden,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardExp: rewardExp ?? this.rewardExp,
      rewardItem: rewardItem ?? this.rewardItem,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'icon_name': iconName,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIso8601String(),
    'reward_gold': rewardGold,
    'reward_exp': rewardExp,
    'reward_item': rewardItem,
    'progress': progress,
    'max_progress': maxProgress,
    'is_hidden': isHidden,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    iconName: json['icon_name'],
    isCompleted: json['is_completed'] ?? false,
    completedAt: json['completed_at'] != null 
        ? DateTime.parse(json['completed_at'])
        : null,
    rewardGold: json['reward_gold'] ?? 0,
    rewardExp: json['reward_exp'] ?? 0,
    rewardItem: json['reward_item'],
    progress: json['progress'] ?? 0,
    maxProgress: json['max_progress'] ?? 1,
    isHidden: json['is_hidden'] ?? false,
  );
}

/// プレイヤーガイド状態
class PlayerGuideState {
  final bool hasCompletedTutorial;
  final bool hasSeenWelcome;
  final bool hasSeenShop;
  final bool hasSeenCrafting;
  final bool hasSeenAdventurer;
  final bool hasCompletedFirstSale;
  final bool hasCompletedFirstCraft;
  final String? currentObjective;
  final List<String> unlockedFeatures;
  final DateTime? lastPlayedAt;
  final int sessionCount;
  final List<String> seenTooltips;
  final int totalActionsCompleted;
  
  const PlayerGuideState({
    this.hasCompletedTutorial = false,
    this.hasSeenWelcome = false,
    this.hasSeenShop = false,
    this.hasSeenCrafting = false,
    this.hasSeenAdventurer = false,
    this.hasCompletedFirstSale = false,
    this.hasCompletedFirstCraft = false,
    this.currentObjective,
    this.unlockedFeatures = const [],
    this.lastPlayedAt,
    this.sessionCount = 0,
    this.seenTooltips = const [],
    this.totalActionsCompleted = 0,
  });
  
  bool get isNewPlayer => sessionCount <= 3;
  bool get needsGuidance => !hasCompletedTutorial || isNewPlayer;
  bool get isFirstTimeUser => sessionCount == 0;
  
  PlayerGuideState copyWith({
    bool? hasCompletedTutorial,
    bool? hasSeenWelcome,
    bool? hasSeenShop,
    bool? hasSeenCrafting,
    bool? hasSeenAdventurer,
    bool? hasCompletedFirstSale,
    bool? hasCompletedFirstCraft,
    String? currentObjective,
    List<String>? unlockedFeatures,
    DateTime? lastPlayedAt,
    int? sessionCount,
    List<String>? seenTooltips,
    int? totalActionsCompleted,
  }) {
    return PlayerGuideState(
      hasCompletedTutorial: hasCompletedTutorial ?? this.hasCompletedTutorial,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      hasSeenShop: hasSeenShop ?? this.hasSeenShop,
      hasSeenCrafting: hasSeenCrafting ?? this.hasSeenCrafting,
      hasSeenAdventurer: hasSeenAdventurer ?? this.hasSeenAdventurer,
      hasCompletedFirstSale: hasCompletedFirstSale ?? this.hasCompletedFirstSale,
      hasCompletedFirstCraft: hasCompletedFirstCraft ?? this.hasCompletedFirstCraft,
      currentObjective: currentObjective ?? this.currentObjective,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      sessionCount: sessionCount ?? this.sessionCount,
      seenTooltips: seenTooltips ?? this.seenTooltips,
      totalActionsCompleted: totalActionsCompleted ?? this.totalActionsCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'has_completed_tutorial': hasCompletedTutorial,
    'has_seen_welcome': hasSeenWelcome,
    'has_seen_shop': hasSeenShop,
    'has_seen_crafting': hasSeenCrafting,
    'has_seen_adventurer': hasSeenAdventurer,
    'has_completed_first_sale': hasCompletedFirstSale,
    'has_completed_first_craft': hasCompletedFirstCraft,
    'current_objective': currentObjective,
    'unlocked_features': unlockedFeatures,
    'last_played_at': lastPlayedAt?.toIso8601String(),
    'session_count': sessionCount,
    'seen_tooltips': seenTooltips,
    'total_actions_completed': totalActionsCompleted,
  };

  factory PlayerGuideState.fromJson(Map<String, dynamic> json) => PlayerGuideState(
    hasCompletedTutorial: json['has_completed_tutorial'] ?? false,
    hasSeenWelcome: json['has_seen_welcome'] ?? false,
    hasSeenShop: json['has_seen_shop'] ?? false,
    hasSeenCrafting: json['has_seen_crafting'] ?? false,
    hasSeenAdventurer: json['has_seen_adventurer'] ?? false,
    hasCompletedFirstSale: json['has_completed_first_sale'] ?? false,
    hasCompletedFirstCraft: json['has_completed_first_craft'] ?? false,
    currentObjective: json['current_objective'],
    unlockedFeatures: (json['unlocked_features'] as List<dynamic>?)
        ?.map((e) => e.toString()).toList() ?? [],
    lastPlayedAt: json['last_played_at'] != null 
        ? DateTime.parse(json['last_played_at'])
        : null,
    sessionCount: json['session_count'] ?? 0,
    seenTooltips: (json['seen_tooltips'] as List<dynamic>?)
        ?.map((e) => e.toString()).toList() ?? [],
    totalActionsCompleted: json['total_actions_completed'] ?? 0,
  );

  static PlayerGuideState initial() => PlayerGuideState(
    sessionCount: 0,
    currentObjective: 'ようこそ！まずはショップを見てみましょう',
    unlockedFeatures: ['shop', 'dashboard'],
  );
}