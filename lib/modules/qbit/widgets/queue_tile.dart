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
          text: '${torrent.statusText} - ${torrent.formattedProgress}',
          style: TextStyle(
            color: _statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (torrent.isDownloading && torrent.dlSpeed > 0) ...[
          const TextSpan(text: '\n'),
          TextSpan(
            text: '${_formatSpeed(torrent.dlSpeed)} - ETA: ${torrent.formattedEta}',
          ),
        ],
        const TextSpan(text: '\n'),
        TextSpan(
          text: '${_formatBytes(torrent.downloaded)} / ${_formatBytes(torrent.size)}',
        ),
        if (torrent.category.isNotEmpty) ...[
          const TextSpan(text: ' - '),
          TextSpan(
            text: torrent.category,
            style: TextStyle(
              color: ZagColours.currentAccent,
            ),
          ),
        ],
      ],
      trailing: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: torrent.progress,
              strokeWidth: 3,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
            ),
            Text(
              '${(torrent.progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
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
