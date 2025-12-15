// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parity_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnraidParityInfo _$UnraidParityInfoFromJson(Map<String, dynamic> json) =>
    UnraidParityInfo(
      date: json['date'] as String?,
      duration: parseNullableInt(json['duration']),
      speed: json['speed'] as String?,
      status: json['status'] as String?,
      errors: parseNullableInt(json['errors']),
      progress: parseNullableDouble(json['progress']),
      correcting: json['correcting'] as bool?,
      paused: json['paused'] as bool?,
      running: json['running'] as bool?,
    );

Map<String, dynamic> _$UnraidParityInfoToJson(UnraidParityInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('date', instance.date);
  writeNotNull('duration', instance.duration);
  writeNotNull('speed', instance.speed);
  writeNotNull('status', instance.status);
  writeNotNull('errors', instance.errors);
  writeNotNull('progress', instance.progress);
  writeNotNull('correcting', instance.correcting);
  writeNotNull('paused', instance.paused);
  writeNotNull('running', instance.running);
  return val;
}
