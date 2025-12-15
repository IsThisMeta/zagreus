part of readarr_commands;

Future<List<ReadarrAuthor>> _commandGetAllAuthors(Dio client) async {
  Response response = await client.get('author');
  return (response.data as List)
      .map((author) => ReadarrAuthor.fromJson(author))
      .toList();
}
