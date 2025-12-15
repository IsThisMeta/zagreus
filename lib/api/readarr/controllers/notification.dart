part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to notifications within Readarr.
class ReadarrControllerNotification {
  final Dio _client;

  ReadarrControllerNotification(this._client);

  /// Handler for `GET /api/v1/notification`.
  ///
  /// Get notifications.
  Future<List<ReadarrNotification>> get() async =>
      _commandGetNotifications(_client);
}
