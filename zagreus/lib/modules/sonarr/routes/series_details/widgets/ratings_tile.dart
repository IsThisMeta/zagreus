import 'package:flutter/material.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/extensions/string/links.dart';
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
      final ratings = await OMDbApi.getMovieRatings(widget.series!.imdbId);

      // Debug: Log ratings data for TV shows
      print('OMDb Ratings for ${widget.series!.title} (${widget.series!.imdbId}):');
      print('  IMDb: ${ratings?.imdbRating}');
      print('  RT: ${ratings?.rottenTomatoes}');
      print('  Metacritic: ${ratings?.metacritic}');

      setState(() {
        _ratings = ratings;
        _loading = false;
        _hasError = ratings == null || !ratings.hasRatings;
      });
    } catch (e) {
      print('Error fetching ratings for ${widget.series!.title}: $e');
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if still loading or has error
    if (_loading || _hasError || _ratings == null || !_ratings!.hasRatings) {
      return const SizedBox.shrink();
    }

    final imdbId = widget.series?.imdbId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_ratings!.imdbRating != null && imdbId != null)
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
          if (_ratings!.rottenTomatoes != null)
            _buildRating('🍅', _ratings!.rottenTomatoes!),
          if (_ratings!.metacritic != null)
            _buildRating('Ⓜ️', _ratings!.metacritic!),
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
