import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/utilities.dart';

part 'file.g.dart';

/// Model for a file from the filesystem from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrFileSystemFile {
  @JsonKey(name: 'type')
  String? type;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'extension')
  String? extension;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(
      name: 'lastModified',
      fromJson: SonarrUtilities.dateTimeFromJson,
      toJson: SonarrUtilities.dateTimeToJson)
  DateTime? lastModified;

  SonarrFileSystemFile({
    this.type,
    this.name,
    this.path,
    this.extension,
    this.size,
    this.lastModified,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrFileSystemFile] object.
  factory SonarrFileSystemFile.fromJson(Map<String, dynamic> json) =>
      _$SonarrFileSystemFileFromJson(json);

  /// Serialize a [SonarrFileSystemFile] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrFileSystemFileToJson(this);
}
