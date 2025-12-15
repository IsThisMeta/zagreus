part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to manual import within Readarr.
class ReadarrControllerManualImport {
  final Dio _client;

  ReadarrControllerManualImport(this._client);

  /// Handler for `GET /api/v1/manualimport`.
  ///
  /// Get manual import list.
  Future<List<ReadarrManualImport>> get({
    required String folder,
    String? downloadId,
    int? authorId,
    bool filterExistingFiles = true,
  }) async =>
      _commandGetManualImport(
        _client,
        folder: folder,
        downloadId: downloadId,
        authorId: authorId,
        filterExistingFiles: filterExistingFiles,
      );

  /// Handler for `PUT /api/v1/manualimport`.
  ///
  /// Update manual import items.
  Future<List<ReadarrManualImport>> update({
    required List<ReadarrManualImport> files,
  }) async =>
      _commandUpdateManualImport(_client, files: files);
}
