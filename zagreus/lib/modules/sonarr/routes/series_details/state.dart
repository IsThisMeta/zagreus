import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';

class SonarrSeriesDetailsState extends ChangeNotifier {
  final SonarrSeries series;

  SonarrSeriesDetailsState({
    required BuildContext context,
    required this.series,
  }) {
    fetchHistory(context);
    fetchCredits(context);
  }

  Future<void> fetchHistory(BuildContext context) async {
    SonarrState state = context.read<SonarrState>();
    if (state.enabled) {
      _history = state.api!.history.getBySeries(
        seriesId: series.id!,
        includeEpisode: true,
      );
    }
    notifyListeners();
    await _history;
  }

  Future<List<SonarrHistoryRecord>>? _history;
  Future<List<SonarrHistoryRecord>>? get history => _history;

  Future<List<SonarrSeriesCredits>>? _credits;
  Future<List<SonarrSeriesCredits>>? get credits => _credits;

  Future<void> fetchCredits(BuildContext context) async {
    try {
      // Step 1: Check if series has IMDb ID
      if (series.imdbId == null || series.imdbId!.isEmpty) {
        ZagLogger().warning(
          'No IMDb ID for series: ${series.title}',
        );
        return;
      }

      // Step 2: Get TMDB ID from IMDb ID
      final tmdbId = await TMDBApi.getTmdbIdFromImdb(series.imdbId!);

      if (tmdbId == null) {
        ZagLogger().warning(
          'Could not find TMDB ID for series: ${series.title} (IMDb: ${series.imdbId})',
        );
        return;
      }

      // Step 3: Fetch credits from TMDB
      final creditsData = await TMDBApi.getTvCredits(tmdbId);

      if (creditsData == null) {
        ZagLogger().warning(
          'Could not fetch credits for series: ${series.title} (TMDB ID: $tmdbId)',
        );
        return;
      }

      // Step 4: Parse and store credits
      final List<SonarrSeriesCredits> creditsList = [];

      // Parse cast members
      final castList = creditsData['cast'] as List;
      for (final castMember in castList) {
        creditsList.add(
          SonarrSeriesCredits.fromTmdbCast(castMember, series.id!),
        );
      }

      // Parse crew members (optional - uncomment if you want crew support)
      // final crewList = creditsData['crew'] as List;
      // for (final crewMember in crewList) {
      //   creditsList.add(
      //     SonarrSeriesCredits.fromTmdbCrew(crewMember, series.id!),
      //   );
      // }

      _credits = Future.value(creditsList);
      notifyListeners();
    } catch (error, stack) {
      ZagLogger().error(
        'Error fetching credits for ${series.title}',
        error,
        stack,
      );
    }
  }
}
