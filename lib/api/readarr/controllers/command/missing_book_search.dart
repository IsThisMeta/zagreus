part of readarr_commands;

Future<ReadarrCommand> _commandMissingBookSearch(
  Dio client, {
  int? authorId,
}) async {
  final data = {'name': 'MissingBookSearch'};
  if (authorId != null) {
    data['authorId'] = authorId;
  }
  Response response = await client.post('command', data: data);
  return ReadarrCommand.fromJson(response.data);
}
