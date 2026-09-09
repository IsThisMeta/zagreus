import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';

class QBitQueueTile extends StatelessWidget {
  final QBitTorrentData torrent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QBitQueueTile({
    Key? key,
    required this.torrent,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: torrent.name,
      body: [
        TextSpan(
          children: [
            TextSpan(
              text: torrent.statusText,
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (torrent.isDownloading && torrent.dlSpeed > 0)
              TextSpan(
                text:
                    ' - ${_formatSpeed(torrent.dlSpeed)} - ETA: ${torrent.formattedEta}',
              ),
          ],
        ),
        TextSpan(
          children: [
            TextSpan(text: _formatBytes(torrent.downloaded)),
            if (torrent.category.isNotEmpty) ...[
              const TextSpan(text: ' - '),
              TextSpan(
                text: torrent.category,
                style: TextStyle(color: ZagColours.currentAccent),
              ),
            ],
          ],
        ),
      ],
      bottomHeight: ZagLinearPercentIndicator.compactHeight,
      bottom: ZagLinearPercentIndicator(
        percent: max(0.0, min(1.0, torrent.progress)),
        progressColor: _progressColor,
        compact: true,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Color get _statusColor {
    if (torrent.isError) return ZagColours.red;
    if (torrent.isPaused) return ZagColours.orange;
    if (torrent.isDownloading) return ZagColours.currentAccent;
    return ZagColours.currentAccent;
  }

  Color get _progressColor {
    if (torrent.isError) return ZagColours.red;
    if (torrent.isPaused) return ZagColours.orange;
    return ZagColours.currentAccent;
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) return '$bytesPerSecond B/s';
    if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < 1024 * 1024 * 1024) {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB/s';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
