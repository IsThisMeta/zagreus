// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_file_quality_quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookFileQualityQuality _$ReadarrBookFileQualityQualityFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookFileQualityQuality(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ReadarrBookFileQualityQualityToJson(
    ReadarrBookFileQualityQuality instance) {
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
