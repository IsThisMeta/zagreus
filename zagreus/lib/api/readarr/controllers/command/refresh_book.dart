part of readarr_commands;

Future<ReadarrCommand> _commandRefreshBook(
  Dio client, {
  required int bookId,
}) async {
  Response response = await client.post('command', data: {
    'name': 'RefreshBook',
    'bookId': bookId,
  });
  return ReadarrCommand.fromJson(response.data);
}
