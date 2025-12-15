part of readarr_commands;

Future<List<ReadarrBookFile>> _commandGetAuthorBookFiles(
  Dio client, {
  required int authorId,
}) async {
  Response response = await client.get('bookfile', queryParameters: {
    'authorId': authorId,
  });
  return (response.data as List)
      .map((file) => ReadarrBookFile.fromJson(file))
      .toList();
}
