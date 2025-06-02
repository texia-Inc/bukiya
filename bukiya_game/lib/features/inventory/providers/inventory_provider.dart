import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/weapon.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PlayerWeapon> _playerWeapons = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PlayerWeapon> get playerWeapons => _playerWeapons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // プレイヤー武器一覧を読み込み
  Future<void> loadPlayerWeapons() async {
    _setLoading(true);
    _clearError();

    try {
      _playerWeapons = await _apiService.getPlayerWeapons();
      notifyListeners();
    } catch (e) {
      _setError('インベントリの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 武器を売却
  Future<bool> sellWeapon(String playerWeaponId) async {
    try {
      await _apiService.sellWeapon(playerWeaponId);
      // インベントリを再読み込み
      await loadPlayerWeapons();
      return true;
    } catch (e) {
      _setError('武器の売却に失敗しました: $e');
      return false;
    }
  }

  // ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // エラーメッセージを設定
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // エラーメッセージをクリア
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
