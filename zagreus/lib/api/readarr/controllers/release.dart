part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to releases within Readarr.
class ReadarrControllerRelease {
  final Dio _client;

  ReadarrControllerRelease(this._client);

  /// Handler for `GET /api/v1/release`.
  ///
  /// Search for releases for a book.
  Future<List<ReadarrRelease>> get({required int bookId}) async =>
      _commandGetReleases(_client, bookId: bookId);

  /// Handler for `POST /api/v1/release`.
  ///
  /// Add/download a release.
  Future<void> add({required String guid, required int indexerId}) async =>
      _commandAddRelease(_client, guid: guid, indexerId: indexerId);
}
