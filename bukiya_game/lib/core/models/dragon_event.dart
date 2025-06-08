import 'package:json_annotation/json_annotation.dart';

part 'dragon_event.g.dart';

enum DragonEventStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('active')
  active,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class DragonEvent {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'dragon_max_hp')
  final int dragonMaxHp;
  @JsonKey(name: 'dragon_current_hp')
  final int dragonCurrentHp;
  @JsonKey(name: 'dragon_level')
  final int dragonLevel;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final DragonEventStatus status;
  @JsonKey(name: 'battle_duration_minutes')
  final int battleDurationMinutes;
  @JsonKey(name: 'damage_update_interval')
  final int damageUpdateInterval;
  @JsonKey(name: 'participation_reward_gold')
  final int participationRewardGold;
  @JsonKey(name: 'victory_bonus_gold')
  final int victoryBonusGold;
  @JsonKey(name: 'mvp_bonus_gold')
  final int mvpBonusGold;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<DragonParticipant> participants;

  DragonEvent({
    required this.id,
    required this.name,
    this.description,
    required this.dragonMaxHp,
    required this.dragonCurrentHp,
    required this.dragonLevel,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.battleDurationMinutes,
    required this.damageUpdateInterval,
    required this.participationRewardGold,
    required this.victoryBonusGold,
    required this.mvpBonusGold,
    required this.createdAt,
    required this.updatedAt,
    this.participants = const [],
  });

  factory DragonEvent.fromJson(Map<String, dynamic> json) =>
      _$DragonEventFromJson(json);

  Map<String, dynamic> toJson() => _$DragonEventToJson(this);

  // Helper methods
  double get hpPercentage => dragonCurrentHp / dragonMaxHp;
  bool get isActive => status == DragonEventStatus.active;
  bool get isCompleted => status == DragonEventStatus.completed;
  bool get isVictory => dragonCurrentHp <= 0;
  
  Duration get timeRemaining {
    final now = DateTime.now().toUtc();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }
  
  Duration get timeSinceStart {
    final now = DateTime.now().toUtc();
    if (now.isBefore(startTime)) return Duration.zero;
    return now.difference(startTime);
  }
}

@JsonSerializable()
class DragonEventSummary {
  final int id;
  final String name;
  @JsonKey(name: 'dragon_max_hp')
  final int dragonMaxHp;
  @JsonKey(name: 'dragon_current_hp')
  final int dragonCurrentHp;
  final DragonEventStatus status;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @JsonKey(name: 'participant_count')
  final int participantCount;
  @JsonKey(name: 'is_victory')
  final bool isVictory;

  DragonEventSummary({
    required this.id,
    required this.name,
    required this.dragonMaxHp,
    required this.dragonCurrentHp,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.participantCount,
    required this.isVictory,
  });

  factory DragonEventSummary.fromJson(Map<String, dynamic> json) =>
      _$DragonEventSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DragonEventSummaryToJson(this);

  double get hpPercentage => dragonCurrentHp / dragonMaxHp;
  bool get isActive => status == DragonEventStatus.active;
}

@JsonSerializable()
class DragonParticipant {
  final int id;
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'player_id')
  final int playerId;
  @JsonKey(name: 'adventurer_instance_id')
  final int adventurerInstanceId;
  @JsonKey(name: 'total_damage_dealt')
  final int totalDamageDealt;
  @JsonKey(name: 'participation_time')
  final DateTime participationTime;
  @JsonKey(name: 'rewards_claimed')
  final bool rewardsClaimed;
  @JsonKey(name: 'participation_reward')
  final int participationReward;
  @JsonKey(name: 'victory_bonus')
  final int victoryBonus;
  @JsonKey(name: 'mvp_bonus')
  final int mvpBonus;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  DragonParticipant({
    required this.id,
    required this.eventId,
    required this.playerId,
    required this.adventurerInstanceId,
    required this.totalDamageDealt,
    required this.participationTime,
    required this.rewardsClaimed,
    required this.participationReward,
    required this.victoryBonus,
    required this.mvpBonus,
    required this.createdAt,
  });

  factory DragonParticipant.fromJson(Map<String, dynamic> json) =>
      _$DragonParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$DragonParticipantToJson(this);

  int get totalRewards => participationReward + victoryBonus + mvpBonus;
}

