// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_profile_cutoff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQualityProfileCutoff _$ReadarrQualityProfileCutoffFromJson(
        Map<String, dynamic> json) =>
    ReadarrQualityProfileCutoff(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ReadarrQualityProfileCutoffToJson(
    ReadarrQualityProfileCutoff instance) {
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
