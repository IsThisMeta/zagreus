// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrManualImportFile _$SonarrManualImportFileFromJson(
        Map<String, dynamic> json) =>
    SonarrManualImportFile(
      path: json['path'] as String?,
      folderName: json['folderName'] as String?,
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
      releaseType: json['releaseType'] as String?,
      downloadId: json['downloadId'] as String?,
    );

Map<String, dynamic> _$SonarrManualImportFileToJson(
    SonarrManualImportFile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('folderName', instance.folderName);
  writeNotNull('seriesId', instance.seriesId);
  writeNotNull('episodeIds', instance.episodeIds);
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull(
      'languages', instance.languages?.map((e) => e.toJson()).toList());
  writeNotNull('releaseGroup', instance.releaseGroup);
  writeNotNull('releaseType', instance.releaseType);
  writeNotNull('downloadId', instance.downloadId);
  return val;
}
