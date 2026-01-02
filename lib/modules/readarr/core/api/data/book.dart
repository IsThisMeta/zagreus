import 'package:zagreus/core.dart';

class ReadarrBookData {
  String title;
  String releaseDate;
  int bookID;
  int editionCount;
  bool monitored;
  bool grabbed;
  int? authorID;

  // Enhanced fields for book details page
  String? overview;
  int? pageCount;
  double? rating;
  String? authorName;
  List<dynamic>? images;
  List<dynamic>? links;
  List<dynamic>? editionsData;

  ReadarrBookData({
    required this.bookID,
    required this.title,
    required this.monitored,
    required this.releaseDate,
    required this.editionCount,
    required this.grabbed,
    this.authorID,
    this.overview,
    this.pageCount,
    this.rating,
    this.authorName,
    this.images,
    this.links,
    this.editionsData,
  });

  DateTime? get releaseDateObject => DateTime.tryParse(releaseDate)?.toLocal();

  String get releaseDateString {
    if (releaseDateObject != null) {
      return DateFormat('MMMM dd, y').format(releaseDateObject!);
    }
    return 'readarr.UnknownReleaseDate'.tr();
  }

  String get editions {
    return editionCount == 1
        ? 'readarr.EditionCount'.tr(args: [editionCount.toString()])
        : 'readarr.EditionsCount'.tr(args: [editionCount.toString()]);
  }

  String bookCoverURI() {
    final host = ZagProfile.forModule('readarr').effectiveReadarrHost();
    final key = ZagProfile.forModule('readarr').readarrKey;
    if (ZagProfile.forModule('readarr').readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Book'
          : '$host/api/v1/MediaCover/Book';
      return '$_base/$bookID/cover-250.jpg?apikey=$key';
    }
    return '';
  }
}