@JsonSerializable()
class DragonBattleLog {
  final int id;
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'participant_id')
  final int? participantId;
  @JsonKey(name: 'action_type')
  final String actionType;
  @JsonKey(name: 'damage_dealt')
  final int damageDealt;
  final String message;
  @JsonKey(name: 'dragon_hp_after')
  final int dragonHpAfter;
  final DateTime timestamp;
  @JsonKey(name: 'battle_second')
  final int battleSecond;

  DragonBattleLog({
    required this.id,
    required this.eventId,
    this.participantId,
    required this.actionType,
    required this.damageDealt,
    required this.message,
    required this.dragonHpAfter,
    required this.timestamp,
    required this.battleSecond,
  });

  factory DragonBattleLog.fromJson(Map<String, dynamic> json) =>
      _$DragonBattleLogFromJson(json);

  Map<String, dynamic> toJson() => _$DragonBattleLogToJson(this);

  bool get isDragonAction => participantId == null;
  bool get isCriticalHit => actionType == 'critical_hit';
  bool get isSpecialAttack => actionType == 'special_attack';
}

@JsonSerializable()
class DragonBattleState {
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'dragon_current_hp')
  final int dragonCurrentHp;
  @JsonKey(name: 'dragon_max_hp')
  final int dragonMaxHp;
  @JsonKey(name: 'hp_percentage')
  final double hpPercentage;
  @JsonKey(name: 'time_remaining_seconds')
  final int timeRemainingSeconds;
  @JsonKey(name: 'participant_count')
  final int participantCount;
  @JsonKey(name: 'total_damage_dealt')
  final int totalDamageDealt;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'recent_logs')
  final List<DragonBattleLog> recentLogs;

  DragonBattleState({
    required this.eventId,
    required this.dragonCurrentHp,
    required this.dragonMaxHp,
    required this.hpPercentage,
    required this.timeRemainingSeconds,
    required this.participantCount,
    required this.totalDamageDealt,
    required this.isActive,
    required this.recentLogs,
  });

  factory DragonBattleState.fromJson(Map<String, dynamic> json) =>
      _$DragonBattleStateFromJson(json);

  Map<String, dynamic> toJson() => _$DragonBattleStateToJson(this);

  Duration get timeRemaining => Duration(seconds: timeRemainingSeconds);
  String get timeRemainingText {
    final minutes = timeRemainingSeconds ~/ 60;
    final seconds = timeRemainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

@JsonSerializable()
class DragonParticipationRequest {
  @JsonKey(name: 'adventurer_instance_id')
  final int adventurerInstanceId;

  DragonParticipationRequest({
    required this.adventurerInstanceId,
  });

  factory DragonParticipationRequest.fromJson(Map<String, dynamic> json) =>
      _$DragonParticipationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DragonParticipationRequestToJson(this);
}

@JsonSerializable()
class DragonRewardsResponse {
  @JsonKey(name: 'participation_reward')
  final int participationReward;
  @JsonKey(name: 'victory_bonus')
  final int victoryBonus;
  @JsonKey(name: 'mvp_bonus')
  final int mvpBonus;
  @JsonKey(name: 'total_reward')
  final int totalReward;
  @JsonKey(name: 'is_mvp')
  final bool isMvp;
  final int rank;
  @JsonKey(name: 'total_damage')
  final int totalDamage;

  DragonRewardsResponse({
    required this.participationReward,
    required this.victoryBonus,
    required this.mvpBonus,
    required this.totalReward,
    required this.isMvp,
    required this.rank,
    required this.totalDamage,
  });

  factory DragonRewardsResponse.fromJson(Map<String, dynamic> json) =>
      _$DragonRewardsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DragonRewardsResponseToJson(this);
}

@JsonSerializable()
class DragonEventStats {
  final DragonEvent event;
  @JsonKey(name: 'total_participants')
  final int totalParticipants;
  @JsonKey(name: 'total_damage_dealt')
  final int totalDamageDealt;
  @JsonKey(name: 'top_participants')
  final List<DragonLeaderboardEntry> topParticipants;
  @JsonKey(name: 'is_victory')
  final bool isVictory;
  @JsonKey(name: 'mvp_player_name')
  final String? mvpPlayerName;

  DragonEventStats({
    required this.event,
    required this.totalParticipants,
    required this.totalDamageDealt,
    required this.topParticipants,
    required this.isVictory,
    this.mvpPlayerName,
  });

  factory DragonEventStats.fromJson(Map<String, dynamic> json) =>
      _$DragonEventStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DragonEventStatsToJson(this);
}

@JsonSerializable()
class DragonLeaderboardEntry {
  @JsonKey(name: 'player_name')
  final String playerName;
  final int damage;
  final int rank;

  DragonLeaderboardEntry({
    required this.playerName,
    required this.damage,
    required this.rank,
  });

  factory DragonLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$DragonLeaderboardEntryFromJson(json);

  Map<String, dynamic> toJson() => _$DragonLeaderboardEntryToJson(this);
}