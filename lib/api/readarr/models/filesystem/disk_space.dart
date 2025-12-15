import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'disk_space.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ReadarrDiskSpace {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'freeSpace')
  int? freeSpace;

  @JsonKey(name: 'totalSpace')
  int? totalSpace;

  ReadarrDiskSpace({
    this.path,
    this.label,
    this.freeSpace,
    this.totalSpace,
  });

  factory ReadarrDiskSpace.fromJson(Map<String, dynamic> json) =>
      _$ReadarrDiskSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$ReadarrDiskSpaceToJson(this);

  @override
  String toString() => json.encode(toJson());
}
