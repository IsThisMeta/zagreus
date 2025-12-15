part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to subtitle providers within Bazarr.
class BazarrControllerProvider {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerProvider(this._client);

  /// Search for available subtitles for a movie.
  Future<List<BazarrSubtitleSearchResult>> searchMovieSubtitles({
    required int radarrId,
  }) async =>
      _controllerSearchMovieSubtitles(_client, radarrId);

  /// Search for available subtitles for an episode.
  Future<List<BazarrSubtitleSearchResult>> searchEpisodeSubtitles({
    required int episodeId,
  }) async =>
      _controllerSearchEpisodeSubtitles(_client, episodeId);

  /// Download a specific subtitle for a movie.
  Future<void> downloadMovieSubtitle({
    required int radarrId,
    required String language,
    required String provider,
    required String subtitle,
    bool? hearingImpaired,
    bool? forced,
  }) async =>
      _controllerDownloadMovieSubtitle(
        _client,
        radarrId,
        language,
        provider,
        subtitle,
        hearingImpaired,
        forced,
      );

  /// Download a specific subtitle for an episode.
  Future<void> downloadEpisodeSubtitle({
    required int seriesId,
    required int episodeId,
    required String language,
    required String provider,
    required String subtitle,
    bool? hearingImpaired,
    bool? forced,
  }) async =>
      _controllerDownloadEpisodeSubtitle(
        _client,
        seriesId,
        episodeId,
        language,
        provider,
        subtitle,
        hearingImpaired,
        forced,
      );
}
