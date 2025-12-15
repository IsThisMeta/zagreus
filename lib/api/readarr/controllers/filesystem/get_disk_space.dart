part of readarr_commands;

Future<List<ReadarrDiskSpace>> _commandGetDiskSpace(Dio client) async {
  Response response = await client.get('diskspace');
  return (response.data as List)
      .map((disk) => ReadarrDiskSpace.fromJson(disk))
      .toList();
}
