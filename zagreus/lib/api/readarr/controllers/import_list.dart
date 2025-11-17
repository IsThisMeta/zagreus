part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to import lists within Readarr.
class ReadarrControllerImportList {
  final Dio _client;

  ReadarrControllerImportList(this._client);

  /// Handler for `GET /api/v1/importlistexclusion`.
  ///
  /// Get import list exclusions.
  Future<List<ReadarrExclusion>> getExclusions() async =>
      _commandGetExclusionList(_client);
}
