part of sonarr_types;

enum SonarrImportMode {
  COPY,
  MOVE,
}

/// Extension on [SonarrImportMode] to implement extended functionality.
extension SonarrImportModeExtension on SonarrImportMode {
  /// Given a String, will return the correct [SonarrImportMode] object.
  SonarrImportMode? from(String? type) {
    switch (type) {
      case 'copy':
        return SonarrImportMode.COPY;
      case 'move':
        return SonarrImportMode.MOVE;
      default:
        return null;
    }
  }

  String get value {
    switch (this) {
      case SonarrImportMode.COPY:
        return 'copy';
      case SonarrImportMode.MOVE:
        return 'move';
    }
  }
}
