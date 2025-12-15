// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SABnzbdServer _$SABnzbdServerFromJson(Map<String, dynamic> json) =>
    SABnzbdServer(
      dailyUsage: (json['day'] as num).toInt(),
      weeklyUsage: (json['week'] as num).toInt(),
      monthlyUsage: (json['month'] as num).toInt(),
      totalUsage: (json['total'] as num).toInt(),
      daily: (json['daily'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$SABnzbdServerToJson(SABnzbdServer instance) {
  final val = <String, dynamic>{
    'day': instance.dailyUsage,
    'week': instance.weeklyUsage,
    'month': instance.monthlyUsage,
    'total': instance.totalUsage,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('daily', instance.daily);
  return val;
}
