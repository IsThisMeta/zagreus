import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/double/time.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrReleaseExtension on SonarrRelease {
  IconData get zagTrailingIcon {
    if (this.approved!) return Icons.download_rounded;
    return Icons.report_outlined;
  }

  Color get zagTrailingColor {
    if (this.approved!) return Colors.white;
    return ZagColours.red;
  }

  String get zagProtocol {
    if (this.protocol != null) {
      return this.protocol == SonarrProtocol.TORRENT
          ? '${this.protocol!.zagReadable()} (${this.seeders ?? 0}/${this.leechers ?? 0})'
          : this.protocol!.zagReadable();
    }
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagIndexer {
    if (this.indexer != null && this.indexer!.isNotEmpty) return this.indexer;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagAge {
    if (this.ageHours != null) return this.ageHours!.asTimeAgo();
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagQuality {
    if (this.quality != null && this.quality!.quality != null)
      return this.quality!.quality!.name;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagLanguage {
    if (this.language != null && this.language != null)
      return this.language!.name;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagSize {
    if (this.size != null) return this.size.asBytes();
    return ZagUI.TEXT_EMDASH;
  }

  String? zagPreferredWordScore({bool nullOnEmpty = false}) {
    if ((this.preferredWordScore ?? 0) != 0) {
      String _prefix = this.preferredWordScore! > 0 ? '+' : '';
      return '$_prefix${this.preferredWordScore}';
    }
    if (nullOnEmpty) return null;
    return ZagUI.TEXT_EMDASH;
  }

  String? zagCustomFormatScore({bool nullOnEmpty = false}) {
    if ((this.customFormatScore ?? 0) != 0) {
      String _prefix = this.customFormatScore! > 0 ? '+' : '';
      return '$_prefix${this.customFormatScore}';
    }
    if (nullOnEmpty) return null;
    return ZagUI.TEXT_EMDASH;
  }
}
