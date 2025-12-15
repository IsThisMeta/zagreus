// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_watch_time_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliUserWatchTimeStats _$TautulliUserWatchTimeStatsFromJson(
        Map<String, dynamic> json) =>
    TautulliUserWatchTimeStats(
      queryDays: TautulliUtilities.ensureIntegerFromJson(json['query_days']),
      totalPlays: TautulliUtilities.ensureIntegerFromJson(json['total_plays']),
      totalTime: TautulliUtilities.secondsDurationFromJson(json['total_time']),
    );

Map<String, dynamic> _$TautulliUserWatchTimeStatsToJson(
    TautulliUserWatchTimeStats instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('query_days', instance.queryDays);
  writeNotNull('total_plays', instance.totalPlays);
  writeNotNull('total_time', instance.totalTime?.inMicroseconds);
  return val;
}
