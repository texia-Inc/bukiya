import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/player.dart';
import '../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Player? _currentPlayer;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Player? get currentPlayer => _currentPlayer;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 認証状態をチェック
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      
      if (token != null && !JwtDecoder.isExpired(token)) {
        // トークンが有効な場合、プレイヤー情報を取得
        await _loadPlayerProfile();
        _isAuthenticated = true;
      } else {
        // トークンが無効な場合、ログアウト処理
        await logout();
      }
    } catch (e) {
      _setError('認証状態の確認に失敗しました: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // ログイン
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _apiService.login(loginRequest);

      // トークンを保存
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response.accessToken,
      );

      // プレイヤー情報を作成（後でプロフィール取得）
      _currentPlayer = Player(
        id: response.playerId,
        username: response.username,
        email: email,
        gold: 1000,
        gems: 100,
        shopLevel: 1,
        experience: 0,
        reputation: 1,
        isActive: true,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('ログインに失敗しました: $e');
      _setLoading(false);
      return false;
    }
  }

  // 新規登録
  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final registerRequest = RegisterRequest(
        username: username,
        email: email,
        password: password,
      );
      final response = await _apiService.register(registerRequest);

      // トークンを保存
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response.accessToken,
      );

      // プレイヤー情報を作成（後でプロフィール取得）
      _currentPlayer = Player(
        id: response.playerId,
        username: response.username,
        email: email,
        gold: 1000,
        gems: 100,
        shopLevel: 1,
        experience: 0,
        reputation: 1,
        isActive: true,
        lastLogin: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('新規登録に失敗しました: $e');
      _setLoading(false);
      return false;
    }
  }

  // ログアウト
  Future<void> logout() async {
    _setLoading(true);

    try {
      // トークンを削除
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      await _secureStorage.delete(key: AppConstants.userIdKey);

      // 状態をリセット
      _currentPlayer = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('ログアウトに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // プレイヤー情報を更新
  Future<void> updatePlayer(Player updatedPlayer) async {
    _currentPlayer = updatedPlayer;
    notifyListeners();
  }

  // プレイヤープロフィールを読み込み
  Future<void> _loadPlayerProfile() async {
    try {
      final player = await _apiService.getPlayerProfile();
      _currentPlayer = player;
    } catch (e) {
      throw Exception('プレイヤー情報の取得に失敗しました: $e');
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

  // トークンを取得
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  // トークンの有効性をチェック
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
