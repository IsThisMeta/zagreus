import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/seerr.dart';
import 'package:zagreus/modules/radarr/core/state.dart';
import 'package:zagreus/modules/sonarr/core/state.dart';
import 'package:zagreus/router/routes/radarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';
import 'package:zagreus/system/logger.dart';

class SeerrIssueTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final SeerrIssue issue;

  const SeerrIssueTile({
    Key? key,
    required this.issue,
  }) : super(key: key);

  @override
  State<SeerrIssueTile> createState() => _State();
}

class _State extends State<SeerrIssueTile> {
  @override
  Widget build(BuildContext context) {
    return _buildBlockTile();
  }

  Widget _buildBlockTile() {
    final media = widget.issue.media;
    final posterPath = media.getPosterPath();
    final backdropPath = media.getBackdropPath();

    // Build TMDB image URLs
    final posterUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w342$posterPath'
        : null;
    final backdropUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
        : null;

    final isOpen = widget.issue.status == 1;

    return ZagBlock(
      key: ObjectKey(widget.issue),
      backgroundUrl: backdropUrl,
      posterUrl: posterUrl,
      posterPlaceholderIcon: media.mediaType == 'movie'
          ? ZagIcons.VIDEO_CAM
          : Icons.tv_rounded,
      onPosterTap: _onPosterTap,
      disabled: !isOpen, // Gray out resolved issues
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
    final issueType = widget.issue.getIssueTypeString();
    final status = widget.issue.getDisplayStatus();
    final problemInfo = _getProblemInfo();

    return TextSpan(
      children: [
        TextSpan(
          text: issueType,
          style: TextStyle(
            color: _getIssueTypeColor(),
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: status,
          style: TextStyle(
            color: _getStatusColor(),
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        if (problemInfo.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: problemInfo),
        ],
      ],
    );
  }

  TextSpan _subtitle2() {
    final createdBy = widget.issue.createdBy;
    final relativeTime = widget.issue.getRelativeTime();

    return TextSpan(
      children: [
        ..._buildNameSpans(
          key: 'seerr.CreatedBy',
          name: createdBy.displayName,
        ),
        if (relativeTime.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: relativeTime),
        ],
      ],
    );
  }

  Widget _subtitle3() {
    final media = widget.issue.media;
    final commentCount = widget.issue.comments?.length ?? 0;
    final isOpen = widget.issue.status == 1;

    return SizedBox(
      height: ZagBlock.SUBTITLE_HEIGHT,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusIndicator(isOpen),
          if (commentCount > 0) _buildCommentBadge(commentCount),
          if (widget.issue.media.mediaType == 'tv')
            _buildIcon(
              Icons.tv_rounded,
              ZagColours.blue,
            ),
          if (widget.issue.media.mediaType == 'movie')
            _buildIcon(
              ZagIcons.VIDEO_CAM,
              ZagColours.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isOpen) {
    return Padding(
      padding: const EdgeInsets.only(right: ZagUI.DEFAULT_MARGIN_SIZE / 4),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ZagUI.DEFAULT_MARGIN_SIZE / 2,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: isOpen ? ZagColours.orange : ZagColours.currentAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isOpen ? 'seerr.Open'.tr() : 'seerr.Resolved'.tr(),
          style: TextStyle(
            fontSize: ZagUI.FONT_SIZE_H5,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentBadge(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: ZagUI.DEFAULT_MARGIN_SIZE / 4),
      child: Row(
        children: [
          Icon(
            Icons.comment_rounded,
            size: ZagUI.FONT_SIZE_H2,
            color: ZagColours.currentAccent,
          ),
          const SizedBox(width: 2),
          Text(
            '$count',
            style: TextStyle(
              fontSize: ZagUI.FONT_SIZE_H5,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
              color: ZagColours.currentAccent,
            ),
          ),
        ],
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

  String _getProblemInfo() {
    if (widget.issue.problemSeason > 0) {
      if (widget.issue.problemEpisode > 0) {
        return 'seerr.SeasonEpisode'.tr(
          args: [
            widget.issue.problemSeason.toString(),
            widget.issue.problemEpisode.toString(),
          ],
        );
      }
      return 'seerr.SeasonNumber'.tr(
        args: [
          widget.issue.problemSeason.toString(),
        ],
      );
    }
    return '';
  }

  Color _getIssueTypeColor() {
    final type = SeerrIssueType.fromValue(widget.issue.issueType);
    switch (type) {
      case SeerrIssueType.VIDEO:
        return ZagColours.red;
      case SeerrIssueType.AUDIO:
        return ZagColours.blue;
      case SeerrIssueType.SUBTITLE:
        return ZagColours.purple;
      case SeerrIssueType.OTHER:
      default:
        return ZagColours.grey;
    }
  }

  Color _getStatusColor() {
    final status = SeerrIssueStatus.fromValue(widget.issue.status);
    switch (status) {
      case SeerrIssueStatus.OPEN:
        return ZagColours.orange;
      case SeerrIssueStatus.RESOLVED:
        return ZagColours.currentAccent;
      default:
        return ZagColours.grey;
    }
  }

  Future<void> _onTap() async {
    await _showIssueActions();
  }

  Future<void> _onLongPress() async {
    await _showIssueActions();
  }

  Future<void> _onPosterTap() async {
    final media = widget.issue.media;
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

  Future<void> _showIssueActions() async {
    final result = await SeerrDialogs().issueActions(context, widget.issue);

    if (result.item1 && result.item2 != null) {
      final action = result.item2!;
      final state = context.read<SeerrState>();

      switch (action) {
        case SeerrIssueActionType.CLOSE:
          final success = await state.resolveIssue(widget.issue.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.IssueClosed'.tr(),
              message: 'seerr.IssueClosedMessage'.tr(
                args: [widget.issue.media.getTitle()],
              ),
            );
          }
          break;

        case SeerrIssueActionType.REOPEN:
          final success = await state.reopenIssue(widget.issue.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'seerr.IssueReopened'.tr(),
              message: 'seerr.IssueReopenedMessage'.tr(
                args: [widget.issue.media.getTitle()],
              ),
            );
          }
          break;

        case SeerrIssueActionType.ADD_COMMENT:
          final commentResult = await SeerrDialogs().addComment(context);
          if (commentResult.item1 && commentResult.item2.isNotEmpty) {
            final success = await state.addComment(
              widget.issue.id,
              commentResult.item2,
            );
            if (success) {
              showZagSuccessSnackBar(
                title: 'seerr.CommentAdded'.tr(),
                message: 'seerr.CommentAddedMessage'.tr(),
              );
            }
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
