// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author_ratings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrAuthorRatings _$ReadarrAuthorRatingsFromJson(
        Map<String, dynamic> json) =>
    ReadarrAuthorRatings(
      votes: (json['votes'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toDouble(),
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReadarrAuthorRatingsToJson(
    ReadarrAuthorRatings instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('votes', instance.votes);
  writeNotNull('value', instance.value);
  writeNotNull('popularity', instance.popularity);
  return val;
}
