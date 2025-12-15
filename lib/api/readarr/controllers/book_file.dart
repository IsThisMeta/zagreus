part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to book files within Readarr.
class ReadarrControllerBookFile {
  final Dio _client;

  ReadarrControllerBookFile(this._client);

  /// Handler for `GET /api/v1/bookfile/{id}`.
  ///
  /// Get book file by ID.
  Future<ReadarrBookFile> get({required int bookFileId}) async =>
      _commandGetBookFile(_client, bookFileId: bookFileId);

  /// Handler for `GET /api/v1/bookfile`.
  ///
  /// Get book files for a specific author.
  Future<List<ReadarrBookFile>> getByAuthor({required int authorId}) async =>
      _commandGetAuthorBookFiles(_client, authorId: authorId);

  /// Handler for `DELETE /api/v1/bookfile/{id}`.
  ///
  /// Delete a book file.
  Future<void> delete({required int bookFileId}) async =>
      _commandDeleteBookFile(_client, bookFileId: bookFileId);

  /// Handler for `DELETE /api/v1/bookfile/bulk`.
  ///
  /// Delete multiple book files.
  Future<void> deleteMultiple({required List<int> bookFileIds}) async =>
      _commandDeleteBookFiles(_client, bookFileIds: bookFileIds);
}
