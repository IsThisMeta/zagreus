part of readarr_commands;

Future<ReadarrTag> _commandGetTag(
  Dio client, {
  required int tagId,
}) async {
  Response response = await client.get('tag/$tagId');
  return ReadarrTag.fromJson(response.data);
}
