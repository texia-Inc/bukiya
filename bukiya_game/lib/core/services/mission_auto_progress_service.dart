import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';
import '../services/api_service.dart';

/// ミッション自動進行検知サービス
/// 
/// このサービスは以下の機能を提供します：
/// - プレイヤーアクションの自動検知
/// - オフライン時間中の進捗推定
/// - バックグラウンド進行の計算
/// - ミッション進捗の自動更新
class MissionAutoProgressService {
  static const String _lastActiveTimeKey = 'last_active_time';
  static const String _sessionActionsKey = 'session_actions';
  
  final ApiService _apiService;
  Timer? _progressCheckTimer;
  Timer? _sessionSaveTimer;
  
  // セッション中のアクション記録
  final Map<String, int> _sessionActions = {};
  
  // アクションタイプの定義
  static const Map<String, String> actionTypes = {
    'craft_weapon': 'craft_weapon',
    'sell_weapon': 'sell_weapon',
    'collect_material': 'collect_material',
    'dispatch_adventurer': 'dispatch_adventurer',
    'login': 'login',
    'earn_gold': 'earn_gold',
    'upgrade_shop': 'upgrade_shop',
    'enchant_weapon': 'enchant_weapon',
    'complete_quest': 'complete_quest',
    'buy_item': 'buy_item',
  };
  
  MissionAutoProgressService(this._apiService);
  
  /// サービスを初期化
  Future<void> initialize() async {
    await _loadSessionActions();
    _startProgressCheckTimer();
    _startSessionSaveTimer();
    
    // 最後のアクティブ時間を記録
    await _updateLastActiveTime();
  }
  
  /// サービスを停止
  void dispose() {
    _progressCheckTimer?.cancel();
    _sessionSaveTimer?.cancel();
  }
  
  /// プレイヤーアクションを記録
  Future<void> recordAction(String actionType, {
    int count = 1,
    Map<String, dynamic>? metadata,
  }) async {
    if (!actionTypes.containsKey(actionType)) {
      debugPrint('未知のアクションタイプ: $actionType');
      return;
    }
    
    // セッションアクションを更新
    _sessionActions[actionType] = (_sessionActions[actionType] ?? 0) + count;
    
    // ローカルに保存
    await _saveSessionActions();
    
    // ミッション進捗を即座に更新
    await _updateMissionProgress(actionType, count: count, metadata: metadata);
    
    debugPrint('アクション記録: $actionType x$count');
  }
  
  /// オフライン期間中の進捗を計算
  Future<OfflineProgressResult> calculateOfflineProgress() async {
    final lastActiveTime = await _getLastActiveTime();
    if (lastActiveTime == null) {
      return const OfflineProgressResult(
        offlineTime: Duration.zero,
        estimatedActions: {},
        goldEarned: 0,
        expGained: 0,
      );
    }
    
    final now = DateTime.now();
    final offlineTime = now.difference(lastActiveTime);
    
    // 最大8時間分のオフライン進捗を計算
    final maxOfflineHours = 8;
    final effectiveOfflineTime = offlineTime.inHours > maxOfflineHours
        ? Duration(hours: maxOfflineHours)
        : offlineTime;
    
    // アイドル収益率からアクション推定
    final estimatedActions = await _estimateOfflineActions(effectiveOfflineTime);
    
    // オフライン収益計算
    final goldEarned = await _calculateOfflineGold(effectiveOfflineTime);
    final expGained = (goldEarned * 0.05).round(); // ゴールドの5%を経験値として
    
    return OfflineProgressResult(
      offlineTime: effectiveOfflineTime,
      estimatedActions: estimatedActions,
      goldEarned: goldEarned,
      expGained: expGained,
    );
  }
  
  /// オフライン進捗をミッションに適用
  Future<void> applyOfflineProgress(OfflineProgressResult result) async {
    if (result.offlineTime.inMinutes < 5) {
      // 5分未満のオフライン時間は無視
      return;
    }
    
    // 推定されたアクションをミッション進捗に反映
    for (final entry in result.estimatedActions.entries) {
      if (entry.value > 0) {
        await _updateMissionProgress(entry.key, count: entry.value);
      }
    }
    
    // セッションアクションをリセット
    _sessionActions.clear();
    await _saveSessionActions();
    
    debugPrint('オフライン進捗適用: ${result.offlineTime.inMinutes}分間, アクション: ${result.estimatedActions}');
  }
  
  /// アクティブ時間を更新
  Future<void> updateActiveTime() async {
    await _updateLastActiveTime();
  }
  
  /// セッション統計を取得
  Map<String, int> getSessionStats() {
    return Map.from(_sessionActions);
  }
  
  /// セッション統計をリセット
  Future<void> resetSessionStats() async {
    _sessionActions.clear();
    await _saveSessionActions();
  }
  
  // プライベートメソッド
  
