part of sonarr_controllers;

/// Facilitates manual import calls within Sonarr.
class SonarrControllerManualImport {
  final Dio _client;

  SonarrControllerManualImport(this._client);

  /// GET /manualimport
  Future<List<SonarrManualImport>> get({
    required String folder,
    bool? filterExistingFiles,
    String? downloadId,
  }) async {
    final response = await _client.get(
      'manualimport',
      queryParameters: {
        'folder': folder,
        if (filterExistingFiles != null)
          'filterExistingFiles': filterExistingFiles,
        if (downloadId != null) 'downloadId': downloadId,
      },
    );
    return (response.data as List)
        .map<SonarrManualImport>(
            (item) => SonarrManualImport.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /manualimport
  ///
  /// Accepts a list of manual import files to process.
  Future<void> import({
    required List<SonarrManualImportFile> files,
  }) async {
    await _client.post(
      'manualimport',
      data: files.map((file) => file.toJson()).toList(),
    );
  }
}
