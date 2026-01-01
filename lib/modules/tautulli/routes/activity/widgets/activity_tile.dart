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

class TautulliActivityTile extends StatelessWidget {
  final TautulliSession session;
  final bool disableOnTap;

  const TautulliActivityTile({
    Key? key,
    required this.session,
    this.disableOnTap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: session.zagTitle,
      posterUrl: session.zagArtworkPath(context),
      posterHeaders: context.read<TautulliState>().headers,
      posterPlaceholderIcon: ZagIcons.VIDEO_CAM,
      onPosterTap: session.ratingKey != null && session.mediaType != null
          ? () => _onPosterTap(context)
          : null,
      backgroundUrl: context.watch<TautulliState>().getImageURLFromPath(
            session.art,
            width: MediaQuery.of(context).size.width.truncate(),
          ),
      body: [
        _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      bottom: _bottomWidget(),
      bottomHeight: ZagLinearPercentIndicator.height,
      trailing: ZagIconButton(icon: session.zagSessionStateIcon),
      onTap: disableOnTap ? null : () async => _enterDetails(context),
    );
  }

  TextSpan _subtitle1() {
    if (session.mediaType == TautulliMediaType.EPISODE) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
              text: 'tautulli.Episode'.tr(args: [
            session.mediaIndex?.toString() ?? ZagUI.TEXT_EMDASH
          ])),
          TextSpan(text: ': '),
          TextSpan(
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title ?? ZagUI.TEXT_EMDASH,
          ),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.MOVIE) {
      return TextSpan(text: session.year.toString());
    }
    if (session.mediaType == TautulliMediaType.TRACK) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_EMDASH.pad()),
          TextSpan(
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
            text: session.title,
          ),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.LIVE) {
      return TextSpan(text: session.title);
    }
    return TextSpan(text: ZagUI.TEXT_EMDASH);
  }

  TextSpan _subtitle2() {
    return TextSpan(text: session.zagFriendlyName);
  }

  TextSpan _subtitle3() {
    return TextSpan(
      text: session.formattedStream(),
      style: TextStyle(
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        color: ZagColours.currentAccent,
      ),
    );
  }

  Widget _bottomWidget() {
    return SizedBox(
      height: ZagLinearPercentIndicator.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ZagLinearPercentIndicator(
            percent: session.zagTranscodeProgress,
            progressColor: ZagColours.currentAccent.withOpacity(
              ZagUI.OPACITY_SPLASH,
            ),
            backgroundColor: Colors.transparent,
          ),
          ZagLinearPercentIndicator(
            percent: session.zagProgressPercent,
            progressColor: ZagColours.currentAccent,
            backgroundColor: ZagColours.grey.withOpacity(
              ZagUI.OPACITY_SPLASH,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enterDetails(BuildContext context) async {
    TautulliRoutes.ACTIVITY_DETAILS.go(params: {
      'session': session.sessionKey.toString(),
    });
  }

  Future<void> _onPosterTap(BuildContext context) async {
    // Try to lookup in Radarr/Sonarr and navigate accordingly
    if (session.mediaType == TautulliMediaType.MOVIE) {
      await _openRadarrAddFlow(context);
    } else if (session.mediaType == TautulliMediaType.EPISODE ||
        session.mediaType == TautulliMediaType.SEASON ||
        session.mediaType == TautulliMediaType.SHOW) {
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
      final title = session.title ?? session.grandparentTitle ?? '';
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
      if (session.year != null && results.length > 1) {
        radarrMovie = results.firstWhere(
          (m) => m.year == session.year,
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
      final title = session.grandparentTitle ?? session.title ?? '';
      if (title.isEmpty) {
        dismissLoader();
        return;
      }

      // Debug: Print search parameters
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 TAUTULLI POSTER CLICK - Activity Tile');
      print('  Session Title: ${session.title}');
      print('  Parent Title: ${session.parentTitle}');
      print('  Grandparent Title: ${session.grandparentTitle}');
      print('  Year: ${session.year}');
      print('  Media Type: ${session.mediaType}');
      print('  Rating Key: ${session.ratingKey}');
      print('  → Searching Sonarr for: "$title"');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      ZagLogger().debug('Searching Sonarr for: "$title" (year: ${session.year})');

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
      print('   provides episode air year (${session.year}), not show year.');


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
