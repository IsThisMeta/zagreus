part of readarr_commands;

Future<List<ReadarrAuthor>> _commandAuthorLookup(
  Dio client, {
  required String term,
}) async {
  Response response = await client.get(
    'author/lookup',
    queryParameters: {'term': term},
  );
  return (response.data as List)
      .map((author) => ReadarrAuthor.fromJson(author))
      .toList();
}
