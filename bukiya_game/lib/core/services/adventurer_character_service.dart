// import 'package:dio/dio.dart';
// import '../models/adventurer_character.dart';
// import 'api_service.dart';

/*
class AdventurerCharacterService {
  final ApiService _apiService;

  AdventurerCharacterService(this._apiService);

  // Adventurer Characters
  Future<List<AdventurerCharacter>> getAvailableAdventurers({
    int? playerLevel,
    String? profession,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
      };
      
      if (playerLevel != null) params['player_level'] = playerLevel;
      if (profession != null) params['profession'] = profession;

      final response = await _apiService.dio.get(
        '/adventurer-relations/characters',
        queryParameters: params,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => AdventurerCharacter.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get available adventurers');
    }
  }

  // Player Relationships
  Future<List<AdventurerRelationSummary>> getPlayerRelations({
    int? trustLevelMin,
    bool includeInactive = false,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'include_inactive': includeInactive,
        'limit': limit,
      };
      
      if (trustLevelMin != null) params['trust_level_min'] = trustLevelMin;

      final response = await _apiService.dio.get(
        '/adventurer-relations/relations',
        queryParameters: params,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => AdventurerRelationSummary.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get player relations');
    }
  }

  Future<PlayerAdventurerRelation> getRelationDetails(int relationId) async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-relations/relations/$relationId',
      );

      return PlayerAdventurerRelation.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get relation details');
    }
  }

  // Visits
  Future<List<AdventurerVisit>> getActiveVisits() async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-relations/visits/active',
      );

      final List<dynamic> data = response.data;
      return data.map((json) => AdventurerVisit.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get active visits');
    }
  }

  Future<AdventurerVisit> createVisit({
    required int adventurerId,
    int? plannedDurationMinutes,
    VisitPurpose visitPurpose = VisitPurpose.trade,
    int urgencyLevel = 3,
    Map<String, dynamic>? weaponRequest,
  }) async {
    try {
      final data = {
        'adventurer_id': adventurerId,
        'visit_purpose': visitPurpose.name,
        'urgency_level': urgencyLevel,
      };

      if (plannedDurationMinutes != null) {
        data['planned_duration_minutes'] = plannedDurationMinutes;
      }
      if (weaponRequest != null) {
        data['weapon_request'] = weaponRequest;
      }

      final response = await _apiService.dio.post(
        '/adventurer-relations/visits',
        data: data,
      );

      return AdventurerVisit.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create visit');
    }
  }

  Future<Map<String, dynamic>> completeVisit(int visitId) async {
    try {
      final response = await _apiService.dio.put(
        '/adventurer-relations/visits/$visitId/complete',
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to complete visit');
    }
  }

  // Transactions
  Future<AdventurerTransaction> createTransaction({
    required int visitId,
    required TransactionType transactionType,
    required String itemType,
    required String itemId,
    required String itemName,
    required int basePrice,
    required int negotiatedPrice,
    bool wasRequestedItem = false,
    int negotiationRounds = 0,
    String? transactionNotes,
  }) async {
    try {
      final data = {
        'visit_id': visitId,
        'transaction_type': transactionType.name,
        'item_type': itemType,
        'item_id': itemId,
        'item_name': itemName,
        'base_price': basePrice,
        'negotiated_price': negotiatedPrice,
        'was_requested_item': wasRequestedItem,
        'negotiation_rounds': negotiationRounds,
      };

      if (transactionNotes != null) {
        data['transaction_notes'] = transactionNotes;
      }

      final response = await _apiService.dio.post(
        '/adventurer-relations/transactions',
        data: data,
      );

      return AdventurerTransaction.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create transaction');
    }
  }

  // Trust Level Benefits
  Future<TrustLevelBenefits> getTrustLevelBenefits(int trustLevel) async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-relations/trust-benefits/$trustLevel',
      );

      return TrustLevelBenefits.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get trust level benefits');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getRelationshipStats() async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-relations/stats/summary',
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get relationship stats');
    }
  }

  // Migration (Admin only)
  Future<Map<String, dynamic>> previewMigration() async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-migration/preview',
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to preview migration');
    }
  }

  Future<Map<String, dynamic>> executeMigration({
    bool confirmDataLoss = false,
    bool preserveCurrentVisits = true,
    bool recalculateTrust = true,
    bool dryRun = true,
  }) async {
    try {
      final data = {
        'confirm_data_loss': confirmDataLoss,
        'preserve_current_visits': preserveCurrentVisits,
        'recalculate_trust': recalculateTrust,
        'dry_run': dryRun,
      };

      final response = await _apiService.dio.post(
        '/adventurer-migration/execute',
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to execute migration');
    }
  }

  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final response = await _apiService.dio.get(
        '/adventurer-migration/status',
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to get migration status');
    }
  }

  Future<Map<String, dynamic>> createDefaultMasters() async {
    try {
      final response = await _apiService.dio.post(
        '/adventurer-migration/create-default-masters',
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e, 'Failed to create default masters');
    }
  }

  Exception _handleError(DioException e, String context) {
    String message = context;
    
    if (e.response?.data != null) {
      if (e.response!.data is Map && e.response!.data['detail'] != null) {
        message = e.response!.data['detail'];
      } else if (e.response!.data is String) {
        message = e.response!.data;
      }
    } else if (e.message != null) {
      message = e.message!;
    }
    
    return Exception(message);
  }
}
*/