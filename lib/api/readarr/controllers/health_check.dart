part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to health check within Readarr.
class ReadarrControllerHealthCheck {
  final Dio _client;

  ReadarrControllerHealthCheck(this._client);

  /// Handler for `GET /api/v1/health`.
  ///
  /// Get health check.
  Future<List<ReadarrHealthCheck>> get() async => _commandGetHealth(_client);
}
