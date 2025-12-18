part of sonarr_commands;

Future<SonarrFileSystem> _controllerGetFileSystem(
  Dio client, {
  String? path,
  bool? allowFoldersWithoutTrailingSlashes,
  bool? includeFiles,
}) async {
  Response response = await client.get('filesystem', queryParameters: {
    if (path != null && path.isNotEmpty) 'path': path,
    if (allowFoldersWithoutTrailingSlashes != null)
      'allowFoldersWithoutTrailingSlashes': allowFoldersWithoutTrailingSlashes,
    if (includeFiles != null) 'includeFiles': includeFiles,
  });
  return SonarrFileSystem.fromJson(response.data);
}
