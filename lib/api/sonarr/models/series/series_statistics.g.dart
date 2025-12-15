// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SonarrSeriesStatistics _$SonarrSeriesStatisticsFromJson(
        Map<String, dynamic> json) =>
    SonarrSeriesStatistics(
      episodeFileCount: (json['episodeFileCount'] as num?)?.toInt(),
      episodeCount: (json['episodeCount'] as num?)?.toInt(),
      totalEpisodeCount: (json['totalEpisodeCount'] as num?)?.toInt(),
      sizeOnDisk: (json['sizeOnDisk'] as num?)?.toInt(),
      percentOfEpisodes: (json['percentOfEpisodes'] as num?)?.toDouble(),
    )..seasonCount = (json['seasonCount'] as num?)?.toInt();

Map<String, dynamic> _$SonarrSeriesStatisticsToJson(
    SonarrSeriesStatistics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('seasonCount', instance.seasonCount);
  writeNotNull('episodeFileCount', instance.episodeFileCount);
  writeNotNull('episodeCount', instance.episodeCount);
  writeNotNull('totalEpisodeCount', instance.totalEpisodeCount);
  writeNotNull('sizeOnDisk', instance.sizeOnDisk);
  writeNotNull('percentOfEpisodes', instance.percentOfEpisodes);
  return val;
}
