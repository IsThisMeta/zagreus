import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'series.g.dart';

/// Model for series subtitle data from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrSeries {
  @JsonKey(name: 'sonarrSeriesId')
  int? sonarrSeriesId;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'profileId')
  int? profileId;

  @JsonKey(name: 'episodeFileCount')
  int? episodeFileCount;

  @JsonKey(name: 'episodesMissing')
  int? episodesMissing;

  @JsonKey(name: 'audio_language')
  List<Map<String, dynamic>>? audioLanguage;

  BazarrSeries({
    this.sonarrSeriesId,
    this.title,
    this.path,
    this.profileId,
    this.episodeFileCount,
    this.episodesMissing,
    this.audioLanguage,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrSeries.fromJson(Map<String, dynamic> json) {
    final series = _$BazarrSeriesFromJson(json);
    if (series.episodesMissing == null &&
        json['episodeMissingCount'] is num) {
      series.episodesMissing = (json['episodeMissingCount'] as num).toInt();
    }
    return series;
  }

  Map<String, dynamic> toJson() => _$BazarrSeriesToJson(this);
}
