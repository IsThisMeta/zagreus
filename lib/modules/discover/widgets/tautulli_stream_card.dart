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

class TautulliStreamCard extends StatelessWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final TautulliSession session;

  const TautulliStreamCard({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      key: ObjectKey(session),
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
      ],
      bottom: _bottomWidget(),
      bottomHeight: ZagLinearPercentIndicator.height,
      trailing: ZagIconButton(icon: session.zagSessionStateIcon),
      onTap: () => _enterDetails(context),
    );
  }

  TextSpan _subtitle1() {
    if (session.mediaType == TautulliMediaType.EPISODE) {
      return TextSpan(
        children: [
          TextSpan(text: session.parentTitle),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: session.title ?? ZagUI.TEXT_EMDASH),
        ],
      );
    }
    if (session.mediaType == TautulliMediaType.MOVIE) {
      return TextSpan(text: session.year?.toString() ?? '');
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
    return TextSpan(text: session.title ?? ZagUI.TEXT_EMDASH);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: session.zagFriendlyName),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: session.formattedStream(),
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: ZagColours.currentAccent,
          ),
        ),
      ],
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
      if (session.year != null && results.length > 1) {
        sonarrSeries = results.firstWhere(
          (s) => s.year == session.year,
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
