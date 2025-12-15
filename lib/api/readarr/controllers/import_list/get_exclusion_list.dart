part of readarr_commands;

Future<List<ReadarrExclusion>> _commandGetExclusionList(Dio client) async {
  Response response = await client.get('importlistexclusion');
  return (response.data as List)
      .map((exclusion) => ReadarrExclusion.fromJson(exclusion))
      .toList();
}
