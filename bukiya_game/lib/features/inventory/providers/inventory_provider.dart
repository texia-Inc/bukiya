import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/inventory.dart';
import '../../../core/constants/app_constants.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 状態管理
  List<PlayerWeapon> _playerWeapons = [];
  List<InventoryPlayerMaterial> _playerMaterials = [];
  InventoryStats? _inventoryStats;
  bool _isLoading = false;
  bool _isWeaponsLoading = false;
  bool _isMaterialsLoading = false;
  String? _errorMessage;

  // フィルター・ソート状態
  String _weaponSortBy = 'name';
  String _materialSortBy = 'name';
  String? _weaponFilterRarity;
  String? _materialFilterRarity;
  String _weaponSearchQuery = '';
  String _materialSearchQuery = '';

  // Getters
  List<PlayerWeapon> get playerWeapons => _getFilteredWeapons();
  List<InventoryPlayerMaterial> get playerMaterials => _getFilteredMaterials();
  InventoryStats? get inventoryStats => _inventoryStats;
  bool get isLoading => _isLoading;
  bool get isWeaponsLoading => _isWeaponsLoading;
  bool get isMaterialsLoading => _isMaterialsLoading;
  String? get errorMessage => _errorMessage;

  // フィルター・ソート状態のGetters
  String get weaponSortBy => _weaponSortBy;
  String get materialSortBy => _materialSortBy;
  String? get weaponFilterRarity => _weaponFilterRarity;
  String? get materialFilterRarity => _materialFilterRarity;
  String get weaponSearchQuery => _weaponSearchQuery;
  String get materialSearchQuery => _materialSearchQuery;

  // 全インベントリデータを読み込み
  Future<void> loadInventory() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        loadPlayerWeapons(),
        loadPlayerMaterials(),
      ]);
      _updateInventoryStats();
    } catch (e) {
      _setError('インベントリの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // プレイヤー武器一覧を読み込み
  Future<void> loadPlayerWeapons() async {
    _isWeaponsLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/api/v1/weapons/player/inventory');
      
      if (response.data['success']) {
        _playerWeapons = (response.data['data'] as List)
            .map((json) => PlayerWeapon.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? '武器データの取得に失敗しました');
      }
    } catch (e) {
      _setError('武器データの読み込みに失敗しました: $e');
    } finally {
      _isWeaponsLoading = false;
      notifyListeners();
    }
  }

  // プレイヤー素材一覧を読み込み
  Future<void> loadPlayerMaterials() async {
    _isMaterialsLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/api/v1/materials/player/inventory');
      
      if (response.data['success']) {
        _playerMaterials = (response.data['data'] as List)
            .map((json) => InventoryPlayerMaterial.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? '素材データの取得に失敗しました');
      }
    } catch (e) {
      _setError('素材データの読み込みに失敗しました: $e');
    } finally {
      _isMaterialsLoading = false;
      notifyListeners();
    }
  }

  // 武器を売却
  Future<bool> sellWeapon(String weaponId) async {
    try {
      final response = await _apiService.dio.delete('/api/v1/weapons/player/$weaponId');
      
      if (response.data['success']) {
        // インベントリを再読み込み
        await loadPlayerWeapons();
        _updateInventoryStats();
        return true;
      } else {
        throw Exception(response.data['message'] ?? '武器の売却に失敗しました');
      }
    } catch (e) {
      _setError('武器の売却に失敗しました: $e');
      return false;
    }
  }

  // 武器をエンチャント
  Future<EnchantResult?> enchantWeapon(String weaponId) async {
    try {
      final response = await _apiService.dio.post('/api/v1/weapons/player/$weaponId/enchant');
      
      if (response.data['success']) {
        final result = EnchantResult.fromJson(response.data);
        // インベントリを再読み込み
        await loadPlayerWeapons();
        _updateInventoryStats();
        return result;
      } else {
        throw Exception(response.data['message'] ?? 'エンチャントに失敗しました');
      }
    } catch (e) {
      _setError('エンチャントに失敗しました: $e');
      return null;
    }
  }

  // 素材を売却
  Future<MaterialSellResult?> sellMaterial(int materialId, int quantity) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/materials/player/sell',
        data: {
          'material_id': materialId,
          'quantity': quantity,
        },
      );
      
      if (response.data['success']) {
        final result = MaterialSellResult.fromJson(response.data);
        // インベントリを再読み込み
        await loadPlayerMaterials();
        _updateInventoryStats();
        return result;
      } else {
        throw Exception(response.data['message'] ?? '素材の売却に失敗しました');
      }
    } catch (e) {
      _setError('素材の売却に失敗しました: $e');
      return null;
    }
  }

  // 武器フィルター・ソート設定
  void setWeaponSort(String sortBy) {
    _weaponSortBy = sortBy;
    notifyListeners();
  }

  void setWeaponRarityFilter(String? rarity) {
    _weaponFilterRarity = rarity;
    notifyListeners();
  }

  void setWeaponSearchQuery(String query) {
    _weaponSearchQuery = query;
    notifyListeners();
  }

  // 素材フィルター・ソート設定
  void setMaterialSort(String sortBy) {
    _materialSortBy = sortBy;
    notifyListeners();
  }

  void setMaterialRarityFilter(String? rarity) {
    _materialFilterRarity = rarity;
    notifyListeners();
  }

  void setMaterialSearchQuery(String query) {
    _materialSearchQuery = query;
    notifyListeners();
  }

  // フィルター・ソートをクリア
  void clearWeaponFilters() {
    _weaponSortBy = 'name';
    _weaponFilterRarity = null;
    _weaponSearchQuery = '';
    notifyListeners();
  }

  void clearMaterialFilters() {
    _materialSortBy = 'name';
    _materialFilterRarity = null;
    _materialSearchQuery = '';
    notifyListeners();
  }

  // フィルター済み武器リストを取得
  List<PlayerWeapon> _getFilteredWeapons() {
    var filtered = List<PlayerWeapon>.from(_playerWeapons);

    // 検索フィルター
    if (_weaponSearchQuery.isNotEmpty) {
      filtered = filtered.where((weapon) =>
          weapon.weaponMaster.name.toLowerCase().contains(_weaponSearchQuery.toLowerCase())
      ).toList();
    }

    // レアリティフィルター
    if (_weaponFilterRarity != null) {
      filtered = filtered.where((weapon) =>
          weapon.weaponMaster.rarity.toLowerCase() == _weaponFilterRarity!.toLowerCase()
      ).toList();
    }

    // ソート
    switch (_weaponSortBy) {
      case 'name':
        filtered.sort((a, b) => a.weaponMaster.name.compareTo(b.weaponMaster.name));
        break;
      case 'attack':
        filtered.sort((a, b) => b.totalAttack.compareTo(a.totalAttack));
        break;
      case 'enchant_level':
        filtered.sort((a, b) => b.enchantLevel.compareTo(a.enchantLevel));
        break;
      case 'sell_price':
        filtered.sort((a, b) => b.sellPrice.compareTo(a.sellPrice));
        break;
      case 'rarity':
        filtered.sort((a, b) => a.weaponMaster.rarity.compareTo(b.weaponMaster.rarity));
        break;
      case 'created_at':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  // フィルター済み素材リストを取得
  List<InventoryPlayerMaterial> _getFilteredMaterials() {
    var filtered = List<InventoryPlayerMaterial>.from(_playerMaterials);

    // 検索フィルター
    if (_materialSearchQuery.isNotEmpty) {
      filtered = filtered.where((material) =>
          material.material.name.toLowerCase().contains(_materialSearchQuery.toLowerCase())
      ).toList();
    }

    // レアリティフィルター
    if (_materialFilterRarity != null) {
      filtered = filtered.where((material) =>
          material.material.rarity.toLowerCase() == _materialFilterRarity!.toLowerCase()
      ).toList();
    }

    // ソート
    switch (_materialSortBy) {
      case 'name':
        filtered.sort((a, b) => a.material.name.compareTo(b.material.name));
        break;
      case 'quantity':
        filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'total_value':
        filtered.sort((a, b) => b.totalSellPrice.compareTo(a.totalSellPrice));
        break;
      case 'unit_price':
        filtered.sort((a, b) => b.sellPrice.compareTo(a.sellPrice));
        break;
      case 'rarity':
        filtered.sort((a, b) => a.material.rarity.compareTo(b.material.rarity));
        break;
    }

    return filtered;
  }

  // インベントリ統計を更新
  void _updateInventoryStats() {
    _inventoryStats = InventoryStats.fromInventory(
      weapons: _playerWeapons,
      materials: _playerMaterials,
    );
    notifyListeners();
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
