import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

enum SonarrQueueTileType {
  ALL,
  EPISODE,
}

class SonarrQueueTile extends StatefulWidget {
  final SonarrQueueRecord queueRecord;
  final SonarrQueueTileType type;

  const SonarrQueueTile({
    Key? key,
    required this.queueRecord,
    required this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrQueueTile> {
  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: widget.queueRecord.title!,
      collapsedSubtitles: [
        if (widget.type == SonarrQueueTileType.ALL) _subtitle1(),
        if (widget.type == SonarrQueueTileType.ALL) _subtitle2(),
        _subtitle3(),
        _subtitle4(),
      ],
      expandedTableContent: _expandedTableContent(),
      expandedHighlightedNodes: _expandedHighlightedNodes(),
      expandedTableButtons: _tableButtons(),
      collapsedTrailing: _collapsedTrailing(),
      onLongPress: _onLongPress,
    );
  }

  Future<void> _onLongPress() async {
    switch (widget.type) {
      case SonarrQueueTileType.ALL:
        SonarrRoutes.SERIES.go(params: {
          'series': widget.queueRecord.seriesId!.toString(),
        });
        break;
      case SonarrQueueTileType.EPISODE:
        SonarrRoutes.QUEUE.go();
        break;
    }
  }

  Widget _collapsedTrailing() {
    Tuple3<String, IconData, Color> _status =
        widget.queueRecord.zagStatusParameters();
    return ZagIconButton(
      icon: _status.item2,
      color: _status.item3,
    );
  }

  TextSpan _subtitle1() {
    return TextSpan(
      text: widget.queueRecord.series!.title ?? ZagUI.TEXT_EMDASH,
    );
  }

  TextSpan _subtitle2() {
    return TextSpan(
      children: [
        TextSpan(
            text: widget.queueRecord.episode?.zagSeasonEpisode() ??
                ZagUI.TEXT_EMDASH),
        const TextSpan(text: ': '),
        TextSpan(
            text: widget.queueRecord.episode!.title ?? ZagUI.TEXT_EMDASH,
            style: const TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  TextSpan _subtitle3() {
    return TextSpan(
      children: [
        TextSpan(
          text: widget.queueRecord.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        if (widget.queueRecord.language != null)
          TextSpan(
            text: widget.queueRecord.language?.name ?? ZagUI.TEXT_EMDASH,
          ),
        if (widget.queueRecord.language != null)
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: widget.queueRecord.zagTimeLeft(),
        ),
      ],
    );
  }

  TextSpan _subtitle4() {
    Tuple3<String, IconData, Color> _params =
        widget.queueRecord.zagStatusParameters(canBeWhite: false);
    return TextSpan(
      style: TextStyle(
        color: _params.item3,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
      children: [
        TextSpan(text: widget.queueRecord.zagPercentage()),
        TextSpan(text: ZagUI.TEXT_EMDASH.pad()),
        TextSpan(text: _params.item1),
      ],
    );
  }

  List<ZagHighlightedNode> _expandedHighlightedNodes() {
    Tuple3<String, IconData, Color> _status =
        widget.queueRecord.zagStatusParameters(canBeWhite: false);
    return [
      ZagHighlightedNode(
        text: widget.queueRecord.protocol!.zagReadable(),
        backgroundColor: widget.queueRecord.protocol!.zagProtocolColor(),
      ),
      ZagHighlightedNode(
        text: widget.queueRecord.zagPercentage(),
        backgroundColor: _status.item3,
      ),
      ZagHighlightedNode(
        text: widget.queueRecord.status!.zagStatus(),
        backgroundColor: _status.item3,
      ),
    ];
  }

  List<ZagTableContent> _expandedTableContent() {
    return [
      if (widget.type == SonarrQueueTileType.ALL)
        ZagTableContent(
          title: 'sonarr.Series'.tr(),
          body: widget.queueRecord.series?.title ?? ZagUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZagTableContent(
          title: 'sonarr.Episode'.tr(),
          body: widget.queueRecord.episode?.zagSeasonEpisode() ??
              ZagUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZagTableContent(
          title: 'sonarr.Title'.tr(),
          body: widget.queueRecord.episode?.title ?? ZagUI.TEXT_EMDASH,
        ),
      if (widget.type == SonarrQueueTileType.ALL)
        ZagTableContent(title: '', body: ''),
      ZagTableContent(
        title: 'sonarr.Quality'.tr(),
        body: widget.queueRecord.quality?.quality?.name ?? ZagUI.TEXT_EMDASH,
      ),
      if (widget.queueRecord.language != null)
        ZagTableContent(
          title: 'sonarr.Language'.tr(),
          body: widget.queueRecord.language?.name ?? ZagUI.TEXT_EMDASH,
        ),
      ZagTableContent(
        title: 'sonarr.Client'.tr(),
        body: widget.queueRecord.downloadClient ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'sonarr.Size'.tr(),
        body: widget.queueRecord.size?.floor().asBytes() ?? ZagUI.TEXT_EMDASH,
      ),
      ZagTableContent(
        title: 'sonarr.TimeLeft'.tr(),
        body: widget.queueRecord.zagTimeLeft(),
      ),
    ];
  }

  List<ZagButton> _tableButtons() {
    return [
      if ((widget.queueRecord.statusMessages ?? []).isNotEmpty)
        ZagButton.text(
          icon: Icons.messenger_outline_rounded,
          color: ZagColours.orange,
          text: 'sonarr.Messages'.tr(),
          onTap: () async {
            SonarrDialogs().showQueueStatusMessages(
              context,
              widget.queueRecord.statusMessages!,
            );
          },
        ),
      // if (widget.queueRecord.status == SonarrQueueStatus.COMPLETED &&
      //     widget.queueRecord?.trackedDownloadStatus ==
      //         SonarrTrackedDownloadStatus.WARNING)
      //   ZagButton.text(
      //     icon: Icons.download_done_rounded,
      //     text: 'sonarr.Import'.tr(),
      //     onTap: () async {},
      //   ),
      ZagButton.text(
        icon: Icons.delete_rounded,
        color: ZagColours.red,
        text: 'zagreus.Remove'.tr(),
        onTap: () async {
          bool result = await SonarrDialogs().removeFromQueue(context);
          if (result) {
            SonarrAPIController()
                .removeFromQueue(
              context: context,
              queueRecord: widget.queueRecord,
            )
                .then((_) {
              switch (widget.type) {
                case SonarrQueueTileType.ALL:
                  context.read<SonarrQueueState>().fetchQueue(
                        context,
                        hardCheck: true,
                      );
                  break;
                case SonarrQueueTileType.EPISODE:
                  context.read<SonarrSeasonDetailsState>().fetchState(
                        context,
                        shouldFetchEpisodes: false,
                        shouldFetchFiles: false,
                      );
                  break;
              }
            });
          }
        },
      ),
    ];
  }
}
