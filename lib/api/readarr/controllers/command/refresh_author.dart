part of readarr_commands;

Future<ReadarrCommand> _commandRefreshAuthor(
  Dio client, {
  required int authorId,
}) async {
  Response response = await client.post('command', data: {
    'name': 'RefreshAuthor',
    'authorId': authorId,
  });
  return ReadarrCommand.fromJson(response.data);
}
