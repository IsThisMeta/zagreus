part of readarr_commands;

Future<List<ReadarrBook>> _commandGetBooksByAuthor(
  Dio client, {
  required int authorId,
}) async {
  Response response = await client.get('book', queryParameters: {
    'authorId': authorId,
  });
  return (response.data as List)
      .map((book) => ReadarrBook.fromJson(book))
      .toList();
}
