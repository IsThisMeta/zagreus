import 'package:zagreus/modules/qbit/core/api/data/priority.dart';

class QBitTorrentData {
  final String hash;
  final String name;
  final String state;
  final int size;
  final int downloaded;
  final int uploaded;
  final double progress;
  final int dlSpeed;
  final int upSpeed;
  final int priority;
  final int eta;
  final double ratio;
  final int addedOn;
  final int completionOn;
  final String category;
  final String tags;
  final String savePath;
  final int seedersCurrent;
  final int seedersTotal;
  final int leechersCurrent;
  final int leechersTotal;

  QBitTorrentData({
    required this.hash,
    required this.name,
    required this.state,
    required this.size,
    required this.downloaded,
    required this.uploaded,
    required this.progress,
    required this.dlSpeed,
    required this.upSpeed,
    required this.priority,
    required this.eta,
    required this.ratio,
    required this.addedOn,
    required this.completionOn,
    required this.category,
    required this.tags,
    required this.savePath,
    required this.seedersCurrent,
    required this.seedersTotal,
    required this.leechersCurrent,
    required this.leechersTotal,
  });

  factory QBitTorrentData.fromJson(Map<String, dynamic> json) {
    return QBitTorrentData(
      hash: json['hash'] ?? '',
      name: json['name'] ?? 'Unknown',
      state: json['state'] ?? 'unknown',
      size: json['size'] ?? 0,
      downloaded: json['downloaded'] ?? 0,
      uploaded: json['uploaded'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      dlSpeed: json['dlspeed'] ?? 0,
      upSpeed: json['upspeed'] ?? 0,
      priority: json['priority'] ?? 0,
      eta: json['eta'] ?? 0,
      ratio: (json['ratio'] ?? 0.0).toDouble(),
      addedOn: json['added_on'] ?? 0,
      completionOn: json['completion_on'] ?? 0,
      category: json['category'] ?? '',
      tags: json['tags'] ?? '',
      savePath: json['save_path'] ?? '',
      seedersCurrent: json['num_seeds'] ?? 0,
      seedersTotal: json['num_complete'] ?? 0,
      leechersCurrent: json['num_leechs'] ?? 0,
      leechersTotal: json['num_incomplete'] ?? 0,
    );
  }

  bool get isDownloading =>
      state == 'downloading' ||
      state == 'stalledDL' ||
      state == 'metaDL' ||
      state == 'forcedMetaDL' ||
      state == 'forcedDL' ||
      state == 'allocating' ||
      state == 'queuedDL' ||
      state == 'checkingDL';

  bool get isCompleted =>
      state == 'uploading' ||
      state == 'stalledUP' ||
      state == 'forcedUP' ||
      state == 'queuedUP' ||
      state == 'checkingUP' ||
      state == 'pausedUP' ||
      state == 'stoppedUP';

  bool get isPaused =>
      state == 'pausedDL' ||
      state == 'pausedUP' ||
      state == 'stoppedDL' ||
      state == 'stoppedUP';

  bool get isSeeding =>
      state == 'uploading' || state == 'stalledUP' || state == 'forcedUP';

  bool get isError => state == 'error' || state == 'missingFiles';

  bool get isChecking =>
      state == 'checkingDL' ||
      state == 'checkingUP' ||
      state == 'checkingResumeData';

  String get statusText {
    switch (state) {
      case 'error':
        return 'Error';
      case 'missingFiles':
        return 'Missing Files';
      case 'uploading':
        return 'Seeding';
      case 'pausedUP':
      case 'stoppedUP':
        return 'Completed';
      case 'queuedUP':
        return 'Queued (Seed)';
      case 'stalledUP':
        return 'Stalled (Seed)';
      case 'checkingUP':
        return 'Checking';
      case 'forcedUP':
        return 'Forced Seed';
      case 'allocating':
        return 'Allocating';
      case 'downloading':
        return 'Downloading';
      case 'metaDL':
        return 'Fetching Metadata';
      case 'forcedMetaDL':
        return 'Fetching Metadata (Forced)';
      case 'pausedDL':
      case 'stoppedDL':
        return 'Paused';
      case 'queuedDL':
        return 'Queued';
      case 'stalledDL':
        return 'Stalled';
      case 'checkingDL':
        return 'Checking';
      case 'forcedDL':
        return 'Forced Download';
      case 'checkingResumeData':
        return 'Checking Resume Data';
      case 'moving':
        return 'Moving';
      default:
        return state;
    }
  }

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  String get formattedEta {
    if (eta < 0 || eta == 8640000) return '\u221E'; // Infinity symbol
    if (eta == 0) return '-';
    final hours = eta ~/ 3600;
    final minutes = (eta % 3600) ~/ 60;
    final seconds = eta % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  QBitPriority get priorityEnum => QBitPriority.fromValue(priority);
}
