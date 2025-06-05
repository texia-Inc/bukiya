import 'package:flutter/foundation.dart';
import 'package:bukiya_game/core/models/enchantment.dart';
import 'package:bukiya_game/core/models/inventory.dart';
import 'package:bukiya_game/core/services/api_service.dart';
import '../services/enchantment_failure_service.dart';

class EnchantmentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // エンチャント関連データ
  List<EnchantmentType> _enchantmentTypes = [];
  List<EnchantmentMaterial> _materials = [];
  List<PlayerEnchantmentMaterial> _playerMaterials = [];
  List<EnchantmentLog> _enchantmentHistory = [];
  EnchantmentStats? _stats;

  // 選択された武器とエンチャント
  PlayerWeapon? _selectedWeapon;
  EnchantmentType? _selectedEnchantmentType;
  List<WeaponEnchantment> _weaponEnchantments = [];

  // 素材選択
  final Map<int, int> _selectedMaterials = {}; // materialId -> quantity
  bool _useProtection = false;

  // UI状態
  bool _isLoading = false;
  bool _isEnchanting = false;
  String? _errorMessage;
  EnchantmentResponse? _lastEnchantmentResult;
  EnchantmentFailureResult? _lastFailureResult;

  // Getters
  List<EnchantmentType> get enchantmentTypes => _enchantmentTypes;
  List<EnchantmentMaterial> get materials => _materials;
  List<PlayerEnchantmentMaterial> get playerMaterials => _playerMaterials;
  List<EnchantmentLog> get enchantmentHistory => _enchantmentHistory;
  EnchantmentStats? get stats => _stats;
  
  PlayerWeapon? get selectedWeapon => _selectedWeapon;
  EnchantmentType? get selectedEnchantmentType => _selectedEnchantmentType;
  List<WeaponEnchantment> get weaponEnchantments => _weaponEnchantments;
  
  Map<int, int> get selectedMaterials => _selectedMaterials;
  bool get useProtection => _useProtection;
  
  bool get isLoading => _isLoading;
  bool get isEnchanting => _isEnchanting;
  String? get errorMessage => _errorMessage;
  EnchantmentResponse? get lastEnchantmentResult => _lastEnchantmentResult;
  EnchantmentFailureResult? get lastFailureResult => _lastFailureResult;

  // エンチャント一覧を取得
  Future<void> loadEnchantmentData() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.dio.get('/api/v1/enchantments/');
      
      if (response.data['success']) {
        final data = EnchantmentListResponse.fromJson(response.data['data']);
        _enchantmentTypes = data.enchantmentTypes;
        _materials = data.materials;
        _playerMaterials = data.playerMaterials;
        _stats = data.stats;
        notifyListeners();
      } else {
        _setError('エンチャントデータの取得に失敗しました');
      }
    } catch (e) {
      _setError('エンチャントデータの取得中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 武器を選択
  void selectWeapon(PlayerWeapon weapon) {
    _selectedWeapon = weapon;
    _selectedEnchantmentType = null;
    _selectedMaterials.clear();
    _useProtection = false;
    _lastEnchantmentResult = null;
    loadWeaponEnchantments(weapon.id.toString());
    notifyListeners();
  }

  // 武器のエンチャント一覧を取得
  Future<void> loadWeaponEnchantments(String weaponId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/enchantments/weapon/$weaponId/enchantments');
      
      if (response.data['success']) {
        _weaponEnchantments = (response.data['data'] as List)
            .map((e) => WeaponEnchantment.fromJson(e))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('武器エンチャント取得エラー: $e');
    }
  }

  // エンチャントタイプを選択
  void selectEnchantmentType(EnchantmentType enchantmentType) {
    _selectedEnchantmentType = enchantmentType;
    _selectedMaterials.clear();
    _lastEnchantmentResult = null;
    notifyListeners();
  }

  // 素材を選択/選択解除
  void toggleMaterial(int materialId, int quantity) {
    if (_selectedMaterials.containsKey(materialId)) {
      _selectedMaterials.remove(materialId);
    } else {
      // プレイヤーの所持数をチェック
      final playerMaterial = _playerMaterials.firstWhere(
        (pm) => pm.materialId == materialId,
        orElse: () => PlayerEnchantmentMaterial(
          id: 0,
          playerId: 0,
          materialId: materialId,
          quantity: 0,
          createdAt: DateTime.now(),
        ),
      );
      
      if (playerMaterial.quantity >= quantity) {
        _selectedMaterials[materialId] = quantity;
      }
    }
    notifyListeners();
  }

  // 保護アイテム使用切り替え
  void toggleProtection() {
    _useProtection = !_useProtection;
    notifyListeners();
  }

  // エンチャント実行
  Future<bool> performEnchantment() async {
    if (_selectedWeapon == null || _selectedEnchantmentType == null) {
      _setError('武器とエンチャントタイプを選択してください');
      return false;
    }

    _setEnchanting(true);
    _clearError();

    try {
      // 使用素材のリストを作成
      List<Map<String, dynamic>>? useMaterials;
      if (_selectedMaterials.isNotEmpty) {
        useMaterials = _selectedMaterials.entries
            .map((entry) => {
                  'material_id': entry.key,
                  'quantity': entry.value,
                })
            .toList();
      }

      final request = EnchantmentRequest(
        weaponId: _selectedWeapon!.id,
        enchantmentTypeId: _selectedEnchantmentType!.id,
        useMaterials: useMaterials,
        useProtection: _useProtection,
      );

      final response = await _apiService.dio.post('/api/v1/enchantments/enchant', data: request.toJson());

      if (response.data['success']) {
        _lastEnchantmentResult = EnchantmentResponse.fromJson(response.data['data']);
        
        // 失敗時の詳細処理
        if (_lastEnchantmentResult!.result != EnchantmentResult.success) {
          await _processEnchantmentFailure();
        }
        
        // 関連データを再読み込み
        await Future.wait([
          loadEnchantmentData(),
          if (_selectedWeapon != null) loadWeaponEnchantments(_selectedWeapon!.id.toString()),
        ]);
        
        // 素材選択をリセット
        _selectedMaterials.clear();
        _useProtection = false;
        
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? 'エンチャントに失敗しました');
        return false;
      }
    } catch (e) {
      _setError('エンチャント中にエラーが発生しました: $e');
      return false;
    } finally {
      _setEnchanting(false);
    }
  }

  // エンチャント履歴を取得
  Future<void> loadEnchantmentHistory({int limit = 50, int offset = 0}) async {
    try {
      final response = await _apiService.dio.get('/api/v1/enchantments/history', queryParameters: {
        'limit': limit,
        'offset': offset,
      });

      if (response.data['success']) {
        if (offset == 0) {
          _enchantmentHistory = (response.data['data'] as List)
              .map((e) => EnchantmentLog.fromJson(e))
              .toList();
        } else {
          _enchantmentHistory.addAll(
            (response.data['data'] as List)
                .map((e) => EnchantmentLog.fromJson(e))
                .toList(),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('エンチャント履歴取得エラー: $e');
    }
  }

  // 現在の武器の特定エンチャントレベルを取得
  int getCurrentEnchantmentLevel(int enchantmentTypeId) {
    if (_selectedWeapon == null) return 0;
    
    final enchantment = _weaponEnchantments.firstWhere(
      (we) => we.enchantmentTypeId == enchantmentTypeId,
      orElse: () => WeaponEnchantment(
        id: 0,
        weaponId: 0,
        enchantmentTypeId: enchantmentTypeId,
        level: 0,
        successCount: 0,
        failureCount: 0,
        totalCost: 0,
        createdAt: DateTime.now(),
      ),
    );
    
    return enchantment.level;
  }

  // エンチャント可能かチェック
  bool canEnchant() {
    if (_selectedWeapon == null || _selectedEnchantmentType == null) {
      return false;
    }

    final currentLevel = getCurrentEnchantmentLevel(_selectedEnchantmentType!.id);
    return currentLevel < _selectedEnchantmentType!.maxLevel;
  }

  // エンチャントコストを計算
  int calculateEnchantmentCost() {
    if (_selectedWeapon == null || _selectedEnchantmentType == null) {
      return 0;
    }

    final currentLevel = getCurrentEnchantmentLevel(_selectedEnchantmentType!.id);
    final levelMultiplier = 1.5 * currentLevel;
    var baseCost = (_selectedEnchantmentType!.baseCost * levelMultiplier).round();

    // 素材によるコスト倍率を適用
    double costMultiplier = 1.0;
    for (final materialId in _selectedMaterials.keys) {
      final material = _materials.firstWhere(
        (m) => m.id == materialId,
        orElse: () => EnchantmentMaterial(
          id: 0,
          name: '',
          description: '',
          rarity: 'common',
          materialType: 'general',
          successRateBonus: 0.0,
          costMultiplier: 1.0,
          maxStack: 1,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
      costMultiplier *= material.costMultiplier;
    }

    return (baseCost * costMultiplier).round();
  }

  // エンチャント成功率を計算（同情ボーナス込み）
  double calculateSuccessRate() {
    if (_selectedWeapon == null || _selectedEnchantmentType == null) {
      return 0.0;
    }

    final currentLevel = getCurrentEnchantmentLevel(_selectedEnchantmentType!.id);
    final levelPenalty = currentLevel * 0.05; // レベルごとに5%減少
    var baseSuccessRate = _selectedEnchantmentType!.baseSuccessRate - levelPenalty;

    // 素材による成功率ボーナスを適用
    double successRateBonus = 0.0;
    for (final entry in _selectedMaterials.entries) {
      final materialId = entry.key;
      final quantity = entry.value;
      
      final material = _materials.firstWhere(
        (m) => m.id == materialId,
        orElse: () => EnchantmentMaterial(
          id: 0,
          name: '',
          description: '',
          rarity: 'common',
          materialType: 'general',
          successRateBonus: 0.0,
          costMultiplier: 1.0,
          maxStack: 1,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
      
      // エンチャントタイプと素材の効果タイプが一致するかチェック
      if (material.effectType == null || 
          material.effectType == _selectedEnchantmentType!.effectType) {
        successRateBonus += material.successRateBonus * quantity;
      }
    }

    final finalSuccessRate = (baseSuccessRate + successRateBonus).clamp(0.05, 0.95);
    return finalSuccessRate;
  }

  // 同情ボーナス込みの成功率を計算
  Future<double> calculateSuccessRateWithPity() async {
    final baseRate = calculateSuccessRate();
    
    if (_selectedEnchantmentType != null) {
      final pityBonus = await EnchantmentFailureService.getNextSuccessRateBonus(_selectedEnchantmentType!.id);
      return (baseRate + pityBonus).clamp(0.05, 0.99);
    }
    
    return baseRate;
  }

  // プレイヤーの素材所持数を取得
  int getPlayerMaterialQuantity(int materialId) {
    final playerMaterial = _playerMaterials.firstWhere(
      (pm) => pm.materialId == materialId,
      orElse: () => PlayerEnchantmentMaterial(
        id: 0,
        playerId: 0,
        materialId: materialId,
        quantity: 0,
        createdAt: DateTime.now(),
      ),
    );
    return playerMaterial.quantity;
  }

  // エラー処理
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // ローディング状態管理
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setEnchanting(bool enchanting) {
    _isEnchanting = enchanting;
    notifyListeners();
  }

  // 結果をクリア
  void clearLastResult() {
    _lastEnchantmentResult = null;
    _lastFailureResult = null;
    notifyListeners();
  }

  // エンチャント失敗時の詳細処理
  Future<void> _processEnchantmentFailure() async {
    if (_lastEnchantmentResult == null || _selectedWeapon == null || _selectedEnchantmentType == null) {
      return;
    }

    try {
      // 使用した素材を取得
      final usedMaterials = <EnchantmentMaterial>[];
      for (final materialId in _selectedMaterials.keys) {
        final material = _materials.firstWhere(
          (m) => m.id == materialId,
          orElse: () => EnchantmentMaterial(
            id: materialId,
            name: 'Unknown Material',
            description: '',
            rarity: 'common',
            materialType: 'general',
            successRateBonus: 0.0,
            costMultiplier: 1.0,
            maxStack: 1,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        usedMaterials.add(material);
      }

      // 失敗処理サービスを呼び出し
      _lastFailureResult = await EnchantmentFailureService.processFailure(
        enchantmentResult: _lastEnchantmentResult!,
        weapon: _selectedWeapon!,
        enchantmentType: _selectedEnchantmentType!,
        usedMaterials: usedMaterials,
        cost: calculateEnchantmentCost(),
        useProtection: _useProtection,
      );

      debugPrint('エンチャント失敗処理完了: ${_lastFailureResult?.message}');
    } catch (e) {
      debugPrint('エンチャント失敗処理エラー: $e');
    }
  }



  // 選択をリセット
  void resetSelection() {
    _selectedWeapon = null;
    _selectedEnchantmentType = null;
    _weaponEnchantments.clear();
    _selectedMaterials.clear();
    _useProtection = false;
    _lastEnchantmentResult = null;
    notifyListeners();
  }

  // エンチャント素材のゲッター（互換性のため）
  List<EnchantmentMaterial> get enchantmentMaterials => _materials;
  List<PlayerEnchantmentMaterial> get playerEnchantmentMaterials => _playerMaterials;

  // 選択された素材をクリア
  void clearSelectedMaterials() {
    _selectedMaterials.clear();
    notifyListeners();
  }

  // 素材を追加
  void addMaterial(int materialId) {
    final playerMaterial = _playerMaterials.firstWhere(
      (pm) => pm.materialId == materialId,
      orElse: () => PlayerEnchantmentMaterial(
        id: 0,
        playerId: 0,
        materialId: materialId,
        quantity: 0,
        createdAt: DateTime.now(),
      ),
    );
    
    if (playerMaterial.quantity > 0) {
      _selectedMaterials[materialId] = 1;
      notifyListeners();
    }
  }

  // 素材を削除
  void removeMaterial(int materialId) {
    _selectedMaterials.remove(materialId);
    notifyListeners();
  }

  // 素材ボーナスを計算
  double calculateMaterialBonus() {
    double bonus = 0.0;
    for (final entry in _selectedMaterials.entries) {
      final materialId = entry.key;
      final quantity = entry.value;
      
      final material = _materials.firstWhere(
        (m) => m.id == materialId,
        orElse: () => EnchantmentMaterial(
          id: 0,
          name: '',
          description: '',
          rarity: 'common',
          materialType: 'general',
          successRateBonus: 0.0,
          costMultiplier: 1.0,
          maxStack: 1,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
      
      bonus += material.successRateBonus * quantity;
    }
    return bonus;
  }

  // エンチャント実行可能かチェック
  bool canPerformEnchantment() {
    return canEnchant();
  }

  // 連続失敗回数を取得
  Future<int> getConsecutiveFailures() async {
    if (_selectedEnchantmentType == null) return 0;
    return await EnchantmentFailureService.getConsecutiveFailures(_selectedEnchantmentType!.id);
  }

  // 失敗履歴を取得
  Future<List<EnchantmentFailureLog>> getFailureHistory() async {
    return await EnchantmentFailureService.getFailureHistory();
  }
}
