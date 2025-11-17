part of readarr_commands;

Future<ReadarrBookFile> _commandGetBookFile(
  Dio client, {
  required int bookFileId,
}) async {
  Response response = await client.get('bookfile/$bookFileId');
  return ReadarrBookFile.fromJson(response.data);
}
