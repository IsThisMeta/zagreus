part of readarr_commands;

Future<ReadarrCommand> _commandMissingBookSearch(
  Dio client, {
  int? authorId,
}) async {
  final Map<String, dynamic> data = {'name': 'MissingBookSearch'};
  if (authorId != null) {
    data['authorId'] = authorId;
  }
  Response response = await client.post('command', data: data);
  return ReadarrCommand.fromJson(response.data);
}
