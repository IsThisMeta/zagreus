part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to history within Readarr.
class ReadarrControllerHistory {
  final Dio _client;

  ReadarrControllerHistory(this._client);

  /// Handler for `GET /api/v1/history`.
  ///
  /// Get download history.
  Future<ReadarrHistory> get({
    int page = 1,
    int pageSize = 20,
    String sortKey = 'date',
    String sortDirection = 'descending',
  }) async =>
      _commandGetHistory(
        _client,
        page: page,
        pageSize: pageSize,
        sortKey: sortKey,
        sortDirection: sortDirection,
      );

  /// Handler for `GET /api/v1/history/author`.
  ///
  /// Get history for a specific author.
  Future<ReadarrHistory> getByAuthor({
    required int authorId,
    int page = 1,
    int pageSize = 20,
  }) async =>
      _commandGetHistoryByAuthor(
        _client,
        authorId: authorId,
        page: page,
        pageSize: pageSize,
      );
}
