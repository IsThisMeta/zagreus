// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TautulliSearchResults _$TautulliSearchResultsFromJson(
        Map<String, dynamic> json) =>
    TautulliSearchResults(
      albums: TautulliSearchResults._resultsFromJson(json['album'] as List),
      artists: TautulliSearchResults._resultsFromJson(json['artist'] as List),
      collections:
          TautulliSearchResults._resultsFromJson(json['collection'] as List),
      episodes: TautulliSearchResults._resultsFromJson(json['episode'] as List),
      movies: TautulliSearchResults._resultsFromJson(json['movie'] as List),
      seasons: TautulliSearchResults._resultsFromJson(json['season'] as List),
      shows: TautulliSearchResults._resultsFromJson(json['show'] as List),
      tracks: TautulliSearchResults._resultsFromJson(json['track'] as List),
    );

Map<String, dynamic> _$TautulliSearchResultsToJson(
    TautulliSearchResults instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('album', TautulliSearchResults._resultsToJson(instance.albums));
  writeNotNull(
      'artist', TautulliSearchResults._resultsToJson(instance.artists));
  writeNotNull(
      'collection', TautulliSearchResults._resultsToJson(instance.collections));
  writeNotNull(
      'episode', TautulliSearchResults._resultsToJson(instance.episodes));
  writeNotNull('movie', TautulliSearchResults._resultsToJson(instance.movies));
  writeNotNull(
      'season', TautulliSearchResults._resultsToJson(instance.seasons));
  writeNotNull('show', TautulliSearchResults._resultsToJson(instance.shows));
  writeNotNull('track', TautulliSearchResults._resultsToJson(instance.tracks));
  return val;
}
