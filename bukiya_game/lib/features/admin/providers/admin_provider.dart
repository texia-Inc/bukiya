import 'package:flutter/material.dart';

import '../../../core/models/admin.dart';
import '../../../core/models/weapon.dart';
import '../../../core/models/crafting.dart' as crafting;
import '../../../core/models/monster.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/services/api_service.dart';

/// 管理画面プロバイダー
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService;
  
  // 認証状態
  AdminAccount? _currentAdmin;
  bool _isLoading = false;
  String? _errorMessage;
  
  // データ管理状態
  List<Weapon> _weapons = [];
  List<crafting.Material> _materials = [];
  List<Monster> _monsters = [];
  List<SystemSetting> _systemSettings = [];
  List<AdminActionLog> _actionLogs = [];
  
  // フィルター・検索状態
  AdminSearchFilter _weaponFilter = const AdminSearchFilter();
  AdminSearchFilter _materialFilter = const AdminSearchFilter();
  AdminSearchFilter _monsterFilter = const AdminSearchFilter();
  PaginationInfo? _weaponPagination;
  PaginationInfo? _materialPagination;
  PaginationInfo? _monsterPagination;
  
  // 選択状態
  final Set<String> _selectedWeaponIds = {};
  final Set<int> _selectedMaterialIds = {};
  final Set<String> _selectedMonsterIds = {};
  
  AdminProvider(ApiService apiService) : _adminService = AdminService(apiService);
  
  // ================== ゲッター ==================
  
  AdminAccount? get currentAdmin => _currentAdmin;
  bool get isAdminLoggedIn => _adminService.isAdminLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Weapon> get weapons => _weapons;
  List<crafting.Material> get materials => _materials;
  List<Monster> get monsters => _monsters;
  List<SystemSetting> get systemSettings => _systemSettings;
  List<AdminActionLog> get actionLogs => _actionLogs;
  
  AdminSearchFilter get weaponFilter => _weaponFilter;
  AdminSearchFilter get materialFilter => _materialFilter;
  AdminSearchFilter get monsterFilter => _monsterFilter;
  PaginationInfo? get weaponPagination => _weaponPagination;
  PaginationInfo? get materialPagination => _materialPagination;
  PaginationInfo? get monsterPagination => _monsterPagination;
  
  Set<String> get selectedWeaponIds => _selectedWeaponIds;
  Set<int> get selectedMaterialIds => _selectedMaterialIds;
  Set<String> get selectedMonsterIds => _selectedMonsterIds;
  
  bool get hasSelectedWeapons => _selectedWeaponIds.isNotEmpty;
  bool get hasSelectedMaterials => _selectedMaterialIds.isNotEmpty;
  bool get hasSelectedMonsters => _selectedMonsterIds.isNotEmpty;
  
  // 権限チェック
  bool hasPermission(AdminPermission permission) => 
      _adminService.hasPermission(permission);
  
  // ================== 認証管理 ==================
  
  /// 管理者ログイン
  Future<bool> adminLogin(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _adminService.adminLogin(username, password);
      if (success) {
        _currentAdmin = _adminService.currentAdmin;
        await loadInitialData();
      } else {
        _setError('ログインに失敗しました。ユーザー名またはパスワードが正しくありません。');
      }
      return success;
    } catch (e) {
      _setError('ログイン処理中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 管理者ログアウト
  Future<void> adminLogout() async {
    await _adminService.adminLogout();
    _currentAdmin = null;
    _clearAllData();
    notifyListeners();
  }
  
  /// 初期データ読み込み
  Future<void> loadInitialData() async {
    await Future.wait([
      loadWeapons(),
      loadMaterials(),
      loadMonsters(),
      loadSystemSettings(),
      loadActionLogs(),
    ]);
  }
  
  // ================== 武器管理 ==================
  
  /// 武器一覧読み込み
  Future<void> loadWeapons({AdminSearchFilter? filter}) async {
    if (!hasPermission(AdminPermission.weaponRead)) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final searchFilter = filter ?? _weaponFilter;
      final response = await _adminService.getWeapons(filter: searchFilter);
      
      if (response.success && response.data != null) {
        _weapons = response.data!;
        _weaponPagination = response.pagination;
        _weaponFilter = searchFilter;
        _selectedWeaponIds.clear();
      } else {
        _setError(response.message ?? '武器データの読み込みに失敗しました');
      }
    } catch (e) {
      _setError('武器データの読み込み中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 武器作成
  Future<bool> createWeapon(Map<String, dynamic> weaponData) async {
    if (!hasPermission(AdminPermission.weaponCreate)) {
      _setError('武器作成の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.createWeapon(weaponData);
      
      if (response.success) {
        await loadWeapons(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? '武器の作成に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('武器作成中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 武器更新
  Future<bool> updateWeapon(String weaponId, Map<String, dynamic> weaponData) async {
    if (!hasPermission(AdminPermission.weaponEdit)) {
      _setError('武器編集の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.updateWeapon(weaponId, weaponData);
      
      if (response.success) {
        await loadWeapons(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? '武器の更新に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('武器更新中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 武器削除
  Future<bool> deleteWeapon(String weaponId) async {
    if (!hasPermission(AdminPermission.weaponDelete)) {
      _setError('武器削除の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.deleteWeapon(weaponId);
      
      if (response.success) {
        await loadWeapons(); // リスト更新
        _selectedWeaponIds.remove(weaponId);
        return true;
      } else {
        _setError(response.message ?? '武器の削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('武器削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 武器バルク削除
  Future<bool> deleteSelectedWeapons() async {
    if (_selectedWeaponIds.isEmpty) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      int successCount = 0;
      for (final weaponId in _selectedWeaponIds.toList()) {
        final response = await _adminService.deleteWeapon(weaponId);
        if (response.success) {
          successCount++;
        }
      }
      
      await loadWeapons(); // リスト更新
      _selectedWeaponIds.clear();
      
      if (successCount > 0) {
        return true;
      } else {
        _setError('選択された武器の削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('バルク削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ================== 素材管理 ==================
  
  /// 素材一覧読み込み
  Future<void> loadMaterials({AdminSearchFilter? filter}) async {
    if (!hasPermission(AdminPermission.materialRead)) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final searchFilter = filter ?? _materialFilter;
      final response = await _adminService.getMaterials(filter: searchFilter);
      
      if (response.success && response.data != null) {
        _materials = response.data!;
        _materialPagination = response.pagination;
        _materialFilter = searchFilter;
        _selectedMaterialIds.clear();
      } else {
        _setError(response.message ?? '素材データの読み込みに失敗しました');
      }
    } catch (e) {
      _setError('素材データの読み込み中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 素材作成
  Future<bool> createMaterial(Map<String, dynamic> materialData) async {
    if (!hasPermission(AdminPermission.materialCreate)) {
      _setError('素材作成の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.createMaterial(materialData);
      
      if (response.success) {
        await loadMaterials(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? '素材の作成に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('素材作成中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 素材更新
  Future<bool> updateMaterial(String materialId, Map<String, dynamic> materialData) async {
    if (!hasPermission(AdminPermission.materialEdit)) {
      _setError('素材編集の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.updateMaterial(materialId, materialData);
      
      if (response.success) {
        await loadMaterials(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? '素材の更新に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('素材更新中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 素材削除
  Future<bool> deleteMaterial(String materialId) async {
    if (!hasPermission(AdminPermission.materialDelete)) {
      _setError('素材削除の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.deleteMaterial(materialId);
      
      if (response.success) {
        await loadMaterials(); // リスト更新
        _selectedMaterialIds.remove(materialId);
        return true;
      } else {
        _setError(response.message ?? '素材の削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('素材削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 素材バルク削除
  Future<bool> deleteSelectedMaterials() async {
    if (_selectedMaterialIds.isEmpty) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      int successCount = 0;
      for (final materialId in _selectedMaterialIds.toList()) {
        final response = await _adminService.deleteMaterial(materialId.toString());
        if (response.success) {
          successCount++;
        }
      }
      
      await loadMaterials(); // リスト更新
      _selectedMaterialIds.clear();
      
      if (successCount > 0) {
        return true;
      } else {
        _setError('選択された素材の削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('バルク削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  
  // ================== モンスター管理 ==================
  
  /// モンスター一覧読み込み
  Future<void> loadMonsters({AdminSearchFilter? filter}) async {
    if (!hasPermission(AdminPermission.weaponRead)) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final searchFilter = filter ?? _monsterFilter;
      final response = await _adminService.getMonsters(filter: searchFilter);
      
      if (response.success && response.data != null) {
        _monsters = response.data!;
        _monsterPagination = response.pagination;
        _monsterFilter = searchFilter;
        _selectedMonsterIds.clear();
      } else {
        _setError(response.message ?? 'モンスターデータの読み込みに失敗しました');
      }
    } catch (e) {
      _setError('モンスターデータの読み込み中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// モンスター作成
  Future<bool> createMonster(Map<String, dynamic> monsterData) async {
    if (!hasPermission(AdminPermission.weaponCreate)) {
      _setError('モンスター作成の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.createMonster(monsterData);
      
      if (response.success) {
        await loadMonsters(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? 'モンスターの作成に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('モンスター作成中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// モンスター更新
  Future<bool> updateMonster(String monsterId, Map<String, dynamic> monsterData) async {
    if (!hasPermission(AdminPermission.weaponEdit)) {
      _setError('モンスター編集の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.updateMonster(monsterId, monsterData);
      
      if (response.success) {
        await loadMonsters(); // リスト更新
        return true;
      } else {
        _setError(response.message ?? 'モンスターの更新に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('モンスター更新中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// モンスター削除
  Future<bool> deleteMonster(String monsterId) async {
    if (!hasPermission(AdminPermission.weaponDelete)) {
      _setError('モンスター削除の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _adminService.deleteMonster(monsterId);
      
      if (response.success) {
        await loadMonsters(); // リスト更新
        _selectedMonsterIds.remove(monsterId);
        return true;
      } else {
        _setError(response.message ?? 'モンスターの削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('モンスター削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// モンスターバルク削除
  Future<bool> deleteSelectedMonsters() async {
    if (_selectedMonsterIds.isEmpty) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      int successCount = 0;
      for (final monsterId in _selectedMonsterIds.toList()) {
        final response = await _adminService.deleteMonster(monsterId);
        if (response.success) {
          successCount++;
        }
      }
      
      await loadMonsters(); // リスト更新
      _selectedMonsterIds.clear();
      
      if (successCount > 0) {
        return true;
      } else {
        _setError('選択されたモンスターの削除に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('バルク削除中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// モンスター選択切り替え
  void toggleMonsterSelection(String monsterId) {
    if (_selectedMonsterIds.contains(monsterId)) {
      _selectedMonsterIds.remove(monsterId);
    } else {
      _selectedMonsterIds.add(monsterId);
    }
    notifyListeners();
  }
  
  /// 全モンスター選択切り替え
  void toggleAllMonstersSelection() {
    if (_selectedMonsterIds.length == _monsters.length) {
      _selectedMonsterIds.clear();
    } else {
      _selectedMonsterIds.addAll(_monsters.map((m) => m.id));
    }
    notifyListeners();
  }
  
  /// モンスターフィルター更新
  void updateMonsterFilter(AdminSearchFilter filter) {
    _monsterFilter = filter;
    loadMonsters(filter: filter);
  }
  
  // ================== システム設定管理 ==================
  
  /// システム設定読み込み
  Future<void> loadSystemSettings() async {
    if (!hasPermission(AdminPermission.systemConfig)) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _systemSettings = await _adminService.getSystemSettings();
    } catch (e) {
      _setError('システム設定の読み込み中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// システム設定更新
  Future<bool> updateSystemSetting(String key, dynamic value) async {
    if (!hasPermission(AdminPermission.systemConfig)) {
      _setError('システム設定変更の権限がありません');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _adminService.updateSystemSetting(key, value);
      
      if (success) {
        await loadSystemSettings(); // 設定を再読み込み
        return true;
      } else {
        _setError('システム設定の更新に失敗しました');
        return false;
      }
    } catch (e) {
      _setError('システム設定更新中にエラーが発生しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // ================== ログ管理 ==================
  
  /// アクションログ読み込み
  Future<void> loadActionLogs({
    int limit = 100,
    String? targetType,
    String? adminId,
  }) async {
    if (!hasPermission(AdminPermission.systemLogs)) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _actionLogs = await _adminService.getActionLogs(
        limit: limit,
        targetType: targetType,
        adminId: adminId,
      );
    } catch (e) {
      _setError('ログデータの読み込み中にエラーが発生しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ================== フィルター・検索管理 ==================
  
  /// 武器フィルター更新
  void updateWeaponFilter(AdminSearchFilter filter) {
    _weaponFilter = filter;
    loadWeapons(filter: filter);
  }
  
  /// 素材フィルター更新
  void updateMaterialFilter(AdminSearchFilter filter) {
    _materialFilter = filter;
    loadMaterials(filter: filter);
  }
  
  /// フィルターリセット
  void resetWeaponFilter() {
    updateWeaponFilter(const AdminSearchFilter());
  }
  
  void resetMaterialFilter() {
    updateMaterialFilter(const AdminSearchFilter());
  }
  
  // ================== 選択管理 ==================
  
  /// 武器選択/解除
  void toggleWeaponSelection(String weaponId) {
    if (_selectedWeaponIds.contains(weaponId)) {
      _selectedWeaponIds.remove(weaponId);
    } else {
      _selectedWeaponIds.add(weaponId);
    }
    notifyListeners();
  }
  
  /// 全武器選択/解除
  void toggleAllWeaponsSelection() {
    if (_selectedWeaponIds.length == _weapons.length) {
      _selectedWeaponIds.clear();
    } else {
      _selectedWeaponIds.addAll(_weapons.map((w) => w.id));
    }
    notifyListeners();
  }
  
  /// 武器選択クリア
  void clearWeaponSelection() {
    _selectedWeaponIds.clear();
    notifyListeners();
  }
  
  // ================== 素材選択管理 ==================
  
  /// 素材選択切り替え
  void toggleMaterialSelection(int materialId) {
    if (_selectedMaterialIds.contains(materialId)) {
      _selectedMaterialIds.remove(materialId);
    } else {
      _selectedMaterialIds.add(materialId);
    }
    notifyListeners();
  }
  
  /// 全素材選択/解除
  void toggleAllMaterialsSelection() {
    if (_selectedMaterialIds.length == _materials.length) {
      _selectedMaterialIds.clear();
    } else {
      _selectedMaterialIds.addAll(_materials.map((m) => m.id));
    }
    notifyListeners();
  }
  
  /// 素材選択クリア
  void clearMaterialSelection() {
    _selectedMaterialIds.clear();
    notifyListeners();
  }
  
  
  // ================== プライベートメソッド ==================
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  void _clearAllData() {
    _weapons.clear();
    _materials.clear();
    _monsters.clear();
    _systemSettings.clear();
    _actionLogs.clear();
    _selectedWeaponIds.clear();
    _selectedMaterialIds.clear();
    _selectedMonsterIds.clear();
    _weaponPagination = null;
    _materialPagination = null;
    _monsterPagination = null;
  }
}