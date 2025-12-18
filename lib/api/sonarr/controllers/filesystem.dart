part of sonarr_commands;

/// Facilitates, encapsulates, and manages individual calls related to the filesystem from Sonarr.
class SonarrControllerFilesystem {
  final Dio _client;

  /// Create a controller using an initialized [Dio] client.
  SonarrControllerFilesystem(this._client);

  /// Handler for `filesystem`.
  ///
  /// Returns a list of directories and files in the supplied path.
  /// If no path is supplied, fetches the root directory of the OS.
  ///
  /// - `path`: The full path on the filesystem
  /// - `allowFoldersWithoutTrailingSlashes`: Go into a folders without trailing slashes
  /// - `includeFiles`: Include files in the folder (defaulted to false)
  Future<SonarrFileSystem> get({
    String? path,
    bool? allowFoldersWithoutTrailingSlashes,
    bool? includeFiles,
  }) async =>
      _controllerGetFileSystem(
        _client,
        path: path,
        allowFoldersWithoutTrailingSlashes: allowFoldersWithoutTrailingSlashes,
        includeFiles: includeFiles,
      );

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
