// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrLanguageProfile _$BazarrLanguageProfileFromJson(
        Map<String, dynamic> json) =>
    BazarrLanguageProfile(
      profileId: (json['profileId'] as num?)?.toInt(),
      name: json['name'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) =>
              BazarrLanguageProfileItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      cutoff: (json['cutoff'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BazarrLanguageProfileToJson(
    BazarrLanguageProfile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('profileId', instance.profileId);
  writeNotNull('name', instance.name);
  writeNotNull('items', instance.items?.map((e) => e.toJson()).toList());
  writeNotNull('cutoff', instance.cutoff);
  return val;
}

BazarrLanguageProfileItem _$BazarrLanguageProfileItemFromJson(
        Map<String, dynamic> json) =>
    BazarrLanguageProfileItem(
      id: (json['id'] as num?)?.toInt(),
      language: json['language'] as String?,
      forced: json['forced'] as String?,
      hearingImpaired: json['hi'] as String?,
      audioExclude: json['audio_exclude'] as String?,
    );

Map<String, dynamic> _$BazarrLanguageProfileItemToJson(
    BazarrLanguageProfileItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('language', instance.language);
  writeNotNull('forced', instance.forced);
  writeNotNull('hi', instance.hearingImpaired);
  writeNotNull('audio_exclude', instance.audioExclude);
  return val;
}
