import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/weapon.dart';
import '../../../core/models/player.dart';
import '../../tutorial/providers/tutorial_provider.dart';

class ShopProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  TutorialProvider? _tutorialProvider;

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
      // より多くの武器を取得するため、limitを増やす
      _weapons = await _apiService.getWeapons(limit: 100);
      debugPrint('取得した武器数: ${_weapons.length}');
      for (var weapon in _weapons) {
        debugPrint('武器: ${weapon.name}, タイプ: ${weapon.weaponType}, レベル: ${weapon.requiredLevel}');
      }
      if (player != null) {
        _currentPlayer = player;
      }
      _applyFilters();
      debugPrint('フィルター後の武器数: ${_filteredWeapons.length}');
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

  // TutorialProviderを設定
  void setTutorialProvider(TutorialProvider tutorialProvider) {
    _tutorialProvider = tutorialProvider;
  }

  // 武器を購入
  Future<bool> purchaseWeapon(String weaponId, {String? weaponName, int? price}) async {
    try {
      await _apiService.purchaseWeapon(weaponId);
      
      // 武器購入実績を記録
      _tutorialProvider?.recordAction('weapon_purchase');
      
      // 購入成功を通知 (呼び出し側でフィードバック表示)
      debugPrint('武器購入成功: $weaponName (${price}G)');
      
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
      debugPrint('武器タイプフィルター: ${_currentFilters['weaponType']}');
      filtered = filtered.where((weapon) {
        debugPrint('武器 ${weapon.name} のタイプ: ${weapon.weaponType}');
        return weapon.weaponType == _currentFilters['weaponType'];
      }).toList();
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
