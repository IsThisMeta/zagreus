// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_watch_time_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliLibraryWatchTimeStats _$TautulliLibraryWatchTimeStatsFromJson(
        Map<String, dynamic> json) =>
    TautulliLibraryWatchTimeStats(
      queryDays: TautulliUtilities.ensureIntegerFromJson(json['query_days']),
      totalPlays: TautulliUtilities.ensureIntegerFromJson(json['total_plays']),
      totalTime: TautulliUtilities.secondsDurationFromJson(json['total_time']),
    );

Map<String, dynamic> _$TautulliLibraryWatchTimeStatsToJson(
    TautulliLibraryWatchTimeStats instance) {
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
