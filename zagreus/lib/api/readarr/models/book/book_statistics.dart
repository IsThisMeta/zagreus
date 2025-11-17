import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'book_statistics.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrBookStatistics {
  @JsonKey(name: 'bookFileCount')
  int? bookFileCount;

  @JsonKey(name: 'bookCount')
  int? bookCount;

  @JsonKey(name: 'totalBookCount')
  int? totalBookCount;

  @JsonKey(name: 'sizeOnDisk')
  int? sizeOnDisk;

  @JsonKey(name: 'percentOfBooks')
  double? percentOfBooks;

  ReadarrBookStatistics({
    this.bookFileCount,
    this.bookCount,
    this.totalBookCount,
    this.sizeOnDisk,
    this.percentOfBooks,
  });

  factory ReadarrBookStatistics.fromJson(Map<String, dynamic> json) =>
      _$ReadarrBookStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrBookStatisticsToJson(this);

  @override
  String toString() => json.encode(toJson());
}
