import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'disk_space.g.dart';

/// Model for disk space details from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrDiskSpace {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'label')
  String? label;

  @JsonKey(name: 'freeSpace')
  int? freeSpace;

  @JsonKey(name: 'totalSpace')
  int? totalSpace;

  SonarrDiskSpace({
    this.path,
    this.label,
    this.freeSpace,
    this.totalSpace,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrDiskSpace] object.
  factory SonarrDiskSpace.fromJson(Map<String, dynamic> json) =>
      _$SonarrDiskSpaceFromJson(json);

  /// Serialize a [SonarrDiskSpace] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrDiskSpaceToJson(this);
}
