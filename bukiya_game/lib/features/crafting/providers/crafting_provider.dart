import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';

class CraftingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // レシピ一覧を読み込み
  Future<void> loadRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: レシピAPIの実装後に更新
      _recipes = [];
      notifyListeners();
    } catch (e) {
      _setError('レシピの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 武器を合成
  Future<bool> craftWeapon(String recipeId) async {
    try {
      // TODO: 合成APIの実装後に更新
      return true;
    } catch (e) {
      _setError('武器の合成に失敗しました: $e');
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
