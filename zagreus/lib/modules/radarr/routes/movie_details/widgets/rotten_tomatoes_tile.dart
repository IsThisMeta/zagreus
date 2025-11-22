import 'package:flutter/material.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/radarr.dart';

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
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  Future<void> _fetchRatings() async {
    if (widget.movie?.imdbId == null) {
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    try {
      final ratings = await OMDbApi.getMovieRatings(widget.movie!.imdbId);
      setState(() {
        _ratings = ratings;
        _loading = false;
        _hasError = ratings == null || !ratings.hasRatings;
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
    if (_loading || _hasError || _ratings == null || !_ratings!.hasRatings) {
      return const SizedBox.shrink();
    }

    final imdbId = widget.movie?.imdbId;
    final title = widget.movie?.title;
    final year = widget.movie?.year;

    // Construct search-friendly title (encode for URL)
    final searchTitle = title != null ? Uri.encodeComponent(title) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_ratings!.imdbRating != null && imdbId != null)
            _buildRating(
              '⭐',
              _ratings!.imdbRating!,
              () => 'https://www.imdb.com/title/$imdbId'.openLink(),
            ),
          if (_ratings!.rottenTomatoes != null && searchTitle != null)
            _buildRating(
              '🍅',
              _ratings!.rottenTomatoes!,
              () => 'https://www.rottentomatoes.com/search?search=$searchTitle'
                  .openLink(),
            ),
          if (_ratings!.metacritic != null && searchTitle != null)
            _buildRating(
              'Ⓜ️',
              _ratings!.metacritic!,
              () {
                // Add year to search if available for better results
                final query = year != null
                    ? '$searchTitle $year'
                    : searchTitle;
                return 'https://www.metacritic.com/search/$query/'.openLink();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRating(String emoji, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
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
        ),
      ),
    );
  }
}
