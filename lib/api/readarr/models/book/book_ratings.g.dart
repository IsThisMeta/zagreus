// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_ratings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadarrBookRatings _$ReadarrBookRatingsFromJson(Map<String, dynamic> json) =>
    ReadarrBookRatings(
      votes: (json['votes'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toDouble(),
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReadarrBookRatingsToJson(ReadarrBookRatings instance) {
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
