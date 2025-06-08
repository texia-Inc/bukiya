import 'package:flutter/foundation.dart';

import '../models/adventurer_new.dart';
import 'api_service.dart';

/// 冒険者システム専用のAPIサービス
/// 実際のバックエンドAPIエンドポイントとの通信を担当
class AdventurerApiService {
  final ApiService _apiService;

  AdventurerApiService(this._apiService);

  /// 訪問中の冒険者一覧を取得
  Future<List<Adventurer>> getVisitingAdventurers() async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/visiting');
      
      if (response.statusCode == 200) {
        final adventurers = (response.data['adventurers'] as List)
            .map((json) => Adventurer.fromJson(json))
            .toList();
        return adventurers;
      }
      
      throw Exception('Failed to load visiting adventurers: ${response.statusCode}');
    } catch (e) {
      debugPrint('訪問中冒険者取得エラー: $e');
      rethrow;
    }
  }

  /// 冒険中の冒険者一覧を取得
  Future<List<Adventurer>> getOnQuestAdventurers() async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/on-quest-noauth');
      
      if (response.statusCode == 200) {
        final adventurers = (response.data['adventurers'] as List)
            .map((json) => Adventurer.fromJson(json))
            .toList();
        return adventurers;
      }
      
      throw Exception('Failed to load on-quest adventurers: ${response.statusCode}');
    } catch (e) {
      debugPrint('冒険中冒険者取得エラー: $e');
      rethrow;
    }
  }

  /// 買取案件一覧を取得
  Future<List<QuestResult>> getPendingBuybacks() async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/buybacks');
      
      if (response.statusCode == 200) {
        final buybacks = (response.data['results'] as List)
            .map((json) => QuestResult.fromJson(json))
            .toList();
        return buybacks;
      }
      
      throw Exception('Failed to load pending buybacks: ${response.statusCode}');
    } catch (e) {
      debugPrint('買取案件取得エラー: $e');
      rethrow;
    }
  }

  /// 利用可能なクエストエリア一覧を取得
  Future<List<QuestArea>> getQuestAreas() async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/quest-areas');
      
      if (response.statusCode == 200) {
        final questAreas = (response.data['areas'] as List)
            .map((json) => QuestArea.fromJson(json))
            .toList();
        return questAreas;
      }
      
      throw Exception('Failed to load quest areas: ${response.statusCode}');
    } catch (e) {
      debugPrint('クエストエリア取得エラー: $e');
      rethrow;
    }
  }

  /// 冒険者に武器を販売
  Future<Map<String, dynamic>> sellWeaponToAdventurer({
    required String adventurerId,
    required String weaponId,
    required int price,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/adventurers/$adventurerId/sell',
        data: {
          'weapon_id': weaponId,
          'price': price,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to sell weapon: ${response.statusCode}');
    } catch (e) {
      debugPrint('武器販売エラー: $e');
      rethrow;
    }
  }

  /// 冒険者をクエストに派遣
  Future<Map<String, dynamic>> sendAdventurerOnQuest({
    required String adventurerId,
    required String questAreaId,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/adventurers/$adventurerId/quest',
        data: {
          'quest_area_id': questAreaId,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to send adventurer on quest: ${response.statusCode}');
    } catch (e) {
      debugPrint('クエスト派遣エラー: $e');
      rethrow;
    }
  }

  /// アイテムを買い取り
  Future<Map<String, dynamic>> buybackItems({
    required String questResultId,
    required List<String> itemIds,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/adventurers/buyback',
        data: {
          'quest_result_id': questResultId,
          'item_ids': itemIds,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to buyback items: ${response.statusCode}');
    } catch (e) {
      debugPrint('アイテム買取エラー: $e');
      rethrow;
    }
  }

  /// 新しい訪問者を生成（手動実行）
  Future<List<Adventurer>> spawnVisitors() async {
    try {
      final response = await _apiService.dio.post('/api/v1/adventurers/spawn-visitors');
      
      if (response.statusCode == 200) {
        final adventurers = (response.data['adventurers'] as List)
            .map((json) => Adventurer.fromJson(json))
            .toList();
        return adventurers;
      }
      
      throw Exception('Failed to spawn visitors: ${response.statusCode}');
    } catch (e) {
      debugPrint('訪問者生成エラー: $e');
      rethrow;
    }
  }

  /// 冒険者の詳細情報を取得
  Future<Adventurer> getAdventurerDetails(String adventurerId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/$adventurerId');
      
      if (response.statusCode == 200) {
        return Adventurer.fromJson(response.data['adventurer']);
      }
      
      throw Exception('Failed to load adventurer details: ${response.statusCode}');
    } catch (e) {
      debugPrint('冒険者詳細取得エラー: $e');
      rethrow;
    }
  }

  /// 冒険者のステータスを更新（時間経過処理など）
  Future<void> updateAdventurerStatus() async {
    try {
      final response = await _apiService.dio.post('/api/v1/adventurers/update-status');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update adventurer status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('冒険者ステータス更新エラー: $e');
      rethrow;
    }
  }
}