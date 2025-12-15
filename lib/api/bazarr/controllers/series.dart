part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to series within Bazarr.
class BazarrControllerSeries {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerSeries(this._client);

  /// Handler for `series`.
  ///
  /// Returns series subtitle data for the given Sonarr series ID.
  Future<BazarrSeries?> get({required int seriesId}) async =>
      _controllerGetSeries(_client, seriesId);

  /// Handler for auto-searching subtitles for an entire series.
  ///
  /// Triggers automatic subtitle search for all episodes in the series.
  Future<void> autoSearch({required int seriesId}) async {
    await _client.patch(
      'series',
      queryParameters: {'seriesid': seriesId},
    );
  }
}
