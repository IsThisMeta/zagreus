part of radarr_types;

enum RadarrAvailability {
  ANNOUNCED,
  IN_CINEMAS,
  RELEASED,
  PREDB,
  TBA,
}

extension RadarrAvailabilityExtension on RadarrAvailability {
  RadarrAvailability? from(String? type) {
    switch (type) {
      case 'announced':
        return RadarrAvailability.ANNOUNCED;
      case 'inCinemas':
        return RadarrAvailability.IN_CINEMAS;
      case 'released':
        return RadarrAvailability.RELEASED;
      case 'preDB':
        return RadarrAvailability.PREDB;
      case 'tba':
        return RadarrAvailability.TBA;
      default:
        return null;
    }
  }

  String get value {
    switch (this) {
      case RadarrAvailability.ANNOUNCED:
        return 'announced';
      case RadarrAvailability.IN_CINEMAS:
        return 'inCinemas';
      case RadarrAvailability.RELEASED:
        return 'released';
      case RadarrAvailability.PREDB:
        return 'preDB';
      case RadarrAvailability.TBA:
        return 'tba';
    }
  }

  String get readable {
    switch (this) {
      case RadarrAvailability.ANNOUNCED:
        return 'radarr.Announced'.tr();
      case RadarrAvailability.IN_CINEMAS:
        return 'radarr.InCinemas'.tr();
      case RadarrAvailability.RELEASED:
        return 'radarr.Released'.tr();
      case RadarrAvailability.PREDB:
        return 'radarr.PreDB'.tr();
      case RadarrAvailability.TBA:
        return 'radarr.TBA'.tr();
    }
  }
}
