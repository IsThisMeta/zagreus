import 'package:flutter/material.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (_ratings!.imdbRating != null)
            _buildRating('⭐', _ratings!.imdbRating!),
          if (_ratings!.rottenTomatoes != null)
            _buildRating('🍅', _ratings!.rottenTomatoes!),
          if (_ratings!.metacritic != null)
            _buildRating('Ⓜ️', _ratings!.metacritic!),
        ],
      ),
    );
  }

  Widget _buildRating(String emoji, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
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
    );
  }
}
