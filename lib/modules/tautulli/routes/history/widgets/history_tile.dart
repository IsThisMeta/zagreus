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

      // Match by year if available
      var sonarrSeries = results.first;
      if (history.year != null && results.length > 1) {
        sonarrSeries = results.firstWhere(
          (s) => s.year == history.year,
          orElse: () => results.first,
        );
      }

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
