part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to episodes within Bazarr.
class BazarrControllerEpisode {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerEpisode(this._client);

  /// Handler for `episodes`.
  ///
  /// Returns all episodes with subtitle data for the given Sonarr series ID.
  Future<List<BazarrEpisode>> getForSeries({required int seriesId}) async =>
      _controllerGetEpisodes(_client, seriesId);

  /// Handler for auto-searching subtitles for a specific episode.
  ///
  /// Triggers automatic subtitle search for the given episode.
  Future<void> autoSearch({
    required int seriesId,
    required int episodeId,
  }) async {
    await _client.patch(
      'episodes/subtitles',
      queryParameters: {
        'seriesid': seriesId,
        'episodeid': episodeId,
      },
    );
  }
}
