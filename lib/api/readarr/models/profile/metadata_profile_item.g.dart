// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_profile_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrMetadataProfileItem _$ReadarrMetadataProfileItemFromJson(
        Map<String, dynamic> json) =>
    ReadarrMetadataProfileItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      allowed: json['allowed'] as bool?,
    );

Map<String, dynamic> _$ReadarrMetadataProfileItemToJson(
    ReadarrMetadataProfileItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('allowed', instance.allowed);
  return val;
}
