// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliActivity _$TautulliActivityFromJson(Map<String, dynamic> json) =>
    TautulliActivity(
      streamCount:
          TautulliUtilities.ensureIntegerFromJson(json['stream_count']),
      streamCountDirectPlay: TautulliUtilities.ensureIntegerFromJson(
          json['stream_count_direct_play']),
      streamCountDirectStream: TautulliUtilities.ensureIntegerFromJson(
          json['stream_count_direct_stream']),
      streamCountTranscode: TautulliUtilities.ensureIntegerFromJson(
          json['stream_count_transcode']),
      totalBandwidth:
          TautulliUtilities.ensureIntegerFromJson(json['total_bandwidth']),
      lanBandwidth:
          TautulliUtilities.ensureIntegerFromJson(json['lan_bandwidth']),
      wanBandwidth:
          TautulliUtilities.ensureIntegerFromJson(json['wan_bandwidth']),
      sessions: TautulliActivity._sessionsFromJson(json['sessions'] as List),
    );

Map<String, dynamic> _$TautulliActivityToJson(TautulliActivity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sessions', TautulliActivity._sessionsToJson(instance.sessions));
  writeNotNull('stream_count', instance.streamCount);
  writeNotNull('stream_count_direct_play', instance.streamCountDirectPlay);
  writeNotNull('stream_count_direct_stream', instance.streamCountDirectStream);
  writeNotNull('stream_count_transcode', instance.streamCountTranscode);
  writeNotNull('total_bandwidth', instance.totalBandwidth);
  writeNotNull('lan_bandwidth', instance.lanBandwidth);
  writeNotNull('wan_bandwidth', instance.wanBandwidth);
  return val;
}
