// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      theme: json['theme'] as String? ?? 'retro',
      language: json['language'] as String? ?? 'ja',
      animations: json['animations'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: (json['autoSaveInterval'] as num?)?.toInt() ?? 30,
      offlineIncome: json['offlineIncome'] as bool? ?? true,
      confirmPurchases: json['confirmPurchases'] as bool? ?? true,
      analytics: json['analytics'] as bool? ?? false,
      crashReporting: json['crashReporting'] as bool? ?? false,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'soundEnabled': instance.soundEnabled,
      'musicEnabled': instance.musicEnabled,
      'soundVolume': instance.soundVolume,
      'musicVolume': instance.musicVolume,
      'theme': instance.theme,
      'language': instance.language,
      'animations': instance.animations,
      'notifications': instance.notifications,
      'autoSave': instance.autoSave,
      'autoSaveInterval': instance.autoSaveInterval,
      'offlineIncome': instance.offlineIncome,
      'confirmPurchases': instance.confirmPurchases,
      'analytics': instance.analytics,
      'crashReporting': instance.crashReporting,
    };
