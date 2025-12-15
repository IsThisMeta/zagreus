part of readarr_commands;

Future<List<ReadarrNotification>> _commandGetNotifications(Dio client) async {
  Response response = await client.get('notification');
  return (response.data as List)
      .map((notification) => ReadarrNotification.fromJson(notification))
      .toList();
}
