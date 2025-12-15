import 'package:zagreus/core.dart';
import 'package:zagreus/extensions/int/bytes.dart';
import 'package:zagreus/modules/sonarr.dart';

extension SonarrEpisodeFileMediaInfoExtension on SonarrEpisodeFileMediaInfo {
  String get zagVideoBitDepth {
    if (videoBitDepth != null) return videoBitDepth.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String get zagVideoBitrate {
    if (videoBitrate != null) return '${videoBitrate.asBits()}/s';
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagVideoCodec {
    if (videoCodec != null && videoCodec!.isNotEmpty) return videoCodec;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagVideoFps {
    if (videoFps != null) return videoFps.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagVideoResolution {
    if (resolution != null && resolution!.isNotEmpty) return resolution;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagVideoScanType {
    if (scanType != null && scanType!.isNotEmpty) return scanType;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagAudioBitrate {
    if (audioBitrate != null) return '${audioBitrate.asBits()}/s';
    return ZagUI.TEXT_EMDASH;
  }

  String get zagAudioChannels {
    if (audioChannels != null) return audioChannels.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagAudioCodec {
    if (audioCodec != null && audioCodec!.isNotEmpty) return audioCodec;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagAudioLanguages {
    if (audioLanguages != null && audioLanguages!.isNotEmpty)
      return audioLanguages;
    return ZagUI.TEXT_EMDASH;
  }

  String get zagAudioStreamCount {
    if (audioStreamCount != null) return audioStreamCount.toString();
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagRunTime {
    if (runTime != null && runTime!.isNotEmpty) return runTime;
    return ZagUI.TEXT_EMDASH;
  }

  String? get zagSubtitles {
    if (subtitles != null && subtitles!.isNotEmpty) return subtitles;
    return ZagUI.TEXT_EMDASH;
  }
}
