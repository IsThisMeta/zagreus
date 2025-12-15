part of readarr_commands;

Future<List<ReadarrManualImport>> _commandUpdateManualImport(
  Dio client, {
  required List<ReadarrManualImport> files,
}) async {
  Response response = await client.put(
    'manualimport',
    data: files.map((f) => f.toJson()).toList(),
  );
  return (response.data as List)
      .map((item) => ReadarrManualImport.fromJson(item))
      .toList();
}
