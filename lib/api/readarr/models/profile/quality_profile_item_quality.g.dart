// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_profile_item_quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQualityProfileItemQuality _$ReadarrQualityProfileItemQualityFromJson(
        Map<String, dynamic> json) =>
    ReadarrQualityProfileItemQuality(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ReadarrQualityProfileItemQualityToJson(
    ReadarrQualityProfileItemQuality instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  return val;
}
