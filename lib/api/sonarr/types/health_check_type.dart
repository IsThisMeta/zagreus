part of sonarr_types;

/// Enumerator to handle all health check types used in Sonarr.
enum SonarrHealthCheckType {
  NOTICE,
  WARNING,
  ERROR,
}

/// Extension on [SonarrHealthCheckType] to implement extended functionality.
extension SonarrHealthCheckTypeExtension on SonarrHealthCheckType {
  /// Given a String, will return the correct [SonarrHealthCheckType] object.
  SonarrHealthCheckType? from(String? type) {
    switch (type) {
      case 'notice':
        return SonarrHealthCheckType.NOTICE;
      case 'warning':
        return SonarrHealthCheckType.WARNING;
      case 'error':
        return SonarrHealthCheckType.ERROR;
      default:
        return null;
    }
  }

  String? get value {
    switch (this) {
      case SonarrHealthCheckType.NOTICE:
        return 'notice';
      case SonarrHealthCheckType.WARNING:
        return 'warning';
      case SonarrHealthCheckType.ERROR:
        return 'error';
      default:
        return null;
    }
  }

  String? get readable {
    switch (this) {
      case SonarrHealthCheckType.NOTICE:
        return 'Notice';
      case SonarrHealthCheckType.WARNING:
        return 'Warning';
      case SonarrHealthCheckType.ERROR:
        return 'Error';
      default:
        return null;
    }
  }
}
