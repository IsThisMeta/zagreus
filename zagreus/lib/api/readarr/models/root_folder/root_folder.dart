import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'root_folder.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrRootFolder {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'accessible')
  bool? accessible;

  @JsonKey(name: 'freeSpace')
  int? freeSpace;

  @JsonKey(name: 'totalSpace')
  int? totalSpace;

  ReadarrRootFolder({
    this.id,
    this.path,
    this.accessible,
    this.freeSpace,
    this.totalSpace,
  });

  factory ReadarrRootFolder.fromJson(Map<String, dynamic> json) =>
      _$ReadarrRootFolderFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrRootFolderToJson(this);

  @override
  String toString() => json.encode(toJson());
}
