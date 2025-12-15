part of readarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to filesystem within Readarr.
class ReadarrControllerFilesystem {
  final Dio _client;

  ReadarrControllerFilesystem(this._client);

  /// Handler for `GET /api/v1/diskspace`.
  ///
  /// Get disk space.
  Future<List<ReadarrDiskSpace>> getDiskSpace() async =>
      _commandGetDiskSpace(_client);
}
