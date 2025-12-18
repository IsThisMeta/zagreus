part of sonarr_commands;

Future<SonarrCommand> _commandManualImport(
  Dio client, {
  required List<SonarrManualImportFile> files,
  required SonarrImportMode importMode,
}) async {
  assert(
    files.isNotEmpty,
    'Files must contain at least one SonarrManualImportFile',
  );
  Response response = await client.post('command', data: {
    'name': 'ManualImport',
    'files': files.map((file) => file.toJson()).toList(),
    'importMode': importMode.value,
  });
  return SonarrCommand.fromJson(response.data);
}
