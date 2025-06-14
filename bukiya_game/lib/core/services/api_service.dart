import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
          // 401エラーの場合、トークンリフレッシュを試行
          if (error.response?.statusCode == 401) {
            try {
              // トークンリフレッシュを試行
              final newToken = await refreshToken();
              if (newToken != null) {
                // 新しいトークンで元のリクエストをリトライ
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              debugPrint('トークンリフレッシュ失敗: $e');
            }
            
            // リフレッシュに失敗した場合、トークンをクリア
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
      debugPrint('Logout error: $e');
    }
  }

  // 汎用HTTPメソッド
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // プレイヤー関連
  Future<Player> getPlayerProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.playerProfile);
      // レスポンス構造に合わせて修正: data.player
      return Player.fromJson(response.data['data']['player']);
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
  Future<Map<String, dynamic>> procureWeapon(String weaponId) async {
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

  // トークンリフレッシュ（永続ログイン対応）
  Future<String?> refreshToken() async {
    try {
      // まずアクセストークンでリフレッシュを試行
      final currentToken = await _secureStorage.read(key: AppConstants.tokenKey);
      if (currentToken != null) {
        try {
          final response = await _dio.post('/auth/refresh', 
            options: Options(
              headers: {'Authorization': 'Bearer $currentToken'}
            )
          );

          if (response.data['success'] == true) {
            final newToken = response.data['data']['access_token'];
            await _secureStorage.write(key: AppConstants.tokenKey, value: newToken);
            return newToken;
          }
        } catch (e) {
          debugPrint('アクセストークンでのリフレッシュ失敗: $e');
        }
      }

      // アクセストークンでのリフレッシュが失敗した場合、リフレッシュトークンを使用
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final response = await _dio.post('/auth/refresh-with-token', 
            data: {'refresh_token': refreshToken}
          );

          if (response.data['success'] == true) {
            final newAccessToken = response.data['data']['access_token'];
            final newRefreshToken = response.data['data']['refresh_token'];
            
            // 新しいトークンを保存
            await _secureStorage.write(key: AppConstants.tokenKey, value: newAccessToken);
            if (newRefreshToken != null) {
              await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
            }
            
            debugPrint('リフレッシュトークンによる永続ログイン成功');
            return newAccessToken;
          }
        } catch (e) {
          debugPrint('リフレッシュトークンでのリフレッシュ失敗: $e');
          // リフレッシュトークンも無効な場合は削除
          await _secureStorage.delete(key: AppConstants.refreshTokenKey);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('トークンリフレッシュエラー: $e');
      return null;
    }
  }

  // リソースのクリーンアップ
  void dispose() {
    _dio.close();
  }
}
