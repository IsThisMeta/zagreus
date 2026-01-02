import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr/core/api/data/search.dart';

/// Enum to identify the type of search result
enum ReadarrSearchResultType {
  author,
  book,
}

/// Unified search result that can represent either an author or a book.
/// The Readarr /search endpoint returns mixed results where each item
/// has either an 'author' or 'book' object populated.
class ReadarrUnifiedSearchResult {
  final ReadarrSearchResultType type;
  final String foreignId;

  // Author fields (populated when type == author)
  final String? authorName;
  final String? authorOverview;
  final String? foreignAuthorId;
  final int? authorTadbId;
  final List<dynamic> authorLinks;
  final List<dynamic> authorImages;

  // Book fields (populated when type == book)
  final String? bookTitle;
  final String? bookOverview;
  final String? foreignBookId;
  final String? bookAuthorName;
  final String? bookReleaseDate;
  final String? remoteCover;
  final List<dynamic> bookImages;
  final List<dynamic> bookLinks;

  // Raw author data for adding (needed for addAuthor API call)
  final Map<String, dynamic>? rawAuthorData;
  // Raw book data for adding
  final Map<String, dynamic>? rawBookData;

  ReadarrUnifiedSearchResult({
    required this.type,
    required this.foreignId,
    this.authorName,
    this.authorOverview,
    this.foreignAuthorId,
    this.authorTadbId,
    this.authorLinks = const [],
    this.authorImages = const [],
    this.bookTitle,
    this.bookOverview,
    this.foreignBookId,
    this.bookAuthorName,
    this.bookReleaseDate,
    this.remoteCover,
    this.bookImages = const [],
    this.bookLinks = const [],
    this.rawAuthorData,
    this.rawBookData,
  });

  /// Factory constructor to create from API response
  factory ReadarrUnifiedSearchResult.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final book = json['book'] as Map<String, dynamic>?;

    if (author != null && author.isNotEmpty) {
      return ReadarrUnifiedSearchResult(
        type: ReadarrSearchResultType.author,
        foreignId: json['foreignId'] ?? author['foreignAuthorId'] ?? '',
        authorName: author['authorName'],
        authorOverview: author['overview'],
        foreignAuthorId: author['foreignAuthorId'],
        authorTadbId: author['tadbId'],
        authorLinks: author['links'] ?? [],
        authorImages: author['images'] ?? [],
        rawAuthorData: author,
      );
    } else if (book != null && book.isNotEmpty) {
      final bookAuthor = book['author'] as Map<String, dynamic>?;
      return ReadarrUnifiedSearchResult(
        type: ReadarrSearchResultType.book,
        foreignId: json['foreignId'] ?? book['foreignBookId'] ?? '',
        bookTitle: book['title'],
        bookOverview: book['overview'],
        foreignBookId: book['foreignBookId'],
        bookAuthorName: bookAuthor?['authorName'] ?? book['authorTitle'],
        bookReleaseDate: book['releaseDate'],
        remoteCover: book['remoteCover'],
        bookImages: book['images'] ?? [],
        bookLinks: book['links'] ?? [],
        rawAuthorData: bookAuthor,
        rawBookData: book,
      );
    }

    // Fallback - shouldn't happen with valid API response
    return ReadarrUnifiedSearchResult(
      type: ReadarrSearchResultType.author,
      foreignId: json['foreignId'] ?? '',
    );
  }

  /// Display title - author name or book title
  String get displayTitle {
    return type == ReadarrSearchResultType.author
        ? authorName ?? 'readarr.UnknownAuthor'.tr()
        : bookTitle ?? 'readarr.UnknownBookTitle'.tr();
  }

  /// Subtitle - for books, shows the author name
  String? get subtitle {
    return type == ReadarrSearchResultType.book ? bookAuthorName : null;
  }

  /// Overview/description
  String get overview {
    final text = type == ReadarrSearchResultType.author
        ? authorOverview
        : bookOverview;
    return (text == null || text.isEmpty)
        ? 'readarr.NoSummaryAvailable'.tr()
        : text;
  }

  /// Type label for display
  String get typeLabel {
    return type == ReadarrSearchResultType.author
        ? 'readarr.Author'.tr()
        : 'readarr.Book'.tr();
  }

  /// Get poster/cover URI
  String? get posterURI {
    if (type == ReadarrSearchResultType.author) {
      for (var image in authorImages) {
        if (image['coverType'] == 'poster') {
          return image['url'];
        }
      }
      return null;
    } else {
      // For books, prefer remoteCover, then look in images
      if (remoteCover != null && remoteCover!.isNotEmpty) {
        return remoteCover;
      }
      for (var image in bookImages) {
        if (image['coverType'] == 'cover') {
          return image['url'];
        }
      }
      return null;
    }
  }

  /// Get Goodreads link if available
  String? get goodreadsLink {
    final links = type == ReadarrSearchResultType.author
        ? authorLinks
        : bookLinks;
    for (var link in links) {
      if (link['name'] == 'goodreads') {
        return link['url'];
      }
    }
    return null;
  }

  /// Convert to ReadarrSearchData for compatibility with existing add author flow
  /// Only valid for author type results
  ReadarrSearchData? toSearchData() {
    if (type != ReadarrSearchResultType.author) return null;
    return ReadarrSearchData(
      title: authorName ?? '',
      foreignAuthorId: foreignAuthorId ?? '',
      overview: authorOverview,
      tadbId: authorTadbId,
      links: authorLinks,
      images: authorImages,
    );
  }
}
