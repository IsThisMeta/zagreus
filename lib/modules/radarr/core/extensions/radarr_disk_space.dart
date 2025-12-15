import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/radarr.dart';

extension ZagRadarrDiskSpaceExtension on RadarrDiskSpace {
  String? get zagPath {
    if (this.path != null && this.path!.isNotEmpty) return this.path;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagSpace {
    String numerator = this.freeSpace.asBytes();
    String denumerator = this.totalSpace.asBytes();
    return '$numerator / $denumerator\n';
  }

  int get zagPercentage {
    int? _percentNumerator = this.freeSpace;
    int? _percentDenominator = this.totalSpace;
    if (_percentNumerator != null &&
        _percentDenominator != null &&
        _percentDenominator != 0) {
      int _val = ((_percentNumerator / _percentDenominator) * 100).round();
      return (_val - 100).abs();
    }
    return 0;
  }

  String get zagPercentageString => '$zagPercentage%';

  Color get zagColor {
    int percentage = this.zagPercentage;
    if (percentage >= 90) return ZagColours.red;
    if (percentage >= 80) return ZagColours.orange;
    return ZagColours.currentAccent;
  }
}
