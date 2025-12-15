// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrQualityProfile _$ReadarrQualityProfileFromJson(
        Map<String, dynamic> json) =>
    ReadarrQualityProfile(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      upgradeAllowed: json['upgradeAllowed'] as bool?,
      cutoff: (json['cutoff'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) =>
              ReadarrQualityProfileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadarrQualityProfileToJson(
    ReadarrQualityProfile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('upgradeAllowed', instance.upgradeAllowed);
  writeNotNull('cutoff', instance.cutoff);
  writeNotNull('items', instance.items?.map((e) => e.toJson()).toList());
  return val;
}
