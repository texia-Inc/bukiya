import 'package:flutter/material.dart';

/// チュートリアルステップの定義
enum TutorialStepType {
  welcome,           // ウェルカム
  shopBasics,        // ショップ基本操作
  weaponPurchase,    // 武器購入
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