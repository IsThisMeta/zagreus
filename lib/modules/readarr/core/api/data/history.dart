import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
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
      if (age.inDays >= 1) {
        return age.inDays == 1
            ? '${age.inDays} Day Ago'
            : '${age.inDays} Days Ago';
      }
      if (age.inHours >= 1) {
        return age.inHours == 1
            ? '${age.inHours} Hour Ago'
            : '${age.inHours} Hours Ago';
      }
      return age.inMinutes == 1
          ? '${age.inMinutes} Minute Ago'
          : '${age.inMinutes} Minutes Ago';
    }
    return 'Unknown Date/Time';
  }

  List<TextSpan> get subtitle;

  final Map historyReasonMessages = {
    'Upgrade': 'Upgraded File',
    'MissingFromDisk': 'Missing From Disk',
    'Manual': 'Manually Removed',
  };
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]} $indexer',
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]} ($quality)',
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]} ($quality)',
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]}',
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
            '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]} (${super.historyReasonMessages[reason] ?? reason})',
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]}',
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
        text: '${ReadarrConstants.EVENT_TYPE_MESSAGES[eventType]}',
        style: TextStyle(
          color: ZagColours.blue,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}
