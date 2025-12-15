part of readarr_commands;

Future<void> _commandAddRelease(
  Dio client, {
  required String guid,
  required int indexerId,
}) async {
  await client.post('release', data: {
    'guid': guid,
    'indexerId': indexerId,
  });
}
