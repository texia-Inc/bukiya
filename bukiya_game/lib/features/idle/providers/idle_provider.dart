import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/services/api_service.dart';
import '../../../core/models/idle_system.dart';
import '../../../core/constants/app_constants.dart';

class IdleProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  IdleSystem? _idleSystem;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _incomeTimer;
  Timer? _bonusTimer;
  
  // Getters
  IdleSystem? get idleSystem => _idleSystem;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  IdleProvider(this._apiService) {
    _initializeIdleSystem();
  }

  // 放置システムを初期化
  Future<void> _initializeIdleSystem() async {
    await loadIdleSystem();
    _startIncomeTimer();
    _startBonusTimer();
  }

  // 放置システムデータを読み込み
  Future<void> loadIdleSystem() async {
    _setLoading(true);
    _clearError();

    try {
      // APIから放置システムデータを取得
      final response = await _apiService.getIdleStatus();
      _idleSystem = IdleSystem.fromJson(response);
      
      // ローカルストレージにも保存
      await _saveToLocal();
      
      notifyListeners();
    } catch (e) {
      // APIが失敗した場合はローカルデータを使用
      await _loadFromLocal();
      _setError('放置システムデータの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 収益を回収
  Future<IdleCollectionResult?> collectIncome() async {
    if (_idleSystem == null) return null;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.collectIdleIncome();
      final result = IdleCollectionResult.fromJson(response);
      
      // 放置システムデータを更新
      await loadIdleSystem();
      
      return result;
    } catch (e) {
      _setError('収益の回収に失敗しました: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // アップグレードを購入
  Future<UpgradeResult?> purchaseUpgrade(String upgradeId) async {
    if (_idleSystem == null) return null;

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.purchaseIdleUpgrade(upgradeId);
      final result = UpgradeResult.fromJson(response);
      
      if (result.success) {
        // 放置システムデータを更新
        await loadIdleSystem();
      }
      
      return result;
    } catch (e) {
      _setError('アップグレードの購入に失敗しました: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ボーナスを有効化
  Future<bool> activateBonus(String bonusId) async {
    if (_idleSystem == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _apiService.activateIdleBonus(bonusId);
      
      // 放置システムデータを更新
      await loadIdleSystem();
      
      return true;
    } catch (e) {
      _setError('ボーナスの有効化に失敗しました: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 現在の待機中収益を取得
  int get currentPendingIncome {
    return _idleSystem?.pendingIncome ?? 0;
  }

  // 1秒あたりの収益を取得
  int get currentIncomePerSecond {
    return _idleSystem?.currentIncomePerSecond ?? 0;
  }

  // アクティブなボーナスを取得
  List<IdleBonus> get activeBonuses {
    return _idleSystem?.activeBonuses.where((bonus) => bonus.isActive).toList() ?? [];
  }

  // 利用可能なアップグレードを取得
  List<IdleUpgrade> get availableUpgrades {
    return _idleSystem?.availableUpgrades.where((upgrade) => upgrade.isUnlocked).toList() ?? [];
  }

  // 購入可能なアップグレードを取得
  List<IdleUpgrade> getAffordableUpgrades(int playerGold) {
    return availableUpgrades.where((upgrade) => upgrade.canUpgrade(playerGold)).toList();
  }

  // 収益タイマーを開始
  void _startIncomeTimer() {
    _incomeTimer?.cancel();
    _incomeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_idleSystem != null) {
        // 1秒ごとに収益を更新
        final now = DateTime.now();
        final newSystem = _idleSystem!.copyWith(
          lastCollectedAt: now,
        );
        _idleSystem = newSystem;
        notifyListeners();
      }
    });
  }

  // ボーナスタイマーを開始
  void _startBonusTimer() {
    _bonusTimer?.cancel();
    _bonusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_idleSystem != null) {
        // 10秒ごとにボーナスの有効性をチェック
        final activeBonuses = _idleSystem!.activeBonuses;
        bool hasExpiredBonus = false;
        
        for (final bonus in activeBonuses) {
          if (!bonus.isActive) {
            hasExpiredBonus = true;
            break;
          }
        }
        
        if (hasExpiredBonus) {
          // 期限切れのボーナスがある場合、データを再読み込み
          loadIdleSystem();
        }
      }
    });
  }

  // ローカルストレージに保存
  Future<void> _saveToLocal() async {
    if (_idleSystem == null) return;
    
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      await box.put('idle_system', _idleSystem!.toJson());
    } catch (e) {
      debugPrint('ローカル保存に失敗: $e');
    }
  }

  // ローカルストレージから読み込み
  Future<void> _loadFromLocal() async {
    try {
      final box = await Hive.openBox(AppConstants.gameDataKey);
      final data = box.get('idle_system');
      
      if (data != null) {
        _idleSystem = IdleSystem.fromJson(Map<String, dynamic>.from(data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ローカル読み込みに失敗: $e');
    }
  }

  // 自動収益を計算（オフライン時間用）
  IdleCollectionResult calculateOfflineIncome(DateTime lastActiveTime) {
    if (_idleSystem == null) {
      return const IdleCollectionResult(
        goldEarned: 0,
        experienceGained: 0,
        offlineTime: Duration.zero,
        bonusesExpired: [],
        leveledUp: false,
        newLevel: 1,
      );
    }

    final now = DateTime.now();
    final offlineTime = now.difference(lastActiveTime);
    
    // 最大8時間分の収益を計算
    final maxOfflineHours = 8;
    final effectiveOfflineTime = offlineTime.inHours > maxOfflineHours
        ? Duration(hours: maxOfflineHours)
        : offlineTime;
    
    final goldEarned = _idleSystem!.calculateIncome(effectiveOfflineTime);
    final experienceGained = (goldEarned * 0.1).round(); // ゴールドの10%を経験値として
    
    // レベルアップチェック
    final currentExp = experienceGained;
    final requiredExp = _idleSystem!.experienceToNextLevel;
    final leveledUp = currentExp >= requiredExp;
    final newLevel = leveledUp ? _idleSystem!.currentLevel + 1 : _idleSystem!.currentLevel;
    
    return IdleCollectionResult(
      goldEarned: goldEarned,
      experienceGained: experienceGained,
      offlineTime: effectiveOfflineTime,
      bonusesExpired: [],
      leveledUp: leveledUp,
      newLevel: newLevel,
    );
  }

  // 効率性の向上を計算
  double calculateEfficiencyImprovement(String upgradeId) {
    final upgrade = _idleSystem?.availableUpgrades
        .firstWhere((u) => u.id == upgradeId, orElse: () => 
            const IdleUpgrade(
              id: '',
              name: '',
              description: '',
              cost: 0,
              incomeMultiplier: 1.0,
              level: 0,
              maxLevel: 0,
              iconName: '',
              isUnlocked: false,
            ));
    
    if (upgrade == null || upgrade.id.isEmpty) return 0.0;
    
    return (upgrade.incomeMultiplier - 1.0) * 100;
  }

  // 投資回収時間を計算（秒）
  int calculatePaybackTime(String upgradeId) {
    final upgrade = _idleSystem?.availableUpgrades
        .firstWhere((u) => u.id == upgradeId, orElse: () => 
            const IdleUpgrade(
              id: '',
              name: '',
              description: '',
              cost: 0,
              incomeMultiplier: 1.0,
              level: 0,
              maxLevel: 0,
              iconName: '',
              isUnlocked: false,
            ));
    
    if (upgrade == null || upgrade.id.isEmpty || _idleSystem == null) return 0;
    
    final currentIncome = _idleSystem!.currentIncomePerSecond;
    final incomeIncrease = (currentIncome * (upgrade.incomeMultiplier - 1.0)).round();
    
    if (incomeIncrease <= 0) return 0;
    
    return (upgrade.nextLevelCost / incomeIncrease).round();
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

  @override
  void dispose() {
    _incomeTimer?.cancel();
    _bonusTimer?.cancel();
    super.dispose();
  }
}
