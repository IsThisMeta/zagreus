part of readarr_commands;

Future<List<ReadarrManualImport>> _commandGetManualImport(
  Dio client, {
  required String folder,
  String? downloadId,
  int? authorId,
  bool filterExistingFiles = true,
}) async {
  final params = <String, dynamic>{
    'folder': folder,
    'filterExistingFiles': filterExistingFiles,
  };
  if (downloadId != null) params['downloadId'] = downloadId;
  if (authorId != null) params['authorId'] = authorId;

  Response response = await client.get('manualimport', queryParameters: params);
  return (response.data as List)
      .map((item) => ReadarrManualImport.fromJson(item))
      .toList();
}
