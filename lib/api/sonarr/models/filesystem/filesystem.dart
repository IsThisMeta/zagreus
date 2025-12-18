import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/models.dart';

part 'filesystem.g.dart';

/// Model for a call to the filesystem from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrFileSystem {
  @JsonKey(name: 'parent')
  String? parent;

  @JsonKey(name: 'directories')
  List<SonarrFileSystemDirectory>? directories;

  @JsonKey(name: 'files')
  List<SonarrFileSystemFile>? files;

  SonarrFileSystem({
    this.parent,
    this.directories,
    this.files,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrFileSystem] object.
  factory SonarrFileSystem.fromJson(Map<String, dynamic> json) =>
      _$SonarrFileSystemFromJson(json);

  /// Serialize a [SonarrFileSystem] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrFileSystemToJson(this);
}
