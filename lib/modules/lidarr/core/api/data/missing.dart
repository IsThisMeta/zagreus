import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/double/time.dart';

class LidarrMissingData {
  String title;
  String artistTitle;
  String releaseDate;
  int artistID;
  int albumID;
  bool monitored;

  LidarrMissingData({
    required this.title,
    required this.artistTitle,
    required this.artistID,
    required this.albumID,
    required this.releaseDate,
    required this.monitored,
  });

  DateTime? get releaseDateObject {
    return DateTime.tryParse(releaseDate)?.toLocal();
  }

  String get releaseDateString {
    if (releaseDateObject != null) {
      Duration age = DateTime.now().difference(releaseDateObject!);
      return (age.inMinutes / 60).asTimeAgo();
    }
    return 'zagreus.UnknownDate'.tr();
  }

  String albumCoverURI() {
    final host = ZagProfile.forModule('lidarr').effectiveLidarrHost();
    final key = ZagProfile.forModule('lidarr').lidarrKey;
    if (ZagProfile.forModule('lidarr').lidarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Album'
          : '$host/api/v1/MediaCover/Album';
      return '$_base/$albumID/cover-250.jpg?apikey=$key';
    }
    return '';
  }

  String posterURI() {
    final host = ZagProfile.forModule('lidarr').effectiveLidarrHost();
    final key = ZagProfile.forModule('lidarr').lidarrKey;
    if (ZagProfile.forModule('lidarr').lidarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Artist'
          : '$host/api/v1/MediaCover/Artist';
      return '$_base/$artistID/poster-500.jpg?apikey=$key';
    }
    return '';
  }

  String fanartURI({bool highRes = false}) {
    final host = ZagProfile.forModule('lidarr').effectiveLidarrHost();
    final key = ZagProfile.forModule('lidarr').lidarrKey;
    if (ZagProfile.forModule('lidarr').lidarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Artist'
          : '$host/api/v1/MediaCover/Artist';
      return '$_base/$artistID/fanart-360.jpg?apikey=$key';
    }
    return '';
  }
}
