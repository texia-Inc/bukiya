import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../core/models/adventurer.dart';
import '../../../core/models/weapon.dart';
import '../../../core/services/api_service.dart';

class AdventurerProvider extends ChangeNotifier {
  final ApiService _apiService;

  AdventurerProvider(this._apiService);

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

  // 緊急度の高い買取案件
  List<QuestResult> get urgentBuybacks {
    return _pendingBuybacks
        .where((result) => result.remainingBuybackMinutes <= 30)
        .toList()
      ..sort((a, b) => a.remainingBuybackMinutes.compareTo(b.remainingBuybackMinutes));
  }

  // 高額買取案件
  List<QuestResult> get highValueBuybacks {
    return _pendingBuybacks
        .where((result) => result.totalBuybackPrice >= 1000)
        .toList()
      ..sort((a, b) => b.totalBuybackPrice.compareTo(a.totalBuybackPrice));
  }

  // 冒険者データの読み込み
  Future<void> loadAdventurerData() async {
    try {
      _setLoading(true);
      _clearError();

      // 並行して各データを取得
      final futures = await Future.wait([
        _loadVisitingAdventurers(),
        _loadOnQuestAdventurers(),
        _loadPendingBuybacks(),
        _loadQuestAreas(),
      ]);

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
      final response = await _apiService.dio.get('/adventurers/visiting');
      _visitingAdventurers = (response.data['adventurers'] as List)
          .map((json) => Adventurer.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('訪問中冒険者の読み込みエラー: $e');
      // モックデータで代替
      _visitingAdventurers = _generateMockVisitingAdventurers();
    }
  }

  // 冒険中の冒険者を取得
  Future<void> _loadOnQuestAdventurers() async {
    try {
      final response = await _apiService.dio.get('/adventurers/on-quest');
      _onQuestAdventurers = (response.data['adventurers'] as List)
          .map((json) => Adventurer.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('冒険中冒険者の読み込みエラー: $e');
      // モックデータで代替
      _onQuestAdventurers = _generateMockOnQuestAdventurers();
    }
  }

  // 買取待ちの結果を取得
  Future<void> _loadPendingBuybacks() async {
    try {
      final response = await _apiService.dio.get('/adventurers/buybacks');
      _pendingBuybacks = (response.data['results'] as List)
          .map((json) => QuestResult.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('買取案件の読み込みエラー: $e');
      // モックデータで代替
      _pendingBuybacks = _generateMockBuybacks();
    }
  }

  // クエストエリアを取得
  Future<void> _loadQuestAreas() async {
    try {
      final response = await _apiService.dio.get('/quest-areas');
      _questAreas = (response.data['areas'] as List)
          .map((json) => QuestArea.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('クエストエリアの読み込みエラー: $e');
      // モックデータで代替
      _questAreas = _generateMockQuestAreas();
    }
  }

  // 武器を冒険者に販売
  Future<bool> sellWeaponToAdventurer(String adventurerId, String weaponId, int price) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.dio.post('/adventurers/$adventurerId/sell', data: {
        'weapon_id': weaponId,
        'price': price,
      });

      if (response.statusCode == 200) {
        // 販売成功後、冒険者リストを更新
        await _loadVisitingAdventurers();
        return true;
      }
      return false;
    } catch (e) {
      _setError('武器の販売に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 冒険者を派遣
  Future<bool> sendAdventurerOnQuest(String adventurerId, String questAreaId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _apiService.dio.post('/adventurers/$adventurerId/quest', data: {
        'quest_area_id': questAreaId,
      });

      if (response.statusCode == 200) {
        // 派遣成功後、冒険者リストを更新
        await loadAdventurerData();
        return true;
      }
      return false;
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

      final response = await _apiService.dio.post('/adventurers/buyback', data: {
        'quest_result_id': questResultId,
        'item_ids': itemIds,
      });

      if (response.statusCode == 200) {
        // 買取成功後、買取リストを更新
        await _loadPendingBuybacks();
        return true;
      }
      return false;
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

      final response = await _apiService.dio.delete('/adventurers/buyback/$questResultId');

      if (response.statusCode == 200) {
        // 拒否成功後、買取リストを更新
        await _loadPendingBuybacks();
        return true;
      }
      return false;
    } catch (e) {
      _setError('買取の拒否に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 冒険者の詳細情報を取得
  Future<Adventurer?> getAdventurerDetails(String adventurerId) async {
    try {
      final response = await _apiService.dio.get('/adventurers/$adventurerId');
      return Adventurer.fromJson(response.data);
    } catch (e) {
      _setError('冒険者の詳細取得に失敗しました: ${e.toString()}');
      return null;
    }
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

  // モックデータ生成メソッド
  List<Adventurer> _generateMockVisitingAdventurers() {
    final now = DateTime.now();
    return [
      Adventurer(
        id: '1',
        name: 'アリス',
        profession: 'warrior',
        level: 15,
        personality: 'generous',
        trustLevel: 75,
        budget: 2500,
        preferredWeaponType: 'sword',
        avatarUrl: '',
        visitStartTime: now.subtract(const Duration(minutes: 10)),
        visitEndTime: now.add(const Duration(minutes: 50)),
        status: AdventurerStatus.visiting,
        currentRequest: AdventurerRequest(
          id: 'req1',
          adventurerId: '1',
          weaponType: 'sword',
          minAttack: 200,
          maxBudget: 2000,
          preferredRarity: 'rare',
          urgency: 4,
          description: '強力な剣が必要です。明日の討伐に使います。',
          deadline: now.add(const Duration(hours: 2)),
        ),
      ),
      Adventurer(
        id: '2',
        name: 'ボブ',
        profession: 'archer',
        level: 12,
        personality: 'stingy',
        trustLevel: 45,
        budget: 1200,
        preferredWeaponType: 'bow',
        avatarUrl: '',
        visitStartTime: now.subtract(const Duration(minutes: 5)),
        visitEndTime: now.add(const Duration(minutes: 25)),
        status: AdventurerStatus.visiting,
        currentRequest: AdventurerRequest(
          id: 'req2',
          adventurerId: '2',
          weaponType: 'bow',
          minAttack: 150,
          maxBudget: 1000,
          preferredRarity: 'common',
          urgency: 2,
          description: '安くて良い弓を探しています。',
          deadline: now.add(const Duration(hours: 4)),
        ),
      ),
    ];
  }

  List<Adventurer> _generateMockOnQuestAdventurers() {
    final now = DateTime.now();
    return [
      Adventurer(
        id: '3',
        name: 'キャロル',
        profession: 'mage',
        level: 18,
        personality: 'normal',
        trustLevel: 60,
        budget: 3000,
        preferredWeaponType: 'staff',
        avatarUrl: '',
        visitStartTime: now.subtract(const Duration(hours: 2)),
        visitEndTime: now.add(const Duration(hours: 1)),
        status: AdventurerStatus.onQuest,
      ),
    ];
  }

  List<QuestResult> _generateMockBuybacks() {
    final now = DateTime.now();
    return [
      QuestResult(
        id: 'result1',
        adventurerId: '3',
        questArea: '森林',
        success: true,
        goldEarned: 500,
        drops: [
          QuestDrop(
            id: 'drop1',
            itemType: 'material',
            itemId: 'iron_ore',
            name: '鉄鉱石',
            rarity: 'common',
            quantity: 3,
            buybackPrice: 150,
            description: '質の良い鉄鉱石です。',
          ),
          QuestDrop(
            id: 'drop2',
            itemType: 'weapon',
            itemId: 'rusty_sword',
            name: '錆びた剣',
            rarity: 'common',
            quantity: 1,
            buybackPrice: 300,
            description: '古い剣ですが、修理すれば使えそうです。',
          ),
        ],
        completedAt: now.subtract(const Duration(minutes: 10)),
        buybackDeadline: now.add(const Duration(minutes: 20)),
      ),
    ];
  }

  List<QuestArea> _generateMockQuestAreas() {
    return [
      const QuestArea(
        id: 'forest',
        name: '森林',
        description: '初心者向けの森林エリア。基本的な素材が手に入ります。',
        requiredLevel: 1,
        duration: 60,
        difficulty: 1,
        imageUrl: '',
      ),
      const QuestArea(
        id: 'cave',
        name: '洞窟',
        description: '中級者向けの洞窟エリア。レアな鉱石が見つかることがあります。',
        requiredLevel: 10,
        duration: 120,
        difficulty: 2,
        imageUrl: '',
      ),
      const QuestArea(
        id: 'mountain',
        name: '山岳',
        description: '上級者向けの山岳エリア。強力なモンスターが生息しています。',
        requiredLevel: 20,
        duration: 240,
        difficulty: 3,
        imageUrl: '',
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
