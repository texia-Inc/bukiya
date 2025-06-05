import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  String? _errorMessage;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 利用可能なテーマオプション
  static const List<String> availableThemes = ['retro', 'modern', 'dark'];
  
  // 利用可能な言語オプション
  static const Map<String, String> availableLanguages = {
    'ja': '日本語',
    'en': 'English',
  };

  SettingsProvider() {
    _loadSettings();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // 設定の読み込み
  Future<void> _loadSettings() async {
    try {
      _setLoading(true);
      _clearError();

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('設定の読み込みエラー: $e');
      _setError('設定の読み込みに失敗しました');
      // エラー時はデフォルト設定を使用
      _settings = const AppSettings();
    } finally {
      _setLoading(false);
    }
  }

  // 設定の保存
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('設定の保存エラー: $e');
      _setError('設定の保存に失敗しました');
    }
  }

  // 音声設定の更新
  Future<void> updateSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateMusicEnabled(bool enabled) async {
    _settings = _settings.copyWith(musicEnabled: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateSoundVolume(double volume) async {
    _settings = _settings.copyWith(soundVolume: volume);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateMusicVolume(double volume) async {
    _settings = _settings.copyWith(musicVolume: volume);
    notifyListeners();
    await _saveSettings();
  }

  // 表示設定の更新
  Future<void> updateTheme(String theme) async {
    if (availableThemes.contains(theme)) {
      _settings = _settings.copyWith(theme: theme);
      notifyListeners();
      await _saveSettings();
    }
  }

  Future<void> updateLanguage(String language) async {
    if (availableLanguages.containsKey(language)) {
      _settings = _settings.copyWith(language: language);
      notifyListeners();
      await _saveSettings();
    }
  }

  Future<void> updateAnimations(bool enabled) async {
    _settings = _settings.copyWith(animations: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateNotifications(bool enabled) async {
    _settings = _settings.copyWith(notifications: enabled);
    notifyListeners();
    await _saveSettings();
  }

  // ゲーム設定の更新
  Future<void> updateAutoSave(bool enabled) async {
    _settings = _settings.copyWith(autoSave: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateAutoSaveInterval(int interval) async {
    if (interval > 0) {
      _settings = _settings.copyWith(autoSaveInterval: interval);
      notifyListeners();
      await _saveSettings();
    }
  }

  Future<void> updateOfflineIncome(bool enabled) async {
    _settings = _settings.copyWith(offlineIncome: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateConfirmPurchases(bool enabled) async {
    _settings = _settings.copyWith(confirmPurchases: enabled);
    notifyListeners();
    await _saveSettings();
  }

  // プライバシー設定の更新
  Future<void> updateAnalytics(bool enabled) async {
    _settings = _settings.copyWith(analytics: enabled);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> updateCrashReporting(bool enabled) async {
    _settings = _settings.copyWith(crashReporting: enabled);
    notifyListeners();
    await _saveSettings();
  }

  // 設定のリセット
  Future<void> resetToDefault() async {
    try {
      _setLoading(true);
      _clearError();

      _settings = const AppSettings();
      notifyListeners();
      await _saveSettings();
    } catch (e) {
      debugPrint('設定のリセットエラー: $e');
      _setError('設定のリセットに失敗しました');
    } finally {
      _setLoading(false);
    }
  }

  // 設定のエクスポート（デバッグ用）
  String exportSettings() {
    return json.encode(_settings.toJson());
  }

  // 設定のインポート（デバッグ用）
  Future<void> importSettings(String settingsJson) async {
    try {
      _setLoading(true);
      _clearError();

      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      _settings = AppSettings.fromJson(settingsMap);
      notifyListeners();
      await _saveSettings();
    } catch (e) {
      debugPrint('設定のインポートエラー: $e');
      _setError('設定のインポートに失敗しました');
    } finally {
      _setLoading(false);
    }
  }
}