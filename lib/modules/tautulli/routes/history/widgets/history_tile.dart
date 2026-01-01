import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/tautulli.dart';
import 'package:zagreus/router/routes/tautulli.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/system/logger.dart';

class TautulliHistoryTile extends StatelessWidget {
  final TautulliHistoryRecord history;

  const TautulliHistoryTile({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: history.lsTitle,
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      bodyLeadingIcons: [
        null,
        null,
        history.zagWatchStatusIcon,
      ],
      posterUrl:
          context.watch<TautulliState>().getImageURLFromPath(history.thumb),
      posterHeaders: context.watch<TautulliState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      onPosterTap: history.ratingKey != null && history.mediaType != null
          ? () => _onPosterTap(context)
          : null,
      backgroundHeaders: context.watch<TautulliState>().headers,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromRatingKey(
            history.grandparentRatingKey ??
                history.parentRatingKey ??
                history.ratingKey ??
                '' as int?,
          ),
      onTap: () => TautulliRoutes.HISTORY_DETAILS.go(
        queryParams: {
          'reference_id': history.referenceId.toString(),
          'session_key': history.sessionKey.toString(),
        },
        params: {
          'rating_key': history.ratingKey!.toString(),
        },
      ),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        if (history.mediaType == TautulliMediaType.EPISODE)
          TextSpan(
            children: [
              TextSpan(text: 'Season ${history.parentMediaIndex}'),
              TextSpan(text: ZagUI.TEXT_BULLET.pad()),
              TextSpan(text: 'Episode ${history.mediaIndex}: '),
              TextSpan(
                text: history.title,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        if (history.mediaType == TautulliMediaType.MOVIE)
          TextSpan(text: history.year.toString()),
        if (history.mediaType == TautulliMediaType.TRACK)
          TextSpan(
            children: [
              TextSpan(text: history.title),
              TextSpan(text: ZagUI.TEXT_BULLET.pad()),
              TextSpan(text: history.parentTitle),
            ],
          ),
        if (history.mediaType == TautulliMediaType.LIVE)
          TextSpan(text: history.title),
      ],
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(text: history.lsDate);
  }

  TextSpan _subtitle3() {
    return TextSpan(text: history.friendlyName ?? 'Unknown User');
  }

  Future<void> _onPosterTap(BuildContext context) async {
    // Try to lookup in Radarr/Sonarr and navigate accordingly
    if (history.mediaType == TautulliMediaType.MOVIE) {
      await _openRadarrAddFlow(context);
    } else if (history.mediaType == TautulliMediaType.EPISODE ||
        history.mediaType == TautulliMediaType.SEASON ||
        history.mediaType == TautulliMediaType.SHOW) {
      await _openSonarrAddFlow(context);
    }
  }

  Future<void> _openRadarrAddFlow(BuildContext context) async {
    final radarrState = context.read<RadarrState>();
    if (radarrState.api == null) {
      showZagInfoSnackBar(
        title: 'Radarr Not Configured',
        message: 'Please configure Radarr in settings',
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderShown = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: ZagLoader()),
    );
    loaderShown = true;

    try {
      // Build search term from title and year
      final title = history.title ?? history.grandparentTitle ?? '';
      if (title.isEmpty) {
        dismissLoader();
        return;
      }

      final results = await radarrState.api!.movieLookup.get(
        term: title,
      );

      if (!context.mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagErrorSnackBar(
          title: 'Movie Not Found',
          message: 'Could not find "$title" in Radarr',
        );
        return;
      }

      // Match by year if available
      var radarrMovie = results.first;
      if (history.year != null && results.length > 1) {
        radarrMovie = results.firstWhere(
          (m) => m.year == history.year,
          orElse: () => results.first,
        );
      }

      // If movie already exists in Radarr, go to details
      if (radarrMovie.id != null) {
        RadarrRoutes.MOVIE.go(params: {'movie': radarrMovie.id!.toString()});
        return;
      }

      // Movie doesn't exist, go to add page
      RadarrRoutes.ADD_MOVIE_DETAILS.go(
        extra: radarrMovie,
        queryParams: {'isDiscovery': 'false'},
      );
    } catch (error, stack) {
      dismissLoader();
      if (!context.mounted) return;
      ZagLogger().error('Failed to open Radarr add flow', error, stack);
      showZagErrorSnackBar(
        title: 'Error',
        message: 'Something went wrong talking to Radarr',
      );
    }
  }

  Future<void> _openSonarrAddFlow(BuildContext context) async {
    final sonarrState = context.read<SonarrState>();
    if (sonarrState.api == null) {
      showZagInfoSnackBar(
        title: 'Sonarr Not Configured',
        message: 'Please configure Sonarr in settings',
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        loaderShown = false;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: ZagLoader()),
    );
    loaderShown = true;

    try {
      // For TV shows, use the grandparent title (show name)
      final title = history.grandparentTitle ?? history.title ?? '';
      if (title.isEmpty) {
        dismissLoader();
        return;
      }

      // Debug: Print search parameters
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 TAUTULLI POSTER CLICK - History Tile');
      print('  History Title: ${history.title}');
      print('  Parent Title: ${history.parentTitle}');
      print('  Grandparent Title: ${history.grandparentTitle}');
      print('  Year: ${history.year}');
      print('  Media Type: ${history.mediaType}');
      print('  Rating Key: ${history.ratingKey}');
      print('  → Searching Sonarr for: "$title"');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      ZagLogger().debug('Searching Sonarr for: "$title" (year: ${history.year})');

      final results = await sonarrState.api!.seriesLookup.get(
        term: title,
      );

      if (!context.mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagErrorSnackBar(
          title: 'Series Not Found',
          message: 'Could not find "$title" in Sonarr',
        );
        return;
      }

      // Debug: Print all results
      print('📊 Sonarr returned ${results.length} results:');
      for (int i = 0; i < results.length && i < 5; i++) {
        final result = results[i];
        print('  [$i] "${result.title}" (${result.year}) - ID: ${result.id}');
      }
      
      ZagLogger().debug('Sonarr returned ${results.length} results for "$title"');

      // For TV shows, don't use year matching because Tautulli provides the
      // episode/season air year (e.g., 2025 for Season 5), not the show's
      // original year (e.g., 2016). Sonarr's search ranking is more reliable.
      // Simply use the first result as it's typically the best match.
      var sonarrSeries = results.first;
      
      print('📌 Using first result from Sonarr (most relevant match)');
      print('   Note: Year matching skipped for TV shows because Tautulli');
      print('   provides episode air year (${history.year}), not show year.');


      // Show which series was matched before navigating
      final matchedTitle = sonarrSeries.title ?? 'Unknown';
      final matchedYear = sonarrSeries.year?.toString() ?? 'Unknown Year';
      
      print('✅ Selected: "$matchedTitle" ($matchedYear)');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      ZagLogger().debug('Matched to Sonarr series: "$matchedTitle" ($matchedYear)');

      // If series already exists in Sonarr, go to details
      if (sonarrSeries.id != null) {
        SonarrRoutes.SERIES.go(params: {'series': sonarrSeries.id!.toString()});
        return;
      }

      // Series doesn't exist, go to add page
      SonarrRoutes.ADD_SERIES_DETAILS.go(extra: sonarrSeries);
    } catch (error, stack) {
      dismissLoader();
      if (!context.mounted) return;
      ZagLogger().error('Failed to open Sonarr add flow', error, stack);
      showZagErrorSnackBar(
        title: 'Error',
        message: 'Something went wrong talking to Sonarr',
      );
    }
  }
}
