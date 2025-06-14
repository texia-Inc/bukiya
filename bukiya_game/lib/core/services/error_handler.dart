import 'package:dio/dio.dart';
import 'dart:convert';

/// エラーハンドリングのユーティリティクラス
class ErrorHandler {
  /// DioExceptionから詳細なエラーメッセージを抽出
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      // ステータスコード別の処理
      if (error.response?.statusCode == 400) {
        return _extractBadRequestMessage(error);
      } else if (error.response?.statusCode == 401) {
        return '認証エラーが発生しました。再ログインしてください。';
      } else if (error.response?.statusCode == 403) {
        return 'アクセス権限がありません。';
      } else if (error.response?.statusCode == 404) {
        return '要求されたリソースが見つかりません。';
      } else if (error.response?.statusCode == 500) {
        return 'サーバーエラーが発生しました。しばらく時間をおいて再度お試しください。';
      }
    }
    
    return 'ネットワークエラーが発生しました。接続を確認してください。';
  }
  
  /// 400 Bad Requestエラーからメッセージを抽出
  static String _extractBadRequestMessage(DioException error) {
    try {
      final responseData = error.response?.data;
      
      if (responseData != null) {
        // Map形式の場合
        if (responseData is Map<String, dynamic>) {
          return _extractFromMap(responseData);
        }
        // 文字列形式の場合
        else if (responseData is String) {
          return _extractFromString(responseData);
        }
      }
    } catch (e) {
      print('エラーメッセージ抽出失敗: $e');
    }
    
    return 'リクエストの処理中にエラーが発生しました。';
  }
  
  /// Map形式のレスポンスからメッセージを抽出
  static String _extractFromMap(Map<String, dynamic> data) {
    // パターン1: error.message
    if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
      final errorMap = data['error'] as Map<String, dynamic>;
      if (errorMap.containsKey('message')) {
        return errorMap['message'].toString();
      }
    }
    
    // パターン2: message
    if (data.containsKey('message')) {
      return data['message'].toString();
    }
    
    // パターン3: detail
    if (data.containsKey('detail')) {
      return data['detail'].toString();
    }
    
    return 'エラーが発生しました。';
  }
  
  /// 文字列形式のレスポンスからメッセージを抽出
  static String _extractFromString(String data) {
    try {
      // JSONパースを試行
      final jsonData = json.decode(data);
      if (jsonData is Map<String, dynamic>) {
        return _extractFromMap(jsonData);
      }
    } catch (e) {
      // JSONパースに失敗した場合、直接検索
      if (data.contains('ゴールドが不足しています')) {
        return 'ゴールドが不足しています';
      } else if (data.contains('アイテムが見つかりません')) {
        return 'アイテムが見つかりません';
      }
    }
    
    return 'エラーが発生しました。';
  }
}