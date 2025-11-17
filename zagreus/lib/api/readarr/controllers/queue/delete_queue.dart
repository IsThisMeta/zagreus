part of readarr_commands;

Future<void> _commandDeleteQueue(
  Dio client, {
  required int queueId,
  bool removeFromClient = true,
  bool blocklist = false,
}) async {
  await client.delete('queue/$queueId', queryParameters: {
    'removeFromClient': removeFromClient,
    'blocklist': blocklist,
  });
}
