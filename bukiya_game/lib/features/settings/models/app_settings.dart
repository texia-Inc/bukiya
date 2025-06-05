import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  // 音声設定
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  
  // 表示設定
  final String theme;
  final String language;
  final bool animations;
  final bool notifications;
  
  // ゲーム設定
  final bool autoSave;
  final int autoSaveInterval;
  final bool offlineIncome;
  final bool confirmPurchases;
  
  // プライバシー設定
  final bool analytics;
  final bool crashReporting;
  
  const AppSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.7,
    this.musicVolume = 0.5,
    this.theme = 'retro',
    this.language = 'ja',
    this.animations = true,
    this.notifications = true,
    this.autoSave = true,
    this.autoSaveInterval = 30,
    this.offlineIncome = true,
    this.confirmPurchases = true,
    this.analytics = false,
    this.crashReporting = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
    String? theme,
    String? language,
    bool? animations,
    bool? notifications,
    bool? autoSave,
    int? autoSaveInterval,
    bool? offlineIncome,
    bool? confirmPurchases,
    bool? analytics,
    bool? crashReporting,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      animations: animations ?? this.animations,
      notifications: notifications ?? this.notifications,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      offlineIncome: offlineIncome ?? this.offlineIncome,
      confirmPurchases: confirmPurchases ?? this.confirmPurchases,
      analytics: analytics ?? this.analytics,
      crashReporting: crashReporting ?? this.crashReporting,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.soundEnabled == soundEnabled &&
        other.musicEnabled == musicEnabled &&
        other.soundVolume == soundVolume &&
        other.musicVolume == musicVolume &&
        other.theme == theme &&
        other.language == language &&
        other.animations == animations &&
        other.notifications == notifications &&
        other.autoSave == autoSave &&
        other.autoSaveInterval == autoSaveInterval &&
        other.offlineIncome == offlineIncome &&
        other.confirmPurchases == confirmPurchases &&
        other.analytics == analytics &&
        other.crashReporting == crashReporting;
  }

  @override
  int get hashCode {
    return Object.hash(
      soundEnabled,
      musicEnabled,
      soundVolume,
      musicVolume,
      theme,
      language,
      animations,
      notifications,
      autoSave,
      autoSaveInterval,
      offlineIncome,
      confirmPurchases,
      analytics,
      crashReporting,
    );
  }
}