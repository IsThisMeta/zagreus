// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrManualImportUpdate _$SonarrManualImportUpdateFromJson(
        Map<String, dynamic> json) =>
    SonarrManualImportUpdate(
      path: json['path'] as String?,
      seriesId: (json['seriesId'] as num?)?.toInt(),
      episodeIds: (json['episodeIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      series: json['series'] == null
          ? null
          : SonarrSeries.fromJson(json['series'] as Map<String, dynamic>),
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => SonarrEpisode.fromJson(e as Map<String, dynamic>))
          .toList(),
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) =>
              SonarrManualImportRejection.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SonarrManualImportUpdateToJson(
    SonarrManualImportUpdate instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('seriesId', instance.seriesId);
  writeNotNull('episodeIds', instance.episodeIds);
  writeNotNull('series', instance.series?.toJson());
  writeNotNull('episodes', instance.episodes?.map((e) => e.toJson()).toList());
  writeNotNull(
      'rejections', instance.rejections?.map((e) => e.toJson()).toList());
  writeNotNull('id', instance.id);
  return val;
}
