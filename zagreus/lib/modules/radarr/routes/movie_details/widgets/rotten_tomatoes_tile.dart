import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/system/platform.dart';
import 'package:zagreus/utils/links.dart';
import 'package:zagreus/services/subscription_service.dart';

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
  late final bool _isPremium;
  int? _tmdbId;

  @override
  void initState() {
    super.initState();
    // Get cached premium status (no DB reads!)
    _isPremium = SubscriptionService.isPremium;

    // Only fetch ratings if user is premium
    if (_isPremium) {
      _fetchRatings();
    } else {
      _loading = false;
    }
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
      int? tmdbId;
      if (widget.movie?.tmdbId != null) {
        tmdbId = widget.movie!.tmdbId;
        final tmdbData = await TMDBApi.getMovieDetails(tmdbId!);
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
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show for Pro/Mega/Ultra users (checked once in initState)
    if (!_isPremium) {
      return const SizedBox.shrink();
    }

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
                        LinkedContentType.MOVIE,
                      );
                      if (link != null) link.openLink();
                    }
                  : null,
            ),
          if (_ratings?.rottenTomatoes != null)
            _buildRating(
              Image.asset(
                _getRottenTomatoesIcon(_ratings!.rottenTomatoes!),
                height: 20,
              ),
              _ratings!.rottenTomatoes!,
              onTap: () {
                final link = ZagLinkedContent.rottenTomatoes(
                  widget.movie?.title,
                  LinkedContentType.MOVIE,
                );
                if (link != null) link.openLink();
              },
            ),
          if (_ratings?.metacritic != null)
            _buildRating(
              Image.asset(
                'assets/icons/ratings/metacritic-30.png',
                height: 20,
              ),
              _ratings!.metacritic!,
            ),
        ],
      ),
    );
  }

  String _getRottenTomatoesIcon(String rating) {
    // Parse the percentage from the rating string (e.g., "85%" -> 85)
    final percentStr = rating.replaceAll('%', '').trim();
    final percent = int.tryParse(percentStr) ?? 0;

    // Show fresh tomato if 60% or higher, rotten if lower
    if (percent >= 60) {
      return 'assets/icons/ratings/rt-fresh-30.png';
    } else {
      return 'assets/icons/ratings/rt-rotten-30.png';
    }
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
