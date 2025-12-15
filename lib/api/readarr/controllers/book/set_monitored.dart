part of readarr_commands;

Future<List<ReadarrBook>> _commandSetMonitored(
  Dio client, {
  required List<int> bookIds,
  required bool monitored,
}) async {
  Response response = await client.put(
    'book/monitor',
    data: {
      'bookIds': bookIds,
      'monitored': monitored,
    },
  );
  return (response.data as List)
      .map((book) => ReadarrBook.fromJson(book))
      .toList();
}
