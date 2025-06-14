import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/adventurer_new.dart';
import '../models/material_targeting.dart';
import 'api_service.dart';
import 'error_handler.dart';

/// 買取処理に関する例外クラス
class BuybackException implements Exception {
  final String message;
  BuybackException(this.message);
  
  @override
  String toString() => message;
}

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
      final response = await _apiService.dio.get('/api/v1/adventurers/on-quest');
      
      if (response.statusCode == 200) {
        debugPrint('=== 冒険中冒険者APIレスポンス ===');
        debugPrint('レスポンスデータ: ${response.data}');
        
        final adventurers = (response.data['adventurers'] as List)
            .map((json) => Adventurer.fromJson(json))
            .toList();
            
        debugPrint('冒険中冒険者数: ${adventurers.length}');
        for (var adv in adventurers) {
          debugPrint('- ${adv.name} (ID: ${adv.id}, ステータス: ${adv.status})');
        }
        debugPrint('============================');
        
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
      debugPrint('=== 武器販売APIリクエスト ===');
      debugPrint('冒険者ID: $adventurerId');
      debugPrint('武器ID: $weaponId');
      debugPrint('価格: $price');
      
      // 現在のプレイヤーIDも確認
      try {
        final currentUserResponse = await _apiService.dio.get('/api/v1/players/me');
        final currentUserId = currentUserResponse.data['data']['player']['id'];
        debugPrint('現在のプレイヤーID: $currentUserId');
        
        if (currentUserId == null) {
          throw Exception('プレイヤーIDが取得できません。認証に問題がある可能性があります。');
        }
      } catch (e) {
        debugPrint('プレイヤー情報取得エラー: $e');
        throw Exception('認証エラー: プレイヤー情報を取得できませんでした。再ログインしてください。');
      }
      
      final response = await _apiService.dio.post(
        '/api/v1/adventurers/$adventurerId/sell',
        data: {
          'weapon_id': weaponId,
          'price': price,
        },
      );
      
      if (response.statusCode == 200) {
        debugPrint('=== 武器販売APIレスポンス ===');
        debugPrint('レスポンスデータ: ${response.data}');
        debugPrint('============================');
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

  /// 素材ターゲティング機能付きで冒険者をクエストに派遣
  Future<Map<String, dynamic>> dispatchAdventurerWithTargeting({
    required String adventurerId,
    required int questAreaId,
    int? targetMaterialId,
    int boostLevel = 1,
  }) async {
    try {
      final data = <String, dynamic>{
        'quest_area_id': questAreaId,
      };
      
      // 素材ターゲティングが指定されている場合
      if (targetMaterialId != null) {
        data['material_target'] = <String, dynamic>{
          'target_material_id': targetMaterialId,
          'boost_level': boostLevel,
        };
      }
      
      debugPrint('素材ターゲティング派遣リクエスト:');
      debugPrint('- URL: /api/v1/adventurers/$adventurerId/dispatch-with-targeting');
      debugPrint('- Data: $data');
      
      final response = await _apiService.dio.post(
        '/api/v1/adventurers/$adventurerId/dispatch-with-targeting',
        data: data,
      );
      
      debugPrint('素材ターゲティング派遣レスポンス: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to dispatch adventurer with targeting: ${response.statusCode}');
    } catch (e) {
      debugPrint('素材ターゲティング派遣エラー詳細: $e');
      if (e is DioException) {
        debugPrint('- ステータスコード: ${e.response?.statusCode}');
        debugPrint('- レスポンスデータ: ${e.response?.data}');
        debugPrint('- リクエストURL: ${e.requestOptions.uri}');
      }
      rethrow;
    }
  }

  /// クエストエリアのドロップ情報を取得
  Future<List<QuestAreaDropInfo>> getQuestAreaDropInfo() async {
    try {
      final response = await _apiService.dio.get('/api/v1/adventurers/quest-areas/drop-info');
      
      if (response.statusCode == 200) {
        debugPrint('クエストエリアドロップ情報レスポンス: ${response.data}');
        
        final dropInfoList = <QuestAreaDropInfo>[];
        final data = response.data as List;
        
        for (int i = 0; i < data.length; i++) {
          try {
            final item = data[i];
            debugPrint('ドロップ情報アイテム $i: $item');
            final dropInfo = QuestAreaDropInfo.fromJson(item);
            dropInfoList.add(dropInfo);
          } catch (e) {
            debugPrint('ドロップ情報アイテム $i の解析エラー: $e');
            debugPrint('問題のあるデータ: ${data[i]}');
            // エラーが発生したアイテムはスキップして続行
            continue;
          }
        }
        
        return dropInfoList;
      }
      
      throw Exception('Failed to load quest area drop info: ${response.statusCode}');
    } catch (e) {
      debugPrint('クエストエリアドロップ情報取得エラー: $e');
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
      debugPrint('=== アイテム買取エラー詳細 ===');
      debugPrint('エラータイプ: ${e.runtimeType}');
      debugPrint('エラー内容: $e');
      
      // ErrorHandlerを使用して詳細なエラーメッセージを抽出
      String detailMessage = ErrorHandler.extractErrorMessage(e);
      debugPrint('ErrorHandlerから抽出されたメッセージ: $detailMessage');
      
      // DioExceptionの場合、追加のデバッグ情報を出力
      if (e is DioException) {
        debugPrint('DioException詳細:');
        debugPrint('- ステータスコード: ${e.response?.statusCode}');
        debugPrint('- レスポンスデータ: ${e.response?.data}');
        debugPrint('- レスポンスヘッダー: ${e.response?.headers}');
      }
      
      throw BuybackException(detailMessage);
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

  /// ジェムを使って新しい訪問者を生成（即座実行）
  Future<Map<String, dynamic>> spawnVisitorsWithGems() async {
    try {
      final response = await _apiService.dio.post('/api/v1/adventurers/spawn-visitors-with-gems');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to spawn visitors with gems: ${response.statusCode}');
    } catch (e) {
      debugPrint('ジェム訪問者生成エラー: $e');
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

  /// 買取を拒否
  Future<Map<String, dynamic>> rejectBuyback({
    required String questResultId,
  }) async {
    try {
      final response = await _apiService.dio.delete(
        '/api/v1/adventurers/buyback/$questResultId',
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to reject buyback: ${response.statusCode}');
    } catch (e) {
      debugPrint('買取拒否エラー: $e');
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