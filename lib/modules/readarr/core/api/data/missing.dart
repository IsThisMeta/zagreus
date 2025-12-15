import 'package:zagreus/core.dart';

class ReadarrMissingData {
  String title;
  String authorTitle;
  String releaseDate;
  int authorID;
  int bookID;
  bool monitored;

  ReadarrMissingData({
    required this.title,
    required this.authorTitle,
    required this.authorID,
    required this.bookID,
    required this.releaseDate,
    required this.monitored,
  });

  DateTime? get releaseDateObject {
    return DateTime.tryParse(releaseDate)?.toLocal();
  }

  String get releaseDateString {
    if (releaseDateObject != null) {
      Duration age = DateTime.now().difference(releaseDateObject!);
      if (age.inDays >= 1) {
        return age.inDays <= 1
            ? '${age.inDays} Day Ago'
            : '${age.inDays} Days Ago';
      }
      if (age.inHours >= 1) {
        return age.inHours <= 1
            ? '${age.inHours} Hour Ago'
            : '${age.inHours} Hours Ago';
      }
      return age.inMinutes <= 1
          ? '${age.inMinutes} Minute Ago'
          : '${age.inMinutes} Minutes Ago';
    }
    return 'Unknown Date/Time';
  }

  String bookCoverURI() {
    final host = ZagProfile.current.effectiveReadarrHost();
    final key = ZagProfile.current.readarrKey;
    if (ZagProfile.current.readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Book'
          : '$host/api/v1/MediaCover/Book';
      return '$_base/$bookID/cover-250.jpg?apikey=$key';
    }
    return '';
  }

  String posterURI() {
    final host = ZagProfile.current.effectiveReadarrHost();
    final key = ZagProfile.current.readarrKey;
    if (ZagProfile.current.readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Author'
          : '$host/api/v1/MediaCover/Author';
      return '$_base/$authorID/poster-500.jpg?apikey=$key';
    }
    return '';
  }

  String fanartURI({bool highRes = false}) {
    final host = ZagProfile.current.effectiveReadarrHost();
    final key = ZagProfile.current.readarrKey;
    if (ZagProfile.current.readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Author'
          : '$host/api/v1/MediaCover/Author';
      return '$_base/$authorID/fanart-360.jpg?apikey=$key';
    }
    return '';
  }
}
