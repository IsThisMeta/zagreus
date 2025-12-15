// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_profile_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQualityProfileItem _$ReadarrQualityProfileItemFromJson(
        Map<String, dynamic> json) =>
    ReadarrQualityProfileItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      quality: json['quality'] == null
          ? null
          : ReadarrQualityProfileItemQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) =>
              ReadarrQualityProfileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      allowed: json['allowed'] as bool?,
    );

Map<String, dynamic> _$ReadarrQualityProfileItemToJson(
    ReadarrQualityProfileItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('items', instance.items?.map((e) => e.toJson()).toList());
  writeNotNull('allowed', instance.allowed);
  return val;
}
