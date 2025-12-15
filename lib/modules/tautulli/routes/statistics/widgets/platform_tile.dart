import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/duration/timestamp.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliStatisticsPlatformTile extends StatefulWidget {
  final Map<String, dynamic> data;

  const TautulliStatisticsPlatformTile({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TautulliStatisticsPlatformTile> {
  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: widget.data['platform'] ?? 'Unknown Platform',
      body: _body(),
      posterPlaceholderIcon: ZagIcons.DEVICES,
      posterIsSquare: true,
    );
  }

  List<TextSpan> _body() {
    return [
      TextSpan(
        text: widget.data['total_plays'].toString() +
            (widget.data['total_plays'] == 1 ? ' Play' : ' Plays'),
        style: TextStyle(
          color: context.watch<TautulliState>().statisticsType ==
                  TautulliStatsType.PLAYS
              ? ZagColours.accent
              : null,
          fontWeight: context.watch<TautulliState>().statisticsType ==
                  TautulliStatsType.PLAYS
              ? ZagUI.FONT_WEIGHT_BOLD
              : null,
        ),
      ),
      widget.data['total_duration'] != null
          ? TextSpan(
              text: Duration(seconds: widget.data['total_duration'])
                  .asWordsTimestamp(),
              style: TextStyle(
                color: context.watch<TautulliState>().statisticsType ==
                        TautulliStatsType.DURATION
                    ? ZagColours.accent
                    : null,
                fontWeight: context.watch<TautulliState>().statisticsType ==
                        TautulliStatsType.DURATION
                    ? ZagUI.FONT_WEIGHT_BOLD
                    : null,
              ),
            )
          : const TextSpan(text: ZagUI.TEXT_EMDASH),
    ];
  }
}
