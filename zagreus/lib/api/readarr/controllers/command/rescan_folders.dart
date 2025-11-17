part of readarr_commands;

Future<ReadarrCommand> _commandRescanFolders(Dio client) async {
  Response response = await client.post('command', data: {
    'name': 'RescanFolders',
  });
  return ReadarrCommand.fromJson(response.data);
}
