import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/datetime.dart';
import 'package:zagreus/extensions/int/bytes.dart';

class SABnzbdHistoryData {
  String nzoId;
  String name;
  String failureMessage;
  String? category;
  int size;
  int timestamp;
  int downloadTime;
  String status;
  String actionLine;
  String storageLocation;
  List<dynamic> stageLog;
  DateTime now = DateTime.now();

  SABnzbdHistoryData({
    required this.nzoId,
    required this.name,
    required this.size,
    required this.status,
    required this.failureMessage,
    required this.timestamp,
    required this.actionLine,
    required this.category,
    required this.downloadTime,
    required this.stageLog,
    required this.storageLocation,
  });

  DateTime get completeTimeObject {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  String get completeTimeString {
    return completeTimeObject.asAge();
  }

  String get sizeReadable {
    return size.asBytes();
  }

  bool get failed {
    return status.toLowerCase() == 'failed';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return ZagColours.currentAccent;
      case 'queued':
        return ZagColours.blue;
      case 'extracting':
        return ZagColours.orange;
      case 'failed':
        return ZagColours.red;
    }
    return ZagColours.purple;
  }

  String get statusString {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'queued':
      case 'extracting':
        return actionLine;
      case 'failed':
        return failureMessage;
      default:
        return status;
    }
  }
}
