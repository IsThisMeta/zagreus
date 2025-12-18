import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/models.dart';

part 'manual_import.g.dart';

/// Model for manual import results from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrManualImport {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'relativePath')
  String? relativePath;

  @JsonKey(name: 'folderName')
  String? folderName;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'size')
  int? size;

  @JsonKey(name: 'series')
  SonarrSeries? series;

  @JsonKey(name: 'episode')
  SonarrEpisode? episode;

  @JsonKey(name: 'episodes')
  List<SonarrEpisode>? episodes;

  @JsonKey(name: 'quality')
  SonarrEpisodeFileQuality? quality;

  @JsonKey(name: 'language')
  SonarrEpisodeFileLanguage? language;

  @JsonKey(name: 'languages')
  List<SonarrEpisodeFileLanguage>? languages;

  @JsonKey(name: 'releaseGroup')
  String? releaseGroup;

  @JsonKey(name: 'releaseType')
  String? releaseType;

  @JsonKey(name: 'qualityWeight')
  int? qualityWeight;

  @JsonKey(name: 'downloadId')
  String? downloadId;

  @JsonKey(name: 'rejections')
  List<SonarrManualImportRejection>? rejections;

  @JsonKey(name: 'id')
  int? id;

  SonarrManualImport({
    this.path,
    this.relativePath,
    this.folderName,
    this.name,
    this.size,
    this.series,
    this.episode,
    this.episodes,
    this.quality,
    this.language,
    this.languages,
    this.releaseGroup,
    this.releaseType,
    this.qualityWeight,
    this.downloadId,
    this.rejections,
    this.id,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrManualImport] object.
  factory SonarrManualImport.fromJson(Map<String, dynamic> json) =>
      _$SonarrManualImportFromJson(json);

  /// Serialize a [SonarrManualImport] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrManualImportToJson(this);
}
