part of sonarr_commands;

Future<List<SonarrManualImportUpdate>> _controllerUpdateManualImport(
  Dio client, {
  required List<SonarrManualImportUpdateData> data,
}) async {
  Response response = await client.put(
    'manualimport',
    data: data.map<Map<dynamic, dynamic>>((data) => data.toJson()).toList(),
  );
  return (response.data as List)
      .map((import) => SonarrManualImportUpdate.fromJson(import))
      .toList();
}
