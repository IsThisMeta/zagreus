import 'package:zagreus/core.dart';

enum LidarrMonitorStatus {
  ALL,
  FUTURE,
  MISSING,
  EXISTING,
  ONLY_FIRST_ALBUM,
  ONLY_LAST_ALBUM,
  NONE,
}

extension LidarrMonitorStatusExtension on LidarrMonitorStatus {
  LidarrMonitorStatus? fromKey(String key) {
    switch (key) {
      case 'all':
        return LidarrMonitorStatus.ALL;
      case 'future':
        return LidarrMonitorStatus.FUTURE;
      case 'missing':
        return LidarrMonitorStatus.MISSING;
      case 'existing':
        return LidarrMonitorStatus.EXISTING;
      case 'first':
        return LidarrMonitorStatus.ONLY_FIRST_ALBUM;
      case 'latest':
        return LidarrMonitorStatus.ONLY_LAST_ALBUM;
      case 'none':
        return LidarrMonitorStatus.NONE;
      default:
        return null;
    }
  }

  String get key {
    switch (this) {
      case LidarrMonitorStatus.ALL:
        return 'all';
      case LidarrMonitorStatus.FUTURE:
        return 'future';
      case LidarrMonitorStatus.MISSING:
        return 'missing';
      case LidarrMonitorStatus.EXISTING:
        return 'existing';
      case LidarrMonitorStatus.ONLY_FIRST_ALBUM:
        return 'first';
      case LidarrMonitorStatus.ONLY_LAST_ALBUM:
        return 'latest';
      case LidarrMonitorStatus.NONE:
        return 'none';
    }
  }

  String get readable {
    switch (this) {
      case LidarrMonitorStatus.ALL:
        return 'lidarr.MonitorAllAlbums'.tr();
      case LidarrMonitorStatus.FUTURE:
        return 'lidarr.MonitorFutureAlbums'.tr();
      case LidarrMonitorStatus.MISSING:
        return 'lidarr.MonitorMissingAlbums'.tr();
      case LidarrMonitorStatus.EXISTING:
        return 'lidarr.MonitorExistingAlbums'.tr();
      case LidarrMonitorStatus.ONLY_FIRST_ALBUM:
        return 'lidarr.MonitorFirstAlbumOnly'.tr();
      case LidarrMonitorStatus.ONLY_LAST_ALBUM:
        return 'lidarr.MonitorLatestAlbumOnly'.tr();
      case LidarrMonitorStatus.NONE:
        return 'lidarr.MonitorNone'.tr();
    }
  }
}
