import 'package:dio/dio.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';
import 'package:bukiya_game/core/services/api_service.dart';

class DragonEventApiService {
  final ApiService _apiService;

  DragonEventApiService(this._apiService);

  /// Get list of dragon events
  Future<List<DragonEventSummary>> getEvents({
    String? status,
    int limit = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
      };
      
      if (status != null) {
        queryParameters['status'] = status;
      }

      final response = await _apiService.dio.get(
        '/dragon-events/events',
        queryParameters: queryParameters,
      );

      if (response.data['success'] == true) {
        final List<dynamic> eventsData = response.data['data'] ?? [];
        return eventsData
            .map((json) => DragonEventSummary.fromJson(json))
            .toList();
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch events',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch events: ${e.message}');
    }
  }

  /// Get current active dragon event
  Future<DragonEvent?> getCurrentEvent() async {
    try {
      final response = await _apiService.dio.get('/dragon-events/events/current');

      if (response.data['success'] == true) {
        final eventData = response.data['data'];
        if (eventData != null) {
          return DragonEvent.fromJson(eventData);
        }
        return null;
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch current event',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch current event: ${e.message}');
    }
  }

  /// Get specific dragon event details
  Future<DragonEvent> getEvent(int eventId) async {
    try {
      final response = await _apiService.dio.get('/dragon-events/events/$eventId');

      if (response.data['success'] == true) {
        return DragonEvent.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch event',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch event: ${e.message}');
    }
  }

  /// Join a dragon event with an adventurer
  Future<Map<String, dynamic>> joinEvent(
    int eventId,
    int adventurerInstanceId,
  ) async {
    try {
      final request = DragonParticipationRequest(
        adventurerInstanceId: adventurerInstanceId,
      );

      final response = await _apiService.dio.post(
        '/dragon-events/events/$eventId/join',
        data: request.toJson(),
      );

      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to join event',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to join event: ${e.message}');
    }
  }

  /// Get real-time battle state
  Future<DragonBattleState> getBattleState(int eventId) async {
    try {
      final response = await _apiService.dio.get(
        '/dragon-events/events/$eventId/battle-state',
      );

      if (response.data['success'] == true) {
        return DragonBattleState.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch battle state',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch battle state: ${e.message}');
    }
  }

  /// Get battle logs for an event
  Future<List<DragonBattleLog>> getBattleLogs(
    int eventId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/dragon-events/events/$eventId/logs',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data['success'] == true) {
        final List<dynamic> logsData = response.data['data'] ?? [];
        return logsData
            .map((json) => DragonBattleLog.fromJson(json))
            .toList();
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch battle logs',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch battle logs: ${e.message}');
    }
  }

  /// Claim rewards from a completed dragon event
  Future<DragonRewardsResponse> claimRewards(int eventId) async {
    try {
      final response = await _apiService.dio.post(
        '/dragon-events/events/$eventId/claim-rewards',
      );

      if (response.data['success'] == true) {
        return DragonRewardsResponse.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to claim rewards',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to claim rewards: ${e.message}');
    }
  }

  /// Get event statistics and leaderboard
  Future<DragonEventStats> getEventStats(int eventId) async {
    try {
      final response = await _apiService.dio.get(
        '/dragon-events/events/$eventId/stats',
      );

      if (response.data['success'] == true) {
        return DragonEventStats.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['error']['message'] ?? 'Failed to fetch event stats',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch event stats: ${e.message}');
    }
  }

  /// Get event participation status for current player
  Future<DragonParticipant?> getParticipationStatus(int eventId) async {
    try {
      // Find current player's participation
      // This would need the current player ID from auth
      // For now, returning null - implement when auth is integrated
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if player can join event
  Future<bool> canJoinEvent(int eventId) async {
    try {
      final event = await getEvent(eventId);
      
      // Check if event is active
      if (!event.isActive) return false;
      
      // Check if event hasn't ended
      if (DateTime.now().toUtc().isAfter(event.endTime)) return false;
      
      // Check if already participating
      final participation = await getParticipationStatus(eventId);
      if (participation != null) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Exception class for Dragon Event API errors
class DragonEventApiException implements Exception {
  final String message;
  DragonEventApiException(this.message);
  
  @override
  String toString() => 'DragonEventApiException: $message';
}