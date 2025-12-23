import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/links.dart';
import 'package:zagreus/services/subscription_service.dart';
import 'package:zagreus/services/ratings_cache_service.dart';

class SonarrRatingsTile extends StatefulWidget {
  final SonarrSeries? series;

  const SonarrRatingsTile({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  State<SonarrRatingsTile> createState() => _SonarrRatingsTileState();
}

class _SonarrRatingsTileState extends State<SonarrRatingsTile> {
  MovieRatings? _ratings;
  double? _tmdbRating;
  bool _loading = true;
  bool _hasError = false;
  late final bool _isPremium;
  int? _tmdbId;

  @override
  void initState() {
    super.initState();
    // Get cached premium status (no DB reads!)
    _isPremium = SubscriptionService.isPremium;

    // Only fetch ratings if user is premium
    if (_isPremium) {
      // Check cache first for instant load
      bool loadedFromCache = false;
      if (widget.series?.imdbId != null) {
        final cached = RatingsCacheService().getCachedRatings(widget.series!.imdbId!);
        if (cached != null) {
          // Hot-load from cache to prevent flicker
          setState(() {
            _ratings = cached.ratings;
            _tmdbRating = cached.tmdbRating;
            _tmdbId = cached.tmdbId;
            _loading = false;
            _hasError = cached.ratings == null && cached.tmdbRating == null;
          });
          loadedFromCache = true;
        }
      }
      // Only fetch if not loaded from cache
      if (!loadedFromCache) {
        _fetchRatings();
      }
    } else {
      _loading = false;
    }
  }

  Future<void> _fetchRatings() async {
    if (widget.series?.imdbId == null) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    try {
      // Fetch OMDb ratings (IMDb only for TV shows)
      final ratings = await OMDbApi.getMovieRatings(widget.series!.imdbId);

      // Fetch TMDb rating by looking up TMDb ID from IMDb ID
      double? tmdbRating;
      int? tmdbId;
      tmdbId = await TMDBApi.getTmdbIdFromImdb(widget.series!.imdbId!);
      if (tmdbId != null) {
        final tmdbData = await TMDBApi.getTVShowDetails(tmdbId);
        if (tmdbData != null && tmdbData['vote_average'] != null) {
          tmdbRating = (tmdbData['vote_average'] as num).toDouble();
        }
      }

      setState(() {
        _ratings = ratings;
        _tmdbRating = tmdbRating;
        _tmdbId = tmdbId;
        _loading = false;
        _hasError = ratings == null && tmdbRating == null;
      });

      // Cache the ratings for potential navigation to details page
      if (widget.series?.imdbId != null) {
        RatingsCacheService().cacheRatings(
          id: widget.series!.imdbId!,
          ratings: ratings,
          tmdbRating: tmdbRating,
          tmdbId: tmdbId,
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  // Fixed height for the ratings row to prevent layout jumps
  static const double _ratingsHeight = 30.0;

  @override
  Widget build(BuildContext context) {
    // Check if ratings are hidden in settings
    if (ZagreusDatabase.APPEARANCE_HIDE_RATINGS.read()) {
      return const SizedBox.shrink();
    }

    // Only show for Pro/Mega/Ultra users (checked once in initState)
    if (!_isPremium) {
      return const SizedBox.shrink();
    }

    // Show loading indicator while fetching ratings (fixed height to prevent jumps)
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SizedBox(
          height: _ratingsHeight,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    // Don't show anything if error or no ratings available
    if (_hasError ||
        (_ratings == null && _tmdbRating == null) ||
        (_ratings != null && !_ratings!.hasRatings && _tmdbRating == null)) {
      return const SizedBox.shrink();
    }

    final imdbId = widget.series?.imdbId;

    // TV shows have IMDb and TMDb ratings
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: _ratingsHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_ratings?.imdbRating != null && imdbId != null)
              _buildRating(
                SvgPicture.asset(
                  'assets/icons/ratings/imdb.svg',
                  height: 17,
                ),
                _ratings!.imdbRating!,
                onTap: () {
                  // Use imdb:// deep link on mobile, https on web
                  final link = ZagPlatform.isMobile
                      ? ZagLinkedContent.imdb(imdbId)
                      : 'https://www.imdb.com/title/$imdbId';
                  if (link != null) link.openLink();
                },
              ),
            if (_tmdbRating != null)
              _buildRating(
                Image.asset(
                  'assets/icons/ratings/tmdb.png',
                  height: 30,
                ),
                _tmdbRating!.toStringAsFixed(1),
                onTap: _tmdbId != null
                    ? () {
                        final link = ZagLinkedContent.theMovieDB(
                          _tmdbId,
                          LinkedContentType.SERIES,
                        );
                        if (link != null) link.openLink();
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRating(Widget icon, String value, {VoidCallback? onTap}) {
    final content = Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: onTap != null
          ? GestureDetector(onTap: onTap, child: content)
          : content,
    );
  }
}
