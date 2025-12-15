part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to calendar within Readarr.
class ReadarrControllerCalendar {
  final Dio _client;

  ReadarrControllerCalendar(this._client);

  /// Handler for `GET /api/v1/calendar`.
  ///
  /// Get upcoming books.
  Future<List<ReadarrCalendar>> get({
    DateTime? start,
    DateTime? end,
    bool unmonitored = false,
  }) async =>
      _commandGetCalendar(
        _client,
        start: start,
        end: end,
        unmonitored: unmonitored,
      );
}
