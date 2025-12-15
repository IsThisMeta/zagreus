part of readarr_commands;

Future<ReadarrHistory> _commandGetHistory(
  Dio client, {
  required int page,
  required int pageSize,
  required String sortKey,
  required String sortDirection,
}) async {
  Response response = await client.get('history', queryParameters: {
    'page': page,
    'pageSize': pageSize,
    'sortKey': sortKey,
    'sortDirection': sortDirection,
  });
  return ReadarrHistory.fromJson(response.data);
}
