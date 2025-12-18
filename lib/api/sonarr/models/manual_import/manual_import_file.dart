import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/models.dart';

part 'manual_import_file.g.dart';

/// Model for a manual import file.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrManualImportFile {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'folderName')
  String? folderName;

  @JsonKey(name: 'seriesId')
  int? seriesId;

  @JsonKey(name: 'episodeIds')
  List<int>? episodeIds;

  @JsonKey(name: 'quality')
  SonarrEpisodeFileQuality? quality;

  @JsonKey(name: 'languages')
  List<SonarrEpisodeFileLanguage>? languages;

  @JsonKey(name: 'releaseGroup')
  String? releaseGroup;

  @JsonKey(name: 'releaseType')
  String? releaseType;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  SonarrManualImportFile({
    this.path,
    this.folderName,
    this.seriesId,
    this.episodeIds,
    this.quality,
    this.languages,
    this.releaseGroup,
    this.releaseType,
    this.downloadId,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrManualImportFile] object.
  factory SonarrManualImportFile.fromJson(Map<String, dynamic> json) =>
      _$SonarrManualImportFileFromJson(json);

  /// Serialize a [SonarrManualImportFile] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrManualImportFileToJson(this);
}
