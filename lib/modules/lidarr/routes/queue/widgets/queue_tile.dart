import 'package:flutter/material.dart';
import 'package:zagreus/api/lidarr/models/queue/queue.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/string/string.dart';
import 'package:zagreus/extensions/int/bytes.dart';

class LidarrQueueTile extends StatelessWidget {
  final LidarrQueueRecord record;
  const LidarrQueueTile({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitle = TextSpan(
      children: [
        if (record.artistName.isNotEmpty)
          TextSpan(
            text: record.artistName,
            style: TextStyle(fontWeight: ZagUI.FONT_WEIGHT_BOLD),
          ),
        if (record.artistName.isNotEmpty && record.albumTitle.isNotEmpty)
          TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        if (record.albumTitle.isNotEmpty) TextSpan(text: record.albumTitle),
      ],
    );

    final statusLine = TextSpan(
      children: [
        TextSpan(
          text: _localizedStatus(record.status),
          style: TextStyle(color: ZagColours.blueGrey),
        ),
        TextSpan(text: ZagUI.TEXT_BULLET.pad()),
        TextSpan(
          text: record.timeleft ?? ZagUI.TEXT_EMDASH,
          style: TextStyle(color: ZagColours.currentAccent),
        ),
      ],
    );

    return ZagExpandableListTile(
      title: (record.title ?? '').isNotEmpty
          ? record.title ?? 'zagreus.Unknown'.tr()
          : (record.albumTitle.isNotEmpty
              ? record.albumTitle
              : 'zagreus.Unknown'.tr()),
      collapsedSubtitles: [
        if (record.albumTitle.isNotEmpty) TextSpan(text: record.albumTitle),
        subtitle,
        statusLine,
      ],
      collapsedTrailing: ZagIconButton(
        icon: _statusIcon,
        color: _statusColor,
      ),
      expandedHighlightedNodes: _highlightedNodes(),
      expandedTableContent: _tableContent(),
    );
  }

  IconData get _statusIcon {
    final status = (record.status ?? '').toLowerCase();
    if (status.contains('paused')) return Icons.pause_rounded;
    if (status.contains('queued')) return Icons.schedule_rounded;
    if (status.contains('down')) return Icons.download_rounded;
    if (status.contains('completed')) return Icons.check_circle_rounded;
    return Icons.queue_music_rounded;
  }

  Color get _statusColor {
    final status = (record.status ?? '').toLowerCase();
    if (status.contains('paused')) return ZagColours.blueGrey;
    if (status.contains('queued')) return ZagColours.currentAccent;
    if (status.contains('down')) return ZagColours.currentAccent;
    if (status.contains('completed')) return ZagColours.orange;
    return ZagColours.currentAccent;
  }

  List<ZagHighlightedNode> _highlightedNodes() {
    return [
      if ((record.status ?? '').isNotEmpty)
        ZagHighlightedNode(
          text: _localizedStatus(record.status),
          backgroundColor: ZagColours.blueGrey,
        ),
      if (record.timeleft != null && record.timeleft!.isNotEmpty)
        ZagHighlightedNode(
          text: record.timeleft!,
          backgroundColor: ZagColours.currentAccent,
        ),
      if (record.size != null && record.sizeleft != null)
        ZagHighlightedNode(
          text:
              '${(record.sizeleft ?? 0).toInt().asBytes()} / ${(record.size ?? 0).toInt().asBytes()}',
          backgroundColor: ZagColours.blue,
        ),
      if (record.artistName.isNotEmpty)
        ZagHighlightedNode(
          text: record.artistName,
          backgroundColor: ZagColours.orange,
        ),
    ];
  }

  List<ZagTableContent> _tableContent() {
    return [
      if (record.artistName.isNotEmpty)
        ZagTableContent(title: 'lidarr.Artist'.tr(), body: record.artistName),
      if (record.albumTitle.isNotEmpty)
        ZagTableContent(title: 'lidarr.Album'.tr(), body: record.albumTitle),
      if ((record.status ?? '').isNotEmpty)
        ZagTableContent(
            title: 'lidarr.Status'.tr(), body: _localizedStatus(record.status)),
      if ((record.timeleft ?? '').isNotEmpty)
        ZagTableContent(
            title: 'lidarr.TimeLeft'.tr(), body: record.timeleft),
      if (record.size != null)
        ZagTableContent(
            title: 'lidarr.Size'.tr(), body: record.size!.toInt().asBytes()),
      if (record.sizeleft != null)
        ZagTableContent(
            title: 'lidarr.Remaining'.tr(),
            body: record.sizeleft!.toInt().asBytes()),
    ];
  }

  String _localizedStatus(String? status) {
    final value = (status ?? '').toLowerCase();
    if (value.contains('paused')) return 'lidarr.Paused'.tr();
    if (value.contains('queued')) return 'lidarr.Queued'.tr();
    if (value.contains('down')) return 'lidarr.Downloading'.tr();
    if (value.contains('completed')) return 'lidarr.Completed'.tr();
    if (value.isEmpty) return 'zagreus.Unknown'.tr();
    return status!.toTitleCase();
  }
}
