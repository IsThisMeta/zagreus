import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'manual_import_item.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrManualImportItem {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'authorId')
  int? authorId;

  @JsonKey(name: 'bookId')
  int? bookId;

  @JsonKey(name: 'foreignEditionId')
  String? foreignEditionId;

  @JsonKey(name: 'quality')
  Map<String, dynamic>? quality;

  @JsonKey(name: 'releaseGroup')
  String? releaseGroup;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  @JsonKey(name: 'rejections')
  List<Map<String, dynamic>>? rejections;

  ReadarrManualImportItem({
    this.id,
    this.path,
    this.name,
    this.size,
    this.authorId,
    this.bookId,
    this.foreignEditionId,
    this.quality,
    this.releaseGroup,
    this.downloadId,
    this.rejections,
  });

  factory ReadarrManualImportItem.fromJson(Map<String, dynamic> json) =>
      _$ReadarrManualImportItemFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrManualImportItemToJson(this);

  @override
  String toString() => json.encode(toJson());
}
