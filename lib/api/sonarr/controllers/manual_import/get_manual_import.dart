part of sonarr_commands;

Future<List<SonarrManualImport>> _controllerGetManualImport(
  Dio client, {
  required String folder,
  String? downloadId,
  bool? filterExistingFiles,
}) async {
  Response response = await client.get('manualimport', queryParameters: {
    'folder': folder,
    if (downloadId != null) 'downloadId': downloadId,
    if (filterExistingFiles != null) 'filterExistingFiles': filterExistingFiles,
  });
  return (response.data as List)
      .map((import) => SonarrManualImport.fromJson(import))
      .toList();
}
