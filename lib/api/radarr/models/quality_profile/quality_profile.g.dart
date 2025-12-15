// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrQualityProfile _$RadarrQualityProfileFromJson(
        Map<String, dynamic> json) =>
    RadarrQualityProfile(
      name: json['name'] as String?,
      upgradeAllowed: json['upgradeAllowed'] as bool?,
      cutoff: (json['cutoff'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) =>
              RadarrQualityProfileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      minFormatScore: (json['minFormatScore'] as num?)?.toInt(),
      cutoffFormatScore: (json['cutoffFormatScore'] as num?)?.toInt(),
      formatItems: (json['formatItems'] as List<dynamic>?)
          ?.map((e) => RadarrQualityProfileFormatItem.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      language: json['language'] == null
          ? null
          : RadarrLanguage.fromJson(json['language'] as Map<String, dynamic>),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RadarrQualityProfileToJson(
    RadarrQualityProfile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  writeNotNull('upgradeAllowed', instance.upgradeAllowed);
  writeNotNull('cutoff', instance.cutoff);
  writeNotNull('items', instance.items?.map((e) => e.toJson()).toList());
  writeNotNull('minFormatScore', instance.minFormatScore);
  writeNotNull('cutoffFormatScore', instance.cutoffFormatScore);
  writeNotNull(
      'formatItems', instance.formatItems?.map((e) => e.toJson()).toList());
  writeNotNull('language', instance.language?.toJson());
  writeNotNull('id', instance.id);
  return val;
}
