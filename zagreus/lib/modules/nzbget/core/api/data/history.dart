import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';

class NZBGetHistoryData {
  int id;
  String name;
  String status;
  String? category;
  String storageLocation;
  int timestamp;
  int downloadedLow;
  int downloadedHigh;
  int downloadTime;
  int health;
  DateTime now = DateTime.now();

  NZBGetHistoryData({
    required this.id,
    required this.name,
    required this.status,
    required this.timestamp,
    required this.downloadedLow,
    required this.downloadedHigh,
    required this.category,
    required this.storageLocation,
    required this.downloadTime,
    required this.health,
  });

  int get downloaded {
    return (downloadedHigh << 32) + downloadedLow;
  }

  String get downloadSpeed {
    if (downloadTime == 0) {
      return '0.00 MB/s';
    } else {
      int speed = (downloaded / downloadTime).floor();
      return '${speed.asBytes()}/s';
    }
  }

  String get sizeReadable {
    return downloaded.asBytes();
  }

  DateTime? get timestampObject {
    return timestamp == -1
        ? null
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  String get completeTime {
    return timestampObject?.asAge() ?? 'Unknown';
  }

  String get healthString {
    return '${(health / 10).toStringAsFixed(1)}%';
  }

  bool get isHideable {
    return status.substring(0, min(7, status.length)) == 'SUCCESS';
  }

  bool get failed {
    return status.substring(0, min(7, status.length)) == 'FAILURE';
  }

  Color get statusColor {
    switch (status.substring(0, min(7, status.length))) {
      case 'SUCCESS':
        return ZagColours.currentAccent;
      case 'WARNING':
        return ZagColours.orange;
      case 'DELETED':
        return ZagColours.purple;
      case 'FAILURE':
        return ZagColours.red;
      default:
        return ZagColours.blueGrey;
    }
  }

  String get statusString {
    switch (status.substring(0, min(7, status.length))) {
      case 'SUCCESS':
        return 'Completed (${status.substring('SUCCESS/'.length)})';
      case 'WARNING':
        return 'Warning (${status.substring('WARNING/'.length)})';
      case 'DELETED':
        return 'Deleted (${status.substring('DELETED/'.length)})';
      case 'FAILURE':
        return 'Failure (${status.substring('FAILURE/'.length)})';
      default:
        return status;
    }
  }
}
