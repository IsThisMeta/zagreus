import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/modules/radarr.dart';
import 'package:zagreus/router/routes/radarr.dart';

class RadarrHistoryTile extends StatelessWidget {
  final RadarrHistoryRecord history;
  final bool movieHistory;
  final String title;

  /// If [movieHistory] is false (default), you must supply a title or else a dash will be shown.
  const RadarrHistoryTile({
    Key? key,
    required this.history,
    this.movieHistory = false,
    this.title = ZagUI.TEXT_EMDASH,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: movieHistory ? history.sourceTitle! : title,
      collapsedSubtitles: [
        TextSpan(
          text: [
            history.date?.asAge() ?? ZagUI.TEXT_EMDASH,
            history.date?.asDateTime() ?? ZagUI.TEXT_EMDASH,
          ].join(ZagUI.TEXT_BULLET.pad()),
        ),
        TextSpan(
          text: history.eventType?.zagReadable(history) ?? ZagUI.TEXT_EMDASH,
          style: TextStyle(
            color: history.eventType?.zagColour ?? ZagColours.blueGrey,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      expandedHighlightedNodes: [
        ZagHighlightedNode(
          text: history.eventType!.readable!,
          backgroundColor: history.eventType!.zagColour,
        ),
        ...history.customFormats!
            .map<ZagHighlightedNode>((format) => ZagHighlightedNode(
                  text: format.name!,
                  backgroundColor: ZagColours.blueGrey,
                )),
      ],
      expandedTableContent: history.eventType?.zagTableContent(
            history,
            movieHistory: movieHistory,
          ) ??
          [],
      onLongPress: movieHistory
          ? null
          : () => RadarrRoutes.MOVIE.go(params: {
                'movie': history.movieId!.toString(),
              }),
    );
  }
}
