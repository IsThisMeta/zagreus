// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_file_quality_revision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookFileQualityRevision _$ReadarrBookFileQualityRevisionFromJson(
        Map<String, dynamic> json) =>
    ReadarrBookFileQualityRevision(
      version: (json['version'] as num?)?.toInt(),
      real: (json['real'] as num?)?.toInt(),
      isRepack: json['isRepack'] as bool?,
    );

Map<String, dynamic> _$ReadarrBookFileQualityRevisionToJson(
    ReadarrBookFileQualityRevision instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('version', instance.version);
  writeNotNull('real', instance.real);
  writeNotNull('isRepack', instance.isRepack);
  return val;
}
