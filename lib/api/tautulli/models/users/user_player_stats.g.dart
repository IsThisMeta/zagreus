// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_player_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserPlayerStats _$TautulliUserPlayerStatsFromJson(
        Map<String, dynamic> json) =>
    TautulliUserPlayerStats(
      resultId: TautulliUtilities.ensureIntegerFromJson(json['result_id']),
      totalPlays: TautulliUtilities.ensureIntegerFromJson(json['total_plays']),
      platform: TautulliUtilities.ensureStringFromJson(json['platform']),
      platformName:
          TautulliUtilities.ensureStringFromJson(json['platform_name']),
      playerName: TautulliUtilities.ensureStringFromJson(json['player_name']),
    );

Map<String, dynamic> _$TautulliUserPlayerStatsToJson(
    TautulliUserPlayerStats instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('result_id', instance.resultId);
  writeNotNull('total_plays', instance.totalPlays);
  writeNotNull('player_name', instance.playerName);
  writeNotNull('platform', instance.platform);
  writeNotNull('platform_name', instance.platformName);
  return val;
}
