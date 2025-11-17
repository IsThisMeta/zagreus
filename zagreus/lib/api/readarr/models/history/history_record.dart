import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'history_record.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrHistoryRecord {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'bookId')
  int? bookId;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'sourceTitle')
  String? sourceTitle;

  @JsonKey(name: 'quality')
  ReadarrBookFileQuality? quality;

  @JsonKey(name: 'qualityCutoffNotMet')
  bool? qualityCutoffNotMet;

  @JsonKey(name: 'date')
  DateTime? date;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  @JsonKey(name: 'eventType')
  String? eventType;

  @JsonKey(name: 'data')
  Map<String, dynamic>? data;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'book')
  ReadarrBook? book;

  ReadarrHistoryRecord({
    this.id,
    this.bookId,
    this.authorId,
    this.sourceTitle,
    this.quality,
    this.qualityCutoffNotMet,
    this.date,
    this.downloadId,
    this.eventType,
    this.data,
    this.author,
    this.book,
  });

  factory ReadarrHistoryRecord.fromJson(Map<String, dynamic> json) =>
      _$ReadarrHistoryRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrHistoryRecordToJson(this);

  @override
  String toString() => json.encode(toJson());
}
