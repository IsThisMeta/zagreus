// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrMetadataProfile _$ReadarrMetadataProfileFromJson(
        Map<String, dynamic> json) =>
    ReadarrMetadataProfile(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      minPopularity: (json['minPopularity'] as num?)?.toDouble(),
      skipMissingDate: json['skipMissingDate'] as bool?,
      skipMissingIsbn: json['skipMissingIsbn'] as bool?,
      skipPartsAndSets: json['skipPartsAndSets'] as bool?,
      skipSeriesSecondary: json['skipSeriesSecondary'] as bool?,
      allowedLanguages: json['allowedLanguages'] as String?,
      minPages: (json['minPages'] as num?)?.toInt(),
      ignored: json['ignored'] as String?,
    );

Map<String, dynamic> _$ReadarrMetadataProfileToJson(
    ReadarrMetadataProfile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('minPopularity', instance.minPopularity);
  writeNotNull('skipMissingDate', instance.skipMissingDate);
  writeNotNull('skipMissingIsbn', instance.skipMissingIsbn);
  writeNotNull('skipPartsAndSets', instance.skipPartsAndSets);
  writeNotNull('skipSeriesSecondary', instance.skipSeriesSecondary);
  writeNotNull('allowedLanguages', instance.allowedLanguages);
  writeNotNull('minPages', instance.minPages);
  writeNotNull('ignored', instance.ignored);
  return val;
}