  /// 進捗チェックタイマーを開始
  void _startProgressCheckTimer() {
    _progressCheckTimer?.cancel();
    _progressCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateLastActiveTime();
    });
  }
  
  /// セッション保存タイマーを開始
  void _startSessionSaveTimer() {
    _sessionSaveTimer?.cancel();
    _sessionSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveSessionActions();
    });
  }
  
  /// ミッション進捗を更新
  Future<void> _updateMissionProgress(String actionType, {
    int count = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _apiService.dio.post('/missions/progress', data: {
        'action_type': actionType,
        'count': count,
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('ミッション進捗更新エラー: $e');
    }
  }
  
  /// オフライン中のアクションを推定
  Future<Map<String, int>> _estimateOfflineActions(Duration offlineTime) async {
    final estimatedActions = <String, int>{};
    
    try {
      // プレイヤーのアイドル設定から推定
      final response = await _apiService.dio.get('/idle/estimate-actions', 
        queryParameters: {
          'offline_minutes': offlineTime.inMinutes,
        });
      
      if (response.data['success']) {
        final data = response.data['data'] as Map<String, dynamic>;
        data.forEach((key, value) {
          if (actionTypes.containsKey(key) && value is int) {
            estimatedActions[key] = value;
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('オフラインアクション推定エラー (フォールバック使用): $e');
      }
      // APIが失敗した場合はローカル推定を使用
      estimatedActions.addAll(_fallbackEstimateActions(offlineTime));
    }
    
    return estimatedActions;
  }
  
  /// フォールバックのアクション推定
  Map<String, int> _fallbackEstimateActions(Duration offlineTime) {
    final hours = offlineTime.inHours.clamp(0, 8);
    
    return {
      'craft_weapon': (hours * 0.5).round(), // 1時間に0.5個の武器作成
      'sell_weapon': (hours * 0.3).round(),  // 1時間に0.3個の武器販売
      'collect_material': (hours * 2.0).round(), // 1時間に2個の素材収集
      'earn_gold': (hours * 100).round(), // 1時間に100ゴールド獲得
    };
  }
  
  /// オフライン中のゴールド収益を計算
  Future<int> _calculateOfflineGold(Duration offlineTime) async {
    try {
      final response = await _apiService.dio.get('/idle/calculate-offline-gold',
        queryParameters: {
          'offline_minutes': offlineTime.inMinutes,
        });
      
      if (response.data['success']) {
        return response.data['gold_earned'] ?? 0;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('オフラインゴールド計算エラー (フォールバック使用): $e');
      }
    }
    
    // フォールバック計算
    final hours = offlineTime.inHours.clamp(0, 8);
    return (hours * 50).round(); // 1時間に50ゴールド
  }
  
  /// 最後のアクティブ時間を取得
  Future<DateTime?> _getLastActiveTime() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final timestamp = box.get(_lastActiveTimeKey);
      
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      debugPrint('最後のアクティブ時間取得エラー: $e');
    }
    
    return null;
  }
  
  /// 最後のアクティブ時間を更新
  Future<void> _updateLastActiveTime() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_lastActiveTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('最後のアクティブ時間更新エラー: $e');
    }
  }
  
  /// セッションアクションを保存
  Future<void> _saveSessionActions() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put(_sessionActionsKey, _sessionActions);
    } catch (e) {
      debugPrint('セッションアクション保存エラー: $e');
    }
  }
  
  /// セッションアクションを読み込み
  Future<void> _loadSessionActions() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get(_sessionActionsKey);
      
      if (data != null && data is Map) {
        _sessionActions.clear();
        data.forEach((key, value) {
          if (key is String && value is int) {
            _sessionActions[key] = value;
          }
        });
      }
    } catch (e) {
      debugPrint('セッションアクション読み込みエラー: $e');
    }
  }
}

/// オフライン進捗結果
class OfflineProgressResult {
  final Duration offlineTime;
  final Map<String, int> estimatedActions;
  final int goldEarned;
  final int expGained;
  
  const OfflineProgressResult({
    required this.offlineTime,
    required this.estimatedActions,
    required this.goldEarned,
    required this.expGained,
  });
  
  /// 推定されたアクションの総数
  int get totalEstimatedActions {
    return estimatedActions.values.fold(0, (sum, count) => sum + count);
  }
  
  /// オフライン時間の表示文字列
  String get offlineTimeDisplay {
    if (offlineTime.inDays > 0) {
      return '${offlineTime.inDays}日${offlineTime.inHours % 24}時間';
    } else if (offlineTime.inHours > 0) {
      return '${offlineTime.inHours}時間${offlineTime.inMinutes % 60}分';
    } else {
      return '${offlineTime.inMinutes}分';
    }
  }
  
  /// 結果のサマリー文字列
  String get summary {
    final actions = totalEstimatedActions;
    return '$offlineTimeDisplay の間に $actions アクション実行、${goldEarned}G 獲得';
  }
}