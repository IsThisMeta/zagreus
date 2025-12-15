// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrHealthCheck _$ReadarrHealthCheckFromJson(Map<String, dynamic> json) =>
    ReadarrHealthCheck(
      source: json['source'] as String?,
      type: json['type'] as String?,
      message: json['message'] as String?,
      wikiUrl: json['wikiUrl'] as String?,
    );

Map<String, dynamic> _$ReadarrHealthCheckToJson(ReadarrHealthCheck instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('source', instance.source);
  writeNotNull('type', instance.type);
  writeNotNull('message', instance.message);
  writeNotNull('wikiUrl', instance.wikiUrl);
  return val;
}
