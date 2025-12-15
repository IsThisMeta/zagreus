part of sonarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to health checks within Sonarr.
class SonarrControllerHealthCheck {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  SonarrControllerHealthCheck(this._client);

  /// Handler for `health`.
  ///
  /// Returns a list of health check messages.
  Future<List<SonarrHealthCheck>> get() async {
    Response response = await _client.get('health');
    return (response.data as List)
        .map((check) => SonarrHealthCheck.fromJson(check))
        .toList();
  }
}
