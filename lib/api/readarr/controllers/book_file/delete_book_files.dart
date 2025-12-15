part of readarr_commands;

Future<void> _commandDeleteBookFiles(
  Dio client, {
  required List<int> bookFileIds,
}) async {
  await client.delete('bookfile/bulk', data: {
    'bookFileIds': bookFileIds,
  });
}
