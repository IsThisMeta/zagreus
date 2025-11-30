import 'package:flutter/material.dart';
import 'package:zagreus/api/lidarr/models/queue/queue.dart';
import 'package:zagreus/core.dart';

class LidarrQueueTile extends StatelessWidget {
  final LidarrQueueRecord record;
  const LidarrQueueTile({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (record.artistName.isNotEmpty) record.artistName,
      if (record.albumTitle.isNotEmpty) record.albumTitle,
      if ((record.timeleft ?? '').isNotEmpty) record.timeleft!,
      if ((record.status ?? '').isNotEmpty) record.status!,
    ].where((e) => e.isNotEmpty).join(' ${ZagUI.TEXT_BULLET} ');

    return ZagBlock(
      title: (record.title ?? '').isNotEmpty
          ? record.title
          : (record.albumTitle.isNotEmpty ? record.albumTitle : 'Unknown'),
      body: [TextSpan(text: subtitle.isEmpty ? 'Pending' : subtitle)],
      trailing: ZagIconButton(
        icon: Icons.queue_music_rounded,
        color: ZagColours.currentAccent,
      ),
    );
  }
}
