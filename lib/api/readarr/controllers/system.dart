part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to system within Readarr.
class ReadarrControllerSystem {
  final Dio _client;

  ReadarrControllerSystem(this._client);

  /// Handler for `GET /api/v1/system/status`.
  ///
  /// Get system status information.
  Future<ReadarrStatus> getStatus() async => _commandGetStatus(_client);
}
