// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dragon_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DragonEvent _$DragonEventFromJson(Map<String, dynamic> json) => DragonEvent(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      dragonMaxHp: (json['dragon_max_hp'] as num).toInt(),
      dragonCurrentHp: (json['dragon_current_hp'] as num).toInt(),
      dragonLevel: (json['dragon_level'] as num).toInt(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: $enumDecode(_$DragonEventStatusEnumMap, json['status']),
      battleDurationMinutes: (json['battle_duration_minutes'] as num).toInt(),
      damageUpdateInterval: (json['damage_update_interval'] as num).toInt(),
      participationRewardGold:
          (json['participation_reward_gold'] as num).toInt(),
      victoryBonusGold: (json['victory_bonus_gold'] as num).toInt(),
      mvpBonusGold: (json['mvp_bonus_gold'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participants: (json['participants'] as List<dynamic>?)
              ?.map(
                  (e) => DragonParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DragonEventToJson(DragonEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dragon_max_hp': instance.dragonMaxHp,
      'dragon_current_hp': instance.dragonCurrentHp,
      'dragon_level': instance.dragonLevel,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'status': _$DragonEventStatusEnumMap[instance.status]!,
      'battle_duration_minutes': instance.battleDurationMinutes,
      'damage_update_interval': instance.damageUpdateInterval,
      'participation_reward_gold': instance.participationRewardGold,
      'victory_bonus_gold': instance.victoryBonusGold,
      'mvp_bonus_gold': instance.mvpBonusGold,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'participants': instance.participants,
    };

const _$DragonEventStatusEnumMap = {
  DragonEventStatus.scheduled: 'scheduled',
  DragonEventStatus.active: 'active',
  DragonEventStatus.completed: 'completed',
  DragonEventStatus.cancelled: 'cancelled',
};

DragonEventSummary _$DragonEventSummaryFromJson(Map<String, dynamic> json) =>
    DragonEventSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      dragonMaxHp: (json['dragon_max_hp'] as num).toInt(),
      dragonCurrentHp: (json['dragon_current_hp'] as num).toInt(),
      status: $enumDecode(_$DragonEventStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      participantCount: (json['participant_count'] as num).toInt(),
      isVictory: json['is_victory'] as bool,
    );

Map<String, dynamic> _$DragonEventSummaryToJson(DragonEventSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dragon_max_hp': instance.dragonMaxHp,
      'dragon_current_hp': instance.dragonCurrentHp,
      'status': _$DragonEventStatusEnumMap[instance.status]!,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'participant_count': instance.participantCount,
      'is_victory': instance.isVictory,
    };

DragonParticipant _$DragonParticipantFromJson(Map<String, dynamic> json) =>
    DragonParticipant(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      playerId: (json['player_id'] as num).toInt(),
      adventurerInstanceId: (json['adventurer_instance_id'] as num).toInt(),
      totalDamageDealt: (json['total_damage_dealt'] as num).toInt(),
      participationTime: DateTime.parse(json['participation_time'] as String),
      rewardsClaimed: json['rewards_claimed'] as bool,
      participationReward: (json['participation_reward'] as num).toInt(),
      victoryBonus: (json['victory_bonus'] as num).toInt(),
      mvpBonus: (json['mvp_bonus'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DragonParticipantToJson(DragonParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'player_id': instance.playerId,
      'adventurer_instance_id': instance.adventurerInstanceId,
      'total_damage_dealt': instance.totalDamageDealt,
      'participation_time': instance.participationTime.toIso8601String(),
      'rewards_claimed': instance.rewardsClaimed,
      'participation_reward': instance.participationReward,
      'victory_bonus': instance.victoryBonus,
      'mvp_bonus': instance.mvpBonus,
      'created_at': instance.createdAt.toIso8601String(),
    };

DragonBattleLog _$DragonBattleLogFromJson(Map<String, dynamic> json) =>
    DragonBattleLog(
      id: (json['id'] as num).toInt(),
      eventId: (json['event_id'] as num).toInt(),
      participantId: (json['participant_id'] as num?)?.toInt(),
      actionType: json['action_type'] as String,
      damageDealt: (json['damage_dealt'] as num).toInt(),
      message: json['message'] as String,
      dragonHpAfter: (json['dragon_hp_after'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      battleSecond: (json['battle_second'] as num).toInt(),
    );

Map<String, dynamic> _$DragonBattleLogToJson(DragonBattleLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'participant_id': instance.participantId,
      'action_type': instance.actionType,
      'damage_dealt': instance.damageDealt,
      'message': instance.message,
      'dragon_hp_after': instance.dragonHpAfter,
      'timestamp': instance.timestamp.toIso8601String(),
      'battle_second': instance.battleSecond,
    };

DragonBattleState _$DragonBattleStateFromJson(Map<String, dynamic> json) =>
    DragonBattleState(
      eventId: (json['event_id'] as num).toInt(),
      dragonCurrentHp: (json['dragon_current_hp'] as num).toInt(),
      dragonMaxHp: (json['dragon_max_hp'] as num).toInt(),
      hpPercentage: (json['hp_percentage'] as num).toDouble(),
      timeRemainingSeconds: (json['time_remaining_seconds'] as num).toInt(),
      participantCount: (json['participant_count'] as num).toInt(),
      totalDamageDealt: (json['total_damage_dealt'] as num).toInt(),
      isActive: json['is_active'] as bool,
      recentLogs: (json['recent_logs'] as List<dynamic>)
          .map((e) => DragonBattleLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DragonBattleStateToJson(DragonBattleState instance) =>
    <String, dynamic>{
      'event_id': instance.eventId,
      'dragon_current_hp': instance.dragonCurrentHp,
      'dragon_max_hp': instance.dragonMaxHp,
      'hp_percentage': instance.hpPercentage,
      'time_remaining_seconds': instance.timeRemainingSeconds,
      'participant_count': instance.participantCount,
      'total_damage_dealt': instance.totalDamageDealt,
      'is_active': instance.isActive,
      'recent_logs': instance.recentLogs,
    };

DragonParticipationRequest _$DragonParticipationRequestFromJson(
        Map<String, dynamic> json) =>
    DragonParticipationRequest(
      adventurerInstanceId: (json['adventurer_instance_id'] as num).toInt(),
    );

Map<String, dynamic> _$DragonParticipationRequestToJson(
        DragonParticipationRequest instance) =>
    <String, dynamic>{
      'adventurer_instance_id': instance.adventurerInstanceId,
    };

DragonRewardsResponse _$DragonRewardsResponseFromJson(
        Map<String, dynamic> json) =>
    DragonRewardsResponse(
      participationReward: (json['participation_reward'] as num).toInt(),
      victoryBonus: (json['victory_bonus'] as num).toInt(),
      mvpBonus: (json['mvp_bonus'] as num).toInt(),
      totalReward: (json['total_reward'] as num).toInt(),
      isMvp: json['is_mvp'] as bool,
      rank: (json['rank'] as num).toInt(),
      totalDamage: (json['total_damage'] as num).toInt(),
    );

Map<String, dynamic> _$DragonRewardsResponseToJson(
        DragonRewardsResponse instance) =>
    <String, dynamic>{
      'participation_reward': instance.participationReward,
      'victory_bonus': instance.victoryBonus,
      'mvp_bonus': instance.mvpBonus,
      'total_reward': instance.totalReward,
      'is_mvp': instance.isMvp,
      'rank': instance.rank,
      'total_damage': instance.totalDamage,
    };

DragonEventStats _$DragonEventStatsFromJson(Map<String, dynamic> json) =>
    DragonEventStats(
      event: DragonEvent.fromJson(json['event'] as Map<String, dynamic>),
      totalParticipants: (json['total_participants'] as num).toInt(),
      totalDamageDealt: (json['total_damage_dealt'] as num).toInt(),
      topParticipants: (json['top_participants'] as List<dynamic>)
          .map(
              (e) => DragonLeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      isVictory: json['is_victory'] as bool,
      mvpPlayerName: json['mvp_player_name'] as String?,
    );

Map<String, dynamic> _$DragonEventStatsToJson(DragonEventStats instance) =>
    <String, dynamic>{
      'event': instance.event,
      'total_participants': instance.totalParticipants,
      'total_damage_dealt': instance.totalDamageDealt,
      'top_participants': instance.topParticipants,
      'is_victory': instance.isVictory,
      'mvp_player_name': instance.mvpPlayerName,
    };

DragonLeaderboardEntry _$DragonLeaderboardEntryFromJson(
        Map<String, dynamic> json) =>
    DragonLeaderboardEntry(
      playerName: json['player_name'] as String,
      damage: (json['damage'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
    );

Map<String, dynamic> _$DragonLeaderboardEntryToJson(
        DragonLeaderboardEntry instance) =>
    <String, dynamic>{
      'player_name': instance.playerName,
      'damage': instance.damage,
      'rank': instance.rank,
    };
