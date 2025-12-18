import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/models.dart';

part 'manual_import_update_data.g.dart';

/// Model for manual import update data that is attached to update requests.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrManualImportUpdateData {
  @JsonKey(name: 'id')
  int? id;

  @JsonKey(name: 'path')
  String? path;

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

  @JsonKey(name: 'downloadId')
  String? downloadId;

  SonarrManualImportUpdateData({
    this.id,
    this.path,
    this.seriesId,
    this.episodeIds,
    this.quality,
    this.languages,
    this.releaseGroup,
    this.downloadId,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrManualImportUpdateData] object.
  factory SonarrManualImportUpdateData.fromJson(Map<String, dynamic> json) =>
      _$SonarrManualImportUpdateDataFromJson(json);

  /// Serialize a [SonarrManualImportUpdateData] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrManualImportUpdateDataToJson(this);
}
