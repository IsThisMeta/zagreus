part of bazarr_controllers;

/// Facilitates, encapsulates, and manages individual calls related to the system within Bazarr.
class BazarrControllerSystem {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  BazarrControllerSystem(this._client);

  /// Handler for `system/status`.
  ///
  /// Returns details about the installation/system.
  Future<BazarrSystemStatus> status() async => _controllerGetSystemStatus(_client);
}
