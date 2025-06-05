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
      final rememberLogin = await _secureStorage.read(key: 'remember_login');
      
      if (token != null && !JwtDecoder.isExpired(token)) {
        // トークンが有効な場合、プレイヤー情報を取得
        try {
          await _loadPlayerProfile();
          _isAuthenticated = true;
          print('自動ログイン成功: ${_currentPlayer?.username}');
        } catch (e) {
          print('プレイヤー情報取得失敗: $e');
          // プレイヤー情報取得に失敗した場合、トークンを削除
          await logout();
        }
      } else {
        print('トークンが無効または期限切れ');
        // 「ログイン状態を保持」が無効な場合、完全にログアウト
        if (rememberLogin != 'true') {
          await logout();
        } else {
          // 保持設定がある場合、トークンのみクリア（ユーザー名などは保持）
          await _secureStorage.delete(key: AppConstants.tokenKey);
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      print('認証状態確認エラー: $e');
      _setError('認証状態の確認に失敗しました');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // ログイン
  Future<bool> login(String email, String password, {bool rememberLogin = true}) async {
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

      // ログイン状態保持設定を保存
      await _secureStorage.write(
        key: 'remember_login',
        value: rememberLogin.toString(),
      );

      // ユーザー情報を保存（自動入力用）
      if (rememberLogin) {
        await _secureStorage.write(key: 'saved_email', value: email);
        await _secureStorage.write(key: 'saved_username', value: response.username);
      }

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

  // 保存されたユーザー情報を取得
  Future<Map<String, String?>> getSavedUserInfo() async {
    final email = await _secureStorage.read(key: 'saved_email');
    final username = await _secureStorage.read(key: 'saved_username');
    final rememberLogin = await _secureStorage.read(key: 'remember_login');
    
    return {
      'email': email,
      'username': username,
      'remember_login': rememberLogin,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}
