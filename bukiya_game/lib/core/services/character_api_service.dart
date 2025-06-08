import 'package:flutter/foundation.dart';

import '../models/character.dart';
import 'api_service.dart';

/// 固有キャラクターシステム専用のAPIサービス
class CharacterApiService {
  final ApiService _apiService;

  CharacterApiService(this._apiService);

  /// 解放可能なキャラクター一覧を取得
  Future<CharacterListResponse> getAvailableCharacters() async {
    try {
      final response = await _apiService.dio.get('/api/v1/characters/available');
      
      if (response.statusCode == 200) {
        return CharacterListResponse.fromJson(response.data);
      }
      
      throw Exception('Failed to load available characters: ${response.statusCode}');
    } catch (e) {
      debugPrint('解放可能キャラクター取得エラー: $e');
      rethrow;
    }
  }

  /// 解放済みキャラクター一覧を取得
  Future<List<CharacterBond>> getUnlockedCharacters() async {
    try {
      final response = await _apiService.dio.get('/api/v1/characters/unlocked');
      
      if (response.statusCode == 200) {
        final List<dynamic> bondsJson = response.data;
        return bondsJson.map((json) => CharacterBond.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load unlocked characters: ${response.statusCode}');
    } catch (e) {
      debugPrint('解放済みキャラクター取得エラー: $e');
      rethrow;
    }
  }

  /// キャラクターの詳細情報を取得
  Future<Map<String, dynamic>> getCharacterDetail(int characterId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/characters/$characterId');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to load character detail: ${response.statusCode}');
    } catch (e) {
      debugPrint('キャラクター詳細取得エラー: $e');
      rethrow;
    }
  }

  /// キャラクターを解放
  Future<Map<String, dynamic>> unlockCharacter({
    required int characterId,
    required String unlockMethod,
    String? conditionDescription,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/characters/$characterId/unlock',
        data: {
          'unlock_method': unlockMethod,
          'condition_description': conditionDescription,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to unlock character: ${response.statusCode}');
    } catch (e) {
      debugPrint('キャラクター解放エラー: $e');
      rethrow;
    }
  }


  /// キャラクターとの絆進捗を取得
  Future<Map<String, dynamic>> getBondProgress(int characterId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/characters/$characterId/bond');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to load bond progress: ${response.statusCode}');
    } catch (e) {
      debugPrint('絆進捗取得エラー: $e');
      rethrow;
    }
  }

  /// キャラクターにあだ名を設定
  Future<Map<String, dynamic>> setCharacterNickname({
    required int characterId,
    required String nickname,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/characters/$characterId/nickname',
        queryParameters: {
          'nickname': nickname,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to set character nickname: ${response.statusCode}');
    } catch (e) {
      debugPrint('あだ名設定エラー: $e');
      rethrow;
    }
  }
}