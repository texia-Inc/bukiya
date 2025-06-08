import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bukiya_game/core/models/dragon_event.dart';
// import 'package:bukiya_game/core/models/adventurer_new.dart' show AdventurerInstance;
import 'package:bukiya_game/core/services/dragon_event_api_service.dart';
import 'package:bukiya_game/core/services/api_service.dart';

class DragonEventProvider extends ChangeNotifier {
  final DragonEventApiService _dragonEventApi;
  
  // Current state
  List<DragonEventSummary> _events = [];
  DragonEvent? _currentEvent;
  DragonBattleState? _battleState;
  List<DragonBattleLog> _battleLogs = [];
  DragonEventStats? _eventStats;
  DragonParticipant? _playerParticipation;
  DragonRewardsResponse? _lastRewards;
  
  // Loading states
  bool _isLoading = false;
  bool _isBattleLoading = false;
  bool _isJoining = false;
  bool _isClaimingRewards = false;
  
  // Error state
  String? _error;
  
  // Real-time updates
  Timer? _battleUpdateTimer;
  Timer? _logUpdateTimer;
  
  DragonEventProvider(ApiService apiService) 
      : _dragonEventApi = DragonEventApiService(apiService);

  // Getters
  List<DragonEventSummary> get events => _events;
  DragonEvent? get currentEvent => _currentEvent;
  DragonBattleState? get battleState => _battleState;
  List<DragonBattleLog> get battleLogs => _battleLogs;
  DragonEventStats? get eventStats => _eventStats;
  DragonParticipant? get playerParticipation => _playerParticipation;
  DragonRewardsResponse? get lastRewards => _lastRewards;
  
  bool get isLoading => _isLoading;
  bool get isBattleLoading => _isBattleLoading;
  bool get isJoining => _isJoining;
  bool get isClaimingRewards => _isClaimingRewards;
  String? get error => _error;
  
  bool get hasActiveEvent => _currentEvent != null && _currentEvent!.isActive;
  bool get isPlayerParticipating => _playerParticipation != null;
  bool get canClaimRewards => _playerParticipation != null && 
      !_playerParticipation!.rewardsClaimed && 
      (_currentEvent?.isCompleted ?? false);

  /// Load list of dragon events
  Future<void> loadEvents({String? status}) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _events = await _dragonEventApi.getEvents(status: status);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load current active event
  Future<void> loadCurrentEvent() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _currentEvent = await _dragonEventApi.getCurrentEvent();
      
      if (_currentEvent != null) {
        // Start real-time updates if event is active
        if (_currentEvent!.isActive) {
          _startRealTimeUpdates(_currentEvent!.id);
        }
        
        // Load participation status
        await _loadParticipationStatus(_currentEvent!.id);
      } else {
        _stopRealTimeUpdates();
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load specific event details
  Future<void> loadEvent(int eventId) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      _currentEvent = await _dragonEventApi.getEvent(eventId);
      
      if (_currentEvent!.isActive) {
        _startRealTimeUpdates(eventId);
      }
      
      await _loadParticipationStatus(eventId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Join an event with selected adventurer
  Future<bool> joinEvent(int eventId, int adventurerInstanceId) async {
    if (_isJoining) return false;
    
    _isJoining = true;
    _clearError();
    notifyListeners();
    
    try {
      await _dragonEventApi.joinEvent(eventId, adventurerInstanceId);
      
      // Reload event to get updated participant list
      await loadEvent(eventId);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }

  /// Claim rewards from completed event
  Future<bool> claimRewards(int eventId) async {
    if (_isClaimingRewards) return false;
    
    _isClaimingRewards = true;
    _clearError();
    notifyListeners();
    
    try {
      _lastRewards = await _dragonEventApi.claimRewards(eventId);
      
      // Update participation status
      await _loadParticipationStatus(eventId);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _isClaimingRewards = false;
      notifyListeners();
    }
  }

  /// Load event statistics
  Future<void> loadEventStats(int eventId) async {
    try {
      _eventStats = await _dragonEventApi.getEventStats(eventId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load event stats: $e');
    }
  }

  /// Start real-time battle updates
  void _startRealTimeUpdates(int eventId) {
    _stopRealTimeUpdates();
    
    // Update battle state every 30 seconds
    _battleUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateBattleState(eventId),
    );
    
    // Update battle logs every 15 seconds
    _logUpdateTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateBattleLogs(eventId),
    );
    
    // Initial load
    _updateBattleState(eventId);
    _updateBattleLogs(eventId);
  }

  /// Stop real-time updates
  void _stopRealTimeUpdates() {
    _battleUpdateTimer?.cancel();
    _logUpdateTimer?.cancel();
    _battleUpdateTimer = null;
    _logUpdateTimer = null;
  }

  /// Update battle state
  Future<void> _updateBattleState(int eventId) async {
    if (_isBattleLoading) return;
    
    try {
      _isBattleLoading = true;
      _battleState = await _dragonEventApi.getBattleState(eventId);
      
      // If battle is no longer active, stop updates
      if (_battleState != null && !_battleState!.isActive) {
        _stopRealTimeUpdates();
        // Reload current event to get final state
        await loadCurrentEvent();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update battle state: $e');
    } finally {
      _isBattleLoading = false;
    }
  }

  /// Update battle logs
  Future<void> _updateBattleLogs(int eventId) async {
    try {
      final newLogs = await _dragonEventApi.getBattleLogs(eventId, limit: 20);
      
      // Merge with existing logs, removing duplicates
      final existingIds = _battleLogs.map((log) => log.id).toSet();
      final filteredNewLogs = newLogs.where((log) => !existingIds.contains(log.id));
      
      _battleLogs = [...filteredNewLogs, ..._battleLogs]
          .take(100) // Keep only last 100 logs
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update battle logs: $e');
    }
  }

  /// Load player's participation status
  Future<void> _loadParticipationStatus(int eventId) async {
    try {
      _playerParticipation = await _dragonEventApi.getParticipationStatus(eventId);
    } catch (e) {
      debugPrint('Failed to load participation status: $e');
      _playerParticipation = null;
    }
  }

  /// Check if player can join event
  Future<bool> canJoinEvent(int eventId) async {
    try {
      return await _dragonEventApi.canJoinEvent(eventId);
    } catch (e) {
      return false;
    }
  }

  /// Get formatted time remaining for current event
  String getTimeRemainingText() {
    if (_battleState != null) {
      return _battleState!.timeRemainingText;
    } else if (_currentEvent != null) {
      final remaining = _currentEvent!.timeRemaining;
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '00:00';
  }

  /// Get dragon HP percentage
  double getDragonHpPercentage() {
    if (_battleState != null) {
      return _battleState!.hpPercentage / 100;
    } else if (_currentEvent != null) {
      return _currentEvent!.hpPercentage;
    }
    return 1.0;
  }

  /// Get recent battle logs formatted for display
  List<String> getRecentBattleMessages({int limit = 5}) {
    if (_battleState?.recentLogs.isNotEmpty == true) {
      return _battleState!.recentLogs
          .take(limit)
          .map((log) => log.message)
          .toList();
    } else {
      return _battleLogs
          .take(limit)
          .map((log) => log.message)
          .toList();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadEvents(),
      loadCurrentEvent(),
    ]);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _stopRealTimeUpdates();
    super.dispose();
  }
}