import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/sonarr/models.dart';

part 'manual_import_update.g.dart';

/// Model for manual import update results from Sonarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SonarrManualImportUpdate {
  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'seriesId')
  int? seriesId;

  @JsonKey(name: 'episodeIds')
  List<int>? episodeIds;

  @JsonKey(name: 'series')
  SonarrSeries? series;

  @JsonKey(name: 'episodes')
  List<SonarrEpisode>? episodes;

  @JsonKey(name: 'rejections')
  List<SonarrManualImportRejection>? rejections;

  @JsonKey(name: 'id')
  int? id;

  SonarrManualImportUpdate({
    this.path,
    this.seriesId,
    this.episodeIds,
    this.series,
    this.episodes,
    this.rejections,
    this.id,
  });

  /// Returns a JSON-encoded string version of this object.
  @override
  String toString() => json.encode(this.toJson());

  /// Deserialize a JSON map to a [SonarrManualImportUpdate] object.
  factory SonarrManualImportUpdate.fromJson(Map<String, dynamic> json) =>
      _$SonarrManualImportUpdateFromJson(json);

  /// Serialize a [SonarrManualImportUpdate] object to a JSON map.
  Map<String, dynamic> toJson() => _$SonarrManualImportUpdateToJson(this);
}
