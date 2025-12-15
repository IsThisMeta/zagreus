part of sonarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to the filesystem from Sonarr.
class SonarrControllerFilesystem {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  SonarrControllerFilesystem(this._client);

  /// Handler for `diskspace`.
  ///
  /// Returns a list of all disks and space information for the disks.
  Future<List<SonarrDiskSpace>> getAllDiskSpaces() async {
    Response response = await _client.get('diskspace');
    return (response.data as List)
        .map((disk) => SonarrDiskSpace.fromJson(disk))
        .toList();
  }
}
