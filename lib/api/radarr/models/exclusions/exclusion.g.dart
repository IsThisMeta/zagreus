// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exclusion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrExclusion _$RadarrExclusionFromJson(Map<String, dynamic> json) =>
    RadarrExclusion(
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
      movieTitle: json['movieTitle'] as String?,
      movieYear: (json['movieYear'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RadarrExclusionToJson(RadarrExclusion instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('tmdbId', instance.tmdbId);
  writeNotNull('movieTitle', instance.movieTitle);
  writeNotNull('movieYear', instance.movieYear);
  writeNotNull('id', instance.id);
  return val;
}
