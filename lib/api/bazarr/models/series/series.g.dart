// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrSeries _$BazarrSeriesFromJson(Map<String, dynamic> json) => BazarrSeries(
      sonarrSeriesId: (json['sonarrSeriesId'] as num?)?.toInt(),
      title: json['title'] as String?,
      path: json['path'] as String?,
      profileId: (json['profileId'] as num?)?.toInt(),
      episodeFileCount: (json['episodeFileCount'] as num?)?.toInt(),
      episodesMissing: (json['episodesMissing'] as num?)?.toInt(),
      audioLanguage: (json['audio_language'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$BazarrSeriesToJson(BazarrSeries instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sonarrSeriesId', instance.sonarrSeriesId);
  writeNotNull('title', instance.title);
  writeNotNull('path', instance.path);
  writeNotNull('profileId', instance.profileId);
  writeNotNull('episodeFileCount', instance.episodeFileCount);
  writeNotNull('episodesMissing', instance.episodesMissing);
  writeNotNull('audio_language', instance.audioLanguage);
  return val;
}
