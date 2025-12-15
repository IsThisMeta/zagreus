import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'subtitle_search_result.g.dart';

/// Model for subtitle search results from Bazarr providers.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class BazarrSubtitleSearchResult {
  @JsonKey(name: 'provider')
  String? provider;

  @JsonKey(name: 'language')
  String? language;

  @JsonKey(name: 'hearing_impaired')
  String? hearingImpaired;

  @JsonKey(name: 'forced')
  String? forced;

  @JsonKey(name: 'subtitle')
  String? subtitle;

  @JsonKey(name: 'uploader')
  String? uploader;

  @JsonKey(name: 'url')
  String? url;

  @JsonKey(name: 'score')
  int? score;

  @JsonKey(name: 'orig_score')
  int? origScore;

  @JsonKey(name: 'score_without_hash')
  int? scoreWithoutHash;

  @JsonKey(name: 'matches')
  List<String>? matches;

  @JsonKey(name: 'dont_matches')
  List<String>? dontMatches;

  @JsonKey(name: 'release_info')
  List<String>? releaseInfo;

  BazarrSubtitleSearchResult({
    this.provider,
    this.language,
    this.hearingImpaired,
    this.forced,
    this.subtitle,
    this.uploader,
    this.url,
    this.score,
    this.origScore,
    this.scoreWithoutHash,
    this.matches,
    this.dontMatches,
    this.releaseInfo,
  });

  @override
  String toString() => json.encode(this.toJson());

  factory BazarrSubtitleSearchResult.fromJson(Map<String, dynamic> json) =>
      _$BazarrSubtitleSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$BazarrSubtitleSearchResultToJson(this);
}
