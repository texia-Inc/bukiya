import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class BulkBuybackApiService {
  final Dio _dio;

  BulkBuybackApiService(this._dio);

  /// 一括買取実行
  Future<Map<String, dynamic>> executeBulkBuyback({int? maxGold}) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}/api/v1/adventurers/bulk-buyback',
        data: {
          if (maxGold != null) 'max_gold': maxGold,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('一括買取に失敗しました: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('一括買取APIエラー: ${e.message}');
    }
  }

  /// 買取概要を取得
  Future<Map<String, dynamic>> getBuybackSummary() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/api/v1/adventurers/buyback-summary',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('買取概要の取得に失敗しました: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('買取概要APIエラー: ${e.message}');
    }
  }
}