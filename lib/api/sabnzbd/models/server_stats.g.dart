// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdServerStats _$SABnzbdServerStatsFromJson(Map<String, dynamic> json) =>
    SABnzbdServerStats(
      dailyUsage: (json['day'] as num).toInt(),
      weeklyUsage: (json['week'] as num).toInt(),
      monthlyUsage: (json['month'] as num).toInt(),
      totalUsage: (json['total'] as num).toInt(),
      servers: (json['servers'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, SABnzbdServer.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SABnzbdServerStatsToJson(SABnzbdServerStats instance) =>
    <String, dynamic>{
      'day': instance.dailyUsage,
      'week': instance.weeklyUsage,
      'month': instance.monthlyUsage,
      'total': instance.totalUsage,
      'servers': instance.servers.map((k, e) => MapEntry(k, e.toJson())),
    };
