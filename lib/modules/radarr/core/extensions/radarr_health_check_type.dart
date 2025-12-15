import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrHealthCheckTypeExtension on RadarrHealthCheckType? {
  Color get zagColour {
    switch (this) {
      case RadarrHealthCheckType.NOTICE:
        return ZagColours.blue;
      case RadarrHealthCheckType.WARNING:
        return ZagColours.orange;
      case RadarrHealthCheckType.ERROR:
        return ZagColours.red;
      default:
        return Colors.white;
    }
  }
}
