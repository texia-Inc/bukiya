import 'package:flutter/foundation.dart';
import 'package:bukiya_game/core/models/mission.dart';
import 'package:bukiya_game/core/services/api_service.dart';
import 'package:bukiya_game/core/services/mission_auto_progress_service.dart';
import 'package:bukiya_game/features/auth/providers/auth_provider.dart';

class MissionProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AuthProvider _authProvider;
  late final MissionAutoProgressService _autoProgressService;

  MissionProvider(this._apiService, this._authProvider) {
    _autoProgressService = MissionAutoProgressService(_apiService);
    _initializeAutoProgress();
  }

  // ミッション状態
  List<Mission> _dailyMissions = [];
  List<Mission> _weeklyMissions = [];
  List<Mission> _achievements = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;
  
  // 自動進行関連
  OfflineProgressResult? _lastOfflineProgress;
  bool _hasCheckedOfflineProgress = false;

  // ゲッター
  List<Mission> get dailyMissions => _dailyMissions;
  List<Mission> get weeklyMissions => _weeklyMissions;
  List<Mission> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  
  // 自動進行関連ゲッター
  OfflineProgressResult? get lastOfflineProgress => _lastOfflineProgress;
  bool get hasCheckedOfflineProgress => _hasCheckedOfflineProgress;
  Map<String, int> get sessionStats => _autoProgressService.getSessionStats();

  // 完了済みミッション数
  int get completedDailyCount => 
      _dailyMissions.where((m) => m.isCompleted).length;
  int get completedWeeklyCount => 
      _weeklyMissions.where((m) => m.isCompleted).length;
  int get completedAchievementCount => 
      _achievements.where((m) => m.isCompleted).length;

  // 受取可能な報酬があるかどうか
  bool get hasClaimableRewards => 
      _dailyMissions.any((m) => m.canClaimReward) ||
      _weeklyMissions.any((m) => m.canClaimReward) ||
      _achievements.any((m) => m.canClaimReward);

  // 受取可能な報酬数
  int get claimableRewardsCount =>
      _dailyMissions.where((m) => m.canClaimReward).length +
      _weeklyMissions.where((m) => m.canClaimReward).length +
      _achievements.where((m) => m.canClaimReward).length;

  // 自動進行システムを初期化
  Future<void> _initializeAutoProgress() async {
    await _autoProgressService.initialize();
    
    // オフライン進捗をチェック
    if (!_hasCheckedOfflineProgress) {
      await checkOfflineProgress();
    }
  }
  
  // オフライン進捗をチェック
  Future<void> checkOfflineProgress() async {
    try {
      _lastOfflineProgress = await _autoProgressService.calculateOfflineProgress();
      _hasCheckedOfflineProgress = true;
      
      if (_lastOfflineProgress != null && 
          _lastOfflineProgress!.offlineTime.inMinutes >= 5) {
        // 5分以上のオフライン時間がある場合は進捗を適用
        await _autoProgressService.applyOfflineProgress(_lastOfflineProgress!);
        
        // ミッション状態を再取得
        await fetchAllMissions();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('オフライン進捗チェックエラー: $e');
    }
  }

  // 全ミッションを取得
  Future<void> fetchAllMissions() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        fetchDailyMissions(),
        fetchWeeklyMissions(),
        fetchAchievements(),
      ]);
      _lastRefresh = DateTime.now();
    } catch (e) {
      _setError('ミッションの取得に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // デイリーミッションを取得
  Future<void> fetchDailyMissions() async {
    try {
      if (_authProvider.currentPlayer == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get('/api/v1/missions/daily');
      
      // バックエンドは MissionListResponse を直接返す
      if (response.data != null && response.data.containsKey('missions')) {
        _dailyMissions = (response.data['missions'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError('デイリーミッションの取得に失敗しました');
      }
    } catch (e) {
      _setError('デイリーミッションの取得に失敗しました: $e');
    }
  }

  // ウィークリーミッションを取得
  Future<void> fetchWeeklyMissions() async {
    try {
      if (_authProvider.currentPlayer == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get('/api/v1/missions/weekly');
      
      // バックエンドは MissionListResponse を直接返す
      if (response.data != null && response.data.containsKey('missions')) {
        _weeklyMissions = (response.data['missions'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError('ウィークリーミッションの取得に失敗しました');
      }
    } catch (e) {
      _setError('ウィークリーミッションの取得に失敗しました: $e');
    }
  }

  // アチーブメントを取得
  Future<void> fetchAchievements() async {
    try {
      if (_authProvider.currentPlayer == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get('/api/v1/missions/achievements');
      
      // バックエンドは MissionListResponse を直接返す
      if (response.data != null && response.data.containsKey('missions')) {
        _achievements = (response.data['missions'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      } else {
        _setError('アチーブメントの取得に失敗しました');
      }
    } catch (e) {
      _setError('アチーブメントの取得に失敗しました: $e');
      print('アチーブメント取得エラーの詳細: $e');
    }
  }

  // ミッション進捗を取得
  Future<void> fetchMissionProgress() async {
    try {
      final response = await _apiService.dio.get('/api/v1/missions/progress');
      if (response.data['success']) {
        final progressData = response.data['data'] as Map<String, dynamic>;
        
        // 各ミッションの進捗を更新
        _updateMissionProgress(progressData);
        notifyListeners();
      }
    } catch (e) {
      _setError('ミッション進捗の取得に失敗しました: $e');
    }
  }

  // 報酬を受け取る
  Future<bool> claimReward(int missionId) async {
    try {
      final response = await _apiService.dio.post('/api/v1/missions/$missionId/claim');
      if (response.data['success']) {
        // ミッション状態を更新
        _updateMissionStatus(missionId, isClaimed: true);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('報酬の受取に失敗しました: $e');
      return false;
    }
  }

  // 複数の報酬を一括受取
  Future<int> claimAllRewards() async {
    int claimedCount = 0;
    
    final claimableMissions = [
      ..._dailyMissions.where((m) => m.canClaimReward),
      ..._weeklyMissions.where((m) => m.canClaimReward),
      ..._achievements.where((m) => m.canClaimReward),
    ];

    for (final mission in claimableMissions) {
      if (await claimReward(mission.id)) {
        claimedCount++;
      }
    }

    return claimedCount;
  }

  // ミッション進捗を手動更新（アクション実行時に呼び出し）
  Future<void> updateProgress(String actionType, {
    int count = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.dio.post('/api/v1/missions/progress', data: {
        'action_type': actionType,
        'count': count,
        'metadata': metadata,
      });
      
      if (response.data['success']) {
        // 進捗が更新されたミッションを再取得
        await fetchMissionProgress();
      }
    } catch (e) {
      debugPrint('ミッション進捗更新エラー: $e');
    }
  }
  
  // プレイヤーアクションを記録（自動進行システム経由）
  Future<void> recordPlayerAction(String actionType, {
    int count = 1,
    Map<String, dynamic>? metadata,
  }) async {
    // 自動進行サービスにアクションを記録
    await _autoProgressService.recordAction(
      actionType, 
      count: count, 
      metadata: metadata,
    );
    
    // 即座にミッション進捗を取得
    await fetchMissionProgress();
    
    // アクティブ時間を更新
    await _autoProgressService.updateActiveTime();
    
    notifyListeners();
  }

  // 自動リフレッシュを開始
  void startAutoRefresh() {
    // 5分ごとに進捗を更新
    Future.delayed(const Duration(minutes: 5), () {
      if (!_isLoading) {
        fetchMissionProgress();
      }
      startAutoRefresh();
    });
  }

  // ミッション進捗を更新（新しいAPIではミッションデータを再取得）
  void _updateMissionProgress(Map<String, dynamic> progressData) {
    // 新しいAPIではミッション進捗はサーバー側で管理されるため、
    // ここでは再フェッチを行う
    fetchAllMissions();
  }

  // ミッション状態を更新（新しいAPIではサーバー側で管理）
  void _updateMissionStatus(int missionId, {
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? completedAt,
  }) {
    // 新しいAPIではミッション状態はサーバー側で管理されるため、
    // ここでは再フェッチを行う
    fetchAllMissions();
  }

  // IDでミッションを検索
  Mission? _findMissionById(int missionId) {
    for (final mission in [..._dailyMissions, ..._weeklyMissions, ..._achievements]) {
      if (mission.id == missionId) {
        return mission;
      }
    }
    return null;
  }

  // ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // エラーを設定
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // エラーをクリア
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // リフレッシュ
  Future<void> refresh() async {
    await fetchAllMissions();
  }

  // 期限切れミッションをクリア
  void clearExpiredMissions() {
    _dailyMissions.removeWhere((mission) => mission.isExpired);
    _weeklyMissions.removeWhere((mission) => mission.isExpired);
    notifyListeners();
  }

  // セッション統計をリセット
  Future<void> resetSessionStats() async {
    await _autoProgressService.resetSessionStats();
    notifyListeners();
  }
  
  // オフライン進捗状態をリセット
  void resetOfflineProgressCheck() {
    _hasCheckedOfflineProgress = false;
    _lastOfflineProgress = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoProgressService.dispose();
    super.dispose();
  }
}
