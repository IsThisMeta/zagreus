import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:zagreus/api/bazarr/models/subtitle/subtitle.dart';

part 'movie.g.dart';

/// Model for movie subtitle data from Bazarr.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrMovie {
  @JsonKey(name: 'radarrId')
  int? radarrId;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'path')
  String? path;

  @JsonKey(name: 'sceneName')
  String? sceneName;

  @JsonKey(name: 'profileId')
  int? profileId;

  @JsonKey(name: 'audio_language')
  List<Map<String, dynamic>>? audioLanguage;

  @JsonKey(name: 'subtitles')
  List<BazarrSubtitle>? existingSubtitles;

  @JsonKey(name: 'missing_subtitles')
  List<BazarrSubtitle>? missingSubtitles;

  BazarrMovie({
    this.radarrId,
    this.title,
    this.path,
    this.sceneName,
    this.profileId,
    this.audioLanguage,
    this.existingSubtitles,
    this.missingSubtitles,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrMovie.fromJson(Map<String, dynamic> json) =>
      _$BazarrMovieFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrMovieToJson(this);
}
