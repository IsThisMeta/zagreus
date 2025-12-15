import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'book_ratings.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookRatings {
  @JsonKey(name: 'votes')
  int? votes;

  @JsonKey(name: 'value')
  double? value;

  @JsonKey(name: 'popularity')
  double? popularity;

  ReadarrBookRatings({
    this.votes,
    this.value,
    this.popularity,
  });

  factory ReadarrBookRatings.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookRatingsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookRatingsToJson(this);

  @override
  String toString() => json.encode(toJson());
}
