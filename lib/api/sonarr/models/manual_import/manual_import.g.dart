// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrManualImport _$SonarrManualImportFromJson(Map<String, dynamic> json) =>
    SonarrManualImport(
      path: json['path'] as String?,
      relativePath: json['relativePath'] as String?,
      folderName: json['folderName'] as String?,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toInt(),
      series: json['series'] == null
          ? null
          : SonarrSeries.fromJson(json['series'] as Map<String, dynamic>),
      episode: json['episode'] == null
          ? null
          : SonarrEpisode.fromJson(json['episode'] as Map<String, dynamic>),
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => SonarrEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
      quality: json['quality'] == null
          ? null
          : SonarrEpisodeFileQuality.fromJson(
              json['quality'] as Map<String, dynamic>),
      language: json['language'] == null
          ? null
          : SonarrEpisodeFileLanguage.fromJson(
              json['language'] as Map<String, dynamic>),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) =>
              SonarrEpisodeFileLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
      releaseGroup: json['releaseGroup'] as String?,
      releaseType: json['releaseType'] as String?,
      qualityWeight: (json['qualityWeight'] as num?)?.toInt(),
      downloadId: json['downloadId'] as String?,
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) =>
              SonarrManualImportRejection.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SonarrManualImportToJson(SonarrManualImport instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('relativePath', instance.relativePath);
  writeNotNull('folderName', instance.folderName);
  writeNotNull('name', instance.name);
  writeNotNull('size', instance.size);
  writeNotNull('series', instance.series?.toJson());
  writeNotNull('episode', instance.episode?.toJson());
  writeNotNull('episodes', instance.episodes?.map((e) => e.toJson()).toList());
  writeNotNull('quality', instance.quality?.toJson());
  writeNotNull('language', instance.language?.toJson());
  writeNotNull(
      'languages', instance.languages?.map((e) => e.toJson()).toList());
  writeNotNull('releaseGroup', instance.releaseGroup);
  writeNotNull('releaseType', instance.releaseType);
  writeNotNull('qualityWeight', instance.qualityWeight);
  writeNotNull('downloadId', instance.downloadId);
  writeNotNull(
      'rejections', instance.rejections?.map((e) => e.toJson()).toList());
  writeNotNull('id', instance.id);
  return val;
}
