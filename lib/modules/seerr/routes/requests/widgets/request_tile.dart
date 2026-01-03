import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/seerr.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/system/logger.dart';

class SeerrRequestTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final SeerrRequest request;

  const SeerrRequestTile({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<SeerrRequestTile> createState() => _State();
}

class _State extends State<SeerrRequestTile> {
  @override
  Widget build(BuildContext context) {
    return _buildBlockTile();
  }

  Widget _buildBlockTile() {
    final media = widget.request.media;
    final posterPath = media.getPosterPath();
    final backdropPath = media.getBackdropPath();

    // Build TMDB image URLs
    final posterUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w342$posterPath'
        : null;
    final backdropUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
        : null;

    return ZagBlock(
      key: ObjectKey(widget.request),
      backgroundUrl: backdropUrl,
      posterUrl: posterUrl,
      posterPlaceholderIcon: media.mediaType == 'movie'
          ? ZagIcons.VIDEO_CAM
          : Icons.tv_rounded,
      onPosterTap: _onPosterTap,
      title: media.getTitle(),
      body: [
        _subtitle1(),
        _subtitle2(),
      ],
      posterIsSquare: false,
      bottom: _subtitle3(),
      onTap: _onTap,
      onLongPress: _onLongPress,
    );
  }

  TextSpan _subtitle1() {
    final media = widget.request.media;
    final year = media.getYear();
    final status = widget.request.getDisplayStatus();
    final seasonCount = widget.request.type == 'tv' ? widget.request.seasonCount : null;
    final seasonCountText = seasonCount != null && seasonCount > 0
        ? seasonCount == 1
            ? 'seerr.SeasonCount'.tr(args: [seasonCount.toString()])
            : 'seerr.SeasonsCount'.tr(args: [seasonCount.toString()])
        : '';

    return TextSpan(
      children: [
        if (year.isNotEmpty) ...[
          TextSpan(text: year),
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        ],
        TextSpan(
          text: status,
          style: TextStyle(
            color: _getStatusColor(),
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        if (seasonCountText.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: seasonCountText),
        ],
      ],
    );
  }

  TextSpan _subtitle2() {
    final requestedBy = widget.request.requestedBy;
    final relativeTime = widget.request.getRelativeTime();
    final media = widget.request.media;
    final mediaStatus = SeerrMediaStatus.fromValue(media.status);
    final availableTime = media.getAvailableRelativeTime();

    return TextSpan(
      children: [
        ..._buildNameSpans(
          key: 'seerr.RequestedBy',
          name: requestedBy.displayName,
        ),
        if (relativeTime.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: relativeTime),
        ],
        // Show when content became available
        if (mediaStatus == SeerrMediaStatus.AVAILABLE && availableTime.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: availableTime,
            style: TextStyle(
              color: ZagColours.currentAccent,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        ],
      ],
    );
  }

  Widget _subtitle3() {
    final media = widget.request.media;
    final is4k = widget.request.is4k;
    final mediaStatus = SeerrMediaStatus.fromValue(media.status);

    return SizedBox(
      height: ZagBlock.SUBTITLE_HEIGHT,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (is4k)
            _buildBadge(
              '4K',
              ZagColours.purple,
            ),
          _buildStatusBadge(mediaStatus),
          // Show download size if content is downloading
          if (media.hasActiveDownloads())
            _buildBadge(
              'seerr.DownloadFilesSize'.tr(args: [
                media.getDownloadCount().toString(),
                media.getFormattedDownloadSize(),
              ]),
              ZagColours.blue,
            ),
          // Show "New" badge for recently available content
          if (mediaStatus == SeerrMediaStatus.AVAILABLE && media.isRecentlyAvailable())
            _buildBadge(
              'seerr.New'.tr(),
              ZagColours.currentAccent,
            ),
          if (widget.request.type == 'tv')
            _buildIcon(
              Icons.tv_rounded,
              ZagColours.blue,
            ),
          if (widget.request.type == 'movie')
            _buildIcon(
              ZagIcons.VIDEO_CAM,
              ZagColours.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: ZagUI.DEFAULT_MARGIN_SIZE / 4),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ZagUI.DEFAULT_MARGIN_SIZE / 2,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ZagUI.FONT_SIZE_H5,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: ZagUI.DEFAULT_MARGIN_SIZE / 4),
      child: Icon(
        icon,
        size: ZagUI.FONT_SIZE_H2,
        color: color,
      ),
    );
  }

  Widget _buildStatusBadge(SeerrMediaStatus status) {
    String text;
    Color color;

    switch (status) {
      case SeerrMediaStatus.AVAILABLE:
        text = 'seerr.Available'.tr();
        color = ZagColours.currentAccent;
        break;
      case SeerrMediaStatus.PARTIALLY_AVAILABLE:
        text = 'seerr.Partial'.tr();
        color = ZagColours.orange;
        break;
      case SeerrMediaStatus.PROCESSING:
        text = 'seerr.Processing'.tr();
        color = ZagColours.blue;
        break;
      default:
        return Container();
    }

    return _buildBadge(text, color);
  }

  Color _getStatusColor() {
    final status = SeerrRequestStatus.fromValue(widget.request.status);
    switch (status) {
      case SeerrRequestStatus.PENDING:
        return ZagColours.orange;
      case SeerrRequestStatus.APPROVED:
        final mediaStatus = SeerrMediaStatus.fromValue(widget.request.media.status);
        switch (mediaStatus) {
          case SeerrMediaStatus.AVAILABLE:
            return ZagColours.currentAccent;
          case SeerrMediaStatus.PARTIALLY_AVAILABLE:
            return ZagColours.orange;
          default:
            return ZagColours.blue;
        }
      case SeerrRequestStatus.DECLINED:
        return ZagColours.red;
      default:
        return ZagColours.grey;
    }
  }

  Future<void> _onTap() async {
    await _showRequestActions();
  }

  Future<void> _onLongPress() async {
    await _showRequestActions();
  }

  Future<void> _onPosterTap() async {
    final media = widget.request.media;
    final serviceId = media.externalServiceId;

    // If already in Radarr/Sonarr, navigate directly to details
    if (serviceId != null) {
      if (media.mediaType == 'movie') {
        RadarrRoutes.MOVIE.go(params: {'movie': serviceId.toString()});
      } else if (media.mediaType == 'tv') {
        SonarrRoutes.SERIES.go(params: {'series': serviceId.toString()});
      }
      return;
    }

    // Not in Radarr/Sonarr, lookup by TMDB ID and navigate to add page
    if (media.mediaType == 'movie') {
      await _openRadarrAddFlow(media.tmdbId);
    } else if (media.mediaType == 'tv') {
      await _openSonarrAddFlow(media.tmdbId);
    }
  }

  Future<void> _openRadarrAddFlow(int tmdbId) async {
    final radarrState = context.read<RadarrState>();
    if (radarrState.api == null) {
      showZagInfoSnackBar(
        title: 'seerr.RadarrNotConfigured'.tr(),
        message: 'seerr.RadarrNotConfiguredMessage'.tr(),
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && mounted) {
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
      final results = await radarrState.api!.movieLookup.get(
        term: 'tmdb:$tmdbId',
      );

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagErrorSnackBar(
          title: 'seerr.MovieNotFound'.tr(),
          message: 'seerr.MovieNotFoundMessage'.tr(
            args: [tmdbId.toString()],
          ),
        );
        return;
      }

      final radarrMovie = results.first;

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
      if (!mounted) return;
      ZagLogger().error('Failed to open Radarr add flow', error, stack);
      showZagErrorSnackBar(
        title: 'seerr.Error'.tr(),
        message: 'seerr.RadarrErrorMessage'.tr(),
      );
    }
  }

  Future<void> _openSonarrAddFlow(int tmdbId) async {
    final sonarrState = context.read<SonarrState>();
    if (sonarrState.api == null) {
      showZagInfoSnackBar(
        title: 'seerr.SonarrNotConfigured'.tr(),
        message: 'seerr.SonarrNotConfiguredMessage'.tr(),
      );
      return;
    }

    bool loaderShown = false;
    void dismissLoader() {
      if (loaderShown && mounted) {
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
      final results = await sonarrState.api!.seriesLookup.get(
        term: 'tmdb:$tmdbId',
      );

      if (!mounted) {
        dismissLoader();
        return;
      }

      dismissLoader();

      if (results.isEmpty) {
        showZagErrorSnackBar(
          title: 'seerr.SeriesNotFound'.tr(),
          message: 'seerr.SeriesNotFoundMessage'.tr(
            args: [tmdbId.toString()],
          ),
        );
        return;
      }

      final sonarrSeries = results.first;

      // If series already exists in Sonarr, go to details
      if (sonarrSeries.id != null) {
        SonarrRoutes.SERIES.go(params: {'series': sonarrSeries.id!.toString()});
        return;
      }

      // Series doesn't exist, go to add page
      SonarrRoutes.ADD_SERIES_DETAILS.go(extra: sonarrSeries);
    } catch (error, stack) {
      dismissLoader();
      if (!mounted) return;
      ZagLogger().error('Failed to open Sonarr add flow', error, stack);
      showZagErrorSnackBar(
        title: 'seerr.Error'.tr(),
        message: 'seerr.SonarrErrorMessage'.tr(),
      );
    }
  }

  Future<void> _showRequestActions() async {
    final result = await SeerrDialogs().requestActions(context, widget.request);

    if (result.item1 && result.item2 != null) {
      final action = result.item2!;
      final state = context.read<SeerrState>();

      switch (action) {
        case SeerrRequestActionType.APPROVE:
          final success = await state.approveRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestApproved'.tr(),
              message: 'seerr.RequestApprovedMessage'.tr(
                args: [widget.request.media.getTitle()],
              ),
            );
          }
          break;

        case SeerrRequestActionType.DECLINE:
          final success = await state.declineRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestDeclined'.tr(),
              message: 'seerr.RequestDeclinedMessage'.tr(
                args: [widget.request.media.getTitle()],
              ),
            );
          }
          break;

        case SeerrRequestActionType.DELETE:
          final success = await state.deleteRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.RequestDeleted'.tr(),
              message: 'seerr.RequestDeletedMessage'.tr(
                args: [widget.request.media.getTitle()],
              ),
            );
          }
          break;
      }
    }
  }

  List<TextSpan> _buildNameSpans({
    required String key,
    required String name,
  }) {
    final template = key.tr(args: ['{name}']);
    final parts = template.split('{name}');
    final spans = <TextSpan>[];
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      spans.add(TextSpan(text: parts.first));
    }
    spans.add(
      TextSpan(
        text: name,
        style: TextStyle(
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    );
    if (parts.length > 1) {
      final trailing = parts.sublist(1).join('{name}');
      if (trailing.isNotEmpty) {
        spans.add(TextSpan(text: trailing));
      }
    }
    return spans;
  }
}
