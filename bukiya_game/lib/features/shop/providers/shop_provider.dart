import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/weapon.dart';
import '../../../core/models/player.dart';

class ShopProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Weapon> _weapons = [];
  List<Weapon> _filteredWeapons = [];
  bool _isLoading = false;
  String? _errorMessage;
  Player? _currentPlayer;
  
  // フィルター状態
  Map<String, dynamic> _currentFilters = {
    'weaponType': 'all',
    'rarity': 'all',
    'sortBy': 'name',
    'sortAscending': true,
  };

  // Getters
  List<Weapon> get weapons => _filteredWeapons.isNotEmpty ? _filteredWeapons : _weapons;
  List<Weapon> get allWeapons => _weapons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get currentFilters => Map.from(_currentFilters);

  // 武器一覧を読み込み
  Future<void> loadWeapons({Player? player}) async {
    _setLoading(true);
    _clearError();

    try {
      _weapons = await _apiService.getWeapons();
      if (player != null) {
        _currentPlayer = player;
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _setError('武器一覧の読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // プレイヤー情報を更新
  void updatePlayer(Player player) {
    _currentPlayer = player;
    _applyFilters();
    notifyListeners();
  }

  // 武器を購入
  Future<bool> purchaseWeapon(String weaponId) async {
    try {
      await _apiService.purchaseWeapon(weaponId);
      
      // ミッション進捗を記録（他のプロバイダーが利用可能な場合）
      // 注意: 実際の実装では依存性注入やイベントバスを使用することを推奨
      
      return true;
    } catch (e) {
      _setError('武器の購入に失敗しました: $e');
      return false;
    }
  }

  // フィルターを更新
  void updateFilters(Map<String, dynamic> filters) {
    _currentFilters.addAll(filters);
    _applyFilters();
    notifyListeners();
  }

  // フィルターをリセット
  void resetFilters() {
    _currentFilters = {
      'weaponType': 'all',
      'rarity': 'all',
      'sortBy': 'name',
      'sortAscending': true,
    };
    _applyFilters();
    notifyListeners();
  }

  // フィルターを適用
  void _applyFilters() {
    if (_weapons.isEmpty) {
      _filteredWeapons = [];
      return;
    }

    List<Weapon> filtered = List.from(_weapons);

    // 武器タイプでフィルター
    if (_currentFilters['weaponType'] != 'all') {
      filtered = filtered.where((weapon) => 
        weapon.weaponType == _currentFilters['weaponType']).toList();
    }

    // レアリティでフィルター
    if (_currentFilters['rarity'] != 'all') {
      filtered = filtered.where((weapon) => 
        weapon.rarity == _currentFilters['rarity']).toList();
    }

    // プレイヤーレベルでフィルター（購入できない武器を除外）
    if (_currentPlayer != null) {
      filtered = filtered.where((weapon) => 
        _currentPlayer!.shopLevel >= weapon.requiredLevel).toList();
    }

    // ソート
    final sortBy = _currentFilters['sortBy'] as String;
    final ascending = _currentFilters['sortAscending'] as bool;

    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'attack':
          comparison = a.attack.compareTo(b.attack);
          break;
        case 'rarity':
          comparison = _getRarityOrder(a.rarity).compareTo(_getRarityOrder(b.rarity));
          break;
        case 'level':
          comparison = a.requiredLevel.compareTo(b.requiredLevel);
          break;
      }
      
      return ascending ? comparison : -comparison;
    });

    _filteredWeapons = filtered;
  }

  // レアリティの順序を数値で取得
  int _getRarityOrder(String rarity) {
    switch (rarity) {
      case 'common':
        return 1;
      case 'uncommon':
        return 2;
      case 'rare':
        return 3;
      case 'epic':
        return 4;
      case 'legendary':
        return 5;
      default:
        return 0;
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

}
