import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/bazarr/models/subtitle/subtitle.dart';

part 'episode.g.dart';

/// Model for episode subtitle data from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrEpisode {
  @JsonKey(name: 'sonarrSeriesId')
  int? sonarrSeriesId;

  @JsonKey(name: 'sonarrEpisodeId')
  int? sonarrEpisodeId;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'sceneName')
  String? sceneName;

  @JsonKey(name: 'season')
  int? season;

  @JsonKey(name: 'episode')
  int? episode;

  @JsonKey(name: 'audio_language')
  List<Map<String, dynamic>>? audioLanguage;

  @JsonKey(name: 'subtitles')
  List<BazarrSubtitle>? existingSubtitles;

  @JsonKey(name: 'missing_subtitles')
  List<BazarrSubtitle>? missingSubtitles;

  BazarrEpisode({
    this.sonarrSeriesId,
    this.sonarrEpisodeId,
    this.title,
    this.path,
    this.sceneName,
    this.season,
    this.episode,
    this.audioLanguage,
    this.existingSubtitles,
    this.missingSubtitles,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrEpisode.fromJson(Map<String, dynamic> json) =>
      _$BazarrEpisodeFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrEpisodeToJson(this);
}
