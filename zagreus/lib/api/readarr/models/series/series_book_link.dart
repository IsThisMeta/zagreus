import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'series_book_link.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrSeriesBookLink {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'position')
  String? position;

  @JsonKey(name: 'seriesId')
  int? seriesId;

  @JsonKey(name: 'bookId')
  int? bookId;

  @JsonKey(name: 'isPrimary')
  bool? isPrimary;

  @JsonKey(name: 'series')
  String? series;

  @JsonKey(name: 'foreignSeriesId')
  String? foreignSeriesId;

  ReadarrSeriesBookLink({
    this.id,
    this.position,
    this.seriesId,
    this.bookId,
    this.isPrimary,
    this.series,
    this.foreignSeriesId,
  });

  factory ReadarrSeriesBookLink.fromJson(Map<String, dynamic> json) =>
      _$ReadarrSeriesBookLinkFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrSeriesBookLinkToJson(this);

  @override
  String toString() => json.encode(toJson());
}
