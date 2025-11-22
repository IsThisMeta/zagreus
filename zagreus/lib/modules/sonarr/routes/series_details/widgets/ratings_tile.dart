import 'package:flutter/material.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/links.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchRatings();
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
      final tmdbId = await TMDBApi.getTmdbIdFromImdb(widget.series!.imdbId!);
      if (tmdbId != null) {
        final tmdbData = await TMDBApi.getTVShowDetails(tmdbId);
        if (tmdbData != null && tmdbData['vote_average'] != null) {
          tmdbRating = (tmdbData['vote_average'] as num).toDouble();
        }
      }

      setState(() {
        _ratings = ratings;
        _tmdbRating = tmdbRating;
        _loading = false;
        _hasError = ratings == null && tmdbRating == null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if still loading or has error
    if (_loading ||
        _hasError ||
        (_ratings == null && _tmdbRating == null) ||
        (_ratings != null && !_ratings!.hasRatings && _tmdbRating == null)) {
      return const SizedBox.shrink();
    }

    final imdbId = widget.series?.imdbId;

    // TV shows have IMDb and TMDb ratings
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_ratings?.imdbRating != null && imdbId != null)
            _buildRating(
              '⭐',
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
            _buildRating('🎬', _tmdbRating!.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildRating(String emoji, String value, {VoidCallback? onTap}) {
    final content = Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 18),
        ),
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
