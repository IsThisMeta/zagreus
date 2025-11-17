part of readarr_commands;

Future<ReadarrHistory> _commandGetHistoryByAuthor(
  Dio client, {
  required int authorId,
  required int page,
  required int pageSize,
}) async {
  Response response = await client.get('history/author', queryParameters: {
    'authorId': authorId,
    'page': page,
    'pageSize': pageSize,
  });
  return ReadarrHistory.fromJson(response.data);
}
