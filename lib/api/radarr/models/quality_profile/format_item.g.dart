// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'format_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrQualityProfileFormatItem _$RadarrQualityProfileFormatItemFromJson(
        Map<String, dynamic> json) =>
    RadarrQualityProfileFormatItem(
      format: (json['format'] as num?)?.toInt(),
      name: json['name'] as String?,
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RadarrQualityProfileFormatItemToJson(
    RadarrQualityProfileFormatItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('format', instance.format);
  writeNotNull('name', instance.name);
  writeNotNull('score', instance.score);
  return val;
}
