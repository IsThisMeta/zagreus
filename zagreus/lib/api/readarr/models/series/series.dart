import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/readarr/models/book/book.dart';

part 'series.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrSeries {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'foreignSeriesId')
  String? foreignSeriesId;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'description')
  String? description;

  @JsonKey(name: 'numbered')
  bool? numbered;

  @JsonKey(name: 'workCount')
  int? workCount;

  @JsonKey(name: 'primaryWorkCount')
  int? primaryWorkCount;

  @JsonKey(name: 'books')
  List<ReadarrBook>? books;

  @JsonKey(name: 'foreignAuthorId')
  String? foreignAuthorId;

  ReadarrSeries({
    this.id,
    this.foreignSeriesId,
    this.title,
    this.description,
    this.numbered,
    this.workCount,
    this.primaryWorkCount,
    this.books,
    this.foreignAuthorId,
  });

  factory ReadarrSeries.fromJson(Map<String, dynamic> json) =>
      _$ReadarrSeriesFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrSeriesToJson(this);

  @override
  String toString() => json.encode(toJson());
}
