import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrReleasesTile extends StatefulWidget {
  final RadarrRelease release;

  const RadarrReleasesTile({
    required this.release,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RadarrReleasesTile> {
  ZagLoadingState _downloadState = ZagLoadingState.INACTIVE;

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.release.title!,
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

  Widget _trailing() {
    return ZagIconButton(
      icon: widget.release.zagTrailingIcon,
      color: widget.release.zagTrailingColor,
      onPressed: () async =>
          widget.release.rejected! ? _showWarnings() : _startDownload(),
      onLongPress: _startDownload,
      loadingState: _downloadState,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.release.zagProtocol,
          style: TextStyle(
            color: widget.release.zagProtocolColor,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zagIndexer),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zagAge),
      ],
    );
  }

  TextSpan _subtitle2() {
    final hasCustomFormats = (widget.release.customFormats?.isNotEmpty ?? false) ||
                             (widget.release.customFormatScore != null && widget.release.customFormatScore != 0);
    return TextSpan(
      children: [
        TextSpan(text: widget.release.zagQuality),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zagSize),
        if (hasCustomFormats) ...[
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
          TextSpan(
            text: widget.release.zagCustomFormatScore()!,
            style: TextStyle(
              color: ZagColours.blue,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        ],
      ],
    );
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: widget.release.protocol!.readable!,
        backgroundColor: widget.release.zagProtocolColor,
      ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(title: 'age', body: widget.release.zagAge),
      ZagTableContent(title: 'indexer', body: widget.release.zagIndexer),
      ZagTableContent(title: 'size', body: widget.release.zagSize),
      ZagTableContent(
          title: 'language',
          body: widget.release.languages
                  ?.map<String>(
                      (language) => language.name ?? ZagUI.TEXT_EMDASH)
                  .join('\n') ??
              ZagUI.TEXT_EMDASH),
      ZagTableContent(title: 'quality', body: widget.release.zagQuality),
      if (widget.release.customFormats?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'custom formats',
          body: widget.release.customFormats!
              .map<String>((format) => format.name ?? ZagUI.TEXT_EMDASH)
              .join('\n'),
        ),
      if (widget.release.seeders != null)
        ZagTableContent(title: 'seeders', body: '${widget.release.seeders}'),
      if (widget.release.leechers != null)
        ZagTableContent(title: 'leechers', body: '${widget.release.leechers}'),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'Download',
        icon: Icons.download_rounded,
        onTap: _startDownload,
        loadingState: _downloadState,
      ),
      if (widget.release.infoUrl?.isNotEmpty ?? false)
        ZagButton.text(
          text: 'Indexer',
          icon: Icons.info_outline_rounded,
          color: ZagColours.blue,
          onTap: widget.release.infoUrl!.openLink,
        ),
      if (widget.release.rejected!)
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
    RadarrAPIHelper()
        .pushRelease(context: context, release: widget.release)
        .then((value) {
      if (mounted)
        setState(() => _downloadState =
            value ? ZagLoadingState.INACTIVE : ZagLoadingState.ERROR);
    });
  }

  Future<void> _showWarnings() async => await ZagDialogs()
      .showRejections(context, widget.release.rejections ?? []);
}
