// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrTag _$ReadarrTagFromJson(Map<String, dynamic> json) => ReadarrTag(
      id: (json['id'] as num?)?.toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$ReadarrTagToJson(ReadarrTag instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('label', instance.label);
  return val;
}
