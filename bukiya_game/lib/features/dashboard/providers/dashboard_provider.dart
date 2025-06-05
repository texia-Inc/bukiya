import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/player.dart';
import '../../../core/constants/app_constants.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  PlayerStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdateTime;

  // Getters
  PlayerStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  // ダッシュボードデータを読み込み
  Future<void> loadDashboardData() async {
    _setLoading(true);
    _clearError();

    try {
      // プレイヤー統計を取得
      _statistics = await _apiService.getPlayerStatistics();
      _lastUpdateTime = DateTime.now();
      
      notifyListeners();
    } catch (e) {
      _setError('ダッシュボードデータの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // オフライン収益を取得
  Future<int> getOfflineIncome() async {
    try {
      final response = await _apiService.getOfflineIncome();
      // idle/statusレスポンスからpending_incomeを取得
      return response['pending_income'] ?? 0;
    } catch (e) {
      print('オフライン収益の取得に失敗: $e');
      return 0;
    }
  }

  // オフライン収益を回収
  Future<bool> collectOfflineIncome() async {
    try {
      await _apiService.collectOfflineIncome();
      // データを再読み込み
      await loadDashboardData();
      return true;
    } catch (e) {
      _setError('オフライン収益の回収に失敗しました: $e');
      return false;
    }
  }

  // プレイヤー統計を更新
  void updateStatistics(PlayerStatistics newStatistics) {
    _statistics = newStatistics;
    _lastUpdateTime = DateTime.now();
    notifyListeners();
  }

  // データの自動更新が必要かチェック
  bool shouldAutoRefresh() {
    if (_lastUpdateTime == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(_lastUpdateTime!);
    
    // 5分以上経過していたら自動更新
    return difference.inMinutes >= 5;
  }

  // 自動更新を実行
  Future<void> autoRefreshIfNeeded() async {
    if (shouldAutoRefresh()) {
      await loadDashboardData();
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

  // リソースのクリーンアップ
  @override
  void dispose() {
    super.dispose();
  }
}
