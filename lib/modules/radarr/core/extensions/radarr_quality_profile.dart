import 'package:zagreus/core.dart';
import 'package:zagreus/modules/radarr.dart';

extension RadarrQualityProfileExtension on RadarrQualityProfile {
  String? get zagName {
    if (this.name != null && this.name!.isNotEmpty) return this.name;
    return ZagUI.TEXT_EMDASH;
  }
}
