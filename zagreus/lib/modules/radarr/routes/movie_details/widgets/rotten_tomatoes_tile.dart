import 'package:flutter/material.dart';
import 'package:zagreus/api/omdb/omdb_api.dart';
import 'package:zagreus/core.dart';
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
  RottenTomatoesRatings? _ratings;
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
      final ratings =
          await OMDbApi.getRottenTomatoesRatings(widget.movie!.imdbId);
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

    return ZagTableCard(
      content: [
        if (_ratings!.tomatoMeterValue != null)
          ZagTableContent(
            title: '🍅 Tomatometer',
            body: '${_ratings!.tomatoMeterValue}%',
          ),
        if (_ratings!.audienceScoreValue != null)
          ZagTableContent(
            title: '🍿 Audience Score',
            body: '${_ratings!.audienceScoreValue}%',
          ),
      ],
    );
  }
}
