part of readarr_commands;

Future<ReadarrQueue> _commandGetQueue(
  Dio client, {
  required int page,
  required int pageSize,
  required String sortKey,
  required String sortDirection,
}) async {
  Response response = await client.get('queue', queryParameters: {
    'page': page,
    'pageSize': pageSize,
    'sortKey': sortKey,
    'sortDirection': sortDirection,
  });
  return ReadarrQueue.fromJson(response.data);
}
