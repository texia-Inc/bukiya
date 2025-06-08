import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/player.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/device_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceService _deviceService = DeviceService();

  Player? _currentPlayer;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _tokenCheckTimer;

  // Getters
  Player? get currentPlayer => _currentPlayer;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiService get apiService => _apiService;

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
          _startTokenCheckTimer(); // 認証成功時にタイマー開始
          print('自動ログイン成功: ${_currentPlayer?.username}');
        } catch (e) {
          print('プレイヤー情報取得失敗 (フォーマットエラーが修正されるまで認証状態は保持): $e');
          // 日付フォーマットエラーの場合は認証状態を保持
          _isAuthenticated = true;
          _startTokenCheckTimer();
        }
      } else {
        print('アクセストークンが無効または期限切れ - リフレッシュトークンを確認');
        
        // リフレッシュトークンで永続ログインを試行
        final refreshTokenExists = await _secureStorage.read(key: AppConstants.refreshTokenKey);
        if (refreshTokenExists != null) {
          try {
            final newToken = await _apiService.refreshToken();
            if (newToken != null) {
              // リフレッシュ成功 - プレイヤー情報を取得
              await _loadPlayerProfile();
              _isAuthenticated = true;
              _startTokenCheckTimer();
              print('リフレッシュトークンによる自動ログイン成功');
            } else {
              throw Exception('リフレッシュトークンが無効');
            }
          } catch (e) {
            print('リフレッシュトークンでの自動ログイン失敗: $e');
            // 「ログイン状態を保持」が無効な場合、完全にログアウト
            if (rememberLogin != 'true') {
              await logout();
            } else {
              // 保持設定がある場合、トークンのみクリア（ユーザー名などは保持）
              await _secureStorage.delete(key: AppConstants.tokenKey);
              _isAuthenticated = false;
            }
          }
        } else {
          // リフレッシュトークンもない場合 - ゲストログインを試行
          print('認証トークンがない - ゲストログインを試行');
          try {
            final guestLoginSuccess = await guestLogin();
            if (guestLoginSuccess) {
              print('ゲストログイン成功');
              return; // ゲストログイン成功なら終了
            }
          } catch (e) {
            print('ゲストログイン失敗: $e');
          }
          
          // ゲストログインも失敗した場合
          if (rememberLogin != 'true') {
            await logout();
          } else {
            await _secureStorage.delete(key: AppConstants.tokenKey);
            _isAuthenticated = false;
          }
        }
      }
    } catch (e) {
      print('認証状態確認エラー: $e');
      
      // 認証チェックエラーの場合もゲストログインを試行
      try {
        print('認証チェック失敗 - ゲストログインを試行');
        final guestLoginSuccess = await guestLogin();
        if (guestLoginSuccess) {
          print('ゲストログインで復旧成功');
          return;
        }
      } catch (guestError) {
        print('ゲストログインも失敗: $guestError');
      }
      
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

      // アクセストークンを保存
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response.accessToken,
      );

      // リフレッシュトークンを保存（永続ログイン用）
      if (response.refreshToken != null) {
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.refreshToken!,
        );
      }

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

      // APIからプレイヤー情報を取得
      try {
        await _loadPlayerProfile();
        _isAuthenticated = true;
        
        // 認証成功後、定期的なトークンチェックを開始
        _startTokenCheckTimer();
        
        debugPrint('ログイン成功: プレイヤー情報取得完了');
      } catch (profileError) {
        debugPrint('プレイヤー情報取得エラー: $profileError');
        // プレイヤー情報取得に失敗してもログイン状態は維持
        _isAuthenticated = true;
        _startTokenCheckTimer();
        
        // 後でプレイヤー情報を再取得
        _setError('プレイヤー情報の取得に失敗しました。画面を更新してください。');
      }

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

      // アクセストークンを保存
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: response.accessToken,
      );

      // リフレッシュトークンを保存（永続ログイン用）
      if (response.refreshToken != null) {
        await _secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: response.refreshToken!,
        );
      }

      // APIからプレイヤー情報を取得
      try {
        await _loadPlayerProfile();
        _isAuthenticated = true;
        
        // 認証成功後、定期的なトークンチェックを開始
        _startTokenCheckTimer();
        
        debugPrint('ログイン成功: プレイヤー情報取得完了');
      } catch (profileError) {
        debugPrint('プレイヤー情報取得エラー: $profileError');
        // プレイヤー情報取得に失敗してもログイン状態は維持
        _isAuthenticated = true;
        _startTokenCheckTimer();
        
        // 後でプレイヤー情報を再取得
        _setError('プレイヤー情報の取得に失敗しました。画面を更新してください。');
      }

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
      // タイマーを停止
      _stopTokenCheckTimer();
      
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
      debugPrint('プレイヤー情報を取得中...');
      final player = await _apiService.getPlayerProfile();
      _currentPlayer = player;
      notifyListeners(); // UI更新のために追加
      debugPrint('プレイヤー情報取得成功: ${player.username}, Gold: ${player.gold}, Level: ${player.shopLevel}');
    } catch (e, stackTrace) {
      debugPrint('プレイヤー情報取得失敗: $e');
      
      // 日付フォーマットエラーの場合はデバッグ情報のみ表示
      if (e.toString().contains('Invalid date format') || e.toString().contains('FormatException')) {
        debugPrint('日付フォーマットエラー検出 - カスタムパーサーで再試行が必要');
      }
      
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

  // トークンリフレッシュ
  Future<bool> refreshToken() async {
    try {
      final newToken = await _apiService.refreshToken();
      if (newToken != null) {
        print('トークンリフレッシュ成功');
        return true;
      }
      return false;
    } catch (e) {
      print('トークンリフレッシュ失敗: $e');
      return false;
    }
  }

  // トークンの有効期限をチェックし、必要に応じてリフレッシュ
  Future<bool> ensureTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      // トークンの残り時間を確認（30分以内ならリフレッシュ）
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiry = expirationDate.difference(now);

      if (timeUntilExpiry.inMinutes < 30) {
        print('トークンの有効期限が近いため、リフレッシュを実行');
        return await refreshToken();
      }

      return true;
    } catch (e) {
      print('トークン確認エラー: $e');
      return false;
    }
  }

  // ゲストログイン
  Future<bool> guestLogin() async {
    _setLoading(true);
    _clearError();

    try {
      final deviceId = await _deviceService.getDeviceId();
      final deviceInfo = await _deviceService.getDeviceInfo();

      final response = await _apiService.dio.post('/api/v1/auth/guest-login', data: {
        'device_id': deviceId,
        'device_info': deviceInfo,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // トークンを保存
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }

        // ゲストトークンとしてマーク
        await _secureStorage.write(
          key: AppConstants.guestTokenKey,
          value: 'true',
        );

        // APIからプレイヤー情報を取得
        try {
          await _loadPlayerProfile();
          _isAuthenticated = true;
          _startTokenCheckTimer();
          
          debugPrint('ゲストログイン成功: プレイヤー情報取得完了');
        } catch (profileError) {
          debugPrint('プレイヤー情報取得エラー: $profileError');
          // プレイヤー情報取得に失敗してもログイン状態は維持
          _isAuthenticated = true;
          _startTokenCheckTimer();
        }

        _setLoading(false);
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('ゲストログインに失敗しました: $e');
      _setLoading(false);
      return false;
    }
  }

  // デバイス認証ログイン
  Future<bool> deviceLogin() async {
    _setLoading(true);
    _clearError();

    try {
      final deviceId = await _deviceService.getDeviceId();
      final deviceInfo = await _deviceService.getDeviceInfo();

      final response = await _apiService.dio.post('/api/v1/auth/device-login', data: {
        'device_id': deviceId,
        'device_info': deviceInfo,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // トークンを保存
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }

        // プレイヤー情報を取得
        await _loadPlayerProfile();
        _isAuthenticated = true;
        _startTokenCheckTimer();

        _setLoading(false);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('デバイスログイン失敗: $e');
      _setLoading(false);
      return false;
    }
  }

  // ゲストアカウントを正規アカウントに連携
  Future<bool> linkGuestAccount(String username, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final deviceId = await _deviceService.getDeviceId();

      final response = await _apiService.dio.post('/auth/link-account', 
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
        queryParameters: {
          'device_id': deviceId,
        }
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // トークンを更新
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: data['access_token'],
        );
        
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refresh_token'],
          );
        }

        // ゲストフラグを削除
        await _secureStorage.delete(key: AppConstants.guestTokenKey);

        // プレイヤー情報を更新
        if (_currentPlayer != null) {
          _currentPlayer = _currentPlayer!.copyWith(
            username: data['username'],
            email: email,
          );
        }

        _setLoading(false);
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('アカウント連携に失敗しました: $e');
      _setLoading(false);
      return false;
    }
  }

  // ゲストアカウントかどうかを確認
  Future<bool> isGuestAccount() async {
    final guestToken = await _secureStorage.read(key: AppConstants.guestTokenKey);
    return guestToken == 'true';
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

  // 定期的なトークンチェックタイマーを開始
  void _startTokenCheckTimer() {
    _stopTokenCheckTimer(); // 既存のタイマーがあれば停止
    
    // 15分ごとにトークンの有効性をチェック
    _tokenCheckTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (_isAuthenticated) {
        await ensureTokenValid();
      } else {
        timer.cancel();
      }
    });
  }

  // トークンチェックタイマーを停止
  void _stopTokenCheckTimer() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
  }

  @override
  void dispose() {
    _stopTokenCheckTimer();
    super.dispose();
  }
}
