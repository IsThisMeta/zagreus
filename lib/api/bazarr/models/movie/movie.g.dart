// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BazarrMovie _$BazarrMovieFromJson(Map<String, dynamic> json) => BazarrMovie(
      radarrId: (json['radarrId'] as num?)?.toInt(),
      title: json['title'] as String?,
      path: json['path'] as String?,
      sceneName: json['sceneName'] as String?,
      profileId: (json['profileId'] as num?)?.toInt(),
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

Map<String, dynamic> _$BazarrMovieToJson(BazarrMovie instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('radarrId', instance.radarrId);
  writeNotNull('title', instance.title);
  writeNotNull('path', instance.path);
  writeNotNull('sceneName', instance.sceneName);
  writeNotNull('profileId', instance.profileId);
  writeNotNull('audio_language', instance.audioLanguage);
  writeNotNull(
      'subtitles', instance.existingSubtitles?.map((e) => e.toJson()).toList());
  writeNotNull('missing_subtitles',
      instance.missingSubtitles?.map((e) => e.toJson()).toList());
  return val;
}
