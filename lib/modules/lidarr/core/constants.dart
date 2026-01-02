import 'package:zagreus/core.dart';

class LidarrConstants {
  LidarrConstants._();

  static String eventTypeMessage(String eventType) {
    switch (eventType) {
      case 'trackFileRenamed':
        return 'lidarr.TrackFileRenamed'.tr();
      case 'trackFileDeleted':
        return 'lidarr.TrackFileDeleted'.tr();
      case 'trackFileImported':
        return 'lidarr.TrackFileImported'.tr();
      case 'trackFileRetagged':
        return 'lidarr.TrackFileRetagged'.tr();
      case 'albumImportIncomplete':
        return 'lidarr.AlbumImportIncomplete'.tr();
      case 'downloadImported':
        return 'lidarr.DownloadImported'.tr();
      case 'downloadFailed':
        return 'lidarr.DownloadFailed'.tr();
      case 'grabbed':
        return 'lidarr.GrabbedFrom'.tr();
      default:
        return eventType;
    }
  }
}
