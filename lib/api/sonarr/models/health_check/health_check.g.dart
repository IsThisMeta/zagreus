// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrHealthCheck _$SonarrHealthCheckFromJson(Map<String, dynamic> json) =>
    SonarrHealthCheck(
      source: json['source'] as String?,
      type: SonarrUtilities.healthCheckTypeFromJson(json['type'] as String?),
      message: json['message'] as String?,
      wikiUrl: json['wikiUrl'] as String?,
    );

Map<String, dynamic> _$SonarrHealthCheckToJson(SonarrHealthCheck instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('source', instance.source);
  writeNotNull('type', SonarrUtilities.healthCheckTypeToJson(instance.type));
  writeNotNull('message', instance.message);
  writeNotNull('wikiUrl', instance.wikiUrl);
  return val;
}
