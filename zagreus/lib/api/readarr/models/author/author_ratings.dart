import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'author_ratings.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrAuthorRatings {
  @JsonKey(name: 'votes')
  int? votes;

  @JsonKey(name: 'value')
  double? value;

  @JsonKey(name: 'popularity')
  double? popularity;

  ReadarrAuthorRatings({
    this.votes,
    this.value,
    this.popularity,
  });

  factory ReadarrAuthorRatings.fromJson(Map<String, dynamic> json) =>
      _$ReadarrAuthorRatingsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrAuthorRatingsToJson(this);

  @override
  String toString() => json.encode(toJson());
}
