import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/overseerr.dart';

class OverseerrRequestTile extends StatefulWidget {
  static final itemExtent = ZagBlock.calculateItemExtent(2, hasBottom: true);

  final OverseerrRequest request;

  const OverseerrRequestTile({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<OverseerrRequestTile> createState() => _State();
}

class _State extends State<OverseerrRequestTile> {
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
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
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
        if (seasonCount != null && seasonCount > 0) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: '$seasonCount Season${seasonCount > 1 ? 's' : ''}'),
        ],
      ],
    );
  }

  TextSpan _subtitle2() {
    final requestedBy = widget.request.requestedBy;
    final relativeTime = widget.request.getRelativeTime();
    final media = widget.request.media;
    final mediaStatus = OverseerrMediaStatus.fromValue(media.status);
    final availableTime = media.getAvailableRelativeTime();

    return TextSpan(
      children: [
        TextSpan(text: 'Requested by '),
        TextSpan(
          text: requestedBy.displayName,
          style: TextStyle(
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        if (relativeTime.isNotEmpty) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(text: relativeTime),
        ],
        // Show when content became available
        if (mediaStatus == OverseerrMediaStatus.AVAILABLE && availableTime.isNotEmpty) ...[
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
    final mediaStatus = OverseerrMediaStatus.fromValue(media.status);

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
              '${media.getDownloadCount()} files • ${media.getFormattedDownloadSize()}',
              ZagColours.blue,
            ),
          // Show "New" badge for recently available content
          if (mediaStatus == OverseerrMediaStatus.AVAILABLE && media.isRecentlyAvailable())
            _buildBadge(
              'NEW',
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

  Widget _buildStatusBadge(OverseerrMediaStatus status) {
    String text;
    Color color;

    switch (status) {
      case OverseerrMediaStatus.AVAILABLE:
        text = 'Available';
        color = ZagColours.currentAccent;
        break;
      case OverseerrMediaStatus.PARTIALLY_AVAILABLE:
        text = 'Partial';
        color = ZagColours.orange;
        break;
      case OverseerrMediaStatus.PROCESSING:
        text = 'Processing';
        color = ZagColours.blue;
        break;
      default:
        return Container();
    }

    return _buildBadge(text, color);
  }

  Color _getStatusColor() {
    final status = OverseerrRequestStatus.fromValue(widget.request.status);
    switch (status) {
      case OverseerrRequestStatus.PENDING:
        return ZagColours.orange;
      case OverseerrRequestStatus.APPROVED:
        final mediaStatus = OverseerrMediaStatus.fromValue(widget.request.media.status);
        switch (mediaStatus) {
          case OverseerrMediaStatus.AVAILABLE:
            return ZagColours.currentAccent;
          case OverseerrMediaStatus.PARTIALLY_AVAILABLE:
            return ZagColours.orange;
          default:
            return ZagColours.blue;
        }
      case OverseerrRequestStatus.DECLINED:
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

  Future<void> _showRequestActions() async {
    final result = await OverseerrDialogs().requestActions(context, widget.request);

    if (result.item1 && result.item2 != null) {
      final action = result.item2!;
      final state = context.read<OverseerrState>();

      switch (action) {
        case OverseerrRequestActionType.APPROVE:
          final success = await state.approveRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'Request Approved',
              message: 'Request for ${widget.request.media.getTitle()} has been approved',
            );
          }
          break;

        case OverseerrRequestActionType.DECLINE:
          final success = await state.declineRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'Request Declined',
              message: 'Request for ${widget.request.media.getTitle()} has been declined',
            );
          }
          break;

        case OverseerrRequestActionType.DELETE:
          final success = await state.deleteRequest(widget.request.id);
          if (success) {
            showZagSuccessSnackBar(
              title: 'Request Deleted',
              message: 'Request for ${widget.request.media.getTitle()} has been deleted',
            );
          }
          break;
      }
    }
  }
}
