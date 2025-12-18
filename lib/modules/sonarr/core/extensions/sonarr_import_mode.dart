import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrImportMode on SonarrImportMode {
  String get zagReadable {
    switch (this) {
      case SonarrImportMode.COPY:
        return 'sonarr.CopyFull'.tr();
      case SonarrImportMode.MOVE:
        return 'sonarr.MoveFull'.tr();
    }
  }

  IconData get zagIcon {
    switch (this) {
      case SonarrImportMode.COPY:
        return Icons.copy_rounded;
      case SonarrImportMode.MOVE:
        return Icons.drive_file_move_outline;
    }
  }
}
