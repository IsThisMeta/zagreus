part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to movies within Bazarr.
class BazarrControllerMovie {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerMovie(this._client);

  /// Handler for `movies`.
  ///
  /// Returns movie subtitle data for the given Radarr movie ID.
  Future<BazarrMovie?> get({required int radarrId}) async =>
      _controllerGetMovie(_client, radarrId);

  /// Handler for auto-searching subtitles for a movie.
  ///
  /// Triggers automatic subtitle search for the given Radarr movie ID.
  /// Optionally specify a [language] code (code2) to search for a specific language.
  Future<void> autoSearch({
    required int radarrId,
    String? language,
    bool? hearingImpaired,
    bool? forced,
  }) async {
    await _client.patch(
      'movies/subtitles',
      queryParameters: {'radarrid': radarrId},
      data: language != null
          ? {
              'language': language,
              'hi': (hearingImpaired ?? false) ? 'True' : 'False',
              'forced': (forced ?? false) ? 'True' : 'False',
            }
          : null,
    );
  }
}
