import 'package:zagreus/core.dart';

class ReadarrBookData {
  String title;
  String releaseDate;
  int bookID;
  int editionCount;
  bool monitored;
  bool grabbed;
  int? authorID;

  ReadarrBookData({
    required this.bookID,
    required this.title,
    required this.monitored,
    required this.releaseDate,
    required this.editionCount,
    required this.grabbed,
    this.authorID,
  });

  DateTime? get releaseDateObject => DateTime.tryParse(releaseDate)?.toLocal();

  String get releaseDateString {
    if (releaseDateObject != null) {
      return DateFormat('MMMM dd, y').format(releaseDateObject!);
    }
    return 'Unknown Release Date';
  }

  String get editions {
    return editionCount != 1 ? '$editionCount Editions' : '$editionCount Edition';
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
}
