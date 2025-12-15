part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to authors within Readarr.
///
/// [ReadarrControllerAuthor] internally handles routing the HTTP client to the API calls.
class ReadarrControllerAuthor {
  final Dio _client;

  /// Create an author command handler using an initialized [Dio] client.
  ReadarrControllerAuthor(this._client);

  /// Handler for `GET /api/v1/author`.
  ///
  /// Returns a list of all authors.
  Future<List<ReadarrAuthor>> getAll() async =>
      _commandGetAllAuthors(_client);

  /// Handler for `GET /api/v1/author/{id}`.
  ///
  /// Returns the author with the matching ID.
  Future<ReadarrAuthor> get({required int authorId}) async =>
      _commandGetAuthor(_client, authorId: authorId);

  /// Handler for `POST /api/v1/author`.
  ///
  /// Adds a new author to your collection.
  Future<ReadarrAuthor> create({
    required ReadarrAuthor author,
    required ReadarrQualityProfile qualityProfile,
    required ReadarrMetadataProfile metadataProfile,
    required ReadarrRootFolder rootFolder,
    required bool monitored,
    String monitorNewItems = 'all',
    bool searchForMissingBooks = false,
  }) async =>
      _commandAddAuthor(
        _client,
        author: author,
        qualityProfile: qualityProfile,
        metadataProfile: metadataProfile,
        rootFolder: rootFolder,
        monitored: monitored,
        monitorNewItems: monitorNewItems,
        searchForMissingBooks: searchForMissingBooks,
      );

  /// Handler for `PUT /api/v1/author`.
  ///
  /// Update an existing author.
  Future<ReadarrAuthor> update({required ReadarrAuthor author}) async =>
      _commandUpdateAuthor(_client, author: author);

  /// Handler for `DELETE /api/v1/author/{id}`.
  ///
  /// Delete the author with the given author ID.
  Future<void> delete({
    required int authorId,
    bool deleteFiles = false,
    bool addImportListExclusion = false,
  }) async =>
      _commandDeleteAuthor(
        _client,
        authorId: authorId,
        deleteFiles: deleteFiles,
        addImportListExclusion: addImportListExclusion,
      );
}
