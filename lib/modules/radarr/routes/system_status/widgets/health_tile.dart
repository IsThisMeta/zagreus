import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/links.dart';
import 'package:zagreus/modules/radarr.dart';

class RadarrHealthCheckTile extends StatelessWidget {
  final RadarrHealthCheck healthCheck;

  const RadarrHealthCheckTile({
    Key? key,
    required this.healthCheck,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagExpandableListTile(
      title: healthCheck.message!,
      collapsedSubtitles: [
        subtitle1(),
        subtitle2(),
      ],
      expandedTableContent: expandedTable(),
      expandedHighlightedNodes: highlightedNodes(),
      onLongPress: healthCheck.wikiUrl!.openLink,
    );
  }

  TextSpan subtitle1() {
    return TextSpan(text: healthCheck.source);
  }

  TextSpan subtitle2() {
    return TextSpan(
      text: healthCheck.type!.readable,
      style: TextStyle(
        color: healthCheck.type.zagColour,
        fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        fontSize: ZagUI.FONT_SIZE_H3,
      ),
    );
  }

  List<ZagHighlightedNode> highlightedNodes() {
    return [
      ZagHighlightedNode(
        text: healthCheck.type!.readable!,
        backgroundColor: healthCheck.type.zagColour,
      ),
    ];
  }

  List<ZagTableContent> expandedTable() {
    return [
      ZagTableContent(title: 'Source', body: healthCheck.source),
    ];
  }
}
