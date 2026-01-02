import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/modules/readarr.dart';

abstract class ReadarrHistoryData {
  String title;
  String timestamp;
  String eventType;
  int authorID;
  int bookID;

  ReadarrHistoryData(
    this.title,
    this.timestamp,
    this.eventType,
    this.authorID,
    this.bookID,
  );

  DateTime? get timestampObject {
    return DateTime.tryParse(timestamp)?.toLocal();
  }

  String get timestampString {
    if (timestampObject != null) {
      Duration age = DateTime.now().difference(timestampObject!);
      return (age.inMinutes / 60).asTimeAgo();
    }
    return 'zagreus.UnknownDate'.tr();
  }

  List<TextSpan> get subtitle;

  String? historyReasonMessage(String reason) {
    switch (reason) {
      case 'Upgrade':
        return 'readarr.HistoryReasonUpgrade'.tr();
      case 'MissingFromDisk':
        return 'readarr.HistoryReasonMissingFromDisk'.tr();
      case 'Manual':
        return 'readarr.HistoryReasonManual'.tr();
      default:
        return null;
    }
  }
}

class ReadarrHistoryDataGeneric extends ReadarrHistoryData {
  @override
  // ignore: overridden_fields
  String eventType;

  ReadarrHistoryDataGeneric({
    required String title,
    required String timestamp,
    required this.eventType,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, eventType, authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(
        text: '$timestampString\n',
      ),
      TextSpan(
        text: eventType,
        style: TextStyle(
          color: ZagColours.purple,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      ),
    ];
  }
}

class ReadarrHistoryDataGrabbed extends ReadarrHistoryData {
  String indexer;

  ReadarrHistoryDataGrabbed({
    required String title,
    required String timestamp,
    required this.indexer,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'grabbed', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(
        text: '$timestampString\n',
      ),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)} $indexer',
        style: TextStyle(
          color: ZagColours.orange,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataBookFileImported extends ReadarrHistoryData {
  String quality;

  ReadarrHistoryDataBookFileImported({
    required String title,
    required String timestamp,
    required this.quality,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'bookFileImported', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)} ($quality)',
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataDownloadImported extends ReadarrHistoryData {
  String quality;

  ReadarrHistoryDataDownloadImported({
    required String title,
    required String timestamp,
    required this.quality,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'downloadImported', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)} ($quality)',
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataBookImportIncomplete extends ReadarrHistoryData {
  ReadarrHistoryDataBookImportIncomplete({
    required String title,
    required String timestamp,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'bookImportIncomplete', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.orange,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataBookFileDeleted extends ReadarrHistoryData {
  String reason;

  ReadarrHistoryDataBookFileDeleted({
    required String title,
    required String timestamp,
    required this.reason,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'bookFileDeleted', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text:
            '${ReadarrConstants.eventTypeMessage(eventType)} (${super.historyReasonMessage(reason) ?? reason})',
        style: TextStyle(
          color: ZagColours.red,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataBookFileRenamed extends ReadarrHistoryData {
  ReadarrHistoryDataBookFileRenamed({
    required String title,
    required String timestamp,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'bookFileRenamed', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.blue,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class ReadarrHistoryDataBookFileRetagged extends ReadarrHistoryData {
  ReadarrHistoryDataBookFileRetagged({
    required String title,
    required String timestamp,
    required int authorID,
    required int bookID,
  }) : super(title, timestamp, 'bookFileRetagged', authorID, bookID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${ReadarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.blue,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}
