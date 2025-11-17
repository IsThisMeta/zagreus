part of readarr_commands;

Future<List<ReadarrHealthCheck>> _commandGetHealth(Dio client) async {
  Response response = await client.get('health');
  return (response.data as List)
      .map((health) => ReadarrHealthCheck.fromJson(health))
      .toList();
}
