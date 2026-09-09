import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/qbit/core/api/data.dart';

class QBitHistoryTile extends StatelessWidget {
  final QBitTorrentData torrent;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const QBitHistoryTile({
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
          text: torrent.statusText,
          style: TextStyle(
            color: _statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const TextSpan(text: '\n'),
        TextSpan(
          text: 'Size: ${_formatBytes(torrent.size)}',
        ),
        if (torrent.isSeeding && torrent.upSpeed > 0) ...[
          const TextSpan(text: ' - '),
          TextSpan(
            text: 'Seeding: ${_formatSpeed(torrent.upSpeed)}',
          ),
        ],
        const TextSpan(text: '\n'),
        TextSpan(
          text: 'Ratio: ${torrent.ratio.toStringAsFixed(2)}',
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
      trailing: Icon(
        torrent.isSeeding ? Icons.cloud_upload_rounded : Icons.check_circle_rounded,
        color: _statusColor,
        size: 28,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Color get _statusColor {
    if (torrent.isError) return ZagColours.red;
    if (torrent.isSeeding) return ZagColours.currentAccent;
    return Colors.green;
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
