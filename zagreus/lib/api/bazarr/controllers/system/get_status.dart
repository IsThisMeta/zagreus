part of bazarr_controllers;

Future<BazarrSystemStatus> _controllerGetSystemStatus(Dio client) async {
  Response response = await client.get('system/status');
  return BazarrSystemStatus.fromJson(response.data);
}
