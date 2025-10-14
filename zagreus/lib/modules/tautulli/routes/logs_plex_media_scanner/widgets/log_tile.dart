import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliLogsPlexMediaScannerLogTile extends StatelessWidget {
  final TautulliPlexLog log;

  const TautulliLogsPlexMediaScannerLogTile({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: log.message!.trim(),
      collapsedSubtitles: [
        _subtitle1(),
        _subtitle2(),
      ],
      expandedTableContent: _tableContent(),
    );
  }

  TextSpan _subtitle1() => TextSpan(text: log.timestamp ?? ZagUI.TEXT_EMDASH);

  TextSpan _subtitle2() {
    return TextSpan(
      text: log.level ?? ZagUI.TEXT_EMDASH,
      style: TextStyle(
        color: ZagColours.currentAccent,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
      ),
    );
  }

  List<ZagTableContent> _tableContent() {
    return [
      ZagTableContent(title: 'level', body: log.level),
      ZagTableContent(title: 'timestamp', body: log.timestamp),
    ];
  }
}
