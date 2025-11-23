import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/system/platform.dart';

enum LinkedContentType {
  MOVIE,
  SERIES,
  PERSON,
  IMAGE_POSTER,
  IMAGE_BACKDROP,
}

enum ZagLinkedContent {
  WEBSITE('https://www.zagreus.app'),
  NOTIFICATIONS_DOC('https://docs.zagreus.app/notifications');

  final String url;
  const ZagLinkedContent(this.url);

  Future<void> launch() async => url.openLink();

  static String? imdb(String? id) {
    if (id == null) return null;

    // Use app deep link on mobile platforms to open the IMDb app
    if (ZagPlatform.isMobile) {
      return 'imdb:///title/$id/';
    }

    // Use web URL on desktop/web platforms
    const base = 'https://www.imdb.com';
    return '$base/title/$id';
  }

  static String? letterboxd(int? id) {
    if (id == null) return null;
    const base = 'https://letterboxd.com';

    return '$base/tmdb/$id';
  }

  static String? musicBrainz(String? id) {
    if (id == null) return null;
    const base = 'https://musicbrainz.org/artist';

    return '$base/$id';
  }

  static String plexMobile(
    String plexIdentifier,
    int ratingKey,
  ) {
    if (ZagPlatform.isAndroid) {
      const base = 'plex://server://';
      const path = '/com.plexapp.plugins.library/library/metadata/';
      return '$base$plexIdentifier$path$ratingKey';
    } else {
      const base = 'plex://preplay/?server=';
      const path = '&metadataKey=/library/metadata/';
      return '$base$plexIdentifier$path$ratingKey';
    }
  }

  static String plexWeb(
    String plexIdentifier,
    int ratingKey, [
    bool useLegacy = false,
  ]) {
    const base = 'https://app.plex.tv/desktop#!/server/';
    const path = '/details?key=%2Flibrary%2Fmetadata%2F';
    final legacy = useLegacy ? '&legacy=1' : '';
    return '$base$plexIdentifier$path$ratingKey$legacy';
  }

  static String? theMovieDB(dynamic id, LinkedContentType type) {
    if (id == null) return null;
    const base = 'https://www.themoviedb.org';
    const baseImage = 'https://image.tmdb.org/t/p';

    switch (type) {
      case LinkedContentType.MOVIE:
        return '$base/movie/$id';
      case LinkedContentType.SERIES:
        return '$base/tv/$id';
      case LinkedContentType.PERSON:
        return '$base/person/$id';
      case LinkedContentType.IMAGE_POSTER:
        return '$baseImage/w185$id';
      case LinkedContentType.IMAGE_BACKDROP:
        return '$baseImage/w300$id';
      default:
        throw UnsupportedError('$type content type is not supported');
    }
  }

  static String? trakt(String? imdbId, LinkedContentType type) {
    if (imdbId == null) return null;
    const base = 'https://trakt.tv';

    switch (type) {
      case LinkedContentType.MOVIE:
        return '$base/movies/$imdbId';
      case LinkedContentType.SERIES:
        return '$base/shows/$imdbId';
      default:
        throw UnsupportedError('$type content type is not supported');
    }
  }

  static String? tvMaze(int? id) {
    if (id == null) return null;
    const base = 'https://www.tvmaze.com';

    return '$base/shows/$id';
  }

  static String? theTVDB(int? id, LinkedContentType type) {
    if (id == null) return null;
    const base = 'https://thetvdb.com';

    switch (type) {
      case LinkedContentType.MOVIE:
        return '$base/dereferrer/movie/$id';
      case LinkedContentType.SERIES:
        return '$base/dereferrer/series/$id';
      case LinkedContentType.PERSON:
        return '$base/people/$id';
      default:
        throw UnsupportedError('$type content type is not supported');
    }
  }

  static String? rottenTomatoes(String? title) {
    if (title == null || title.isEmpty) return null;
    const base = 'https://www.rottentomatoes.com';

    // URL encode the title for the search query
    final encodedTitle = Uri.encodeComponent(title);
    return '$base/search?search=$encodedTitle';
  }

  static String? youtube(String? id) {
    if (id == null) return null;
    const base = 'https://www.youtube.com';

    return '$base/watch?v=$id';
  }
}
