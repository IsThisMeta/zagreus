import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'queue_record.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrQueueRecord {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'bookId')
  int? bookId;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'book')
  ReadarrBook? book;

  @JsonKey(name: 'quality')
  ReadarrBookFileQuality? quality;

  @JsonKey(name: 'size')
  double? size;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'sizeleft')
  double? sizeleft;

  @JsonKey(name: 'timeleft')
  String? timeleft;

  @JsonKey(name: 'estimatedCompletionTime')
  DateTime? estimatedCompletionTime;

  @JsonKey(name: 'status')
  String? status;

  @JsonKey(name: 'trackedDownloadStatus')
  String? trackedDownloadStatus;

  @JsonKey(name: 'trackedDownloadState')
  String? trackedDownloadState;

  @JsonKey(name: 'statusMessages')
  List<Map<String, dynamic>>? statusMessages;

  @JsonKey(name: 'errorMessage')
  String? errorMessage;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  @JsonKey(name: 'protocol')
  String? protocol;

  @JsonKey(name: 'downloadClient')
  String? downloadClient;

  @JsonKey(name: 'indexer')
  String? indexer;

  @JsonKey(name: 'outputPath')
  String? outputPath;

  ReadarrQueueRecord({
    this.id,
    this.authorId,
    this.bookId,
    this.author,
    this.book,
    this.quality,
    this.size,
    this.title,
    this.sizeleft,
    this.timeleft,
    this.estimatedCompletionTime,
    this.status,
    this.trackedDownloadStatus,
    this.trackedDownloadState,
    this.statusMessages,
    this.errorMessage,
    this.downloadId,
    this.protocol,
    this.downloadClient,
    this.indexer,
    this.outputPath,
  });

  factory ReadarrQueueRecord.fromJson(Map<String, dynamic> json) =>
      _$ReadarrQueueRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrQueueRecordToJson(this);

  @override
  String toString() => json.encode(toJson());
}
