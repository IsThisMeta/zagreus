part of readarr_commands;

Future<List<ReadarrCalendar>> _commandGetCalendar(
  Dio client, {
  DateTime? start,
  DateTime? end,
  bool unmonitored = false,
}) async {
  final Map<String, dynamic> params = {
    'unmonitored': unmonitored,
  };

  if (start != null) {
    params['start'] = start.toIso8601String();
  }
  if (end != null) {
    params['end'] = end.toIso8601String();
  }

  Response response = await client.get('calendar', queryParameters: params);
  return (response.data as List)
      .map((item) => ReadarrCalendar.fromJson(item))
      .toList();
}
