import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'api_service.dart';

/// 放置収入システムのAPIサービス
class IdleIncomeApiService {
  final ApiService _apiService;

  IdleIncomeApiService(this._apiService);

  /// 現在の放置収入状況を取得
  Future<Map<String, dynamic>> getIdleIncomeStatus() async {
    try {
      final response = await _apiService.dio.get('/api/v1/idle-income/status');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to get idle income status: ${response.statusCode}');
    } catch (e) {
      debugPrint('放置収入状況取得エラー: $e');
      rethrow;
    }
  }

  /// 放置収入を回収
  Future<Map<String, dynamic>> collectIdleIncome() async {
    try {
      final response = await _apiService.dio.post('/api/v1/idle-income/collect');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to collect idle income: ${response.statusCode}');
    } catch (e) {
      debugPrint('放置収入回収エラー: $e');
      rethrow;
    }
  }

  /// 放置収入システムの詳細情報を取得
  Future<Map<String, dynamic>> getIdleIncomeInfo() async {
    try {
      final response = await _apiService.dio.get('/api/v1/idle-income/info');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to get idle income info: ${response.statusCode}');
    } catch (e) {
      debugPrint('放置収入情報取得エラー: $e');
      rethrow;
    }
  }

  /// 放置収入をブースト（将来の機能）
  Future<Map<String, dynamic>> boostIdleIncome({
    required int durationHours,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/api/v1/idle-income/boost',
        queryParameters: {
          'duration_hours': durationHours,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to boost idle income: ${response.statusCode}');
    } catch (e) {
      debugPrint('放置収入ブーストエラー: $e');
      rethrow;
    }
  }
}