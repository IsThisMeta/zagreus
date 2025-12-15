part of readarr_commands;

Future<ReadarrBook> _commandGetBook(
  Dio client, {
  required int bookId,
}) async {
  Response response = await client.get('book/$bookId');
  return ReadarrBook.fromJson(response.data);
}
