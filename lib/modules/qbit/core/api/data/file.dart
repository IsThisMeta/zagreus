import 'package:zagreus/modules/qbit/core/api/data/priority.dart';

class QBitFileData {
  final int index;
  final String name;
  final int size;
  final double progress;
  final int priority;
  final bool isSeed;
  final int pieceRange;
  final double availability;

  QBitFileData({
    required this.index,
    required this.name,
    required this.size,
    required this.progress,
    required this.priority,
    required this.isSeed,
    required this.pieceRange,
    required this.availability,
  });

  factory QBitFileData.fromJson(Map<String, dynamic> json, int index) {
    return QBitFileData(
      index: index,
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
      priority: json['priority'] ?? 1,
      isSeed: json['is_seed'] ?? false,
      pieceRange: json['piece_range']?.length ?? 0,
      availability: (json['availability'] ?? 0.0).toDouble(),
    );
  }

  static List<QBitFileData> fromJsonList(List<dynamic> jsonList) {
    final List<QBitFileData> files = [];
    for (int i = 0; i < jsonList.length; i++) {
      files.add(QBitFileData.fromJson(jsonList[i] as Map<String, dynamic>, i));
    }
    return files;
  }

  String get formattedProgress => '${(progress * 100).toStringAsFixed(1)}%';

  QBitFilePriority get priorityEnum => QBitFilePriority.fromValue(priority);

  bool get isDownloading => priority > 0;
  bool get isSkipped => priority == 0;

  String get fileName {
    final parts = name.split('/');
    return parts.last;
  }

  String get folderPath {
    final parts = name.split('/');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join('/');
    }
    return '';
  }
}
