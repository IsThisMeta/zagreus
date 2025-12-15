part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to queue within Readarr.
class ReadarrControllerQueue {
  final Dio _client;

  ReadarrControllerQueue(this._client);

  /// Handler for `GET /api/v1/queue`.
  ///
  /// Get the download queue.
  Future<ReadarrQueue> get({
    int page = 1,
    int pageSize = 20,
    String sortKey = 'timeleft',
    String sortDirection = 'ascending',
  }) async =>
      _commandGetQueue(
        _client,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
        sortDirection: sortDirection,
      );

  /// Handler for `DELETE /api/v1/queue/{id}`.
  ///
  /// Remove an item from the queue.
  Future<void> delete({
    required int queueId,
    bool removeFromClient = true,
    bool blocklist = false,
  }) async =>
      _commandDeleteQueue(
        _client,
        queueId: queueId,
        removeFromClient: removeFromClient,
        blocklist: blocklist,
      );
}
