part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to root folders within Readarr.
class ReadarrControllerRootFolder {
  final Dio _client;

  ReadarrControllerRootFolder(this._client);

  /// Handler for `GET /api/v1/rootfolder`.
  ///
  /// Get root folders.
  Future<List<ReadarrRootFolder>> get() async => _commandGetRootFolders(_client);
}
