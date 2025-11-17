import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/modules/readarr.dart';

part 'manual_import.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrManualImport {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'author')
  ReadarrAuthor? author;

  @JsonKey(name: 'book')
  ReadarrBook? book;

  @JsonKey(name: 'foreignEditionId')
  String? foreignEditionId;

  @JsonKey(name: 'quality')
  ReadarrBookFileQuality? quality;

  @JsonKey(name: 'qualityWeight')
  int? qualityWeight;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  @JsonKey(name: 'rejections')
  List<Map<String, dynamic>>? rejections;

  @JsonKey(name: 'audioTags')
  Map<String, dynamic>? audioTags;

  @JsonKey(name: 'additionalFile')
  bool? additionalFile;

  @JsonKey(name: 'replaceExistingFiles')
  bool? replaceExistingFiles;

  @JsonKey(name: 'disableReleaseSwitching')
  bool? disableReleaseSwitching;

  ReadarrManualImport({
    this.path,
    this.name,
    this.size,
    this.author,
    this.book,
    this.foreignEditionId,
    this.quality,
    this.qualityWeight,
    this.downloadId,
    this.rejections,
    this.audioTags,
    this.additionalFile,
    this.replaceExistingFiles,
    this.disableReleaseSwitching,
  });

  factory ReadarrManualImport.fromJson(Map<String, dynamic> json) =>
      _$ReadarrManualImportFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrManualImportToJson(this);

  @override
  String toString() => json.encode(toJson());
}
