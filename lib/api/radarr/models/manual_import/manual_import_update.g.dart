// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_import_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RadarrManualImportUpdate _$RadarrManualImportUpdateFromJson(
        Map<String, dynamic> json) =>
    RadarrManualImportUpdate(
      path: json['path'] as String?,
      movieId: (json['movieId'] as num?)?.toInt(),
      movie: json['movie'] == null
          ? null
          : RadarrMovie.fromJson(json['movie'] as Map<String, dynamic>),
      rejections: (json['rejections'] as List<dynamic>?)
          ?.map((e) =>
              RadarrManualImportRejection.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RadarrManualImportUpdateToJson(
    RadarrManualImportUpdate instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('path', instance.path);
  writeNotNull('movieId', instance.movieId);
  writeNotNull('movie', instance.movie?.toJson());
  writeNotNull(
      'rejections', instance.rejections?.map((e) => e.toJson()).toList());
  writeNotNull('id', instance.id);
  return val;
}
