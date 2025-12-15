part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to commands within Readarr.
class ReadarrControllerCommand {
  final Dio _client;

  ReadarrControllerCommand(this._client);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Trigger an author search.
  Future<ReadarrCommand> authorSearch({required int authorId}) async =>
      _commandAuthorSearch(_client, authorId: authorId);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Trigger a book search.
  Future<ReadarrCommand> bookSearch({required List<int> bookIds}) async =>
      _commandBookSearch(_client, bookIds: bookIds);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Trigger a missing book search.
  Future<ReadarrCommand> missingBookSearch({int? authorId}) async =>
      _commandMissingBookSearch(_client, authorId: authorId);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Refresh an author.
  Future<ReadarrCommand> refreshAuthor({required int authorId}) async =>
      _commandRefreshAuthor(_client, authorId: authorId);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Refresh a book.
  Future<ReadarrCommand> refreshBook({required int bookId}) async =>
      _commandRefreshBook(_client, bookId: bookId);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Rescan folders.
  Future<ReadarrCommand> rescanFolders() async =>
      _commandRescanFolders(_client);

  /// Handler for `POST /api/v1/command`.
  ///
  /// Trigger an RSS sync.
  Future<ReadarrCommand> rssSync() async => _commandRssSync(_client);
}
