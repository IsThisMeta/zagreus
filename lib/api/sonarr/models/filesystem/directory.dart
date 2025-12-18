import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/utilities.dart';

part 'directory.g.dart';

/// Model for a directory from the filesystem from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrFileSystemDirectory {
  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(
      name: 'lastModified',
      fromJson: SonarrUtilities.dateTimeFromJson,
      toJson: SonarrUtilities.dateTimeToJson)
  DateTime? lastModified;

  SonarrFileSystemDirectory({
    this.type,
    this.name,
    this.path,
    this.size,
    this.lastModified,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrFileSystemDirectory] object.
  factory SonarrFileSystemDirectory.fromJson(Map<String, dynamic> json) =>
      _$SonarrFileSystemDirectoryFromJson(json);

  /// Serialize a [SonarrFileSystemDirectory] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrFileSystemDirectoryToJson(this);
}
