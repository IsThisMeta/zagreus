// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrEpisode _$BazarrEpisodeFromJson(Map<String, dynamic> json) =>
    BazarrEpisode(
      sonarrSeriesId: (json['sonarrSeriesId'] as num?)?.toInt(),
      sonarrEpisodeId: (json['sonarrEpisodeId'] as num?)?.toInt(),
      title: json['title'] as String?,
      path: json['path'] as String?,
      sceneName: json['sceneName'] as String?,
      season: (json['season'] as num?)?.toInt(),
      episode: (json['episode'] as num?)?.toInt(),
      audioLanguage: (json['audio_language'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      existingSubtitles: (json['subtitles'] as List<dynamic>?)
          ?.map((e) => BazarrSubtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
      missingSubtitles: (json['missing_subtitles'] as List<dynamic>?)
          ?.map((e) => BazarrSubtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BazarrEpisodeToJson(BazarrEpisode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sonarrSeriesId', instance.sonarrSeriesId);
  writeNotNull('sonarrEpisodeId', instance.sonarrEpisodeId);
  writeNotNull('title', instance.title);
  writeNotNull('path', instance.path);
  writeNotNull('sceneName', instance.sceneName);
  writeNotNull('season', instance.season);
  writeNotNull('episode', instance.episode);
  writeNotNull('audio_language', instance.audioLanguage);
  writeNotNull(
      'subtitles', instance.existingSubtitles?.map((e) => e.toJson()).toList());
  writeNotNull('missing_subtitles',
      instance.missingSubtitles?.map((e) => e.toJson()).toList());
  return val;
}
