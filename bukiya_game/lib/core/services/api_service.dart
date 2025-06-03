import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../models/player.dart';
import '../models/weapon.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dioインスタンスへのアクセス
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // インターセプターを追加
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 認証が必要なエンドポイントにトークンを追加
          final token = await _secureStorage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401エラーの場合、トークンをクリアして再認証を促す
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: AppConstants.tokenKey);
          }
          handler.next(error);
        },
      ),
    );

    // ログ用インターセプター（デバッグ時のみ）
    if (AppConstants.isDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
  }

  // 認証関連
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'ログインに失敗しました');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '新規登録に失敗しました');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      // ログアウトエラーは無視（トークンは既にクリアされている）
      print('Logout error: $e');
    }
  }

  // プレイヤー関連
  Future<Player> getPlayerProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.playerProfile);
      return Player.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PlayerStatistics> getPlayerStatistics() async {
    try {
      final response = await _dio.get(ApiEndpoints.playerStatistics);
      return PlayerStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Player> updatePlayerGold(int amount) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.playerGold,
        data: {'amount': amount},
      );
      return Player.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Player> updatePlayerGems(int amount) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.playerGems,
        data: {'amount': amount},
      );
      return Player.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 武器関連
  Future<List<Weapon>> getWeapons({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? weaponType,
    String? rarity,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.weapons,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (weaponType != null) 'weapon_type': weaponType,
          if (rarity != null) 'rarity': rarity,
        },
      );
      final List<dynamic> weaponsJson = response.data['data'];
      return weaponsJson.map((json) => Weapon.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PlayerWeapon>> getPlayerWeapons() async {
    try {
      final response = await _dio.get(ApiEndpoints.playerWeapons);
      final List<dynamic> weaponsJson = response.data['data'];
      return weaponsJson.map((json) => PlayerWeapon.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<WeaponType>> getWeaponTypes() async {
    try {
      final response = await _dio.get(ApiEndpoints.weaponTypes);
      final List<dynamic> typesJson = response.data['data'];
      return typesJson.map((json) => WeaponType.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ショップ関連
  Future<Map<String, dynamic>> purchaseWeapon(String weaponId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.purchase,
        data: {'weapon_id': weaponId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sellWeapon(String playerWeaponId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sell,
        data: {'player_weapon_id': playerWeaponId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 放置システム関連
  Future<Map<String, dynamic>> getIdleStatus() async {
    try {
      final response = await _dio.get('/api/v1/idle/status');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> collectIdleIncome() async {
    try {
      final response = await _dio.post('/api/v1/idle/collect');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> purchaseIdleUpgrade(String upgradeId) async {
    try {
      final response = await _dio.post(
        '/api/v1/idle/upgrade',
        data: {'upgrade_id': upgradeId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> activateIdleBonus(String bonusId) async {
    try {
      final response = await _dio.post(
        '/api/v1/idle/activate-bonus',
        data: {'bonus_id': bonusId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 旧メソッド（後方互換性のため）
  Future<Map<String, dynamic>> getOfflineIncome() async {
    return await getIdleStatus();
  }

  Future<Map<String, dynamic>> collectOfflineIncome() async {
    return await collectIdleIncome();
  }

  // エラーハンドリング
  Exception _handleError(DioException error) {
    String message;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.networkErrorMessage;
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = AppConstants.authErrorMessage;
        } else if (statusCode == 422) {
          message = AppConstants.validationErrorMessage;
        } else if (statusCode != null && statusCode >= 500) {
          message = AppConstants.serverErrorMessage;
        } else {
          message = error.response?.data['message'] ?? AppConstants.unknownErrorMessage;
        }
        break;
      case DioExceptionType.cancel:
        message = 'リクエストがキャンセルされました';
        break;
      case DioExceptionType.unknown:
      default:
        message = AppConstants.networkErrorMessage;
        break;
    }

    return Exception(message);
  }

  // リソースのクリーンアップ
  void dispose() {
    _dio.close();
  }
}
