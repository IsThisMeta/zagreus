import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/router/routes/sonarr.dart';

enum SonarrHistoryTileType {
  ALL,
  SERIES,
  SEASON,
  EPISODE,
}

class SonarrHistoryTile extends StatelessWidget {
  final SonarrHistoryRecord history;
  final SonarrHistoryTileType type;
  final SonarrSeries? series;
  final SonarrEpisode? episode;

  const SonarrHistoryTile({
    Key? key,
    required this.history,
    required this.type,
    this.series,
    this.episode,
  }) : super(key: key);

  bool _hasEpisodeInfo() {
    if (history.episode != null || episode != null) return true;
    return false;
  }

  bool _hasLongPressAction() {
    switch (type) {
      case SonarrHistoryTileType.ALL:
        return true;
      case SonarrHistoryTileType.SERIES:
        return _hasEpisodeInfo();
      case SonarrHistoryTileType.SEASON:
      case SonarrHistoryTileType.EPISODE:
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isThreeLine =
        _hasEpisodeInfo() && type != SonarrHistoryTileType.EPISODE;
    return ZagExpandableListTile(
      title: type != SonarrHistoryTileType.ALL
          ? history.sourceTitle!
          : series?.title ?? ZagUI.TEXT_EMDASH,
      collapsedSubtitles: [
        if (_isThreeLine) _subtitle1(),
        _subtitle2(),
        _subtitle3(),
      ],
      expandedHighlightedNodes: [
        ZagHighlightedNode(
          text: history.eventType?.readable ?? ZagUI.TEXT_EMDASH,
          backgroundColor: history.eventType!.zagColour(),
        ),
        if (history.zagHasPreferredWordScore())
          ZagHighlightedNode(
            text: history.zagPreferredWordScore(),
            backgroundColor: ZagColours.purple,
          ),
        if (history.episode?.seasonNumber != null)
          ZagHighlightedNode(
            text: 'sonarr.SeasonNumber'.tr(
              args: [history.episode!.seasonNumber.toString()],
            ),
            backgroundColor: ZagColours.blueGrey,
          ),
        if (episode?.seasonNumber != null)
          ZagHighlightedNode(
            text: 'sonarr.SeasonNumber'.tr(
              args: [episode?.seasonNumber?.toString() ?? ZagUI.TEXT_EMDASH],
            ),
            backgroundColor: ZagColours.blueGrey,
          ),
        if (history.episode?.episodeNumber != null)
          ZagHighlightedNode(
            text: 'sonarr.EpisodeNumber'.tr(
              args: [history.episode!.episodeNumber.toString()],
            ),
            backgroundColor: ZagColours.blueGrey,
          ),
        if (episode?.episodeNumber != null)
          ZagHighlightedNode(
            text: 'sonarr.EpisodeNumber'.tr(
              args: [episode?.episodeNumber?.toString() ?? ZagUI.TEXT_EMDASH],
            ),
            backgroundColor: ZagColours.blueGrey,
          ),
      ],
      expandedTableContent: history.eventType?.zagTableContent(
            history: history,
            showSourceTitle: type != SonarrHistoryTileType.ALL,
          ) ??
          [],
      onLongPress:
          _hasLongPressAction() ? () async => _onLongPress(context) : null,
    );
  }

  Future<void> _onLongPress(BuildContext context) async {
    switch (type) {
      case SonarrHistoryTileType.ALL:
        final id = history.series?.id ?? series?.id ?? -1;
        return SonarrRoutes.SERIES.go(params: {
          'series': id.toString(),
        });
      case SonarrHistoryTileType.SERIES:
        if (_hasEpisodeInfo()) {
          final seriesId =
              history.seriesId ?? history.series?.id ?? series!.id ?? -1;
          final seasonNum =
              history.episode?.seasonNumber ?? episode?.seasonNumber ?? -1;
          return SonarrRoutes.SERIES_SEASON.go(params: {
            'series': seriesId.toString(),
            'season': seasonNum.toString(),
          });
        }
        break;
      default:
        break;
    }
  }

  TextSpan _subtitle1() {
    return TextSpan(children: [
      TextSpan(
        text: history.zagSeasonEpisode() ??
            episode?.zagSeasonEpisode() ??
            ZagUI.TEXT_EMDASH,
      ),
      const TextSpan(text: ': '),
      TextSpan(
        text: history.episode?.title ?? episode?.title ?? ZagUI.TEXT_EMDASH,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
    ]);
  }

  TextSpan _subtitle2() {
    return TextSpan(
      text: [
        history.date?.asAge() ?? ZagUI.TEXT_EMDASH,
        history.date?.asDateTime() ?? ZagUI.TEXT_EMDASH,
      ].join(ZagUI.TEXT_BULLET.pad()),
    );
  }

  TextSpan _subtitle3() {
    return TextSpan(
      text: history.eventType?.zagReadable(history) ?? ZagUI.TEXT_EMDASH,
      style: TextStyle(
        color: history.eventType?.zagColour() ?? ZagColours.blueGrey,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }
}
