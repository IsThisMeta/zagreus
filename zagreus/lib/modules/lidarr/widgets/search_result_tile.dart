import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/lidarr.dart';
import 'package:zagreus/router/router.dart';

class LidarrReleasesTile extends StatefulWidget {
  final LidarrReleaseData release;

  const LidarrReleasesTile({
    Key? key,
    required this.release,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LidarrReleasesTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.release.title,
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      collapsedTrailing: _trailing(),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
      expandedTableButtons: _tableButtons(),
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(
        style: TextStyle(
          color: zagProtocolColor,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
        text: widget.release.protocol.toTitleCase(),
      ),
      if (widget.release.isTorrent)
        TextSpan(
          text: ' (${widget.release.seeders}/${widget.release.leechers})',
          style: TextStyle(
            color: zagProtocolColor,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.release.indexer),
      TextSpan(text: ZagUI.TEXT_BULLET.pad()),
      TextSpan(text: widget.release.ageHours.asTimeAgo()),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(text: widget.release.quality),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.size.asBytes()),
      ],
    );
  }

  Widget _trailing() {
    return ZagIconButton(
      icon: widget.release.approved
          ? Icons.file_download_rounded
          : Icons.report_outlined,
      color: widget.release.approved ? Colors.white : ZagColours.red,
      onPressed: () async =>
          widget.release.approved ? _startDownload() : _showWarnings(),
      onLongPress: _startDownload,
      loadingState: _downloadState,
    );
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: widget.release.protocol.toTitleCase(),
        backgroundColor: zagProtocolColor,
      ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(
          title: 'source', body: widget.release.protocol.toTitleCase()),
      ZagTableContent(title: 'age', body: widget.release.ageHours.asTimeAgo()),
      ZagTableContent(title: 'indexer', body: widget.release.indexer),
      ZagTableContent(title: 'size', body: widget.release.size.asBytes()),
      ZagTableContent(title: 'quality', body: widget.release.quality),
      if (widget.release.protocol == 'torrent' &&
          widget.release.seeders != null)
        ZagTableContent(title: 'seeders', body: '${widget.release.seeders}'),
      if (widget.release.protocol == 'torrent' &&
          widget.release.leechers != null)
        ZagTableContent(title: 'leechers', body: '${widget.release.leechers}'),
    ];
  }

  Color get zagProtocolColor {
    if (!widget.release.isTorrent) return ZagColours.currentAccent;
    int seeders = widget.release.seeders ?? 0;
    if (seeders > 10) return ZagColours.blue;
    if (seeders > 0) return ZagColours.orange;
    return ZagColours.red;
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        icon: Icons.download_rounded,
        text: 'Download',
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
      if (widget.release.infoUrl.isNotEmpty)
        ZagButton.text(
          text: 'Indexer',
          icon: Icons.info_outline_rounded,
          color: ZagColours.blue,
          onTap: widget.release.infoUrl.openLink,
        ),
      if (!widget.release.approved)
        ZagButton.text(
          text: 'Rejected',
          icon: Icons.report_outlined,
          color: ZagColours.red,
          onTap: _showWarnings,
        ),
    ];
  }

  Future<void> _startDownload() async {
    setState(() => _downloadState = ZagLoadingState.ACTIVE);
    LidarrAPI _api = LidarrAPI.from(ZagProfile.current);
    await _api
        .downloadRelease(widget.release.guid, widget.release.indexerId)
        .then((_) {
      showZagSuccessSnackBar(
        title: 'Downloading...',
        message: widget.release.title,
        showButton: true,
        buttonText: 'Back',
        buttonOnPressed: ZagRouter().popToRootRoute,
      );
    }).catchError((error, stack) {
      showZagErrorSnackBar(
        title: 'Failed to Start Downloading',
        error: error,
      );
    });
    setState(() => _downloadState = ZagLoadingState.INACTIVE);
  }

  Future<void> _showWarnings() async => await ZagDialogs().showRejections(
        context,
        widget.release.rejections.cast<String>(),
      );
}
