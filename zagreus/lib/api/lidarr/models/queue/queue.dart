import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'queue.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LidarrQueuePage {
  @JsonKey(name: 'page')
  int? page;

  @JsonKey(name: 'pageSize')
  int? pageSize;

  @JsonKey(name: 'totalRecords')
  int? totalRecords;

  @JsonKey(name: 'records')
  List<LidarrQueueRecord>? records;

  LidarrQueuePage({
    this.page,
    this.pageSize,
    this.totalRecords,
    this.records,
  });

  @override
  String toString() => json.encode(toJson());

  factory LidarrQueuePage.fromJson(Map<String, dynamic> json) =>
      _$LidarrQueuePageFromJson(json);

  Map<String, dynamic> toJson() => _$LidarrQueuePageToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LidarrQueueRecord {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'artist')
  Map<String, dynamic>? artist;

  @JsonKey(name: 'album')
  Map<String, dynamic>? album;

  @JsonKey(name: 'status')
  String? status;

  @JsonKey(name: 'timeleft')
  String? timeleft;

  @JsonKey(name: 'size')
  num? size;

  @JsonKey(name: 'sizeleft')
  num? sizeleft;

  @JsonKey(name: 'estimatedCompletionTime')
  String? estimatedCompletionTime;

  LidarrQueueRecord({
    this.id,
    this.title,
    this.artist,
    this.album,
    this.status,
    this.timeleft,
    this.size,
    this.sizeleft,
    this.estimatedCompletionTime,
  });

  String get artistName => artist?['artistName'] ?? '';
  String get albumTitle => album?['title'] ?? '';

  @override
  String toString() => json.encode(toJson());

  factory LidarrQueueRecord.fromJson(Map<String, dynamic> json) =>
      _$LidarrQueueRecordFromJson(json);

  Map<String, dynamic> toJson() => _$LidarrQueueRecordToJson(this);
}
