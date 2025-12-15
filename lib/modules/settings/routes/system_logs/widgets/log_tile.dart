import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/log.dart';
import 'package:zagreus/extensions/datetime.dart';

class SettingsSystemLogTile extends StatelessWidget {
  final ZagLog log;

  const SettingsSystemLogTile({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateTime =
        DateTime.fromMillisecondsSinceEpoch(log.timestamp).asDateTime();
    return ZagExpandableListTile(
      title: log.message,
      collapsedSubtitles: [
        TextSpan(text: dateTime),
        TextSpan(
          text: log.type.title.toUpperCase(),
          style: TextStyle(
            color: log.type.color,
            fontWeight: ZagUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      expandedHighlightedNodes: [
        ZagHighlightedNode(
          text: log.type.title.toUpperCase(),
          backgroundColor: log.type.color,
        ),
        ZagHighlightedNode(
          text: dateTime,
          backgroundColor: ZagColours.blueGrey,
        ),
      ],
      expandedTableContent: [
        if (log.className != null && log.className!.isNotEmpty)
          ZagTableContent(title: 'settings.Class'.tr(), body: log.className),
        if (log.methodName != null && log.methodName!.isNotEmpty)
          ZagTableContent(title: 'settings.Method'.tr(), body: log.methodName),
        if (log.error != null && log.error!.isNotEmpty)
          ZagTableContent(title: 'settings.Exception'.tr(), body: log.error),
      ],
    );
  }
}
