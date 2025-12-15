// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_file_quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookFileQuality _$ReadarrBookFileQualityFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookFileQuality(
      quality: json['quality'] == null
          ? null
          : ReadarrBookFileQualityQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      revision: json['revision'] == null
          ? null
          : ReadarrBookFileQualityRevision.fromJson(
              json['revision'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadarrBookFileQualityToJson(
    ReadarrBookFileQuality instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('revision', instance.revision?.toJson());
  return val;
}
