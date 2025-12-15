// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exclusion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrExclusion _$ReadarrExclusionFromJson(Map<String, dynamic> json) =>
    ReadarrExclusion(
      id: (json['id'] as num?)?.toInt(),
      foreignId: json['foreignId'] as String?,
      authorName: json['authorName'] as String?,
    );

Map<String, dynamic> _$ReadarrExclusionToJson(ReadarrExclusion instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('foreignId', instance.foreignId);
  writeNotNull('authorName', instance.authorName);
  return val;
}
