import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/links.dart';

class RadarrRottenTomatoesTile extends StatefulWidget {
  final RadarrMovie? movie;

  const RadarrRottenTomatoesTile({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  State<RadarrRottenTomatoesTile> createState() =>
      _RadarrRottenTomatoesTileState();
}

class _RadarrRottenTomatoesTileState extends State<RadarrRottenTomatoesTile> {
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
    if (widget.movie?.imdbId == null && widget.movie?.tmdbId == null) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    try {
      // Fetch OMDb ratings (IMDb, RT, Metacritic)
      final ratings = widget.movie?.imdbId != null
          ? await OMDbApi.getMovieRatings(widget.movie!.imdbId)
          : null;

      // Fetch TMDb rating
      double? tmdbRating;
      if (widget.movie?.tmdbId != null) {
        final tmdbData = await TMDBApi.getMovieDetails(widget.movie!.tmdbId!);
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

    final imdbId = widget.movie?.imdbId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_ratings?.imdbRating != null && imdbId != null)
            _buildRating(
              SvgPicture.asset(
                'assets/icons/ratings/imdb.svg',
                height: 20,
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
              SvgPicture.asset(
                'assets/icons/ratings/tmdb.svg',
                height: 20,
                colorFilter: null, // Preserve original SVG colors
              ),
              _tmdbRating!.toStringAsFixed(1),
            ),
          if (_ratings?.rottenTomatoes != null)
            _buildRating(
              Image.asset(
                'assets/icons/ratings/rotten_tomatoes.png',
                height: 20,
              ),
              _ratings!.rottenTomatoes!,
            ),
          if (_ratings?.metacritic != null)
            _buildRating(
              ClipOval(
                child: Image.asset(
                  'assets/icons/ratings/metacritic.jpg',
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                ),
              ),
              _ratings!.metacritic!,
            ),
        ],
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
