part of readarr_commands;

Future<void> _commandDeleteTag(
  Dio client, {
  required int tagId,
}) async {
  await client.delete('tag/$tagId');
}
