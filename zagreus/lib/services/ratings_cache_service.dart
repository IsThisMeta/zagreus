import 'package:zagreus/api/omdb/omdb_api.dart';

/// Cached ratings data for a movie or TV show
class CachedRatings {
  final MovieRatings? ratings;
  final double? tmdbRating;
  final int? tmdbId;
  final String? imdbId;

  CachedRatings({
    this.ratings,
    this.tmdbRating,
    this.tmdbId,
    this.imdbId,
  });
}

/// Simple single-item cache for ratings to prevent flicker when navigating
/// from monitor/add pages to details pages.
///
/// This cache only stores the last viewed item's ratings, which is perfect
/// for the add -> details flow where we know the user is viewing the same item.
class RatingsCacheService {
  static final RatingsCacheService _instance = RatingsCacheService._internal();
  factory RatingsCacheService() => _instance;
  RatingsCacheService._internal();

  CachedRatings? _cachedRatings;
  String? _cachedId;

  /// Store ratings for a movie or TV show
  void cacheRatings({
    required String id,
    MovieRatings? ratings,
    double? tmdbRating,
    int? tmdbId,
  }) {
    _cachedId = id;
    _cachedRatings = CachedRatings(
      ratings: ratings,
      tmdbRating: tmdbRating,
      tmdbId: tmdbId,
      imdbId: id,
    );
  }

  /// Get cached ratings if the ID matches
  CachedRatings? getCachedRatings(String id) {
    if (_cachedId == id && _cachedRatings != null) {
      return _cachedRatings;
    }
    return null;
  }

  /// Clear the cache
  void clear() {
    _cachedRatings = null;
    _cachedId = null;
  }
}
