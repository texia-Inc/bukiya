import 'package:flutter/foundation.dart';

import '../../../core/services/idle_income_api_service.dart';
import '../../../core/models/player.dart';

/// 放置収入システムのプロバイダー
class IdleIncomeProvider extends ChangeNotifier {
  final IdleIncomeApiService _idleIncomeApiService;

  IdleIncomeProvider(this._idleIncomeApiService);

  // 状態管理
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _idleIncomeStatus;
  Map<String, dynamic>? _idleIncomeInfo;

  // ゲッター
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get idleIncomeStatus => _idleIncomeStatus;
  Map<String, dynamic>? get idleIncomeInfo => _idleIncomeInfo;

  // 利用可能な収入
  int get availableIncome => _idleIncomeStatus?['available_income'] ?? 0;
  int get elapsedMinutes => _idleIncomeStatus?['elapsed_minutes'] ?? 0;
  int get maxMinutes => _idleIncomeStatus?['max_minutes'] ?? 720;
  double get incomeRate => (_idleIncomeStatus?['income_rate'] ?? 10).toDouble();
  double get levelBonus => (_idleIncomeStatus?['level_bonus'] ?? 1.0).toDouble();
  double get multiplier => (_idleIncomeStatus?['multiplier'] ?? 1.0).toDouble();

  // 進捗率（0.0-1.0）
  double get progressRatio => maxMinutes > 0 ? elapsedMinutes / maxMinutes : 0.0;

  // 進捗率（パーセント）
  int get progressPercentage => (progressRatio * 100).floor();

  // 残り時間（分）
  int get remainingMinutes => maxMinutes - elapsedMinutes;

  // 残り時間表示
  String get remainingTimeDisplay {
    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;
    if (hours > 0) {
      return '${hours}時間${minutes}分';
    } else {
      return '${minutes}分';
    }
  }

  // 現在の1分あたり収入
  double get currentIncomePerMinute {
    return incomeRate * levelBonus * multiplier;
  }

  // プライベートメソッド
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// 放置収入状況を読み込み
  Future<void> loadIdleIncomeStatus() async {
    try {
      _setLoading(true);
      _clearError();

      _idleIncomeStatus = await _idleIncomeApiService.getIdleIncomeStatus();
      notifyListeners();
    } catch (e) {
      _setError('放置収入状況の取得に失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 放置収入詳細情報を読み込み
  Future<void> loadIdleIncomeInfo() async {
    try {
      _idleIncomeInfo = await _idleIncomeApiService.getIdleIncomeInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('放置収入詳細情報の取得に失敗: $e');
    }
  }

  /// 放置収入を回収
  Future<bool> collectIdleIncome() async {
    if (availableIncome <= 0) {
      _setError('回収可能な収入がありません');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final result = await _idleIncomeApiService.collectIdleIncome();
      
      // 成功時は状況を再読み込み
      await loadIdleIncomeStatus();
      
      return true;
    } catch (e) {
      _setError('放置収入の回収に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 放置収入をブースト（将来の機能）
  Future<bool> boostIdleIncome({required int durationHours}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _idleIncomeApiService.boostIdleIncome(
        durationHours: durationHours,
      );
      
      // 成功時は状況を再読み込み
      await loadIdleIncomeStatus();
      
      return true;
    } catch (e) {
      _setError('放置収入ブーストに失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// プレイヤーデータから放置収入を計算（オフライン時用）
  IdleIncomeCalculation calculateIdleIncomeFromPlayer(Player player) {
    return player.calculateIdleIncome();
  }

  /// 定期的な状況更新を開始
  void startPeriodicUpdates() {
    // TODO: 定期的なタイマー更新の実装
    // Timer.periodic(Duration(minutes: 1), (timer) {
    //   loadIdleIncomeStatus();
    // });
  }

  /// 定期的な状況更新を停止
  void stopPeriodicUpdates() {
    // TODO: タイマーの停止実装
  }

  @override
  void dispose() {
    stopPeriodicUpdates();
    super.dispose();
  }
}