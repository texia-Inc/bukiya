import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/weapon.dart';

class ShopProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Weapon> _weapons = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Weapon> get weapons => _weapons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 武器一覧を読み込み
  Future<void> loadWeapons() async {
    _setLoading(true);
    _clearError();

    try {
      _weapons = await _apiService.getWeapons();
      notifyListeners();
    } catch (e) {
      _setError('武器一覧の読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 武器を購入
  Future<bool> purchaseWeapon(String weaponId) async {
    try {
      await _apiService.purchaseWeapon(weaponId);
      return true;
    } catch (e) {
      _setError('武器の購入に失敗しました: $e');
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
