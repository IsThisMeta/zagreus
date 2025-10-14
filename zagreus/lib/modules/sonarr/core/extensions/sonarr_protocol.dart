import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';

extension ZagSonarrProtocolExtension on SonarrProtocol {
  Color zagProtocolColor({
    SonarrRelease? release,
  }) {
    if (this == SonarrProtocol.USENET) return ZagColours.currentAccent;
    if (release == null) return ZagColours.blue;

    int seeders = release.seeders ?? 0;
    if (seeders > 10) return ZagColours.blue;
    if (seeders > 0) return ZagColours.orange;
    return ZagColours.red;
  }

  String zagReadable() {
    switch (this) {
      case SonarrProtocol.USENET:
        return 'sonarr.Usenet'.tr();
      case SonarrProtocol.TORRENT:
        return 'sonarr.Torrent'.tr();
    }
  }
}
