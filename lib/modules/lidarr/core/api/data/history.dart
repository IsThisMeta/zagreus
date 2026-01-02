import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/modules/lidarr.dart';

abstract class LidarrHistoryData {
  String title;
  String timestamp;
  String eventType;
  int artistID;
  int albumID;

  LidarrHistoryData(
    this.title,
    this.timestamp,
    this.eventType,
    this.artistID,
    this.albumID,
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
        return 'lidarr.HistoryReasonUpgrade'.tr();
      case 'MissingFromDisk':
        return 'lidarr.HistoryReasonMissingFromDisk'.tr();
      case 'Manual':
        return 'lidarr.HistoryReasonManual'.tr();
      default:
        return null;
    }
  }
}

class LidarrHistoryDataGeneric extends LidarrHistoryData {
  @override
  // ignore: overridden_fields
  String eventType;

  LidarrHistoryDataGeneric({
    required String title,
    required String timestamp,
    required this.eventType,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, eventType, artistID, albumID);

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

class LidarrHistoryDataGrabbed extends LidarrHistoryData {
  String indexer;

  LidarrHistoryDataGrabbed({
    required String title,
    required String timestamp,
    required this.indexer,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'grabbed', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(
        text: '$timestampString\n',
      ),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)} $indexer',
        style: TextStyle(
          color: ZagColours.orange,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataTrackFileImported extends LidarrHistoryData {
  String quality;

  LidarrHistoryDataTrackFileImported({
    required String title,
    required String timestamp,
    required this.quality,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'trackFileImported', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)} ($quality)',
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataDownloadImported extends LidarrHistoryData {
  String quality;

  LidarrHistoryDataDownloadImported({
    required String title,
    required String timestamp,
    required this.quality,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'downloadImported', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)} ($quality)',
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataAlbumImportIncomplete extends LidarrHistoryData {
  LidarrHistoryDataAlbumImportIncomplete({
    required String title,
    required String timestamp,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'albumImportIncomplete', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.orange,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataTrackFileDeleted extends LidarrHistoryData {
  String reason;

  LidarrHistoryDataTrackFileDeleted({
    required String title,
    required String timestamp,
    required this.reason,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'trackFileDeleted', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text:
            '${LidarrConstants.eventTypeMessage(eventType)} (${super.historyReasonMessage(reason) ?? reason})',
        style: TextStyle(
          color: ZagColours.red,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataTrackFileRenamed extends LidarrHistoryData {
  LidarrHistoryDataTrackFileRenamed({
    required String title,
    required String timestamp,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'trackFileRenamed', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.blue,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}

class LidarrHistoryDataTrackFileRetagged extends LidarrHistoryData {
  LidarrHistoryDataTrackFileRetagged({
    required String title,
    required String timestamp,
    required int artistID,
    required int albumID,
  }) : super(title, timestamp, 'trackFileRetagged', artistID, albumID);

  @override
  List<TextSpan> get subtitle {
    return [
      TextSpan(text: timestampString),
      TextSpan(
        text: '${LidarrConstants.eventTypeMessage(eventType)}',
        style: TextStyle(
          color: ZagColours.blue,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      )
    ];
  }
}
