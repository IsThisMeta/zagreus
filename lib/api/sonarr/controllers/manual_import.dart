part of sonarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to manual import within Sonarr.
///
/// [SonarrCommandHandlerManualImport] internally handles routing the HTTP client to the API calls.
class SonarrCommandHandlerManualImport {
  final Dio _client;

  /// Create a command handler using an initialized [Dio] client.
  SonarrCommandHandlerManualImport(this._client);

  /// Handler for `manualimport`.
  ///
  /// Returns a list of potential files to manually import at the given path.
  ///
  /// Required Parameters:
  /// - `folder`: Full, absolute path to the folder to scan.
  ///
  /// Optional Parameters:
  /// - `downloadId`: Download ID to filter results.
  /// - `filterExistingFiles`: If the scan should ignore/filter out existing files in Sonarr.
  Future<List<SonarrManualImport>> get({
    required String folder,
    String? downloadId,
    bool? filterExistingFiles,
  }) async =>
      _controllerGetManualImport(_client,
          folder: folder,
          downloadId: downloadId,
          filterExistingFiles: filterExistingFiles);

  /// Handler for `manualimport`.
  ///
  /// Returns the updated information and rejections for a manual import.
  ///
  /// Required Parameters:
  /// - `data`: Array of [SonarrManualImportUpdateData] objects that each contain a single manual import to update.
  Future<List<SonarrManualImportUpdate>> update({
    required List<SonarrManualImportUpdateData> data,
  }) async =>
      _controllerUpdateManualImport(_client, data: data);
}
