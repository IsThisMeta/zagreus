import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'history.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrHistory {
  @JsonKey(name: 'page')
  int? page;

  @JsonKey(name: 'pageSize')
  int? pageSize;

  @JsonKey(name: 'sortKey')
  String? sortKey;

  @JsonKey(name: 'sortDirection')
  String? sortDirection;

  @JsonKey(name: 'totalRecords')
  int? totalRecords;

  @JsonKey(name: 'records')
  List<ReadarrHistoryRecord>? records;

  ReadarrHistory({
    this.page,
    this.pageSize,
    this.sortKey,
    this.sortDirection,
    this.totalRecords,
    this.records,
  });

  factory ReadarrHistory.fromJson(Map<String, dynamic> json) =>
      _$ReadarrHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrHistoryToJson(this);

  @override
  String toString() => json.encode(toJson());
}
