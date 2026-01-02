import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrCatalogueData {
  String title;
  String sortTitle;
  String overview;
  String? path;
  String authorType;
  String added;
  int authorID;
  int? qualityProfile;
  int? metadataProfile;
  String? quality;
  String? metadata;
  bool? monitored;
  Map statistics;
  List genres;
  List links;
  String foreignAuthorID;
  int sizeOnDisk;

  ReadarrCatalogueData({
    required this.title,
    required this.sortTitle,
    required this.overview,
    required this.path,
    required this.authorID,
    required this.monitored,
    required this.statistics,
    required this.qualityProfile,
    required this.metadataProfile,
    required this.quality,
    required this.metadata,
    required this.genres,
    required this.links,
    required this.foreignAuthorID,
    required this.sizeOnDisk,
    required this.authorType,
    required this.added,
  });

  String get genre {
    if (genres.isNotEmpty) return genres.join('\n');
    return 'zagreus.Unknown'.tr();
  }

  DateTime? get dateAddedObject => DateTime.tryParse(added)?.toLocal();

  String get dateAdded {
    return DateFormat('MMMM dd, y').format(dateAddedObject!);
  }

  String? subtitle(ReadarrCatalogueSorting sorting) => _sortSubtitle(sorting);

  String? _sortSubtitle(ReadarrCatalogueSorting sorting) {
    switch (sorting) {
      case ReadarrCatalogueSorting.metadata:
        return metadata;
      case ReadarrCatalogueSorting.quality:
        return quality;
      case ReadarrCatalogueSorting.books:
        return bookStats;
      case ReadarrCatalogueSorting.type:
        return authorType;
      case ReadarrCatalogueSorting.dateAdded:
        return dateAdded;
      case ReadarrCatalogueSorting.size:
      case ReadarrCatalogueSorting.alphabetical:
        return sizeOnDisk.asBytes();
    }
  }

  String get bookStats {
    final percentValue = statistics['percentOfBooks'];
    final percentage = percentValue is int
        ? percentValue
        : (percentValue as double).floor();
    return '${statistics['bookFileCount']}/${statistics['bookCount']} ($percentage%)';
  }

  String get books {
    return statistics['bookCount'] == 1
        ? 'readarr.BookCount'
            .tr(args: [statistics['bookCount'].toString()])
        : 'readarr.BooksCount'
            .tr(args: [statistics['bookCount'].toString()]);
  }

  String? get goodreadsURI {
    for (var link in links) {
      if (link['name'] == 'goodreads') {
        return link['url'];
      }
    }
    return '';
  }

  String? get amazonURI {
    for (var link in links) {
      if (link['name'] == 'amazon') {
        return link['url'];
      }
    }
    return '';
  }

  String? get wikipediaURI {
    for (var link in links) {
      if (link['name'] == 'wikipedia') {
        return link['url'];
      }
    }
    return '';
  }

  String posterURI() {
    final host = ZagProfile.forModule('readarr').effectiveReadarrHost();
    final key = ZagProfile.forModule('readarr').readarrKey;
    if (ZagProfile.forModule('readarr').readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Author'
          : '$host/api/v1/MediaCover/Author';
      return '$_base/$authorID/poster-500.jpg?apikey=$key';
    }
    return '';
  }

  String fanartURI({bool highRes = false}) {
    final host = ZagProfile.forModule('readarr').effectiveReadarrHost();
    final key = ZagProfile.forModule('readarr').readarrKey;
    if (ZagProfile.forModule('readarr').readarrEnabled) {
      String _base = host.endsWith('/')
          ? '${host}api/v1/MediaCover/Author'
          : '$host/api/v1/MediaCover/Author';
      return '$_base/$authorID/fanart-360.jpg?apikey=$key';
    }
    return '';
  }
}
