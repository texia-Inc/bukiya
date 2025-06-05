import 'package:flutter/foundation.dart';

import '../../../core/models/adventurer_new.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/adventurer_api_service.dart';
import '../../../core/services/adventurer_mock_service.dart';

class AdventurerProvider extends ChangeNotifier {
  final ApiService _apiService;
  late final AdventurerApiService _adventurerApiService;
  
  // 開発中はモックAPIを使用、本番では実際のAPIを使用
  static const bool _useRealApi = true;

  AdventurerProvider(this._apiService) {
    _adventurerApiService = AdventurerApiService(_apiService);
  }

  // 状態管理
  bool _isLoading = false;
  String? _errorMessage;
  
  // 冒険者データ
  List<Adventurer> _visitingAdventurers = [];
  List<Adventurer> _onQuestAdventurers = [];
  List<QuestResult> _pendingBuybacks = [];
  List<QuestArea> _questAreas = [];

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Adventurer> get visitingAdventurers => _visitingAdventurers;
  List<Adventurer> get onQuestAdventurers => _onQuestAdventurers;
  List<QuestResult> get pendingBuybacks => _pendingBuybacks;
  List<QuestArea> get questAreas => _questAreas;

  // メインデータ読み込み
  Future<void> loadAdventurerData() async {
    try {
      _setLoading(true);
      _clearError();

      // 並行して全データを読み込み
      final futures = [
        _loadVisitingAdventurers(),
        _loadOnQuestAdventurers(),
        _loadPendingBuybacks(),
        _loadQuestAreas(),
      ];

      await Future.wait(futures);

      // 訪問中の冒険者がいない場合、自動で生成を試行
      if (_visitingAdventurers.isEmpty) {
        await _spawnVisitors();
      }

      notifyListeners();
    } catch (e) {
      _setError('冒険者データの読み込みに失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 訪問中の冒険者を取得
  Future<void> _loadVisitingAdventurers() async {
    try {
      if (_useRealApi) {
        _visitingAdventurers = await _adventurerApiService.getVisitingAdventurers();
      } else {
        _visitingAdventurers = await AdventurerMockService.generateVisitingAdventurers();
      }
    } catch (e) {
      debugPrint('訪問中冒険者の読み込みエラー: $e');
      // エラー時は空リストにして、spawn-visitorsで冒険者を生成してもらう
      _visitingAdventurers = [];
    }
  }

  // 冒険中の冒険者を取得
  Future<void> _loadOnQuestAdventurers() async {
    try {
      if (_useRealApi) {
        _onQuestAdventurers = await _adventurerApiService.getOnQuestAdventurers();
      } else {
        _onQuestAdventurers = await AdventurerMockService.generateOnQuestAdventurers();
      }
    } catch (e) {
      debugPrint('冒険中冒険者の読み込みエラー: $e');
      // エラー時は空リスト
      _onQuestAdventurers = [];
    }
  }

  // 買取待ちの結果を取得
  Future<void> _loadPendingBuybacks() async {
    try {
      if (_useRealApi) {
        _pendingBuybacks = await _adventurerApiService.getPendingBuybacks();
      } else {
        _pendingBuybacks = await AdventurerMockService.generatePendingBuybacks();
      }
    } catch (e) {
      debugPrint('買取案件の読み込みエラー: $e');
      // エラー時は空リスト
      _pendingBuybacks = [];
    }
  }

  // クエストエリアを取得
  Future<void> _loadQuestAreas() async {
    try {
      if (_useRealApi) {
        _questAreas = await _adventurerApiService.getQuestAreas();
      } else {
        _questAreas = await AdventurerMockService.getQuestAreas();
      }
    } catch (e) {
      debugPrint('クエストエリアの読み込みエラー: $e');
      // エラー時は空リスト
      _questAreas = [];
    }
  }

  // 武器を冒険者に販売
  Future<bool> sellWeaponToAdventurer(String adventurerId, String weaponId, int price) async {
    try {
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.sellWeaponToAdventurer(
          adventurerId: adventurerId,
          weaponId: weaponId,
          price: price,
        );
        
        if (result['success'] == true) {
          // 販売成功時、該当の冒険者を訪問者リストから冒険中リストに移動
          _moveAdventurerToQuest(adventurerId);
          return true;
        }
        return false;
      } else {
        final result = await AdventurerMockService.sellWeapon(
          adventurerId: adventurerId,
          weaponId: weaponId,
          price: price,
        );
        
        if (result['success'] == true) {
          // 販売成功時、該当の冒険者を訪問者リストから冒険中リストに移動
          _moveAdventurerToQuest(adventurerId);
          return true;
        }
        return false;
      }
    } catch (e) {
      _setError('武器の販売に失敗しました: ${e.toString()}');
      return false;
    }
  }

  // 冒険者を訪問者リストから冒険中リストに移動
  void _moveAdventurerToQuest(String adventurerId) {
    final adventurerIndex = _visitingAdventurers.indexWhere((a) => a.id == adventurerId);
    if (adventurerIndex != -1) {
      final adventurer = _visitingAdventurers[adventurerIndex];
      
      // 新しい冒険者インスタンスを作成（ステータスを変更）
      final updatedAdventurer = Adventurer(
        id: adventurer.id,
        adventurerMasterId: adventurer.adventurerMasterId,
        playerId: adventurer.playerId,
        name: adventurer.name,
        level: adventurer.level,
        trustLevel: adventurer.trustLevel,
        status: 'on_quest', // ステータスを冒険中に変更
        currentQuestId: 'quest_${DateTime.now().millisecondsSinceEpoch}',
        visitStartTime: adventurer.visitStartTime,
        visitEndTime: adventurer.visitEndTime,
        createdAt: adventurer.createdAt,
        updatedAt: DateTime.now(),
        adventurerMaster: adventurer.adventurerMaster,
        requests: adventurer.requests,
      );
      
      // リストから削除して冒険中リストに追加
      _visitingAdventurers.removeAt(adventurerIndex);
      _onQuestAdventurers.add(updatedAdventurer);
      
      notifyListeners();
    }
  }

  // 冒険者を派遣
  Future<bool> sendAdventurerOnQuest(String adventurerId, String questAreaId) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.sendAdventurerOnQuest(
          adventurerId: adventurerId,
          questAreaId: questAreaId,
        );
        
        if (result['success'] == true) {
          await loadAdventurerData();
          return true;
        }
        return false;
      } else {
        final result = await AdventurerMockService.sendOnQuest(
          adventurerId: adventurerId,
          questAreaId: questAreaId,
        );
        
        if (result['success'] == true) {
          await loadAdventurerData();
          return true;
        }
        return false;
      }
    } catch (e) {
      _setError('冒険者の派遣に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // アイテムを買取
  Future<bool> buybackItems(String questResultId, List<String> itemIds) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.buybackItems(
          questResultId: questResultId,
          itemIds: itemIds,
        );
        
        if (result['success'] == true) {
          await _loadPendingBuybacks();
          return true;
        }
        return false;
      } else {
        final result = await AdventurerMockService.buybackItems(
          questResultId: questResultId,
          itemIds: itemIds,
        );
        
        if (result['success'] == true) {
          await _loadPendingBuybacks();
          return true;
        }
        return false;
      }
    } catch (e) {
      _setError('アイテムの買取に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 買取を拒否
  Future<bool> rejectBuyback(String questResultId) async {
    try {
      _setLoading(true);
      _clearError();

      // 買取案件を削除
      _pendingBuybacks.removeWhere((buyback) => buyback.id == questResultId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('買取の拒否に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 新しい訪問者を生成
  Future<void> _spawnVisitors() async {
    try {
      if (_useRealApi) {
        _visitingAdventurers = await _adventurerApiService.spawnVisitors();
      } else {
        _visitingAdventurers = await AdventurerMockService.spawnVisitors();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('新しい訪問者の生成エラー: $e');
      // 生成に失敗した場合は何もしない（空リストのまま）
    }
  }

  // 手動で訪問者を生成
  Future<void> manualSpawnVisitors() async {
    await _spawnVisitors();
  }

  // プライベートメソッド
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

}