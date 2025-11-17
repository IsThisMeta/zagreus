part of readarr_commands;

Future<ReadarrTag> _commandUpdateTag(
  Dio client, {
  required int tagId,
  required String label,
}) async {
  Response response = await client.put('tag/$tagId', data: {'label': label});
  return ReadarrTag.fromJson(response.data);
}
