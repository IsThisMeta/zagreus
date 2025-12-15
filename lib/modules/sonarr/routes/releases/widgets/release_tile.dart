import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';

class SonarrReleasesTile extends StatefulWidget {
  final SonarrRelease release;

  const SonarrReleasesTile({
    required this.release,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrReleasesTile> {
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
            color: widget.release.protocol!.zagProtocolColor(
              release: widget.release,
            ),
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
    String? _preferredWordScore =
        widget.release.zagPreferredWordScore(nullOnEmpty: true);
    final hasCustomFormats = (widget.release.customFormats?.isNotEmpty ?? false) ||
                             (widget.release.customFormatScore != null && widget.release.customFormatScore != 0);
    return TextSpan(
      children: [
        if (_preferredWordScore != null)
          TextSpan(
            text: _preferredWordScore,
            style: const TextStyle(
              color: ZagColours.purple,
              fontWeight: ZagUI.FONT_WEIGHT_BOLD,
            ),
          ),
        if (_preferredWordScore != null)
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(text: widget.release.zagQuality),
        if (widget.release.language != null)
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        if (widget.release.language != null)
          TextSpan(text: widget.release.zagLanguage),
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
        text: widget.release.protocol!.zagReadable(),
        backgroundColor: widget.release.protocol!.zagProtocolColor(
          release: widget.release,
        ),
      ),
      if (widget.release.zagPreferredWordScore(nullOnEmpty: true) != null)
        ZagHighlightedNode(
          text: widget.release.zagPreferredWordScore()!,
          backgroundColor: ZagColours.purple,
        ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(
        title: 'sonarr.Age'.tr(),
        body: widget.release.zagAge,
      ),
      ZagTableContent(
        title: 'sonarr.Indexer'.tr(),
        body: widget.release.zagIndexer,
      ),
      ZagTableContent(
        title: 'sonarr.Size'.tr(),
        body: widget.release.zagSize,
      ),
      if (widget.release.language != null)
        ZagTableContent(
          title: 'sonarr.Language'.tr(),
          body: widget.release.zagLanguage,
        ),
      ZagTableContent(
        title: 'sonarr.Quality'.tr(),
        body: widget.release.zagQuality,
      ),
      if (widget.release.customFormats?.isNotEmpty ?? false)
        ZagTableContent(
          title: 'sonarr.CustomFormats'.tr(),
          body: widget.release.customFormats!
              .map<String>((format) => format.name ?? ZagUI.TEXT_EMDASH)
              .join('\n'),
        ),
      if (widget.release.seeders != null)
        ZagTableContent(
          title: 'sonarr.Seeders'.tr(),
          body: '${widget.release.seeders}',
        ),
      if (widget.release.leechers != null)
        ZagTableContent(
          title: 'sonarr.Leechers'.tr(),
          body: '${widget.release.leechers}',
        ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      ZagButton(
        type: ZagButtonType.TEXT,
        text: 'sonarr.Download'.tr(),
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
          text: 'sonarr.Rejected'.tr(),
          icon: Icons.report_outlined,
          color: ZagColours.red,
          onTap: _showWarnings,
        ),
    ];
  }

  Future<void> _startDownload() async {
    Future<void> setDownloadState(ZagLoadingState state) async {
      if (this.mounted) setState(() => _downloadState = state);
    }

    setDownloadState(ZagLoadingState.ACTIVE);
    SonarrAPIController()
        .downloadRelease(
          context: context,
          release: widget.release,
        )
        .whenComplete(() async => setDownloadState(ZagLoadingState.INACTIVE));
  }

  Future<void> _showWarnings() async => await ZagDialogs()
      .showRejections(context, widget.release.rejections ?? []);
}
