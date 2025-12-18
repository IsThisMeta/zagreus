part of sonarr_commands;

Future<List<SonarrManualImportUpdate>> _controllerUpdateManualImport(
  Dio client, {
  required List<SonarrManualImportUpdateData> data,
}) async {
  final payload = data.map<Map<dynamic, dynamic>>((data) => data.toJson()).toList();
  Response response;
  try {
    response = await client.put(
      'manualimport',
      data: payload,
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 405) {
      response = await client.post(
        'manualimport',
        data: payload,
      );
    } else {
      rethrow;
    }
  }
  return (response.data as List)
      .map((import) => SonarrManualImportUpdate.fromJson(import))
      .toList();
}
