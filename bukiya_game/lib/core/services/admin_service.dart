import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/admin.dart';
import '../models/weapon.dart';
import '../models/crafting.dart' as crafting;
import '../models/monster.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

/// 管理者サービス
/// 
/// CRUD操作、権限管理、ログ記録などの管理機能を提供
class AdminService {
  static const String _adminAccountsKey = 'admin_accounts';
  static const String _actionLogsKey = 'admin_action_logs';
  static const String _systemSettingsKey = 'system_settings';
  
  final ApiService _apiService;
  AdminAccount? _currentAdmin;
  
  AdminService(this._apiService);
  
  /// 現在の管理者アカウント
  AdminAccount? get currentAdmin => _currentAdmin;
  
  /// 管理者としてログイン中かどうか
  bool get isAdminLoggedIn => _currentAdmin != null;
  
  /// 管理者ログイン
  Future<bool> adminLogin(String username, String password) async {
    try {
      // 開発環境では固定の管理者アカウントを使用
      if (AppConstants.isDebugMode) {
        if ((username == 'admin' || username == 'admin@bukiya.game') && password == 'admin123') {
          _currentAdmin = AdminAccount(
            id: 'admin_1',
            username: 'admin',
            email: 'admin@bukiya.game',
            role: AdminRole.superAdmin,
            permissions: AdminPermission.values, // 全権限
            isActive: true,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            lastLoginAt: DateTime.now(),
          );
          
          await _logAction(
            operation: CrudOperation.read,
            targetType: 'admin_login',
            targetId: 'session',
            notes: 'Admin login successful',
          );
          
          return true;
        }
      }
      
      // 本番環境では API を使用
      final response = await _apiService.dio.post('/admin/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.data['success']) {
        _currentAdmin = AdminAccount.fromJson(response.data['data']);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Admin login error: $e');
      return false;
    }
  }
  
  /// 管理者ログアウト
  Future<void> adminLogout() async {
    if (_currentAdmin != null) {
      await _logAction(
        operation: CrudOperation.read,
        targetType: 'admin_logout',
        targetId: 'session',
        notes: 'Admin logout',
      );
    }
    
    _currentAdmin = null;
  }
  
  /// 権限チェック
  bool hasPermission(AdminPermission permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }
  
  /// 権限チェック（例外付き）
  void requirePermission(AdminPermission permission) {
    if (!hasPermission(permission)) {
      throw Exception('権限が不足しています: ${permission.name}');
    }
  }
  
  // ================== 武器管理 ==================
  
  /// 武器一覧取得
  Future<AdminApiResponse<List<Weapon>>> getWeapons({
    AdminSearchFilter? filter,
  }) async {
    requirePermission(AdminPermission.weaponRead);
    
    try {
      if (AppConstants.isDebugMode) {
        // モックデータを返す
        final weapons = await _getMockWeapons();
        return AdminApiResponse<List<Weapon>>(
          success: true,
          data: weapons,
          pagination: PaginationInfo(
            currentPage: filter?.page ?? 1,
            totalPages: (weapons.length / (filter?.itemsPerPage ?? 20)).ceil(),
            totalItems: weapons.length,
            itemsPerPage: filter?.itemsPerPage ?? 20,
            hasNext: false,
            hasPrevious: false,
          ),
        );
      }
      
      final response = await _apiService.dio.get('/admin/weapons', 
        queryParameters: filter?.toJson(),
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => Weapon.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Get weapons error: $e');
      return const AdminApiResponse<List<Weapon>>(
        success: false,
        message: '武器データの取得に失敗しました',
      );
    }
  }
  
  /// 武器作成
  Future<AdminApiResponse<Weapon>> createWeapon(Map<String, dynamic> weaponData) async {
    requirePermission(AdminPermission.weaponCreate);
    
    try {
      if (AppConstants.isDebugMode) {
        final weapon = Weapon.fromJson({
          ...weaponData,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        await _logAction(
          operation: CrudOperation.create,
          targetType: 'weapon',
          targetId: weapon.id,
          newData: weapon.toJson(),
          notes: '武器を作成しました: ${weapon.name}',
        );
        
        return AdminApiResponse<Weapon>(
          success: true,
          data: weapon,
          message: '武器を作成しました',
        );
      }
      
      final response = await _apiService.dio.post('/admin/weapons', data: weaponData);
      
      final weapon = Weapon.fromJson(response.data['data']);
      await _logAction(
        operation: CrudOperation.create,
        targetType: 'weapon',
        targetId: weapon.id,
        newData: weapon.toJson(),
        notes: '武器を作成しました: ${weapon.name}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => Weapon.fromJson(data),
      );
    } catch (e) {
      debugPrint('Create weapon error: $e');
      return const AdminApiResponse<Weapon>(
        success: false,
        message: '武器の作成に失敗しました',
      );
    }
  }
  
  /// 武器更新
  Future<AdminApiResponse<Weapon>> updateWeapon(String weaponId, Map<String, dynamic> weaponData) async {
    requirePermission(AdminPermission.weaponEdit);
    
    try {
      // 現在のデータを取得（ログ用）
      final currentWeapon = await _getWeaponById(weaponId);
      
      if (AppConstants.isDebugMode) {
        final updatedWeapon = Weapon.fromJson({
          ...weaponData,
          'id': weaponId,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        await _logAction(
          operation: CrudOperation.update,
          targetType: 'weapon',
          targetId: weaponId,
          oldData: currentWeapon?.toJson(),
          newData: updatedWeapon.toJson(),
          notes: '武器を更新しました: ${updatedWeapon.name}',
        );
        
        return AdminApiResponse<Weapon>(
          success: true,
          data: updatedWeapon,
          message: '武器を更新しました',
        );
      }
      
      final response = await _apiService.dio.put('/admin/weapons/$weaponId', data: weaponData);
      
      final weapon = Weapon.fromJson(response.data['data']);
      await _logAction(
        operation: CrudOperation.update,
        targetType: 'weapon',
        targetId: weaponId,
        oldData: currentWeapon?.toJson(),
        newData: weapon.toJson(),
        notes: '武器を更新しました: ${weapon.name}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => Weapon.fromJson(data),
      );
    } catch (e) {
      debugPrint('Update weapon error: $e');
      return const AdminApiResponse<Weapon>(
        success: false,
        message: '武器の更新に失敗しました',
      );
    }
  }
  
  /// 武器削除
  Future<AdminApiResponse<bool>> deleteWeapon(String weaponId) async {
    requirePermission(AdminPermission.weaponDelete);
    
    try {
      // 現在のデータを取得（ログ用）
      final currentWeapon = await _getWeaponById(weaponId);
      
      if (AppConstants.isDebugMode) {
        await _logAction(
          operation: CrudOperation.delete,
          targetType: 'weapon',
          targetId: weaponId,
          oldData: currentWeapon?.toJson(),
          notes: '武器を削除しました: ${currentWeapon?.name ?? weaponId}',
        );
        
        return const AdminApiResponse<bool>(
          success: true,
          data: true,
          message: '武器を削除しました',
        );
      }
      
      final response = await _apiService.dio.delete('/admin/weapons/$weaponId');
      
      await _logAction(
        operation: CrudOperation.delete,
        targetType: 'weapon',
        targetId: weaponId,
        oldData: currentWeapon?.toJson(),
        notes: '武器を削除しました: ${currentWeapon?.name ?? weaponId}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => data as bool,
      );
    } catch (e) {
      debugPrint('Delete weapon error: $e');
      return const AdminApiResponse<bool>(
        success: false,
        message: '武器の削除に失敗しました',
      );
    }
  }
  
  // ================== 素材管理 ==================
  
  /// 素材一覧取得
  Future<AdminApiResponse<List<crafting.Material>>> getMaterials({
    AdminSearchFilter? filter,
  }) async {
    requirePermission(AdminPermission.materialRead);
    
    try {
      if (AppConstants.isDebugMode) {
        final materials = await _getMockMaterials();
        return AdminApiResponse<List<crafting.Material>>(
          success: true,
          data: materials,
          pagination: PaginationInfo(
            currentPage: filter?.page ?? 1,
            totalPages: (materials.length / (filter?.itemsPerPage ?? 20)).ceil(),
            totalItems: materials.length,
            itemsPerPage: filter?.itemsPerPage ?? 20,
            hasNext: false,
            hasPrevious: false,
          ),
        );
      }
      
      final response = await _apiService.dio.get('/admin/materials', 
        queryParameters: filter?.toJson(),
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => crafting.Material.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Get materials error: $e');
      return const AdminApiResponse<List<crafting.Material>>(
        success: false,
        message: '素材データの取得に失敗しました',
      );
    }
  }
  
  /// 素材作成
  Future<AdminApiResponse<crafting.Material>> createMaterial(
    Map<String, dynamic> materialData,
  ) async {
    requirePermission(AdminPermission.materialCreate);
    
    try {
      if (AppConstants.isDebugMode) {
        // モックレスポンス
        final newMaterial = crafting.Material(
          id: DateTime.now().millisecondsSinceEpoch,
          name: materialData['name'],
          description: materialData['description'] ?? '',
          rarity: materialData['rarity'],
          sellPrice: materialData['sell_price'],
          isActive: materialData['is_active'] ?? true,
        );
        
        await _logAction(
          operation: CrudOperation.create,
          targetType: 'material',
          targetId: newMaterial.id.toString(),
          newData: materialData,
          notes: '素材を作成しました: ${newMaterial.name}',
        );
        
        return AdminApiResponse<crafting.Material>(
          success: true,
          data: newMaterial,
          message: '素材を作成しました',
        );
      }
      
      final response = await _apiService.post(
        '/admin/materials',
        data: materialData,
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => crafting.Material.fromJson(data),
      );
    } catch (e) {
      debugPrint('Create material error: $e');
      return const AdminApiResponse<crafting.Material>(
        success: false,
        message: '素材の作成に失敗しました',
      );
    }
  }
  
  /// 素材更新
  Future<AdminApiResponse<crafting.Material>> updateMaterial(
    String materialId,
    Map<String, dynamic> materialData,
  ) async {
    requirePermission(AdminPermission.materialEdit);
    
    try {
      if (AppConstants.isDebugMode) {
        // モックレスポンス
        final updatedMaterial = crafting.Material(
          id: int.parse(materialId),
          name: materialData['name'],
          description: materialData['description'] ?? '',
          rarity: materialData['rarity'],
          sellPrice: materialData['sell_price'],
          isActive: materialData['is_active'] ?? true,
        );
        
        await _logAction(
          operation: CrudOperation.update,
          targetType: 'material',
          targetId: materialId,
          newData: materialData,
          notes: '素材を更新しました: ${updatedMaterial.name}',
        );
        
        return AdminApiResponse<crafting.Material>(
          success: true,
          data: updatedMaterial,
          message: '素材を更新しました',
        );
      }
      
      final response = await _apiService.put(
        '/admin/materials/$materialId',
        data: materialData,
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => crafting.Material.fromJson(data),
      );
    } catch (e) {
      debugPrint('Update material error: $e');
      return const AdminApiResponse<crafting.Material>(
        success: false,
        message: '素材の更新に失敗しました',
      );
    }
  }
  
  /// 素材削除
  Future<AdminApiResponse<void>> deleteMaterial(String materialId) async {
    requirePermission(AdminPermission.materialDelete);
    
    try {
      if (AppConstants.isDebugMode) {
        await _logAction(
          operation: CrudOperation.delete,
          targetType: 'material',
          targetId: materialId,
          notes: '素材を削除しました: ID=$materialId',
        );
        
        return const AdminApiResponse<void>(
          success: true,
          message: '素材を削除しました',
        );
      }
      
      final response = await _apiService.delete('/admin/materials/$materialId');
      
      return AdminApiResponse.fromJson(response.data, (_) => null);
    } catch (e) {
      debugPrint('Delete material error: $e');
      return const AdminApiResponse<void>(
        success: false,
        message: '素材の削除に失敗しました',
      );
    }
  }
  
  // ================== モンスター管理 ==================
  
  /// モンスター一覧取得
  Future<AdminApiResponse<List<Monster>>> getMonsters({
    AdminSearchFilter? filter,
  }) async {
    requirePermission(AdminPermission.weaponRead);
    
    try {
      if (AppConstants.isDebugMode) {
        final monsters = await _getMockMonsters();
        return AdminApiResponse<List<Monster>>(
          success: true,
          data: monsters,
          pagination: PaginationInfo(
            currentPage: filter?.page ?? 1,
            totalPages: (monsters.length / (filter?.itemsPerPage ?? 20)).ceil(),
            totalItems: monsters.length,
            itemsPerPage: filter?.itemsPerPage ?? 20,
            hasNext: false,
            hasPrevious: false,
          ),
        );
      }
      
      final response = await _apiService.dio.get('/admin/monsters', 
        queryParameters: filter?.toJson(),
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => (data as List).map((e) => Monster.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Get monsters error: $e');
      return const AdminApiResponse<List<Monster>>(
        success: false,
        message: 'モンスターデータの取得に失敗しました',
      );
    }
  }
  
  /// モンスター作成
  Future<AdminApiResponse<Monster>> createMonster(Map<String, dynamic> monsterData) async {
    requirePermission(AdminPermission.weaponCreate);
    
    try {
      if (AppConstants.isDebugMode) {
        final monster = Monster.fromJson({
          ...monsterData,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        await _logAction(
          operation: CrudOperation.create,
          targetType: 'monster',
          targetId: monster.id,
          newData: monster.toJson(),
          notes: 'モンスターを作成しました: ${monster.name}',
        );
        
        return AdminApiResponse<Monster>(
          success: true,
          data: monster,
          message: 'モンスターを作成しました',
        );
      }
      
      final response = await _apiService.dio.post('/admin/monsters', data: monsterData);
      
      final monster = Monster.fromJson(response.data['data']);
      await _logAction(
        operation: CrudOperation.create,
        targetType: 'monster',
        targetId: monster.id,
        newData: monster.toJson(),
        notes: 'モンスターを作成しました: ${monster.name}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => Monster.fromJson(data),
      );
    } catch (e) {
      debugPrint('Create monster error: $e');
      return const AdminApiResponse<Monster>(
        success: false,
        message: 'モンスターの作成に失敗しました',
      );
    }
  }
  
  /// モンスター更新
  Future<AdminApiResponse<Monster>> updateMonster(String monsterId, Map<String, dynamic> monsterData) async {
    requirePermission(AdminPermission.weaponEdit);
    
    try {
      // 現在のデータを取得（ログ用）
      final currentMonster = await _getMonsterById(monsterId);
      
      if (AppConstants.isDebugMode) {
        final updatedMonster = Monster.fromJson({
          ...monsterData,
          'id': monsterId,
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        await _logAction(
          operation: CrudOperation.update,
          targetType: 'monster',
          targetId: monsterId,
          oldData: currentMonster?.toJson(),
          newData: updatedMonster.toJson(),
          notes: 'モンスターを更新しました: ${updatedMonster.name}',
        );
        
        return AdminApiResponse<Monster>(
          success: true,
          data: updatedMonster,
          message: 'モンスターを更新しました',
        );
      }
      
      final response = await _apiService.dio.put('/admin/monsters/$monsterId', data: monsterData);
      
      final monster = Monster.fromJson(response.data['data']);
      await _logAction(
        operation: CrudOperation.update,
        targetType: 'monster',
        targetId: monsterId,
        oldData: currentMonster?.toJson(),
        newData: monster.toJson(),
        notes: 'モンスターを更新しました: ${monster.name}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => Monster.fromJson(data),
      );
    } catch (e) {
      debugPrint('Update monster error: $e');
      return const AdminApiResponse<Monster>(
        success: false,
        message: 'モンスターの更新に失敗しました',
      );
    }
  }
  
  /// モンスター削除
  Future<AdminApiResponse<bool>> deleteMonster(String monsterId) async {
    requirePermission(AdminPermission.weaponDelete);
    
    try {
      // 現在のデータを取得（ログ用）
      final currentMonster = await _getMonsterById(monsterId);
      
      if (AppConstants.isDebugMode) {
        await _logAction(
          operation: CrudOperation.delete,
          targetType: 'monster',
          targetId: monsterId,
          oldData: currentMonster?.toJson(),
          notes: 'モンスターを削除しました: ${currentMonster?.name ?? monsterId}',
        );
        
        return const AdminApiResponse<bool>(
          success: true,
          data: true,
          message: 'モンスターを削除しました',
        );
      }
      
      final response = await _apiService.dio.delete('/admin/monsters/$monsterId');
      
      await _logAction(
        operation: CrudOperation.delete,
        targetType: 'monster',
        targetId: monsterId,
        oldData: currentMonster?.toJson(),
        notes: 'モンスターを削除しました: ${currentMonster?.name ?? monsterId}',
      );
      
      return AdminApiResponse.fromJson(
        response.data,
        (data) => data as bool,
      );
    } catch (e) {
      debugPrint('Delete monster error: $e');
      return const AdminApiResponse<bool>(
        success: false,
        message: 'モンスターの削除に失敗しました',
      );
    }
  }
  
  // ================== システム設定 ==================
  
  /// システム設定取得
  Future<List<SystemSetting>> getSystemSettings() async {
    requirePermission(AdminPermission.systemConfig);
    
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final settingsData = box.get(_systemSettingsKey, defaultValue: <String, dynamic>{});
      
      // デフォルト設定
      final defaultSettings = _getDefaultSystemSettings();
      
      return defaultSettings.map((setting) {
        final savedValue = settingsData[setting.key];
        return setting.copyWith(value: savedValue ?? setting.defaultValue);
      }).toList();
    } catch (e) {
      debugPrint('Get system settings error: $e');
      return [];
    }
  }
  
  /// システム設定更新
  Future<bool> updateSystemSetting(String key, dynamic value) async {
    requirePermission(AdminPermission.systemConfig);
    
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final settingsData = Map<String, dynamic>.from(
        box.get(_systemSettingsKey, defaultValue: <String, dynamic>{}),
      );
      
      final oldValue = settingsData[key];
      settingsData[key] = value;
      
      await box.put(_systemSettingsKey, settingsData);
      
      await _logAction(
        operation: CrudOperation.update,
        targetType: 'system_setting',
        targetId: key,
        oldData: {'value': oldValue},
        newData: {'value': value},
        notes: 'システム設定を更新しました: $key',
      );
      
      return true;
    } catch (e) {
      debugPrint('Update system setting error: $e');
      return false;
    }
  }
  
  // ================== ログ管理 ==================
  
  /// アクションログ記録
  Future<void> _logAction({
    required CrudOperation operation,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? notes,
  }) async {
    if (_currentAdmin == null) return;
    
    try {
      final log = AdminActionLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        adminId: _currentAdmin!.id,
        adminUsername: _currentAdmin!.username,
        operation: operation,
        targetType: targetType,
        targetId: targetId,
        oldData: oldData,
        newData: newData,
        timestamp: DateTime.now(),
        notes: notes,
      );
      
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final logs = List<Map<String, dynamic>>.from(
        box.get(_actionLogsKey, defaultValue: <Map<String, dynamic>>[]),
      );
      
      logs.add(log.toJson());
      
      // 最新1000件のみ保持
      if (logs.length > 1000) {
        logs.removeRange(0, logs.length - 1000);
      }
      
      await box.put(_actionLogsKey, logs);
    } catch (e) {
      debugPrint('Log action error: $e');
    }
  }
  
  /// アクションログ取得
  Future<List<AdminActionLog>> getActionLogs({
    int limit = 100,
    String? targetType,
    String? adminId,
  }) async {
    requirePermission(AdminPermission.systemLogs);
    
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final logsData = List<Map<String, dynamic>>.from(
        box.get(_actionLogsKey, defaultValue: <Map<String, dynamic>>[]),
      );
      
      var logs = logsData
          .map((e) => AdminActionLog.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      
      // フィルタリング
      if (targetType != null) {
        logs = logs.where((log) => log.targetType == targetType).toList();
      }
      if (adminId != null) {
        logs = logs.where((log) => log.adminId == adminId).toList();
      }
      
      // 最新順にソート
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // 件数制限
      if (logs.length > limit) {
        logs = logs.take(limit).toList();
      }
      
      return logs;
    } catch (e) {
      debugPrint('Get action logs error: $e');
      return [];
    }
  }
  
  // ================== プライベートメソッド ==================
  
  /// 武器IDで武器を取得
  Future<Weapon?> _getWeaponById(String weaponId) async {
    try {
      // 実装は省略（APIまたはローカルストレージから取得）
      return null;
    } catch (e) {
      return null;
    }
  }

  /// モンスターIDでモンスターを取得
  Future<Monster?> _getMonsterById(String monsterId) async {
    try {
      // 実装は省略（APIまたはローカルストレージから取得）
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// モック武器データ生成
  Future<List<Weapon>> _getMockWeapons() async {
    final now = DateTime.now();
    return [
      Weapon(
        id: '1',
        name: '鉄の剣',
        description: '基本的な鉄製の剣',
        weaponType: 'sword',
        attack: 10,
        requiredLevel: 1,
        rarity: 'common',
        price: 100,
        createdAt: now,
        updatedAt: now,
      ),
      Weapon(
        id: '2',
        name: '鋼の斧',
        description: '頑丈な鋼でできた斧',
        weaponType: 'axe',
        attack: 15,
        requiredLevel: 3,
        rarity: 'uncommon',
        price: 250,
        createdAt: now,
        updatedAt: now,
      ),
      // 他のモックデータ...
    ];
  }
  
  /// モック素材データ生成
  Future<List<crafting.Material>> _getMockMaterials() async {
    return [
      crafting.Material(
        id: 1,
        name: '鉄鉱石',
        description: '一般的な鉄鉱石',
        rarity: 'common',
        sellPrice: 10,
        isActive: true,
      ),
      crafting.Material(
        id: 2,
        name: '魔法の水晶',
        description: '魔力を宿した水晶',
        rarity: 'rare',
        sellPrice: 100,
        isActive: true,
      ),
      // 他のモックデータ...
    ];
  }

  /// モックモンスターデータ生成
  Future<List<Monster>> _getMockMonsters() async {
    final now = DateTime.now();
    return [
      Monster(
        id: '1',
        name: 'スライム',
        description: '基本的なスライムモンスター',
        monsterType: MonsterType.normal,
        rarity: 'common',
        hp: 50,
        attack: 8,
        defense: 5,
        speed: 10,
        level: 1,
        expReward: 10,
        goldReward: 5,
        skills: ['体当たり'],
        habitat: MonsterHabitat.forest,
        isBoss: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Monster(
        id: '2',
        name: 'ゴブリン',
        description: '小型の戦士モンスター',
        monsterType: MonsterType.humanoid,
        rarity: 'common',
        hp: 80,
        attack: 15,
        defense: 8,
        speed: 15,
        level: 3,
        expReward: 25,
        goldReward: 12,
        skills: ['剣撃', '回避'],
        dropItems: {'iron_ore': 20, 'leather': 15},
        habitat: MonsterHabitat.cave,
        isBoss: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Monster(
        id: '3',
        name: 'ドラゴン',
        description: '強力な龍族のボスモンスター',
        monsterType: MonsterType.dragon,
        rarity: 'legendary',
        hp: 1000,
        attack: 100,
        defense: 80,
        speed: 50,
        level: 50,
        expReward: 1000,
        goldReward: 500,
        skills: ['火炎ブレス', '咆哮', '翼撃'],
        dropItems: {'dragon_scale': 100, 'dragon_fang': 80, 'rare_gem': 50},
        habitat: MonsterHabitat.mountain,
        isBoss: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Monster(
        id: '4',
        name: 'アンデッドナイト',
        description: '不死の騎士',
        monsterType: MonsterType.undead,
        rarity: 'epic',
        hp: 300,
        attack: 60,
        defense: 70,
        speed: 25,
        level: 25,
        expReward: 200,
        goldReward: 100,
        skills: ['暗黒剣', '生命吸収', '呪い'],
        dropItems: {'cursed_metal': 30, 'bone_fragment': 40},
        habitat: MonsterHabitat.dungeon,
        isBoss: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Monster(
        id: '5',
        name: 'ウォーターエレメンタル',
        description: '水の精霊',
        monsterType: MonsterType.elemental,
        rarity: 'rare',
        hp: 150,
        attack: 35,
        defense: 30,
        speed: 40,
        level: 15,
        expReward: 75,
        goldReward: 35,
        skills: ['水流攻撃', '治癒', '霧化'],
        dropItems: {'water_crystal': 25, 'pure_water': 50},
        habitat: MonsterHabitat.ocean,
        isBoss: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
  
  /// デフォルトシステム設定
  List<SystemSetting> _getDefaultSystemSettings() {
    return [
      const SystemSetting(
        key: 'game_version',
        label: 'ゲームバージョン',
        group: 'システム',
        type: AdminFieldType.text,
        value: '1.0.0',
        defaultValue: '1.0.0',
        description: '現在のゲームバージョン',
      ),
      const SystemSetting(
        key: 'maintenance_mode',
        label: 'メンテナンスモード',
        group: 'システム',
        type: AdminFieldType.checkbox,
        value: false,
        defaultValue: false,
        description: 'メンテナンスモードの有効/無効',
        requiresRestart: true,
      ),
      const SystemSetting(
        key: 'max_players',
        label: '最大プレイヤー数',
        group: 'ゲーム',
        type: AdminFieldType.number,
        value: 1000,
        defaultValue: 1000,
        description: '同時接続可能な最大プレイヤー数',
      ),
      const SystemSetting(
        key: 'default_gold',
        label: '初期ゴールド',
        group: 'ゲーム',
        type: AdminFieldType.number,
        value: 1000,
        defaultValue: 1000,
        description: '新規プレイヤーの初期ゴールド額',
      ),
      const SystemSetting(
        key: 'enchant_base_success_rate',
        label: 'エンチャント基本成功率',
        group: 'ゲームバランス',
        type: AdminFieldType.range,
        value: 0.8,
        defaultValue: 0.8,
        description: 'エンチャントの基本成功率（0.0-1.0）',
      ),
    ];
  }
}