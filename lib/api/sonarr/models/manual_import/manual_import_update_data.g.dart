// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_update_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrManualImportUpdateData _$SonarrManualImportUpdateDataFromJson(
        Map<String, dynamic> json) =>
    SonarrManualImportUpdateData(
      id: (json['id'] as num?)?.toInt(),
      path: json['path'] as String?,
      seriesId: (json['seriesId'] as num?)?.toInt(),
      episodeIds: (json['episodeIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      quality: json['quality'] == null
          ? null
          : SonarrEpisodeFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) =>
              SonarrEpisodeFileLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseGroup: json['releaseGroup'] as String?,
      downloadId: json['downloadId'] as String?,
    );

Map<String, dynamic> _$SonarrManualImportUpdateDataToJson(
    SonarrManualImportUpdateData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('path', instance.path);
  writeNotNull('seriesId', instance.seriesId);
  writeNotNull('episodeIds', instance.episodeIds);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull(
      'languages', instance.languages?.map((e) => e.toJson()).toList());
  writeNotNull('releaseGroup', instance.releaseGroup);
  writeNotNull('downloadId', instance.downloadId);
  return val;
}
