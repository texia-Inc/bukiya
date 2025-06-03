import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/mission.dart';
import 'package:bukiya_game/core/services/api_service.dart';
import 'package:bukiya_game/features/auth/providers/auth_provider.dart';

class MissionProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AuthProvider _authProvider;

  MissionProvider(this._apiService, this._authProvider);

  // ミッション状態
  List<Mission> _dailyMissions = [];
  List<Mission> _weeklyMissions = [];
  List<Mission> _achievements = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  // ゲッター
  List<Mission> get dailyMissions => _dailyMissions;
  List<Mission> get weeklyMissions => _weeklyMissions;
  List<Mission> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;

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
      final playerId = _authProvider.currentPlayer?.id;
      if (playerId == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get(
        '/missions/daily',
        queryParameters: {'player_id': playerId},
      );
      
      if (response.data['success']) {
        _dailyMissions = (response.data['data'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('デイリーミッションの取得に失敗しました: $e');
    }
  }

  // ウィークリーミッションを取得
  Future<void> fetchWeeklyMissions() async {
    try {
      final playerId = _authProvider.currentPlayer?.id;
      if (playerId == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get(
        '/missions/weekly',
        queryParameters: {'player_id': playerId},
      );
      
      if (response.data['success']) {
        _weeklyMissions = (response.data['data'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('ウィークリーミッションの取得に失敗しました: $e');
    }
  }

  // アチーブメントを取得
  Future<void> fetchAchievements() async {
    try {
      final playerId = _authProvider.currentPlayer?.id;
      if (playerId == null) {
        _setError('プレイヤー情報が取得できません。ログインしてください。');
        return;
      }

      final response = await _apiService.dio.get(
        '/missions/achievements',
        queryParameters: {'player_id': playerId},
      );
      
      if (response.data['success']) {
        _achievements = (response.data['data'] as List)
            .map((json) => Mission.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('アチーブメントの取得に失敗しました: $e');
    }
  }

  // ミッション進捗を取得
  Future<void> fetchMissionProgress() async {
    try {
      final response = await _apiService.dio.get('/missions/progress');
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
      final response = await _apiService.dio.post('/missions/$missionId/claim');
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
      final response = await _apiService.dio.post('/missions/progress', data: {
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

  // ミッション進捗を更新
  void _updateMissionProgress(Map<String, dynamic> progressData) {
    for (final mission in [..._dailyMissions, ..._weeklyMissions, ..._achievements]) {
      final progressKey = mission.id.toString();
      if (progressData.containsKey(progressKey)) {
        final progress = progressData[progressKey];
        final updatedMission = mission.copyWith(
          currentProgress: progress['current_progress'],
          isCompleted: progress['is_completed'],
          isClaimed: progress['is_claimed'],
          completedAt: progress['completed_at'] != null 
              ? DateTime.parse(progress['completed_at'])
              : null,
        );
        
        // リストを更新
        _replaceMission(updatedMission);
      }
    }
  }

  // ミッション状態を更新
  void _updateMissionStatus(int missionId, {
    int? currentProgress,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? completedAt,
  }) {
    final mission = _findMissionById(missionId);
    if (mission != null) {
      final updatedMission = mission.copyWith(
        currentProgress: currentProgress,
        isCompleted: isCompleted,
        isClaimed: isClaimed,
        completedAt: completedAt,
      );
      _replaceMission(updatedMission);
    }
  }

  // ミッションを置き換え
  void _replaceMission(Mission updatedMission) {
    switch (updatedMission.missionType) {
      case MissionType.daily:
        final index = _dailyMissions.indexWhere((m) => m.id == updatedMission.id);
        if (index != -1) {
          _dailyMissions[index] = updatedMission;
        }
        break;
      case MissionType.weekly:
        final index = _weeklyMissions.indexWhere((m) => m.id == updatedMission.id);
        if (index != -1) {
          _weeklyMissions[index] = updatedMission;
        }
        break;
      case MissionType.achievement:
        final index = _achievements.indexWhere((m) => m.id == updatedMission.id);
        if (index != -1) {
          _achievements[index] = updatedMission;
        }
        break;
    }
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

  @override
  void dispose() {
    super.dispose();
  }
}
