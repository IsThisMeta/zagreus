import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrIssueTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final OverseerrIssue issue;

  const OverseerrIssueTile({
    Key? key,
    required this.issue,
  }) : super(key: key);

  @override
  State<OverseerrIssueTile> createState() => _State();
}

class _State extends State<OverseerrIssueTile> {
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
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
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
        TextSpan(text: 'Created by '),
        TextSpan(
          text: createdBy.displayName,
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
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
          isOpen ? 'Open' : 'Resolved',
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
        return 'S${widget.issue.problemSeason} E${widget.issue.problemEpisode}';
      }
      return 'Season ${widget.issue.problemSeason}';
    }
    return '';
  }

  Color _getIssueTypeColor() {
    final type = OverseerrIssueType.fromValue(widget.issue.issueType);
    switch (type) {
      case OverseerrIssueType.VIDEO:
        return ZagColours.red;
      case OverseerrIssueType.AUDIO:
        return ZagColours.blue;
      case OverseerrIssueType.SUBTITLE:
        return ZagColours.purple;
      case OverseerrIssueType.OTHER:
      default:
        return ZagColours.grey;
    }
  }

  Color _getStatusColor() {
    final status = OverseerrIssueStatus.fromValue(widget.issue.status);
    switch (status) {
      case OverseerrIssueStatus.OPEN:
        return ZagColours.orange;
      case OverseerrIssueStatus.RESOLVED:
        return ZagColours.currentAccent;
      default:
        return ZagColours.grey;
    }
  }

  Future<void> _onTap() async {
    // TODO: Navigate to issue detail view
    ZagLogger().debug('Issue tapped: ${widget.issue.id}');
  }

  Future<void> _onLongPress() async {
    // TODO: Show issue action menu (close, reopen, add comment)
    ZagLogger().debug('Issue long-pressed: ${widget.issue.id}');
  }
}
