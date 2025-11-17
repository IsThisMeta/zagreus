part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to author lookup within Readarr.
class ReadarrControllerAuthorLookup {
  final Dio _client;

  ReadarrControllerAuthorLookup(this._client);

  /// Handler for `GET /api/v1/author/lookup`.
  ///
  /// Search for authors using a search term.
  Future<List<ReadarrAuthor>> lookup({required String term}) async =>
      _commandAuthorLookup(_client, term: term);
}
