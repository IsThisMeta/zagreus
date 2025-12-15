import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class LidarrTrackData {
  String title;
  bool explicit;
  bool hasFile;
  String trackNumber;
  int trackID;
  int duration;

  LidarrTrackData({
    required this.trackID,
    required this.title,
    required this.trackNumber,
    required this.duration,
    required this.explicit,
    required this.hasFile,
  });

  TextSpan file(bool monitored) {
    if (hasFile) {
      return TextSpan(
        text: 'Downloaded',
        style: TextStyle(
          color: ZagColours.currentAccent,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );
    } else {
      return TextSpan(
        text: 'Not Downloaded',
        style: TextStyle(
          color: ZagColours.red,
          fontWeight: ZagUI.FONT_WEIGHT_BOLD,
        ),
      );
    }
  }
}
